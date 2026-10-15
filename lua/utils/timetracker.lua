local M = {}

local data_dir = vim.fn.stdpath('data') .. '/timetracker'
local data_file = data_dir .. '/tasks.json'

local function ensure_dir()
    if vim.fn.isdirectory(data_dir) == 0 then
        vim.fn.mkdir(data_dir, 'p')
    end
end

local function pretty_json(val, indent)
    indent = indent or 0
    local pad = string.rep('  ', indent)
    local pad1 = string.rep('  ', indent + 1)
    if type(val) == 'table' then
        if vim.islist(val) then
            if #val == 0 then return '[]' end
            local items = {}
            for _, v in ipairs(val) do
                table.insert(items, pad1 .. pretty_json(v, indent + 1))
            end
            return '[\n' .. table.concat(items, ',\n') .. '\n' .. pad .. ']'
        else
            local keys = vim.tbl_keys(val)
            table.sort(keys)
            if #keys == 0 then return '{}' end
            local items = {}
            for _, k in ipairs(keys) do
                table.insert(items, pad1 .. vim.json.encode(k) .. ': ' .. pretty_json(val[k], indent + 1))
            end
            return '{\n' .. table.concat(items, ',\n') .. '\n' .. pad .. '}'
        end
    else
        return vim.json.encode(val)
    end
end

-- Migrate v1 (single entry per ticket) to v2 (entries array)
local function migrate_v1(store)
    for id, task in pairs(store.tasks) do
        if not task.entries then
            local entry = {
                start_time = task.start_time,
                end_time = task.end_time,
                duration_minutes = task.duration_minutes,
                rounded_minutes = task.rounded_minutes,
                status = task.status or 'closed',
                description = task.description or '',
            }
            store.tasks[id] = {
                ticket_id = task.ticket_id or id,
                hq_project = task.hq_project or '',
                entries = { entry },
            }
        end
    end
    store.version = 2
    return store
end

local function read_store()
    ensure_dir()
    if vim.fn.filereadable(data_file) == 0 then
        return { version = 2, tasks = {} }
    end
    local content = table.concat(vim.fn.readfile(data_file), '\n')
    local ok, decoded = pcall(vim.json.decode, content)
    if not ok or type(decoded) ~= 'table' then
        return { version = 2, tasks = {} }
    end
    decoded.tasks = decoded.tasks or {}
    if (decoded.version or 1) < 2 then
        decoded = migrate_v1(decoded)
    end
    return decoded
end

local function write_store(store)
    ensure_dir()
    local encoded = pretty_json(store)
    local tmp = data_file .. '.tmp.' .. vim.fn.getpid()
    vim.fn.writefile(vim.split(encoded, '\n'), tmp)
    vim.fn.rename(tmp, data_file)
end

function M.round_to_30(minutes)
    return math.floor((minutes + 15) / 30) * 30
end

-- Find the open entry for a ticket, if any
local function find_open_entry(task)
    if not task or not task.entries then return nil, nil end
    for i, entry in ipairs(task.entries) do
        if entry.status == 'open' then
            return entry, i
        end
    end
    return nil, nil
end

-- Compute ticket status: "open" if any entry is open, else "closed"
local function ticket_status(task)
    if not task or not task.entries or #task.entries == 0 then return 'closed' end
    for _, entry in ipairs(task.entries) do
        if entry.status == 'open' then return 'open' end
    end
    return 'closed'
end

-- Compute total duration across all closed entries
local function total_duration(task)
    local total = 0
    local total_rounded = 0
    for _, entry in ipairs(task.entries) do
        if entry.status == 'closed' and entry.duration_minutes then
            total = total + entry.duration_minutes
            total_rounded = total_rounded + (entry.rounded_minutes or 0)
        end
    end
    return total, total_rounded
end

-- Get the most recent entry's start_time
local function latest_start(task)
    local latest = 0
    for _, entry in ipairs(task.entries) do
        if entry.start_time and entry.start_time > latest then
            latest = entry.start_time
        end
    end
    return latest
end

function M.start(ticket_id, hq_project)
    local store = read_store()
    local task = store.tasks[ticket_id]
    if task then
        local open_entry = find_open_entry(task)
        if open_entry then
            return task, 'already running'
        end
        if hq_project then task.hq_project = hq_project end
    else
        task = {
            ticket_id = ticket_id,
            hq_project = hq_project or '',
            entries = {},
        }
        store.tasks[ticket_id] = task
    end
    table.insert(task.entries, {
        start_time = os.time(),
        end_time = vim.NIL,
        duration_minutes = vim.NIL,
        rounded_minutes = vim.NIL,
        status = 'open',
        description = '',
    })
    write_store(store)
    return task, nil
