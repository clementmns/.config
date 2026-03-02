return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<cr>",  desc = "Neo-tree toggle" },
      { "<leader>E", "<cmd>Neotree reveal<cr>",  desc = "Neo-tree reveal fichier courant" },
    },
    opts = {
      close_if_last_window = true,
      hide_root_node = true,
      retain_hidden_root_indent = true,

      -- Pas de prise en main de netrw (oil s'en charge)
      filesystem = {
        hijack_netrw_behavior = "disabled",
        filtered_items = {
          visible        = false,
          hide_dotfiles  = false,
          hide_gitignored = true,
        },
        follow_current_file    = { enabled = true },
        group_empty_dirs       = true,
        use_libuv_file_watcher = true,
      },

      window = {
        position = "left",
        width    = 30,
        mappings = {
          -- Navigation vim dans la sidebar
          ["l"]       = "open",
          ["h"]       = "close_node",
          ["H"]       = "close_all_nodes",
          ["<space>"] = "none",
          ["<C-v>"]   = "open_vsplit",
          ["<C-x>"]   = "open_split",
          -- Prévisualisation
          ["P"]       = { "toggle_preview", config = { use_float = true } },
        },
      },

      default_component_configs = {
        indent = {
          indent_size   = 2,
          padding       = 1,
          with_markers  = true,
          indent_marker = "│",
          last_indent_marker = "└",
        },
        icon = {
          folder_closed = "",
          folder_open   = "",
          folder_empty  = "",
        },
        git_status = {
          symbols = {
            added     = "✚",
            modified  = "●",
            deleted   = "✖",
            renamed   = "➜",
            untracked = "?",
            ignored   = "◌",
            unstaged  = "",
            staged    = "",
            conflict  = "",
          },
        },
      },

      -- Fond transparent (cohérent avec le reste de la config)
      event_handlers = {
        {
          event   = "neo_tree_buffer_enter",
          handler = function()
            vim.opt_local.signcolumn = "auto"
          end,
        },
      },
    },
  },
}
