return {
  "nvim-java/nvim-java",
  config = false,
  dependencies = {
    "nvim-java/lua-async-await",
    "nvim-java/nvim-java-core",
    "nvim-java/nvim-java-test",
    "nvim-java/nvim-java-dap",
    "MunifTanjim/nui.nvim",
    "neovim/nvim-lspconfig",
    "mfussenegger/nvim-dap",
    {
      "williamboman/mason.nvim",
      opts = {
        registries = {
          "github:nvim-java/mason-registry",
          "github:mason-org/mason-registry",
        },
      },
    },
    {
      "neovim/nvim-lspconfig",
      opts = {
        servers = {
          jdtls = {
            -- your jdtls configuration goes here
            cmd = { "~/.local/share/nvim/mason/bin/jdtls" },
            root_dir = vim.fs.dirname(vim.fs.find({ "gradlew", ".git", "mvnw" }, { upward = true })[1]),
          },
        },
        setup = {
          jdtls = function()
            require("java").setup()
          end,
        },
      },
    },
  },
}
