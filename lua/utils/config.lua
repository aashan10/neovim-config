-- Module to read, validate, and provide access to project-specific
-- configuration stored in environment variables (e.g., from .env.local).

local M = {}

-- Internal cache for the validated config to avoid redundant checks per session/project
local validated_config_cache = nil
-- Store the project root for which the cache is valid
local cached_project_root = nil

-- Helper function to get the project root (can be shared or duplicated)
-- Ensure this aligns with how you determine the project root elsewhere.
local function find_project_root(start_path)
    local markers = { "composer.json", ".git" } -- Or markers relevant to your projects
    local current_dir = vim.fn.fnamemodify(start_path, ':p')
    if vim.fn.isdirectory(current_dir) == 0 then
        current_dir = vim.fn.fnamemodify(current_dir, ':h')
    end
    while current_dir ~= "" and current_dir ~= "/" and vim.fn.isdirectory(current_dir) == 1 do
        for _, marker in ipairs(markers) do
            if vim.fn.filereadable(current_dir .. "/" .. marker) == 1 or vim.fn.isdirectory(current_dir .. "/" .. marker) == 1 then
                return current_dir
            end
        end
        local parent_dir = vim.fn.fnamemodify(current_dir, ':h')
        if parent_dir == current_dir then break end
        current_dir = parent_dir
    end
    return nil
end


-- Internal function to read environment variables and validate them.
-- Returns a structured config table or nil if validation fails.
local function _get_validated_config()
    local current_dir = vim.fn.getcwd()
    local project_root = find_project_root(current_dir)

    -- If no project root, config is not applicable
    if not project_root then
        if cached_project_root then -- Clear cache if we moved out of a configured project
            validated_config_cache = nil
            cached_project_root = nil
        end
        return nil
    end

    -- Check cache first
    if cached_project_root == project_root and validated_config_cache ~= nil then
        -- Return a deep copy to prevent accidental modification of the cache
        return vim.deepcopy(validated_config_cache)
    end

    -- Clear old cache if project root changed
    validated_config_cache = nil
    cached_project_root = project_root

    -- Read values from vim.env
    local config = {
        docker = {
            method = vim.env.NVIM_DOCKER_METHOD,
            console_executable = vim.env.NVIM_DOCKER_CONSOLE_EXECUTABLE or "php",
            console_path = vim.env.NVIM_DOCKER_CONSOLE_PATH or "bin/console",
            compose = {
                service = vim.env.NVIM_DOCKER_COMPOSE_SERVICE,
                user = vim.env.NVIM_DOCKER_COMPOSE_USER,
                workdir = vim.env.NVIM_DOCKER_COMPOSE_WORKDIR,
                -- file = vim.env.NVIM_DOCKER_COMPOSE_FILE,
            },
            exec = {
                container = vim.env.NVIM_DOCKER_EXEC_CONTAINER,
                user = vim.env.NVIM_DOCKER_EXEC_USER,
                workdir = vim.env.NVIM_DOCKER_EXEC_WORKDIR,
            }
        },
        -- Add other config sections here later if needed
        -- general = { project_type = vim.env.NVIM_PROJECT_TYPE }
    }

    -- Validation logic
    local is_valid = true
    local error_messages = {}

    if not config.docker.method then
        is_valid = false
        table.insert(error_messages, "NVIM_DOCKER_METHOD is not set.")
    elseif config.docker.method ~= "compose" and config.docker.method ~= "exec" then
        is_valid = false
        table.insert(error_messages, "NVIM_DOCKER_METHOD must be 'compose' or 'exec'.")
    else
        -- Method-specific validation
        if config.docker.method == "compose" and not config.docker.compose.service then
            is_valid = false
            table.insert(error_messages, "NVIM_DOCKER_COMPOSE_SERVICE is required for method 'compose'.")
        end
        if config.docker.method == "exec" and not config.docker.exec.container then
            is_valid = false
            table.insert(error_messages, "NVIM_DOCKER_EXEC_CONTAINER is required for method 'exec'.")
        end
    end

    if not config.docker.console_path then
        -- Maybe just warn and use default? Or consider it invalid? Let's warn for now.
        -- print("Warning: NVIM_DOCKER_CONSOLE_PATH not set, using default: " .. config.docker.console_path)
    end
    if not vim.env.NVIM_DOCKER_CONSOLE_EXECUTABLE then -- Check original env var name
        -- print("Warning: NVIM_DOCKER_CONSOLE_EXECUTABLE not set, using default: " .. config.docker.console_executable)
    end


    if not is_valid then
        vim.notify(
            "Invalid project configuration found in environment variables:\n" .. table.concat(error_messages, "\n"),
            vim.log.levels.ERROR)
        validated_config_cache = false -- Cache the failure state for this root
        return nil
    end

    -- Store the valid config in the cache
    validated_config_cache = config
    -- Return a deep copy
    return vim.deepcopy(validated_config_cache)
end

--- Returns the validated Docker configuration table.
--- Returns nil if the configuration is missing or invalid.
--- @return table|nil docker_config The Docker configuration section.
function M.get_docker_config()
    local config = _get_validated_config()
    return config and config.docker -- Return only the docker part, or nil
end

--- Builds the base Docker command prefix as a table.
--- Reads configuration using get_docker_config().
--- @param interactive boolean True if the command needs an interactive TTY (-it), false otherwise (-T for compose).
--- @return table|nil command_table The base command parts (e.g., {'docker', 'compose', ...}), or nil on failure.
function M.build_docker_command_table(interactive)
    local docker_config = M.get_docker_config() -- Use the public getter which uses the cache
    if not docker_config then return nil end

    local cmd_table = {}

    if docker_config.method == "compose" then
        table.insert(cmd_table, "docker")
        table.insert(cmd_table, "compose")
        -- [[ Add compose file args if needed, reading from docker_config.compose.file ]]
        table.insert(cmd_table, "exec")
        if not interactive then
            table.insert(cmd_table, "-T") -- Disable pseudo-TTY for non-interactive execs
        end
        if docker_config.compose.user then
            table.insert(cmd_table, "-u")
            table.insert(cmd_table, docker_config.compose.user)
        end
        if docker_config.compose.workdir then
            table.insert(cmd_table, "-w")
            table.insert(cmd_table, docker_config.compose.workdir)
        end
        table.insert(cmd_table, docker_config.compose.service) -- Already validated
    elseif docker_config.method == "exec" then
        table.insert(cmd_table, "docker")
        table.insert(cmd_table, "exec")
        if interactive then
            table.insert(cmd_table, "-it") -- Interactive TTY for user commands
        end
        if docker_config.exec.user then
            table.insert(cmd_table, "-u")
            table.insert(cmd_table, docker_config.exec.user)
        end
        if docker_config.exec.workdir then
            table.insert(cmd_table, "-w")
            table.insert(cmd_table, docker_config.exec.workdir)
        end
        table.insert(cmd_table, docker_config.exec.container) -- Already validated
    else
        -- Should not happen due to validation in _get_validated_config
        return nil
    end

    -- Add the actual executable (e.g., 'php')
    table.insert(cmd_table, docker_config.console_executable)

    return cmd_table
end

--- Clears the internal configuration cache.
-- Useful if environment variables might change without restarting Neovim,
-- or when leaving a project context.
function M.clear_cache()
    validated_config_cache = nil
    cached_project_root = nil
    print("utils.config cache cleared.")
end

-- Autocommand to clear cache on leaving Vim?
vim.api.nvim_create_autocmd("VimLeavePre", {
    pattern = "*",
    callback = M.clear_cache
});

return M
