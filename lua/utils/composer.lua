local M = {}

-- Checks if a directory contains composer.json or composer.lock
M.is_composer_project = function(path)
    -- Ensure path is not nil or empty
    if not path or path == "" then return false end

    local files = { path .. "/composer.json", path .. "/composer.lock" }

    for _, file in ipairs(files) do
        -- Use pcall for safer file opening
        local status, f = pcall(io.open, file, "r")
        if status and f then
            f:close()
            return true
        end
    end
    return false
end

-- Attempts to get dependencies from composer.lock, falling back to composer.json
M.get_deps = function(path)
    if not path or path == "" then return nil end

    local composer_lock_path = path .. "/composer.lock"
    local composer_json_path = path .. "/composer.json"

    local Dependencies = {
        packages = {},
    }

    Dependencies.package_exists = function(self, name) -- Added self for clarity
        return self.packages[name] ~= nil
    end

    Dependencies.get_package_version = function(self, name) -- Added self for clarity
        return self.packages[name]
    end

    -- Try composer.lock first
    local lock_status, c_lock = pcall(io.open, composer_lock_path, "r")
    if lock_status and c_lock then
        local read_status, lock_data = pcall(c_lock.read, c_lock, "*a")
        pcall(c_lock.close, c_lock) -- Ensure file is closed even on read error

        if read_status and lock_data then
            local decode_status, parsed_lock_data = pcall(vim.json.decode, lock_data, { luanil = { object = true } }) -- Use luanil for safety

            if decode_status and parsed_lock_data and parsed_lock_data.packages then
                for _, package in ipairs(parsed_lock_data.packages) do
                    if package and package.name and package.version then -- Add checks
                        Dependencies.packages[package.name] = package.version
                    end
                end
                return Dependencies -- Return successfully parsed lock data
            end
        end
    end

    -- Fallback to composer.json if lock failed or wasn't readable/parsable
    local json_status, c_json = pcall(io.open, composer_json_path, "r")
    if json_status and c_json then
        local read_status, json_data = pcall(c_json.read, c_json, "*a")
        pcall(c_json.close, c_json)

        if read_status and json_data then
            local decode_status, parsed_json_data = pcall(vim.json.decode, json_data, { luanil = { object = true } })

            if decode_status and parsed_json_data and parsed_json_data.require then
                for name, version in pairs(parsed_json_data.require) do
                    Dependencies.packages[name] = version
                end
                return Dependencies -- Return successfully parsed json data
            end
        end
    end

    -- Return nil only if both files failed completely
    -- If Dependencies has packages from json even if lock failed, it might still be useful,
    -- but current logic returns nil if lock fails initially before trying json fully.
    -- Let's adjust slightly: return Dependencies if *any* data was loaded, otherwise nil.
    if next(Dependencies.packages) ~= nil then
        return Dependencies
    else
        -- Print a warning if needed: print("Warning: Could not read deps from composer.lock or composer.json in " .. path)
        return nil
    end
end

return M
