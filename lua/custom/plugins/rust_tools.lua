-- Main inspiration taken from this thread: https://www.reddit.com/r/neovim/comments/11clka0/adding_rust_to_lazyvim/

-- local rt = require("rust-tools")

-- rt.setup({
--   server = {
--     on_attach = function(_, bufnr)
--       -- Hover actions
--       vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
--       -- Code action groups
--       vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
--     end,
--   },
-- })

-- return {
--   { -- extend auto completion
--     'hrsh7th/nvim-cmp',
--     dependencies = {
--       {
--         'Saecki/crates.nvim',
--         event = { 'BufRead Cargo.toml' },
--         config = true,
--       },
--     },
--     ---@param opts cmp.ConfigSchema
--     opts = function(_, opts)
--       local cmp = require 'cmp'
--       opts.sources = cmp.config.sources(vim.list_extend(opts.sources, {
--         { name = 'crates', priority = 750 },
--       }))
--     end,
--   },
--
--   -- add rust to treesitter
--   {
--     'nvim-treesitter/nvim-treesitter',
--     opts = function(_, opts)
--       if type(opts.ensure_installed) == 'table' then
--         vim.list_extend(opts.ensure_installed, { 'rust', 'toml' })
--       end
--     end,
--   },
--
--   -- correctly setup mason lsp / dap extensions
--   {
--     'williamboman/mason.nvim',
--     opts = function(_, opts)
--       if type(opts.ensure_installed) == 'table' then
--         vim.list_extend(opts.ensure_installed, { 'codelldb', 'rust-analyzer', 'taplo' })
--       end
--     end,
--   },
--
--   -- correctly setup lspconfig for Rust 🚀
--   {
--     'neovim/nvim-lspconfig',
--     dependencies = { 'simrat39/rust-tools.nvim' },
--     opts = {
--       -- make sure mason installs the server
--       servers = {
--         rust_analyzer = {},
--       },
--       setup = {
--         rust_analyzer = function(_, opts)
--           require('lazyvim.util').on_attach(function(client, buffer)
--           -- stylua: ignore
--           if client.name == "rust_analyzer" then
--             vim.keymap.set("n", "K", "<cmd>RustHoverActions<cr>", { buffer = buffer, desc = "Hover Actions (Rust)" })
--             vim.keymap.set("n", "<leader>cR", "<cmd>RustCodeAction<cr>", { buffer = buffer, desc = "Code Action (Rust)" })
--             vim.keymap.set("n", "<leader>dr", "<cmd>RustDebuggables<cr>", { buffer = buffer, desc = "Run Debuggables (Rust)" })
--           end
--           end)
--           local mason_registry = require 'mason-registry'
--           -- rust tools configuration for debugging support
--           local codelldb = mason_registry.get_package 'codelldb'
--           local extension_path = codelldb:get_install_path() .. '/extension/'
--           local codelldb_path = extension_path .. 'adapter/codelldb'
--           local liblldb_path = vim.fn.has 'mac' == 1 and extension_path .. 'lldb/lib/liblldb.dylib' or extension_path .. 'lldb/lib/liblldb.so'
--           local rust_tools_opts = vim.tbl_deep_extend('force', opts, {
--             dap = {
--               adapter = require('rust-tools.dap').get_codelldb_adapter(codelldb_path, liblldb_path),
--             },
--             tools = {
--               on_initialized = function()
--                 vim.cmd [[
--               augroup RustLSP
--               autocmd CursorHold                      *.rs silent! lua vim.lsp.buf.document_highlight()
--               autocmd CursorMoved,InsertEnter         *.rs silent! lua vim.lsp.buf.clear_references()
--               autocmd BufEnter,CursorHold,InsertLeave *.rs silent! lua vim.lsp.codelens.refresh()
--               augroup END
--               ]]
--               end,
--             },
--             server = {
--               settings = {
--                 ['rust-analyzer'] = {
--                   cargo = {
--                     allFeatures = true,
--                     loadOutDirsFromCheck = true,
--                     runBuildScripts = true,
--                   },
--                   -- Add clippy lints for Rust.
--                   checkOnSave = {
--                     allFeatures = true,
--                     command = 'clippy',
--                     extraArgs = { '--no-deps' },
--                   },
--                   procMacro = {
--                     enable = true,
--                     ignored = {
--                       ['async-trait'] = { 'async_trait' },
--                       ['napi-derive'] = { 'napi' },
--                       ['async-recursion'] = { 'async_recursion' },
--                     },
--                   },
--                 },
--               },
--             },
--           })
--           require('rust-tools').setup(rust_tools_opts)
--           return true
--         end,
--         taplo = function(_, _)
--           local function show_documentation()
--             if vim.fn.expand '%:t' == 'Cargo.toml' and require('crates').popup_available() then
--               require('crates').show_popup()
--             else
--               vim.lsp.buf.hover()
--             end
--           end
--           require('lazyvim.util').on_attach(function(client, buffer)
--           -- stylua: ignore
--           if client.name == "taplo" then
--             vim.keymap.set("n", "K", show_documentation, { buffer = buffer, desc = "Show Crate Documentation" })
--           end
--           end)
--           return false -- make sure the base implementation calls taplo.setup
--         end,
--       },
--     },
--   },
-- }

