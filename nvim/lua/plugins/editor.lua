return {

  -- Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    version = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function() return vim.fn.executable("make") == 1 end,
      },
      "nvim-telescope/telescope-ui-select.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      { "<leader>,",      "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>", desc = "Switch buffer" },
      { "<leader>/",      "<cmd>Telescope live_grep<cr>",                                desc = "Grep (root)" },
      { "<leader>:",      "<cmd>Telescope command_history<cr>",                          desc = "Command history" },
      { "<leader><space>","<cmd>Telescope find_files<cr>",                               desc = "Find files" },
      -- Find
      { "<leader>fb",     "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>", desc = "Buffers" },
      { "<leader>ff",     "<cmd>Telescope find_files<cr>",                               desc = "Find files" },
      { "<leader>fF",     "<cmd>Telescope find_files cwd=true<cr>",                     desc = "Find files (cwd)" },
      { "<leader>fr",     "<cmd>Telescope oldfiles<cr>",                                 desc = "Recent files" },
      -- Git
      { "<leader>gc",     "<cmd>Telescope git_commits<cr>",                              desc = "Commits" },
      { "<leader>gs",     "<cmd>Telescope git_status<cr>",                               desc = "Status" },
      -- Search
      { '<leader>s"',     "<cmd>Telescope registers<cr>",                                desc = "Registers" },
      { "<leader>sa",     "<cmd>Telescope autocommands<cr>",                             desc = "Auto commands" },
      { "<leader>sb",     "<cmd>Telescope current_buffer_fuzzy_find<cr>",                desc = "Buffer" },
      { "<leader>sc",     "<cmd>Telescope command_history<cr>",                          desc = "Command history" },
      { "<leader>sC",     "<cmd>Telescope commands<cr>",                                 desc = "Commands" },
      { "<leader>sd",     "<cmd>Telescope diagnostics bufnr=0<cr>",                      desc = "Document diagnostics" },
      { "<leader>sD",     "<cmd>Telescope diagnostics<cr>",                              desc = "Workspace diagnostics" },
      { "<leader>sg",     "<cmd>Telescope live_grep<cr>",                                desc = "Grep" },
      { "<leader>sh",     "<cmd>Telescope help_tags<cr>",                                desc = "Help pages" },
      { "<leader>sH",     "<cmd>Telescope highlights<cr>",                               desc = "Highlight groups" },
      { "<leader>sk",     "<cmd>Telescope keymaps<cr>",                                  desc = "Key maps" },
      { "<leader>sm",     "<cmd>Telescope marks<cr>",                                    desc = "Marks" },
      { "<leader>so",     "<cmd>Telescope vim_options<cr>",                              desc = "Options" },
      { "<leader>sw",     "<cmd>Telescope grep_string<cr>",                              desc = "Word under cursor" },
    },
    config = function()
      local telescope = require("telescope")
      local actions   = require("telescope.actions")

      telescope.setup({
        defaults = {
          prompt_prefix   = " ",
          selection_caret = " ",
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-n>"] = actions.cycle_history_next,
              ["<C-p>"] = actions.cycle_history_prev,
              ["<esc>"] = actions.close,
            },
          },
          file_ignore_patterns = { "%.git/", "node_modules/", "%.lock" },
        },
        extensions = {
          fzf = {},
          ["ui-select"] = { require("telescope.themes").get_dropdown() },
        },
      })

      telescope.load_extension("fzf")
      telescope.load_extension("ui-select")
    end,
  },

  -- Parser installer (new rewrite — does NOT support lazy-loading)
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    -- build tourne uniquement à l'install/update du plugin, jamais au démarrage
    build = function()
      require("nvim-treesitter").install({
        "bash", "c", "css", "diff", "dockerfile", "gitcommit",
        "html", "javascript", "json", "json5",
        "lua", "luadoc", "markdown", "markdown_inline",
        "python", "regex", "rust", "scss", "toml",
        "tsx", "typescript", "vim", "vimdoc", "xml", "yaml",
      }):wait(300000)
    end,
    dependencies = {
      {
        "nvim-treesitter/nvim-treesitter-textobjects",
        config = function()
          require("nvim-treesitter-textobjects").setup({
            move = {
              enable    = true,
              set_jumps = true,
              goto_next_start     = { ["]f"] = "@function.outer", ["]c"] = "@class.outer" },
              goto_next_end       = { ["]F"] = "@function.outer", ["]C"] = "@class.outer" },
              goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer" },
              goto_previous_end   = { ["[F"] = "@function.outer", ["[C"] = "@class.outer" },
            },
            select = {
              enable    = true,
              lookahead = true,
              keymaps   = {
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                ["ac"] = "@class.outer",
                ["ic"] = "@class.inner",
              },
            },
          })
        end,
      },
    },
    config = function()
      -- Highlighting + folds via FileType autocmd (aucun message au démarrage)
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
        callback = function(ev)
          pcall(vim.treesitter.start, ev.buf)
          vim.wo[0][0].foldmethod = "expr"
          vim.wo[0][0].foldexpr   = "v:lua.vim.treesitter.foldexpr()"
        end,
      })
    end,
  },

  -- Show current context (function/class) at top of window
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      max_lines = 3,
      mode = "cursor",
    },
    keys = {
      { "<leader>ut", "<cmd>TSContextToggle<cr>", desc = "Toggle treesitter context" },
    },
  },

  -- Smart pairs
  {
    "echasnovski/mini.pairs",
    event = "VeryLazy",
    opts = {
      modes = { insert = true, command = true, terminal = false },
    },
  },

  -- Enhanced text objects (inside function, class, etc.)
  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    opts = function()
      local ai = require("mini.ai")
      return {
        n_lines = 500,
        custom_textobjects = {
          o = ai.gen_spec.treesitter({
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }),
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
          c = ai.gen_spec.treesitter({ a = "@class.outer",    i = "@class.inner" }),
          -- HTML tags
          t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" },
        },
      }
    end,
  },

  -- Surround: gsa, gsd, gsr, gsf, gsF, gsh
  {
    "echasnovski/mini.surround",
    keys = {
      { "gsa", desc = "Add surrounding",          mode = { "n", "v" } },
      { "gsd", desc = "Delete surrounding" },
      { "gsf", desc = "Find right surrounding" },
      { "gsF", desc = "Find left surrounding" },
      { "gsh", desc = "Highlight surrounding" },
      { "gsr", desc = "Replace surrounding" },
      { "gsn", desc = "Update n_lines" },
    },
    opts = {
      mappings = {
        add            = "gsa",
        delete         = "gsd",
        find           = "gsf",
        find_left      = "gsF",
        highlight      = "gsh",
        replace        = "gsr",
        update_n_lines = "gsn",
      },
    },
  },

  -- TODO / FIXME / HACK / NOTE highlights
  {
    "folke/todo-comments.nvim",
    cmd   = { "TodoTrouble", "TodoTelescope" },
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { signs = false },
    keys = {
      { "]t",         function() require("todo-comments").jump_next() end, desc = "Next todo" },
      { "[t",         function() require("todo-comments").jump_prev() end, desc = "Prev todo" },
      { "<leader>st", "<cmd>TodoTelescope<cr>",                           desc = "Todo" },
      { "<leader>sT", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>",  desc = "Todo/Fix/Fixme" },
      { "<leader>xt", "<cmd>TodoTrouble<cr>",                             desc = "Todo (Trouble)" },
      { "<leader>xT", "<cmd>TodoTrouble keywords=TODO,FIX,FIXME<cr>",    desc = "Todo/Fix/Fixme (Trouble)" },
    },
  },

  -- Diagnostics panel
  {
    "folke/trouble.nvim",
    cmd  = { "Trouble" },
    opts = { use_diagnostic_signs = true },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",                           desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",              desc = "Buffer diagnostics (Trouble)" },
      { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>",                   desc = "Symbols (Trouble)" },
      { "<leader>xl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",   desc = "LSP (Trouble)" },
      { "<leader>xL", "<cmd>Trouble loclist toggle<cr>",                               desc = "Location list (Trouble)" },
      { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>",                                desc = "Quickfix list (Trouble)" },
    },
  },

  -- Integrated terminal
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
      { "<leader>tt", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Terminal (horizontal)" },
      { "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>",   desc = "Terminal (vertical)" },
      { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>",      desc = "Terminal (float)" },
      { "<C-\\>",     "<cmd>ToggleTerm<cr>",                       desc = "Toggle terminal" },
    },
    opts = {
      size = function(term)
        if term.direction == "horizontal" then
          return 15
        elseif term.direction == "vertical" then
          return math.floor(vim.o.columns * 0.4)
        end
      end,
      shade_terminals = false,
      direction = "float",
      float_opts = { border = "curved" },
    },
  },
}
