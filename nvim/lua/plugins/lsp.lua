return {

  -- Lua LSP enhancements (Neovim API, lazy.nvim types)
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "luvit-meta/library", words = { "vim%.uv" } },
      },
    },
  },
  { "Bilal2453/luvit-meta", lazy = true },

  -- Mason: install/manage LSP servers, linters, formatters
  {
    "williamboman/mason.nvim",
    cmd   = "Mason",
    build = ":MasonUpdate",
    keys  = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    opts = {
      ensure_installed = {
        -- Formatters
        "stylua",
        "shfmt",
        "prettier",
        "black",
        "ruff",
        -- Linters
        "eslint_d",
      },
    },
    config = function(_, opts)
      require("mason").setup(opts)
      local mr = require("mason-registry")
      mr.refresh(function()
        for _, tool in ipairs(opts.ensure_installed) do
          local ok, p = pcall(mr.get_package, tool)
          if ok and not p:is_installed() then
            p:install()
          end
        end
      end)
    end,
  },

  -- Bridge between mason and nvim-lspconfig
  { "williamboman/mason-lspconfig.nvim", lazy = true },

  -- LSP configurations
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "folke/lazydev.nvim",
    },
    opts = {
      -- Diagnostic display
      diagnostics = {
        underline = true,
        update_in_insert = false,
        virtual_text = { spacing = 4, source = "if_many", prefix = "●" },
        severity_sort = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN]  = " ",
            [vim.diagnostic.severity.HINT]  = " ",
            [vim.diagnostic.severity.INFO]  = " ",
          },
        },
      },
      inlay_hints = { enabled = true },
      -- Servers (mason-lspconfig will install + configure them)
      servers = {
        lua_ls = {
          settings = {
            Lua = {
              workspace = { checkThirdParty = false },
              codeLens  = { enable = true },
              completion = { callSnippet = "Replace" },
              hint = {
                enable      = true,
                setType     = false,
                paramFormat = "%p",
                arrayIndex  = "Disable",
              },
            },
          },
        },
        ts_ls = {
          settings = {
            typescript = {
              inlayHints = {
                includeInlayParameterNameHints           = "all",
                includeInlayFunctionParameterTypeHints   = true,
                includeInlayVariableTypeHints            = true,
                includeInlayReturnTypeHints              = true,
              },
            },
            javascript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
              },
            },
          },
        },
        pyright = {},
        rust_analyzer = {},
        jsonls = {
          settings = {
            json = {
              format   = { enable = true },
              validate = { enable = true },
            },
          },
        },
        yamlls = {
          settings = {
            redhat = { telemetry = { enabled = false } },
            yaml = {
              keyOrdering = false,
              format      = { enable = true },
              validate    = true,
              schemaStore = { enable = false, url = "" },
            },
          },
        },
        html    = { filetypes = { "html", "templ" } },
        cssls   = {},
        bashls  = {},
        dockerls = {},
        taplo   = {}, -- TOML
      },
    },
    config = function(_, opts)
      -- Diagnostics
      vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

      -- Keymaps on LSP attach
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("user_lsp_attach", { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end
          local tb = require("telescope.builtin")

          map("gd",          tb.lsp_definitions,             "Goto definition")
          map("gr",          tb.lsp_references,              "Goto references")
          map("gI",          tb.lsp_implementations,         "Goto implementation")
          map("gy",          tb.lsp_type_definitions,        "Type definition")
          map("<leader>cs",  tb.lsp_document_symbols,        "Document symbols")
          map("<leader>cS",  tb.lsp_dynamic_workspace_symbols, "Workspace symbols")
          map("K",           vim.lsp.buf.hover,              "Hover documentation")
          map("gD",          vim.lsp.buf.declaration,        "Goto declaration")
          map("<leader>ca",  vim.lsp.buf.code_action,        "Code action")
          map("<leader>cr",  vim.lsp.buf.rename,             "Rename symbol")

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.supports_method("textDocument/inlayHint") then
            if opts.inlay_hints.enabled then
              vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
            end
            map("<leader>ch", function()
              local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf })
              vim.lsp.inlay_hint.enable(not enabled, { bufnr = event.buf })
            end, "Toggle inlay hints")
          end
        end,
      })

      -- Capabilities (extended by nvim-cmp)
      local capabilities = vim.tbl_deep_extend(
        "force",
        {},
        vim.lsp.protocol.make_client_capabilities(),
        require("cmp_nvim_lsp").default_capabilities()
      )

      -- Setup each server
      local function setup(server)
        local server_opts = vim.tbl_deep_extend("force", {
          capabilities = vim.deepcopy(capabilities),
        }, opts.servers[server] or {})
        require("lspconfig")[server].setup(server_opts)
      end

      local mlsp = require("mason-lspconfig")
      local available = mlsp.get_available_servers()
      local ensure_installed = {}

      for server, server_opts in pairs(opts.servers) do
        if server_opts then
          if not vim.tbl_contains(available, server) then
            setup(server)
          else
            ensure_installed[#ensure_installed + 1] = server
          end
        end
      end

      mlsp.setup({
        ensure_installed = ensure_installed,
        handlers = { setup },
      })
    end,
  },
}
