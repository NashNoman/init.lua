return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    { "antosha417/nvim-lsp-file-operations", config = true },
    { "folke/neodev.nvim", opts = {} },
    { "folke/neoconf.nvim" },
    "williamboman/mason.nvim",
  },
  opts = {
    diagnostics = {
      update_in_insert = true,
    },
  },
  config = function()
    require("neoconf").setup({})

    -- used to enable autocompletion (assign to every lsp server config)
    local capabilities = vim.tbl_deep_extend(
      -- "error": raise an error
      -- "keep": use value from the leftmost map
      -- "force": use value from the rightmost map
      "force",
      {}, -- Empty capabilities
      vim.lsp.protocol.make_client_capabilities(), -- Minimal capabilities
      require("cmp_nvim_lsp").default_capabilities() -- Default capabilities
    )

    -- vim lsp api
    local lsp = vim.lsp
    lsp.handlers["textDocument/hover"] = lsp.with(vim.lsp.handlers.hover, {
      border = "rounded",
    })

    -- import lspconfig plugin
    local lspconfig = require("lspconfig")

    -- local configs = require("lspconfig.configs")
    --
    -- configs.blade = {
    --   default_config = {
    --     -- Path to the executable: laravel-dev-generators
    --     cmd = { "laravel-dev-generators", "lsp" },
    --
    --     filetypes = { "blade" },
    --     root_dir = function(fname)
    --       return lspconfig.util.find_git_ancestor(fname)
    --     end,
    --     settings = {},
    --   },
    -- }
    --
    -- lspconfig.blade.setup({
    --   -- Capabilities is specific to my setup.
    --   capabilities = capabilities,
    -- })

    -- import mason_lspconfig plugin
    local mason_lspconfig = require("mason-lspconfig")

    -- import cmp-nvim-lsp plugin
    -- local cmp_nvim_lsp = require("cmp-nvim-lsp")

    local keymap = vim.keymap -- for conciseness

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(ev)
        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local opts = { buffer = ev.buf, silent = true }

        -- set keybinds
        opts.desc = "Show LSP references"
        keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

        opts.desc = "Go to declaration"
        keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

        opts.desc = "Show LSP definitions"

        keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

        opts.desc = "Show LSP implementations"
        keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

        opts.desc = "Show LSP type definitions"
        keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

        opts.desc = "See available code actions"
        keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

        opts.desc = "Smart rename"
        keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

        opts.desc = "Show buffer diagnostics"
        keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

        opts.desc = "Show line diagnostics"
        keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line

        opts.desc = "Go to previous diagnostic"
        keymap.set("n", "[d", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

        opts.desc = "Go to next diagnostic"

        keymap.set("n", "]d", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

        opts.desc = "Show documentation for what is under cursor"
        keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

        opts.desc = "Restart LSP"
        keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
      end,
    })

    -- Change the Diagnostic symbols in the sign column (gutter)

    -- (not in youtube nvim video)
    local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

    mason_lspconfig.setup_handlers({
      -- default handler for installed servers
      function(server_name)
        if require("neoconf").get(server_name .. ".disable") then
          return
        end
        lspconfig[server_name].setup({
          capabilities = capabilities,
        })
      end,
      ["emmet_language_server"] = function()
        -- configure emmet language server
        lspconfig["emmet_language_server"].setup({
          capabilities = capabilities,
          filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte", "vue" },
        })
      end,
      ["lua_ls"] = function()
        -- configure lua server (with special settings)
        lspconfig["lua_ls"].setup({

          capabilities = capabilities,
          settings = {
            Lua = {
              -- make the language server recognize "vim" global
              diagnostics = {
                globals = { "vim" },
              },
              completion = {
                callSnippet = "Replace",
              },
            },
          },
        })
      end,
      ["volar"] = function()
        lspconfig["volar"].setup({
          -- filetypes = { "vue", "javascript", "typescript" },
          capabilities = capabilities,
          init_options = {
            -- typescript = {
            -- tsdk = "~/.local/share/nvim/mason/packages/typescript-language-server/node_modules/typescript/lib",
            -- tsdk = require('mason').,
            -- tsdk = vim.fn.getcwd() .. "/node_modules/typescript/lib",
            -- },
            vue = {
              -- hybridMode = false,
            },
          },
        })
      end,
      ["ts_ls"] = function()
        lspconfig["ts_ls"].setup({
          capabilities = capabilities,
          init_options = {
            plugins = {
              {
                name = "@vue/typescript-plugin",
                -- location = vim.env.HOME .. "/.nvm/versions/node/v22.3.0/lib/node_modules/@vue/typescript-plugin/lib",
                location = require("mason-registry").get_package("vue-language-server"):get_install_path()
                  .. "/node_modules/@vue/language-server",
                languages = { "vue" },
              },
            },
          },
          filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
        })
      end,
      ["intelephense"] = function()
        lspconfig["intelephense"].setup({
          capabilities = capabilities,
          settings = {
            intelephense = {
              filetypes = { "php", "blade" },
              files = {
                associations = { "*.php", "*.blade.php" }, -- Associating .blade.php files as well
                maxSize = 5000000,
              },
            },
          },
          root_pattern = { "composer.json", ".git" },
          filetypes = { "php", "blade" },
        })
      end,
    })
  end,
}
