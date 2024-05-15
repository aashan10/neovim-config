local M = {};

local active_colorscheme = 'aashan'; -- this theme is inside ROOT/colors/habamax-custom.vim


M.init = function()
    return nil;
end

M.setup = function()
    -- Apply custom colorscheme 
    vim.cmd('colorscheme ' .. active_colorscheme);
end



return M;
