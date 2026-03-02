local map = vim.keymap.set

-- Better up/down on wrapped lines
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Resize windows
map("n", "<C-Up>",    "<cmd>resize +2<cr>",          { desc = "Increase window height" })
map("n", "<C-Down>",  "<cmd>resize -2<cr>",           { desc = "Decrease window height" })
map("n", "<C-Left>",  "<cmd>vertical resize -2<cr>",  { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>",  { desc = "Increase window width" })

-- Buffer navigation (S-h/S-l/[b/]b gérés par bufferline)
-- Smart delete : ouvre le dashboard avant de supprimer si c'est le dernier buffer réel
local function smart_bdelete(force)
  local buf = vim.api.nvim_get_current_buf()
  local has_others = false
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if b ~= buf
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
      if vim.api.nvim_buf_is_valid(buf) then
        pcall(vim.api.nvim_buf_delete, buf, { force = force })
      end
    end)
  else
    vim.cmd(force and "bd!" or "bdelete")
  end
end

map("n", "<leader>bd", function() smart_bdelete(false) end, { desc = "Delete buffer" })
map("n", "<leader>bD", function() smart_bdelete(true) end,  { desc = "Delete buffer (force)" })

-- Clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<cr>")

-- Better indenting in visual mode (stays in visual)
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Move lines
map("n", "<A-j>", "<cmd>m .+1<cr>==",       { desc = "Move line down" })
map("n", "<A-k>", "<cmd>m .-2<cr>==",       { desc = "Move line up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move line down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move line up" })
map("v", "<A-j>", ":m '>+1<cr>gv=gv",       { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv",       { desc = "Move selection up" })

-- Save
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

-- Quit
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })

-- New file
map("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New file" })

-- Lazy
map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })

-- Diagnostics
local function diagnostic_goto(next, severity)
  local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function()
    go({ severity = severity })
  end
end

map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "]d", diagnostic_goto(true),          { desc = "Next diagnostic" })
map("n", "[d", diagnostic_goto(false),         { desc = "Prev diagnostic" })
map("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next error" })
map("n", "[e", diagnostic_goto(false, "ERROR"),{ desc = "Prev error" })
map("n", "]w", diagnostic_goto(true, "WARN"),  { desc = "Next warning" })
map("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev warning" })

-- Terminal: exit with double Escape
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Splits
map("n", "<leader>-",  "<C-W>s", { desc = "Split window below" })
map("n", "<leader>|",  "<C-W>v", { desc = "Split window right" })
map("n", "<leader>wd", "<C-W>c", { desc = "Delete window" })

-- Clipboard: paste without clobbering register in visual mode
map("x", "<leader>p", [["_dP]], { desc = "Paste without yanking" })
