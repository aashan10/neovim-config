local colors = {
    bg      = '#1c1c1c',
    fg      = '#cecece',
    variables = '#e06c75',
    keywords = '#c678dd',
    numbers = '#d19a66',
    constants = '#e5c07b',
    functions = '#61afef',
    string  = '#98c379',
    operators = '#56b6c2',
    comments = '#7f848e',
    gray = '#2b2b2b'
}

local function withBg(object)
    object = object or {}
    object.bg = colors.bg
    return object
end

local function withFg(object)
    object = object or {}
    object.fg = colors.fg
    return object
end

local function bold(object)
    object = object or {}
    object.cterm = {
        bold = true
    }
    return object
end

local mappings = {
    {
        groups = { 'Normal', 'Syntax', 'Special', 'Title', 'BufferVisible', 'BufferOffset' },
        colors = withFg(),
    },
    {
        groups = { 'SignColumn', 'WinSeparator', 'NvimTreeSignColumn' },
        colors = withBg(),
    },
    {
        groups = { 'BufferTabpageFill', 'BufferInactive', 'BufferInactiveSign', 'BufferInactiveSignRight', 'NvimTreeHighlights' },
        colors = { bg = colors.gray, fg = colors.comments },
    },
    {
        groups = { 'Comment', 'LineNr', 'CursorLineNr', 'MiniIndentscopeSymbol' },
        colors = { fg = colors.comments },
    },
    {
        groups = { 'Identifier' },
        colors = { fg = colors.variables },
    },
    {
        groups = { 'Keyword', 'DiffAdd', 'Statement', 'PreProc' },
        colors = { fg = colors.keywords },
    },
    {
        groups = { 'Number' },
        colors = { fg = colors.numbers },
    },
    {
        groups = { 'Constant', '@variable.lua', '@lsp.type.variable.lua', '@attribute.php', 'Type' },
        colors = { fg = colors.constants },
    },
    {
        groups = { 'Function', 'NvimTreeFolderName', 'NvimTreeOpenedFolderName', 'NvimTreeFolderIcon' },
        colors = bold({ fg = colors.functions }),
    },
    {
        groups = { 'String' },
        colors = { fg = colors.string },
    },
    {
        groups = { 'Operator' },
        colors = { fg = colors.operators },
    },
    {
        groups = { 'GitSignsAdd', 'GitSignsAddLn', 'GitSignsAddInline' },
        colors = { fg = colors.string }
    },
    {
        groups = { 'GitSignsChange', 'GitSignsChangeLn', 'GitSignsChangeInline' },
        colors = { fg = colors.variables }
    },
    {
        groups = { 'GitSignsDelete', 'GitSignsDeleteLn', 'GitSignsDeleteInline' },
        colors = { fg = colors.variables }
    },
}



-- link highlight groups 
vim.cmd("highlight link @type.php Type")
vim.cmd("highlight link @type.builtin.php Type")
vim.cmd("highlight link NvimTreeOpenedFolderName Function")

local M = {};

M.colors = colors;

function M.setup()
    vim.cmd("colorscheme habamax")
    for _, mapping in ipairs(mappings) do
        for _, group in ipairs(mapping.groups) do
            vim.api.nvim_set_hl(0, group, mapping.colors)
        end
    end
end

M.setup();

return M;
