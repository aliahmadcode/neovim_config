return {
  "akinsho/toggleterm.nvim",
  version = "*",
  config = function()
    local toggleterm = require("toggleterm")
    toggleterm.setup({
      open_mapping = [[<C-\>]],
      insert_mappings = true,
      terminal_mappings = true,
    })
  end,
}
