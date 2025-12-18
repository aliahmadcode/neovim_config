return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "stevearc/conform.nvim",
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    "hrsh7th/nvim-cmp",
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
    "rafamadriz/friendly-snippets",
    "j-hui/fidget.nvim",
    "windwp/nvim-autopairs",
    "windwp/nvim-ts-autotag",
  },

  config = function()
    require("conform").setup({
      formatters_by_ft = {
      }
    })
    local cmp = require('cmp')
    local cmp_lsp = require("cmp_nvim_lsp")
    local capabilities = vim.tbl_deep_extend(
      "force",
      {},
      vim.lsp.protocol.make_client_capabilities(),
      cmp_lsp.default_capabilities())

    require("fidget").setup({})
    require("mason").setup()
    require("mason-lspconfig").setup({
      ensure_installed = {
        "lua_ls",
        "rust_analyzer",
        "gopls",
        "jdtls",
        "clangd",
        "asm_lsp",
        "html",
        "cssls",
        "tailwindcss",
        "ts_ls",
      },
      handlers = {
        function(server_name) -- default handler (optional)
          require("lspconfig")[server_name].setup {
            capabilities = capabilities
          }
        end,

        ["ts_ls"] = function()
          require("lspconfig").ts_ls.setup({
            capabilities = capabilities,
            filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact" },
            init_options = {
              jsx = {
                autoClosingTags = true,
              },
              tsx = {
                autoClosingTags = true,
              },
            },
          })
        end,

        zls = function()
          local lspconfig = require("lspconfig")
          lspconfig.zls.setup({
            root_dir = lspconfig.util.root_pattern(".git", "build.zig", "zls.json"),
            settings = {
              zls = {
                enable_inlay_hints = true,
                enable_snippets = true,
                warn_style = true,
              },
            },
          })
          vim.g.zig_fmt_parse_errors = 0
          vim.g.zig_fmt_autosave = 0
        end,
        ["lua_ls"] = function()
          local lspconfig = require("lspconfig")
          lspconfig.lua_ls.setup {
            capabilities = capabilities,
            settings = {
              Lua = {
                runtime = { version = "LuaJIT" },
                diagnostics = {
                  globals = { "bit", "vim", "it", "describe", "before_each", "after_each", "love" },
                },
                workspace = {
                  checkThirdParty = false,
                  telemetry = { enable = false }, }
              },
            }
          }
        end,
        -- java configuration
        jdtls = function()
          local lspconfig = require("lspconfig")
          lspconfig.jdtls.setup {
            capabilities = capabilities,
            settings = {
              java = {
                diagnostics = {
                  enable = true,
                  severity = "warning", },
              },
            },
          }
        end,
        -- C/C++ configuration
        clangd = function()
          local lspconfig = require("lspconfig")
          lspconfig.clangd.setup {
            capabilities = capabilities,
          }
        end,
        asm_lsp = function()
          local lspconfig = require("lspconfig")
          lspconfig.asm_lsp.setup({
            capabilities = capabilities,
            filetypes = { "asm", "s", "S" },
            root_dir = function(fname)
              return lspconfig.util.find_git_ancestor(fname) or
                  lspconfig.util.path.dirname(fname)
            end,
            cmd = { vim.fn.expand("~/.local/share/nvim/mason/bin/asm-lsp") }
          })
        end,
        html = function()
          local lspconfig = require("lspconfig")
          lspconfig.html.setup {
            capabilities = capabilities,
          }
        end,
        cssls = function()
          local lspconfig = require("lspconfig")
          lspconfig.cssls.setup {
            capabilities = capabilities,
          }
        end,
        tailwindcss = function()
          local lspconfig = require("lspconfig")
          lspconfig.tailwindcss.setup {
            capabilities = capabilities,
            filetypes = {
              "html", "css", "scss", "javascript", "javascriptreact",
              "typescript", "typescriptreact", "svelte", "vue"
            },
            init_options = {
              userLanguages = {
                typescript = "javascript",
                typescriptreact = "javascript",
              },
            },
            settings = {
              tailwindCSS = {
                includeLanguages = {
                  typescript = "javascript",
                  typescriptreact = "javascript",
                },
                experimental = {
                  classRegex = {
                    "className\\s*=\\s*\"([^\"]*)\"",
                    "className\\s*=\\s*'([^']*)'",
                    "class\\s*=\\s*\"([^\"]*)\"",
                    "class\\s*=\\s*'([^']*)'",
                    "clsx\\(([^)]*)\\)",
                    "cn\\(([^)]*)\\)",
                    "cva\\(([^)]*)\\)",
                    "tw`([^`]*)`",
                    "className\\s*=\\s*`([^`]*)`",
                  },
                },
              },
            },
          }
        end,
      }
    })

    -- Modified nvim-autopairs setup with TSX/JSX support
    local npairs = require("nvim-autopairs")
    npairs.setup({
      check_ts = true, -- Enable treesitter
      ts_config = {
        javascript = { 'template_string' },
        javascriptreact = { 'template_string', 'jsx_element' },
        typescript = { 'template_string' },
        typescriptreact = { 'template_string', 'jsx_element' },
      },
      enable_check_bracket_line = true,
      fast_wrap = {
        map = '<M-e>',
        chars = { '{', '[', '(', '"', "'" },
        pattern = [=[[%'%"%>%]%)%}%,]]=],
        end_key = '$',
        keys = 'qwertyuiopzxcvbnmasdfghjkl',
        check_comma = true,
        highlight = 'Search',
        highlight_grey = 'Comment'
      },
    })

    local cmp_select = { behavior = cmp.SelectBehavior.Select }
    local luasnip = require 'luasnip'
    require('luasnip.loaders.from_vscode').lazy_load()

    cmp.setup({
      snippet = {
        expand = function(args)
          require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
        ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
        ['<C-y>'] = cmp.mapping.confirm({ select = true }),
        ["<C-Space>"] = cmp.mapping.complete(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
        ['<Tab>'] = cmp.mapping(function(fallback)
          if luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          elseif cmp.visible() then
            cmp.select_next_item()
          else
            fallback()
          end
        end, { 'i', 's' }), -- Tab to jump to next argument
        ['<S-Tab>'] = cmp.mapping(function(fallback)
          if luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { 'i', 's' }), -- Shift+Tab to jump to previous argument
      }),
      sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'codeium' },
        { name = 'luasnip' }, -- For luasnip users.
      }, {
        { name = 'buffer' },
      })
    })
    require('nvim-ts-autotag').setup({
      opts = {
        -- Defaults
        enable_close = true,          -- Auto close tags
        enable_rename = true,         -- Auto rename pairs of tags
        enable_close_on_slash = false -- Auto close on trailing </
      },
      -- Also override individual filetype configs, these take priority.
      -- Empty by default, useful if one of the "opts" global settings
      -- doesn't work well in a specific filetype
      per_filetype = {
        ["html"] = {
          enable_close = false
        }
      }
    })
    local cmp_autopairs = require("nvim-autopairs.completion.cmp")
    cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

    -- nvim-autopairs setup
    require("nvim-autopairs").setup()

    vim.diagnostic.config({
      update_in_insert = false,
      signs = true,
      virtual_text = false,
      underline = {
        severity = { min = vim.diagnostic.severity.WARN },
      },
    })

    vim.api.nvim_create_autocmd("CursorHold", {
      callback = function()
        vim.diagnostic.open_float(nil, {
          focusable = false,
          border = "none",
          source = "always",
          scope = "line",
          style = "minimal",
          header = "",
          prefix = "",
          close_events = {
            "CursorMoved",
            "CursorMovedI",
            "InsertEnter",
            "BufLeave",
            "WinLeave",
          },
        })
      end,
    })
  end
}
