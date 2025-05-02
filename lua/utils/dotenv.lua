--[[
dotenv.lua - Incremental Build

Step 1: Basic file parsing into a key-value table.
Step 2: Define the public API shell.
Step 3: Implement M.load to parse and cache raw values.
Step 4: Add simple ${VAR} expansion within M.load.
Step 5: Add recursive expansion for nested ${VAR}.
Step 6: Add support for default values (${VAR:-default}, ${VAR-default}).
Step 7: Implement remaining public API (get, set, unset).
Step 8: Integrate vim.env into context and ensure load/set update vim.env.
Step 9: Clean up INFO and DEBUG notifications.

(Reverted from $VAR support earlier - can be re-added if needed)
Still no error operators (?).
--]]

local M = {}

-- Internal state
local H = {
    loaded_files = {}, -- Tracks paths of files loaded by this module { path = true }
    cache = {},        -- Stores key-value pairs loaded *by this module* { key = value }
}

-- Configuration
local MAX_EXPANSION_DEPTH = 10 -- Maximum depth for recursive expansion

-- =============================================================================
-- Internal Helper Functions
-- =============================================================================

--- Reads and parses a .env file into a simple key-value table.
-- Ignores comments, empty lines, 'export' prefix.
-- Removes simple surrounding quotes from values.
-- Does NOT perform variable expansion itself.
-- @param path (string) Path to the .env file.
-- @return (table|nil) A table containing raw key-value pairs, or nil on file read error.
local function parse_file(path)
    local abs_path = vim.fn.fnamemodify(path, ":p")

    -- Check readability
    if vim.fn.filereadable(abs_path) ~= 1 then
        vim.notify("dotenv.lua: File not found or not readable: " .. abs_path, vim.log.levels.WARN)
        return nil
    end

    -- Read file content
    local lines = vim.fn.readfile(abs_path)
    if not lines then
        vim.notify("dotenv.lua: Error reading file: " .. abs_path, vim.log.levels.ERROR)
        return nil
    end

    local parsed_env = {} -- Stores raw key=value pairs from this file
    local parse_warnings = false

    -- Parse lines into raw key-value pairs
    for i, line in ipairs(lines) do
        local trimmed_line = vim.fn.trim(line)

        -- Skip empty lines and comments
        if trimmed_line == "" or trimmed_line:sub(1, 1) == "#" then
            goto continue -- Skip to next line
        end

        -- Remove optional 'export' prefix
        local key_value_part = trimmed_line:gsub("^%s*export%s+", "")

        -- Split on the first '=' sign
        local key, raw_value = key_value_part:match("^([^=]+)=(.*)$")

        if not key then
            vim.notify(
                "dotenv.lua: Invalid line format (no '=' found) in " .. abs_path .. ":" .. i .. ": " .. line,
                vim.log.levels.WARN
            )
            parse_warnings = true
            goto continue -- Skip malformed line
        end

        -- Clean and validate key
        key = vim.fn.trim(key)
        if key == "" or not key:match("^[a-zA-Z_][a-zA-Z0-9_]*$") then
            vim.notify("dotenv.lua: Invalid key format in " .. abs_path .. ":" .. i .. ": '" .. key .. "'",
                vim.log.levels.WARN)
            parse_warnings = true
            goto continue
        end

        -- Clean value (trim whitespace, remove simple surrounding quotes)
        local value = vim.fn.trim(raw_value)
        local quote_char = value:sub(1, 1)
        if (quote_char == '"' or quote_char == "'") and value:sub(-1) == quote_char then
            value = value:sub(2, -2)
        end

        -- Store raw value
        parsed_env[key] = value

        ::continue:: -- Lua goto label for loop skipping
    end

    if parse_warnings then
        vim.notify("dotenv.lua: Parsing finished with warnings for: " .. abs_path, vim.log.levels.WARN)
    end

    return parsed_env
end

