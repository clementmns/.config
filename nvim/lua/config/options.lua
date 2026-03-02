local opt = vim.opt

-- General
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.swapfile = false
opt.undofile = true
opt.undolevels = 10000
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }

-- UI
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.termguicolors = true
-- background is intentionally not set: Neovim queries Ghostty via OSC 11
-- and auto-detects light/dark from the system theme
opt.showmode = false
opt.pumblend = 10
opt.pumheight = 10
opt.scrolloff = 8
opt.sidescrolloff = 8

-- Line wrapping
opt.wrap = false
opt.breakindent = true

-- Whitespace display
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.fillchars = {
  foldopen  = "▾",
  foldclose = "▸",
  fold      = " ",
  foldsep   = " ",
  diff      = "╱",
  eob       = " ",
}

-- Editing
opt.expandtab = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.smartindent = true
opt.formatoptions = "jcroqlnt"
opt.conceallevel = 2

-- Search
opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true
opt.inccommand = "nosplit"

-- Splits
opt.splitright = true
opt.splitbelow = true
opt.splitkeep = "screen"

-- Performance
opt.updatetime = 200
opt.timeoutlen = 300

-- Folds (treesitter per-filetype via autocmd in plugins/editor.lua)
opt.foldmethod    = "expr"
opt.foldexpr      = "v:lua.vim.treesitter.foldexpr()"
opt.foldlevel     = 99
opt.foldlevelstart = 99

-- Spelling
opt.spelllang = { "en", "fr" }
