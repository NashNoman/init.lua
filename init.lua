require("nash.core")
require("nash.lazy")

function SetColorScheme(color)
  vim.cmd.colorscheme(color or "tokyonight-moon")
end

SetColorScheme("github_dark_default")