--- Performs recursive expansion of ${VAR} variables, including default values.
-- Handles ${VAR}, ${VAR:-default}, ${VAR-default}.
-- Looks up variables in the provided context table, falling back to vim.env.
-- Stops at MAX_EXPANSION_DEPTH.
-- @param value (string) The string value to expand.
-- @param depth (number) The current recursion depth.
-- @param context (table) The primary table to use for variable lookups (e.g., parsed_env or H.cache).
-- @return (string) The expanded string.
local function expand_value(value, depth, context)
    -- Base cases: max depth reached or not a string
    if depth > MAX_EXPANSION_DEPTH then
        vim.notify(
            "dotenv.lua: Max expansion depth (" .. MAX_EXPANSION_DEPTH .. ") reached for value: " .. tostring(value),
            vim.log.levels.WARN)
        return value -- Return potentially partially expanded value
    end
    if type(value) ~= "string" then
        return value -- Return non-strings as-is
    end

    -- Pattern to find ${VARNAME:-default} or ${VARNAME-default} or ${VARNAME}
    -- Captures: 1: var_name, 2: operator (':-' or '-'), 3: default_value
    local pattern = "%${([a-zA-Z_][a-zA-Z0-9_]*)(:?-?)([^}]*)}"

    -- Use gsub for replacement.
    local expanded_value, _ = value:gsub(pattern, function(var_name, operator, default_value)
        local var_current_value = context[var_name] -- Look up in the primary context first
        local is_set = var_current_value ~= nil

        -- Fallback to vim.env if not found in primary context
        if not is_set then
            var_current_value = vim.env[var_name]
            is_set = var_current_value ~= nil
        end

        local replacement_value                                                                   -- Value to return

        if operator == ":-" then                                                                  -- Use default if unset OR empty
            if not is_set or var_current_value == "" then
                replacement_value = expand_value(default_value or "", depth + 1, context)         -- Expand default
            else
                replacement_value = expand_value(tostring(var_current_value), depth + 1, context) -- Expand found value
            end
        elseif operator == "-" then                                                               -- Use default only if unset
            if not is_set then
                replacement_value = expand_value(default_value or "", depth + 1, context)         -- Expand default
            else
                replacement_value = expand_value(tostring(var_current_value), depth + 1, context) -- Expand found value
            end
        else                                                                                      -- Simple expansion (no operator or default captured)
            if is_set then
                replacement_value = expand_value(tostring(var_current_value), depth + 1, context) -- Expand found value
            else
                replacement_value =
                "" -- Variable not found in context or vim.env, replace with empty string
            end
        end
        return replacement_value
    end)

    return expanded_value
end


-- =============================================================================
-- Public API Functions
-- =============================================================================

--- Loads, parses, and performs recursive expansion (incl. defaults) on a .env file.
-- Stores expanded values in the internal cache and sets vim.env.
-- Does NOT handle $VAR syntax or error operators (?).
-- @param path (string) Absolute or relative path to the .env file.
-- @return (boolean) true if loading and parsing succeeded without errors, false otherwise.
M.load = function(path)
    -- Get absolute path early for consistency
    local abs_path = vim.fn.fnamemodify(path, ":p")
    -- vim.notify("dotenv.lua: Loading environment from: " .. abs_path, vim.log.levels.INFO) -- Removed INFO

    -- Call the parsing function to get raw values
    local parsed_env = parse_file(abs_path)

    -- Check if parsing was successful
    if not parsed_env then
        -- Error handled in parse_file
        return false -- Indicate failure
    end

    -- Pass 2: Expand variables and store in cache and vim.env
    -- vim.notify("dotenv.lua: Performing recursive expansion with defaults...", vim.log.levels.INFO) -- Removed INFO

    -- Build the primary context for this load operation (parsed values override vim.env for lookups)
    local expansion_context = vim.deepcopy(vim.env)
    for k, v in pairs(parsed_env) do
        expansion_context[k] = v -- Parsed values take precedence
    end

    local final_env = {} -- Table to hold expanded values before setting globally

    -- Need to handle potential errors during expansion
    local success = true
    for key, raw_value in pairs(parsed_env) do
        -- Start expansion at depth 0, using the combined context
        local expand_ok, expanded = pcall(expand_value, raw_value, 0, expansion_context)
        if expand_ok then
            final_env[key] = expanded
        else
            -- Handle expansion error (e.g., max depth exceeded)
            vim.notify("dotenv.lua: Error expanding key '" .. key .. "': " .. tostring(expanded), vim.log.levels.ERROR)
            final_env[key] = raw_value -- Store raw value on error
            success = false
        end
    end

    -- Store the *expanded* values into the internal cache AND vim.env
    -- This overwrites any previous values for the same keys
    for key, value in pairs(final_env) do
        H.cache[key] = value
        vim.env[key] = value -- Set Neovim's environment
    end

    -- Mark the file as loaded
    H.loaded_files[abs_path] = true

    -- vim.notify("dotenv.lua: M.load completed for " .. abs_path .. ". Cache and vim.env updated.", vim.log.levels.INFO) -- Removed INFO
    return success -- Return overall success based on expansion too
