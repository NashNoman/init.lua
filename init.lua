require("nash.core")
require("nash.lazy")

function SetColorScheme(color)
  vim.cmd.colorscheme(color or "tokyonight-moon")
end

SetColorScheme("github_dark_default")

vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  group = vim.api.nvim_create_augroup("ts_imports", { clear = true }),
  pattern = { "*.tsx,*.ts" },
  callback = function()
    vim.lsp.buf.code_action({
      apply = true,
      context = {
        only = { "source.organizeImports" },
        -- only = { "source.removeUnused.ts" },
        diagnostics = {},
      },
    })
  end,
})
