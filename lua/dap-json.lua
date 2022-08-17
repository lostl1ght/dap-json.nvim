local p, dap = pcall(require, 'dap')
if not p then
    vim.api.nvim_notify("Install 'nvim-dap' (https://github.com/mfussenegger/nvim-dap)", vim.log.levels.ERROR, {})
    return
end

local M = {}

local read_file = function(file)
    local f = assert(io.open(file, 'rb'))
    local content = f:read '*all'
    f:close()
    return content
end

local collect_names = function(configs)
    local t = {}
    for _, v in ipairs(configs) do
        table.insert(t, v.name)
    end
    return t
end

local config = {}

M.run = function(file)
    local f = file or config.file
    local c = vim.json.decode(read_file(f))
    local n = collect_names(c)
    vim.ui.select(n, {}, function(_, idx)
        if idx ~= nil then
            dap.run(c[idx])
        end
    end)
end

local default_config = {
    file = '.nvim/debug.json',
    create_command = true,
}

M.setup = function(values)
    setmetatable(config, { __index = vim.tbl_extend('force', default_config, values) })
    if config.create_command then
        vim.api.nvim_create_user_command('DapRun', function(val)
            local file = string.len(val.args) > 0 and val.args or nil
            M.run(file)
        end, { nargs = '?' })
    end
end

return M
