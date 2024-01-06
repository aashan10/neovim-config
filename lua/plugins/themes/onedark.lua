local M = {};

M.name = 'OneDark';
M.colorscheme = 'onedark';

M.setup = function()
    require('onedark').setup({
        style = 'darker'
    })
end

M.on_load = function()
    return [[ let g:onedark_config = {
        \ 'style': 'darker',
    \}
    colorscheme onedark]]
end

M.init = function()
    return {
        'navarasu/onedark.nvim'
    }
end

return M;