end

function M.stop(ticket_id)
    local store = read_store()
    local task = store.tasks[ticket_id]
    if not task then
        return nil, 'task not found'
    end
    local open_entry = find_open_entry(task)
    if not open_entry then
        return nil, 'no open entry'
    end
    local now = os.time()
    local duration = math.floor((now - open_entry.start_time) / 60)
    open_entry.end_time = now
    open_entry.duration_minutes = duration
    open_entry.rounded_minutes = M.round_to_30(duration)
    open_entry.status = 'closed'
    write_store(store)
    -- Return task-level info plus this entry's details for the notification
    return {
        ticket_id = task.ticket_id,
        hq_project = task.hq_project,
        start_time = open_entry.start_time,
        duration_minutes = open_entry.duration_minutes,
        rounded_minutes = open_entry.rounded_minutes,
    }, nil
end

function M.get(ticket_id)
    local store = read_store()
    return store.tasks[ticket_id]
end

function M.list(filter)
    local store = read_store()
    local result = {}
    for _, task in pairs(store.tasks) do
        local status = ticket_status(task)
        if not filter or status == filter then
            local dur, dur_rounded = total_duration(task)
            table.insert(result, {
                ticket_id = task.ticket_id,
                hq_project = task.hq_project,
                entries = task.entries,
                status = status,
                total_duration = dur,
                total_rounded = dur_rounded,
                latest_start = latest_start(task),
            })
        end
    end
    table.sort(result, function(a, b) return a.latest_start > b.latest_start end)
    return result
end

function M.set_description(ticket_id, desc)
    local store = read_store()
    local task = store.tasks[ticket_id]
    if not task then
        return nil, 'task not found'
    end
    -- Set description on the most recent entry
    local last = task.entries[#task.entries]
    if last then
        last.description = desc
    end
    write_store(store)
    return task, nil
end

local function format_time(ts)
    if not ts or ts == vim.NIL then return '' end
    return os.date('%Y-%m-%d %H:%M:%S', ts)
end

local function csv_escape(s)
    if not s or s == vim.NIL then return '' end
    s = tostring(s)
    if s:find('[,"\n]') then
        return '"' .. s:gsub('"', '""') .. '"'
    end
    return s
end

function M.archive()
    local store = read_store()
    local archived = {}
    local kept = {}
    for id, task in pairs(store.tasks) do
        local status = ticket_status(task)
        if status == 'closed' then
            archived[id] = task
        else
            kept[id] = task
        end
    end
    if vim.tbl_isempty(archived) then
        return nil, 'no closed tasks to archive'
    end
    local archive_file = data_dir .. '/archive-' .. os.date('%Y-%m-%d-%H%M%S') .. '.json'
    local archive_store = { version = 2, tasks = archived }
    local encoded = pretty_json(archive_store)
    vim.fn.writefile(vim.split(encoded, '\n'), archive_file)
    store.tasks = kept
    write_store(store)
    return archive_file, nil
end

function M.export_csv(filter)
    local store = read_store()
    local lines = { 'ticket_id,hq_project,entry,status,start_time,end_time,duration_minutes,rounded_minutes,description' }
    -- Collect all entries across all tasks
    local rows = {}
    for _, task in pairs(store.tasks) do
        for i, entry in ipairs(task.entries) do
            if not filter or entry.status == filter then
                table.insert(rows, {
                    ticket_id = task.ticket_id,
                    hq_project = task.hq_project,
                    entry_num = i,
                    entry = entry,
                })
            end
        end
    end
    table.sort(rows, function(a, b) return (a.entry.start_time or 0) > (b.entry.start_time or 0) end)
    for _, row in ipairs(rows) do
        local e = row.entry
        table.insert(lines, table.concat({
            csv_escape(row.ticket_id),
            csv_escape(row.hq_project),
            csv_escape(row.entry_num),
            csv_escape(e.status),
            csv_escape(format_time(e.start_time)),
            csv_escape(format_time(e.end_time)),
            csv_escape(e.duration_minutes),
            csv_escape(e.rounded_minutes),
            csv_escape(e.description),
        }, ','))
    end
    return table.concat(lines, '\n') .. '\n'
end

function M.export_csv_to_file(path, filter)
    local csv = M.export_csv(filter)
    local lines = vim.split(csv, '\n')
    vim.fn.writefile(lines, path)
    return path
end

return M
