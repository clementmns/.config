return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      -- Match Ghostty: catppuccin-macchiato (dark) / catppuccin-latte (light)
      flavour = "auto",
      background = { light = "latte", dark = "macchiato" },
      -- Transparent bg lets Ghostty's background-opacity = 0.75 show through
      transparent_background = true,
      term_colors = true,
      dim_inactive = { enabled = false },
      styles = {
        comments    = { "italic" },
        conditionals = { "italic" },
        functions   = {},
        keywords    = { "italic" },
        strings     = {},
        variables   = {},
      },
      integrations = {
        blink_cmp        = false,
        cmp              = true,
        gitsigns         = true,
        indent_blankline = { enabled = true },
        lsp_trouble      = true,
        mason            = true,
        mini             = { enabled = true },
        neogit           = true,
        neo_tree         = true,
        noice            = true,
        notify           = true,
        telescope        = { enabled = true },
        treesitter       = true,
        treesitter_context = true,
        which_key        = true,
        native_lsp = {
          enabled = true,
          underlines = {
            errors      = { "undercurl" },
            hints       = { "undercurl" },
            warnings    = { "undercurl" },
            information = { "undercurl" },
          },
        },
      },
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme("catppuccin")
    end,
  },
}