end

--- Gets an environment variable's value.
-- Checks internal cache first, then falls back to vim.env.
-- Does NOT perform expansion on retrieval.
-- @param key (string) The environment variable name.
-- @return (string|nil) The value, or nil if not found in cache or vim.env.
M.get = function(key)
    if H.cache[key] ~= nil then
        return H.cache[key]
    else
        -- Fallback to checking vim.env directly
        return vim.env[key]
    end
end

--- Sets an environment variable after expanding it.
-- Updates both the internal cache and vim.env.
-- @param key (string) The variable name.
-- @param value (any) The value to set (will be expanded if it's a string).
M.set = function(key, value)
    if not key or type(key) ~= "string" or key == "" then
        vim.notify("dotenv.lua: Invalid key provided to set_env.", vim.log.levels.ERROR)
        return
    end

    local final_value
    if type(value) == "string" then
        -- Build context for expansion: Current vim.env + H.cache (cache takes precedence)
        local current_context = vim.deepcopy(vim.env)
        for k_cache, v_cache in pairs(H.cache) do
            current_context[k_cache] = v_cache
        end

        -- Expand the provided value using the current context
        local expand_ok, expanded = pcall(expand_value, value, 0, current_context)
        if expand_ok then
            final_value = expanded
        else
            vim.notify("dotenv.lua: Error expanding value for set_env key '" .. key .. "': " .. tostring(expanded),
                vim.log.levels.ERROR)
            final_value = value -- Use original value on expansion error
        end
    else
        -- Not a string, use the value directly
        final_value = value
    end

    -- Set the final (potentially expanded) value in cache and vim.env
    -- vim.notify("dotenv.lua: Setting ["..key.."] = '"..tostring(final_value).."'", vim.log.levels.DEBUG) -- Removed DEBUG
    H.cache[key] = final_value
    vim.env[key] = final_value
end

--- Unsets an environment variable from both the internal cache and vim.env.
-- @param key (string) The variable name.
M.unset = function(key)
    if not key or type(key) ~= "string" or key == "" then
        vim.notify("dotenv.lua: Invalid key provided to unset_env.", vim.log.levels.ERROR)
        return
    end

    if H.cache[key] ~= nil or vim.env[key] ~= nil then
        -- vim.notify("dotenv.lua: Unsetting ["..key.."]", vim.log.levels.DEBUG) -- Removed DEBUG
        H.cache[key] = nil
        vim.env[key] = nil -- Unset from Neovim's environment
    else
        -- vim.notify("dotenv.lua: Key not found for unset_env: " .. key, vim.log.levels.INFO) -- Removed INFO
    end
end

--- Resets the internal state (cache and loaded files list).
-- Does NOT modify vim.env.
M.reset = function()
    H.cache = {}
    H.loaded_files = {}
    -- vim.notify("dotenv.lua: M.reset_env() called. Internal state reset.", vim.log.levels.INFO) -- Removed INFO
end

--- Returns a deep copy of the internal environment cache.
-- @return (table) A copy of the variables loaded/set by this module.
M.get_all = function()
    return vim.deepcopy(H.cache) -- Return copy of current cache
end

--- Returns a deep copy of the list of files loaded by M.load() since the last reset.
-- @return (table) A table where keys are absolute file paths and values are true.
M.get_read_files = function()
    return vim.deepcopy(H.loaded_files) -- Return copy of loaded files list
end

-- Return the public API
return M