return {
  {
    'simrat39/rust-tools.nvim',
    dependencies = {
      'neovim/nvim-lspconfig',
      'nvim-lua/plenary.nvim',
    },
    opts = {
      tools = { -- rust-tools options

        -- how to execute terminal commands
        -- options right now: termopen / quickfix
        -- executor = require("rust-tools/executors").termopen,

        -- callback to execute once rust-analyzer is done initializing the workspace
        -- The callback receives one parameter indicating the `health` of the server: "ok" | "warning" | "error"
        on_initialized = nil,

        -- automatically call RustReloadWorkspace when writing to a Cargo.toml file.
        reload_workspace_from_cargo_toml = true,

        -- These apply to the default RustSetInlayHints command
        inlay_hints = {
          -- automatically set inlay hints (type hints)
          -- default: true
          auto = true,

          -- Only show inlay hints for the current line
          only_current_line = false,

          -- whether to show parameter hints with the inlay hints or not
          -- default: true
          show_parameter_hints = true,

          -- prefix for parameter hints
          -- default: "<-"
          parameter_hints_prefix = '<- ',

          -- prefix for all the other hints (type, chaining)
          -- default: "=>"
          other_hints_prefix = '=> ',

          -- whether to align to the lenght of the longest line in the file
          max_len_align = false,

          -- padding from the left if max_len_align is true
          max_len_align_padding = 1,

          -- whether to align to the extreme right or not
          right_align = false,

          -- padding from the right if right_align is true
          right_align_padding = 7,

          -- The color of the hints
          highlight = 'Comment',
        },

        -- options same as lsp hover / vim.lsp.util.open_floating_preview()
        hover_actions = {

          -- the border that is used for the hover window
          -- see vim.api.nvim_open_win()
          border = {
            { '╭', 'FloatBorder' },
            { '─', 'FloatBorder' },
            { '╮', 'FloatBorder' },
            { '│', 'FloatBorder' },
            { '╯', 'FloatBorder' },
            { '─', 'FloatBorder' },
            { '╰', 'FloatBorder' },
            { '│', 'FloatBorder' },
          },

          -- whether the hover action window gets automatically focused
          -- default: false
          auto_focus = false,
        },

        -- all the opts to send to nvim-lspconfig
        -- these override the defaults set by rust-tools.nvim
        -- see https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#rust_analyzer
        server = {
          -- standalone file support
          -- setting it to false may improve startup time
          standalone = true,
          settings = {
            ['rust-analyzer'] = {
              imports = {
                granularity = {
                  group = 'module',
                },
                prefix = 'self',
              },
              cargo = {
                buildScripts = {
                  enable = true,
                },
              },
              procMacro = {
                enable = true,
              },
              checkOnSave = {
                command = 'clippy',
              },
            },
          },
        }, -- rust-analyer options

        -- debugging stuff
        -- dap = { },
      },
      config = function(_, opts)
        require('rust-tools').setup(opts)
      end,
    },
  },
}
