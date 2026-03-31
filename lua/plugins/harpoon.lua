local M = {}

M.init = function()
    return {
        'ThePrimeagen/harpoon',
        branch = 'harpoon2',
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope.nvim"
        }
    }
end

M.setup = function()
    local harpoon = require('harpoon')
    harpoon:setup({})

    -- Telescope integration with delete functionality
    local conf = require("telescope.config").values
    local function toggle_telescope(harpoon_files)
        local file_paths = {}
        for _, item in ipairs(harpoon_files.items) do
            table.insert(file_paths, item.value)
        end

        require("telescope.pickers").new({}, {
            prompt_title = "Harpoon",
            finder = require("telescope.finders").new_table({
                results = file_paths,
            }),
            previewer = conf.file_previewer({}),
            sorter = conf.generic_sorter({}),
            attach_mappings = function(prompt_bufnr, map)
                map("i", "<C-x>", function()
                    local state = require("telescope.actions.state")
                    local selected_entry = state.get_selected_entry()
                    local current_picker = state.get_current_picker(prompt_bufnr)

                    -- Remove from harpoon list
                    harpoon:list():remove_at(selected_entry.index)

                    -- Refresh the picker
                    current_picker:refresh(require("telescope.finders").new_table({
                        results = vim.tbl_map(function(item) return item.value end, harpoon:list().items)
                    }))
                end)

                return true
            end,
        }):find()
    end

    -- Add file to harpoon
    vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end,
        { desc = "Harpoon: Add file" })

    -- Toggle Telescope UI
    vim.keymap.set("n", "<leader>h", function() toggle_telescope(harpoon:list()) end,
        { desc = "Harpoon: Open" })

    -- Quick navigation to slots 1-4
    vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end,
        { desc = "Harpoon: File 1" })
    vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end,
        { desc = "Harpoon: File 2" })
    vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end,
        { desc = "Harpoon: File 3" })
    vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end,
        { desc = "Harpoon: File 4" })
end

return M
