return {

  -- Formatter (format on save)
  {
    "stevearc/conform.nvim",
    lazy = true,
    event = { "BufWritePre" },
    cmd   = { "ConformInfo" },
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        mode = "",
        desc = "Format buffer",
      },
    },
    opts = {
      formatters_by_ft = {
        lua              = { "stylua" },
        python           = { "ruff_format", "black" },
        javascript       = { "prettier" },
        typescript       = { "prettier" },
        javascriptreact  = { "prettier" },
        typescriptreact  = { "prettier" },
        css              = { "prettier" },
        scss             = { "prettier" },
        html             = { "prettier" },
        json             = { "prettier" },
        jsonc            = { "prettier" },
        yaml             = { "prettier" },
        markdown         = { "prettier" },
        graphql          = { "prettier" },
        rust             = { "rustfmt" },
        sh               = { "shfmt" },
        bash             = { "shfmt" },
        zsh              = { "shfmt" },
      },
      default_format_opts = {
        timeout_ms  = 3000,
        async       = false,
        quiet       = false,
        lsp_format  = "fallback",
      },
      format_on_save = {
        timeout_ms   = 500,
        lsp_fallback = true,
      },
    },
  },

  -- Linter (run on save / insert leave)
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")

      lint.linters_by_ft = {
        python          = { "ruff" },
        javascript      = { "eslint_d" },
        typescript      = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescriptreact = { "eslint_d" },
      }

      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        group = vim.api.nvim_create_augroup("user_nvim_lint", { clear = true }),
        callback = function()
          -- Only lint if linter is available (avoid errors on missing tools)
          lint.try_lint(nil, { ignore_errors = true })
        end,
      })
    end,
  },
}
