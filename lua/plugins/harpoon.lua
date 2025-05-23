local M = {};

M.init = function()
    return {
        'ThePrimeagen/harpoon',
        branch = 'harpoon2',
        dependencies = { "nvim-lua/plenary.nvim" }
    }
end


M.setup = function()
    local harpoon = require("harpoon")

    harpoon:setup()

    -- basic telescope configuration
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
            attach_mappings = function(prompt_buffer_nr, map)
                map("n", "<C-x>", function()
                    local state = require('telescope.actions.state')
                    local selected = state.get_selected_entry()
                    local picker = state.get_current_picker(prompt_buffer_nr)

                    harpoon:list():remove_at(selected.index)
                    picker:refresh()
                end)

                return true
            end
        }):find()
    end

    vim.keymap.set("n", "<leader>a", function() harpoon:list():append() end, { desc = "Harpoon: Append to list" })
    vim.keymap.set("n", "<leader>h", function() toggle_telescope(harpoon:list()) end,
        { desc = "Harpoon: Toggle UI" })
end




return M;
