return {

  -- Icons (used by many plugins)
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- Statusline (style tmux : fond transparent, vert/jaune/blanc, séparateur │)
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = function()
      -- Récupère la palette catppuccin (latte ou macchiato selon le thème actif)
      local palette = {}
      local ok, cpp = pcall(require, "catppuccin.palettes")
      if ok then
        palette = cpp.get_palette()
      end

      local green   = palette.green   or "green"
      local yellow  = palette.yellow  or "yellow"
      local red     = palette.red     or "red"
      local blue    = palette.blue    or "blue"
      local subtext = palette.subtext1 or "white"

      -- Thème custom : fond transparent partout (comme tmux bg=default)
      local function s(fg, bold)
        return {
          a = { bg = "NONE", fg = fg, gui = bold and "bold" or "NONE" },
          b = { bg = "NONE", fg = subtext },
          c = { bg = "NONE", fg = subtext },
        }
      end

      local theme = {
        normal   = s(green,  true),
        insert   = s(green,  true),
        visual   = s(yellow, true),
        replace  = s(red,    true),
        command  = s(yellow, true),
        inactive = s(subtext, false),
      }

      return {
        options = {
          theme                = theme,
          -- Pas de séparateurs de section (pas de powerline)
          section_separators   = { left = "", right = "" },
          -- │ entre composants — comme tmux window-status-separator
          component_separators = { left = "│", right = "│" },
          globalstatus         = true,
          disabled_filetypes   = { statusline = { "dashboard" } },
        },
        sections = {
          -- Gauche : branch en vert gras — comme #S (session name) dans tmux
          lualine_a = {
            { "branch", icon = "", color = { fg = green, bg = "NONE", gui = "bold" }, padding = { left = 0, right = 1 } },
          },
          lualine_b = {},
          -- Centre : fichier en jaune gras + diagnostics — comme la fenêtre active tmux
          lualine_c = {
            {
              "filename",
              path = 1,
              color = { fg = yellow, bg = "NONE", gui = "bold" },
              symbols = { modified = " ●", readonly = " ", unnamed = "—" },
            },
            {
              "diagnostics",
              color = { bg = "NONE" },
              symbols = { error = " ", warn = " ", hint = " ", info = " " },
            },
          },
          lualine_x = {
            { "diff", color = { bg = "NONE" } },
          },
          lualine_y = {
            { "mode", color = { fg = blue, bg = "NONE", gui = "bold" } },
          },
          -- Droite : heure en vert gras — comme hostname dans tmux
          lualine_z = {
            { function() return os.date("%R") end, color = { fg = green, bg = "NONE", gui = "bold" } },
          },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {
            { "filename", color = { fg = subtext, bg = "NONE" } },
          },
          lualine_x = {},
          lualine_y = {},
          lualine_z = {},
        },
      }
    end,
  },

  -- Buffer tabs
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>",          desc = "Toggle pin" },
      { "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete non-pinned buffers" },
      { "<leader>bo", "<Cmd>BufferLineCloseOthers<CR>",        desc = "Delete other buffers" },
      { "<leader>br", "<Cmd>BufferLineCloseRight<CR>",         desc = "Delete buffers to the right" },
      { "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>",          desc = "Delete buffers to the left" },
      { "<S-h>",      "<cmd>BufferLineCyclePrev<cr>",          desc = "Prev buffer" },
      { "<S-l>",      "<cmd>BufferLineCycleNext<cr>",          desc = "Next buffer" },
      { "[b",         "<cmd>BufferLineCyclePrev<cr>",          desc = "Prev buffer" },
      { "]b",         "<cmd>BufferLineCycleNext<cr>",          desc = "Next buffer" },
    },
    opts = function()
      return {
        options = {
          mode = "buffers",
          separator_style = "thin",
          show_buffer_close_icons = true,
          show_close_icon = false,
          color_icons = true,
          always_show_bufferline = false,
          close_command = function(bufnr)
            local has_others = false
            for _, b in ipairs(vim.api.nvim_list_bufs()) do
              if b ~= bufnr
                and vim.api.nvim_buf_is_valid(b)
                and vim.bo[b].buflisted
                and vim.api.nvim_buf_get_name(b) ~= ""
              then
                has_others = true
                break
              end
            end
            if not has_others then
              pcall(vim.cmd, "Dashboard")
              vim.schedule(function()
                if vim.api.nvim_buf_is_valid(bufnr) then
                  pcall(vim.api.nvim_buf_delete, bufnr, { force = false })
                end
              end)
            else
              vim.api.nvim_buf_delete(bufnr, { force = false })
            end
          end,
          diagnostics = "nvim_lsp",
          diagnostics_indicator = function(_, _, diag)
            local icons = { error = " ", warning = " ", hint = " " }
            local ret = (diag.error and icons.error .. diag.error .. " " or "")
              .. (diag.warning and icons.warning .. diag.warning or "")
            return vim.trim(ret)
          end,
          custom_filter = function(buf)
            local ft = vim.bo[buf].filetype
            local excluded = { "neo-tree", "TelescopePrompt", "notify", "toggleterm", "dashboard" }
            return not vim.tbl_contains(excluded, ft)
          end,
          offsets = {
            { filetype = "neo-tree", text = "Explorer", highlight = "Directory", text_align = "left", separator = true },
          },
        },
      }
    end,
  },

  -- Notifications + improved cmdline UI
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      routes = {
        {
          filter = {
            event = "msg_show",
            any = {
              { find = "%d+L, %d+B" },
              { find = "; after #%d+" },
              { find = "; before #%d+" },
            },
          },
          view = "mini",
        },
      },
      presets = {
        bottom_search      = true,
        command_palette    = true,
        long_message_to_split = true,
        inc_rename         = false,
      },
    },
    keys = {
      { "<leader>sn",  "",                                                          desc = "+noice" },
      { "<S-Enter>",   function() require("noice").redirect(vim.fn.getcmdline()) end, mode = "c", desc = "Redirect cmdline" },
      { "<leader>snl", function() require("noice").cmd("last") end,                  desc = "Noice last message" },
      { "<leader>snh", function() require("noice").cmd("history") end,               desc = "Noice history" },
      { "<leader>sna", function() require("noice").cmd("all") end,                   desc = "Noice all" },
    },
  },

  -- Better vim.ui.select / vim.ui.input
  {
    "stevearc/dressing.nvim",
    lazy = true,
    init = function()
      vim.ui.select = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.select(...)
      end
      vim.ui.input = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.input(...)
      end
    end,
  },

  -- Indent guides
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    main = "ibl",
    opts = {
      indent = { char = "│", tab_char = "│" },
      scope  = { enabled = false },
      exclude = {
        filetypes = { "help", "dashboard", "lazy", "mason", "notify", "toggleterm" },
      },
    },
  },

  -- Dashboard
  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = function()
      local logo = table.concat({
        "",
        "      ____                _                     ",
        " _ __| ___| ___ _   _ ___| |_ ___ _ __ ___  ___ ",
        "| '_ \\___ \\/ __| | | / __| __/ _ \\ '_ ` _ \\/ __|",
        "| |_) |__) \\__ \\ |_| \\__ \\ ||  __/ | | | | \\__ \\",
        "| .__/____/|___/\\__, |___/\\__\\___|_| |_| |_|___/",
        "|_|             |___/                       ",
        "",
      }, "\n")

      return {
        theme = "doom",
        hide = { statusline = false },
        config = {
          header = vim.split(logo, "\n"),
          center = {
            { action = "Telescope find_files",              desc = " Find file",     icon = " ", key = "f" },
            { action = "ene | startinsert",                  desc = " New file",      icon = " ", key = "n" },
            { action = "Telescope oldfiles",                 desc = " Recent files",  icon = " ", key = "r" },
            { action = "Telescope live_grep",                desc = " Find text",     icon = " ", key = "g" },
            { action = "Lazy",                               desc = " Lazy",          icon = "󰒲 ", key = "l" },
            { action = "qa",                                 desc = " Quit",          icon = " ", key = "q" },
          },
          footer = function()
            local stats = require("lazy").stats()
            local ms = math.floor(stats.startuptime * 100 + 0.5) / 100
            return { "⚡ " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms" }
          end,
        },
      }
    end,
    config = function(_, opts)
      local ok, palette = pcall(require, "catppuccin.palettes")
      if ok then
        local p = palette.get_palette()
        vim.api.nvim_set_hl(0, "DashboardHeader", { fg = p.green, bold = true })
      end
      require("dashboard").setup(opts)
    end,
  },

  -- Keybinding hints
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      plugins = { spelling = true },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.add({
        { "<leader>b",  group = "buffer" },
        { "<leader>c",  group = "code" },
        { "<leader>f",  group = "file/find" },
        { "<leader>g",  group = "git" },
        { "<leader>gh", group = "hunks" },
        { "<leader>s",  group = "search" },
        { "<leader>t",  group = "terminal" },
        { "<leader>w",  group = "windows" },
        { "<leader>x",  group = "diagnostics/quickfix" },
        { "[",          group = "prev" },
        { "]",          group = "next" },
        { "g",          group = "goto" },
        { "gs",         group = "surround" },
        { "z",          group = "fold" },
      })
    end,
  },
}
