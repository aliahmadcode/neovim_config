require("ali.set")
require("ali.remap")
require("ali.lazy_init")

--[[
-- Buffer and File Events:
    "BufEnter": Triggered when entering a buffer.
    "BufLeave": Triggered when leaving a buffer.
    "BufWritePre": Before writing a buffer to a file.
    "BufWritePost": After writing a buffer to a file.
    "BufReadPre": Before reading a buffer.
    "BufReadPost": After reading a buffer.
-- Window Events:
    "WinEnter": Triggered when entering a window.
    "WinLeave": Triggered when leaving a window.
-- Tab Events:
    "TabEnter": Triggered when entering a tab page.
    "TabLeave": Triggered when leaving a tab page.
-- Cursor Events:
    "CursorMoved": Triggered when the cursor moves.
    "CursorMovedI": Triggered when the cursor moves in Insert mode.
-- File Type and Syntax Events:
    "FileType": Triggered when a file's type is detected.
    "Syntax": Triggered when setting syntax.
-- Editor Lifecycle Events:
    "VimEnter": When Neovim starts.
    "VimLeave": When Neovim is closing.
-- Colorscheme Events:
    "ColorScheme": After a colorscheme is applied.
    "ColorSchemePre": Before a colorscheme is applied.
--
 ]]



vim.cmd([[
  highlight CodeiumSuggestion guifg=#888888
]])


local augroup = vim.api.nvim_create_augroup
local AliGroup = augroup('Ali', {})

local autocmd = vim.api.nvim_create_autocmd
local yank_group = augroup('HighlightYank', {})

function R(name)
  require("plenary.reload").reload_module(name)
end

vim.filetype.add({
  extension = {
    templ = 'templ',
  }
})

autocmd('TextYankPost', {
  group = yank_group,
  pattern = '*',
  callback = function()
    vim.highlight.on_yank({
      higroup = 'IncSearch',
      timeout = 40,
    })
  end,
})

autocmd({ "BufWritePre" }, {
  group = AliGroup,
  pattern = "*",
  command = [[%s/\s\+$//e]],
})


autocmd('BufEnter', {
  group = AliGroup,
  callback = function()
    if vim.bo.filetype == "zig" then
      vim.cmd.colorscheme("tokyonight-night")
    else
      vim.cmd.colorscheme("rose-pine-main")
    end
  end
})


autocmd('LspAttach', {
  group = AliGroup,
  callback = function(e)
    local opts = { buffer = e.buf }
    vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
    vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
    vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
    vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
    vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
    vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
    vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
    vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
    vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
    vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
  end
})

vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25


vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = "*.pdf",
  callback = function()
    local filepath = vim.fn.expand("%:p")
    vim.fn.jobstart({ "evince", filepath }, { detach = true })
    vim.cmd("bd")
  end
})

vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = { "*.jpg", "*.jpeg", "*.png", "*.gif", "*.bmp", "*.tiff" },
  callback = function()
    local filepath = vim.fn.expand("%:p") -- gives me the complete path of the current file
    vim.fn.jobstart({ "display", filepath }, { detach = true })
    vim.cmd("bd")
  end
})

vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
  pattern = "*",
  callback = function()
    vim.api.nvim_set_hl(0, "GitSignsAdd", { fg = "#004d00" })
    vim.api.nvim_set_hl(0, "GitSignsChange", { fg = "#4D3600" })
    vim.api.nvim_set_hl(0, "GitSignsDelete", { fg = "#F44747" })
  end,
})

-- Set the default statusline with time in 12-hour format and custom name "Ali"
vim.opt.statusline = ' © ali %f %y %m %= %l,%c %{strftime("%I:%M %p")}'
