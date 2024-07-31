return {
  "yioneko/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    "hrsh7th/cmp-buffer", -- source for text in buffer
    "hrsh7th/cmp-path", -- source for file system paths
    {
      "L3MON4D3/LuaSnip",
      -- follow latest release.
      version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
      -- install jsregexp (optional!).
      build = "make install_jsregexp",
    },
    "saadparwaiz1/cmp_luasnip", -- for autocompletion
    "rafamadriz/friendly-snippets", -- useful snippets
    "onsails/lspkind.nvim", -- vs-code like pictograms
    "lukas-reineke/cmp-under-comparator",
  },
  config = function()
    local cmp = require("cmp")

    local types = require("cmp.types")

    local compare = cmp.config.compare

    local luasnip = require("luasnip")

    local lspkind = require("lspkind")

    local cmp_under_comparator = require("cmp-under-comparator").under

    -- loads vscode style snippets from installed plugins (e.g. friendly-snippets)
    require("luasnip.loaders.from_vscode").lazy_load()
    local cmp_autopairs = require("nvim-autopairs.completion.cmp")

    cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done({ map_char = { tex = "" } }))

    local function is_in_start_tag()
      local ts_utils = require("nvim-treesitter.ts_utils")
      local node = ts_utils.get_node_at_cursor()
      if not node then
        return false
      end
      local node_to_check = { "start_tag", "self_closing_tag", "directive_attribute" }
      return vim.tbl_contains(node_to_check, node:type())
    end

    ---@type table<integer, integer>
    local modified_priority = {
      -- [types.lsp.CompletionItemKind.Field] = 1,
      -- [types.lsp.CompletionItemKind.Variable] = 3,
      -- [types.lsp.CompletionItemKind.Method] = 2,
      -- [types.lsp.CompletionItemKind.Snippet] = 0, -- top
      -- [types.lsp.CompletionItemKind.Keyword] = 0, -- top
      [types.lsp.CompletionItemKind.Text] = 100, -- bottom
    }
    ---@param kind integer: kind of completion entry
    local function modified_kind(kind)
      return modified_priority[kind] or kind
    end

    local buffers = {
      name = "buffer",
      option = {
        keyword_length = 3,
        get_bufnrs = function() -- from all buffers (less than 1MB)
          local bufs = {}
          for _, bufn in ipairs(vim.api.nvim_list_bufs()) do
            local buf_size = vim.api.nvim_buf_get_offset(bufn, vim.api.nvim_buf_line_count(bufn))
            if buf_size < 1024 * 1024 then
              table.insert(bufs, bufn)
            end
          end
          return bufs
        end,
      },
    }

    cmp.setup({
      completion = {
        completeopt = "menu,menuone,preview,noselect",
      },
      snippet = { -- configure how nvim-cmp interacts with snippet engine
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-k>"] = cmp.mapping.select_prev_item(), -- previous suggestion
        ["<C-j>"] = cmp.mapping.select_next_item(), -- next suggestion
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(), -- show completion suggestions
        ["<C-e>"] = cmp.mapping.abort(), -- close completion window
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
      }),
      -- sources for autocompletion
      sources = cmp.config.sources({
        {
          name = "nvim_lsp",

          ---@param entry cmp.Entry
          ---@param ctx cmp.Context
          entry_filter = function(entry, ctx)
            -- Use a buffer-local variable to cache the result of the Treesitter check
            local bufnr = ctx.bufnr
            local cached_is_in_start_tag = vim.b[bufnr]._vue_ts_cached_is_in_start_tag
            if cached_is_in_start_tag == nil then
              vim.b[bufnr]._vue_ts_cached_is_in_start_tag = is_in_start_tag()
            end
            -- If not in start tag, return true
            if vim.b[bufnr]._vue_ts_cached_is_in_start_tag == false then
              return true
            end

            -- Check if the buffer type is 'vue'
            if ctx.filetype ~= "vue" then
              return true
            end

            local cursor_before_line = ctx.cursor_before_line
            -- For events
            if cursor_before_line:sub(-1) == "@" then
              return entry.completion_item.label:match("^@")
            -- For props also exclude events with `:on-` prefix
            elseif cursor_before_line:sub(-1) == ":" then
              return entry.completion_item.label:match("^:") and not entry.completion_item.label:match("^:on%-")
            else
              return true
            end
          end,
        },
        { name = "luasnip" }, -- snippets
        -- { name = "buffer" }, -- text within current buffer
        { name = "path" }, -- file system paths
      }, {
        buffers,
        { name = "dictionary", keyword_length = 3 },
        { name = "spell" },
        { name = "calc" },
        { name = "emoji" },
        { name = "git" },
      }),
      sorting = {
        priority_weight = 2,
        comparators = {
          -- vue_filter_comparator, -- Add the custom comparator here
          cmp_under_comparator,
          compare.offset,
          compare.exact,
          -- compare.recently_used,
          -- compare.locality,
          function(entry1, entry2) -- sort by compare kind (Variable, Function etc)
            local kind1 = modified_kind(entry1:get_kind())
            local kind2 = modified_kind(entry2:get_kind())
            if kind1 ~= kind2 then
              return kind1 - kind2 < 0
            end
          end,
          -- compare.sort_text,
          -- compare.length,
          compare.score,
          compare.order,
        },
      },

      -- configure lspkind for vs-code like pictograms in completion menu
      formatting = {
        format = lspkind.cmp_format({
          maxwidth = 50,
          ellipsis_char = "...",
        }),
      },
    })
  end,
}
