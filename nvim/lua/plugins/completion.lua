return {

  -- Snippet engine
  {
    "L3MON4D3/LuaSnip",
    build = (not jit.os:find("Windows"))
      and "echo 'NOTE: jsregexp is optional'; make install_jsregexp"
      or nil,
    dependencies = {
      {
        "rafamadriz/friendly-snippets",
        config = function()
          require("luasnip.loaders.from_vscode").lazy_load()
        end,
      },
    },
    opts = {
      history = true,
      delete_check_events = "TextChanged",
    },
  },

  -- Completion engine
  {
    "hrsh7th/nvim-cmp",
    version = false,
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip",
    },
    opts = function()
      vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })

      local cmp     = require("cmp")
      local luasnip = require("luasnip")
      local defaults = require("cmp.config.default")()

      -- Kind icons
      local kind_icons = {
        Array         = " ", Boolean       = "󰨙 ", Class         = " ",
        Color         = " ", Constant      = "󰏿 ", Constructor   = " ",
        Enum          = " ", EnumMember    = " ", Event         = " ",
        Field         = " ", File          = " ", Folder        = " ",
        Function      = "󰊕 ", Interface     = " ", Key           = " ",
        Keyword       = " ", Method        = "󰊕 ", Module        = " ",
        Namespace     = "󰦮 ", Null          = " ", Number        = "󰎠 ",
        Object        = " ", Operator      = " ", Package       = " ",
        Property      = " ", Reference     = " ", Snippet       = "󱄽 ",
        String        = " ", Struct        = "󰆼 ", Text          = " ",
        TypeParameter = " ", Unit          = " ", Value         = " ",
        Variable      = "󰀫 ",
      }

      return {
        completion = { completeopt = "menu,menuone,noinsert" },
        preselect  = cmp.PreselectMode.Item,

        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },

        mapping = cmp.mapping.preset.insert({
          ["<C-n>"]     = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-p>"]     = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-b>"]     = cmp.mapping.scroll_docs(-4),
          ["<C-f>"]     = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"]     = cmp.mapping.abort(),
          ["<CR>"]      = cmp.mapping.confirm({ select = true }),
          ["<S-CR>"]    = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
          ["<Tab>"]     = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"]   = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),

        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "path" },
        }, {
          { name = "buffer" },
        }),

        formatting = {
          format = function(_, item)
            if kind_icons[item.kind] then
              item.kind = kind_icons[item.kind] .. item.kind
            end
            return item
          end,
        },

        experimental = {
          ghost_text = { hl_group = "CmpGhostText" },
        },

        sorting = defaults.sorting,
      }
    end,
  },
}
