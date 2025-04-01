return {
  'nvimtools/none-ls.nvim',
  config = function()
    local none_ls = require('none-ls')

    none_ls.setup({
      sources = {
        none_ls.builtins.formatting.prettier.with({
          extra_args = { "--tab-width", "2" }
        })
      },
    })
  end,
}
