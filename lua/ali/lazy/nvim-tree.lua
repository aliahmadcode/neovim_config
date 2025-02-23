return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("nvim-tree").setup {
      view = { width = 30 },
      update_focused_file = { enable = true },
      actions = {
        open_file = { quit_on_open = false },
      },
      filters = {
        dotfiles = false,
      },
      git = {
        ignore = false,
      }
    }
    vim.keymap.set("n", "<A-e>", ":NvimTreeToggle<CR>", { noremap = true, silent = true })
  end
}
