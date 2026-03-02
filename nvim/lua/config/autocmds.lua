local function augroup(name)
  return vim.api.nvim_create_augroup("user_" .. name, { clear = true })
end

-- Flash yanked region
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Equalize splits on terminal resize
vim.api.nvim_create_autocmd("VimResized", {
  group = augroup("resize_splits"),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

-- Return to last position when reopening a file
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_loc"),
  callback = function(event)
    local exclude = { "gitcommit", "gitrebase" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) then
      return
    end
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Close certain filetypes with 'q'
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "PlenaryTestPopup",
    "checkhealth",
    "help",
    "lspinfo",
    "notify",
    "qf",
    "query",
    "startuptime",
    "tsplayground",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- Enable wrap + spell in prose filetypes
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("wrap_spell"),
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Dashboard : démarrage sans fichier + fermeture du dernier buffer
local function has_real_bufs()
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(b)
      and vim.bo[b].buflisted
      and vim.api.nvim_buf_get_name(b) ~= ""
    then
      return true
    end
  end
  return false
end

-- Démarrage : vim.schedule diffère après que lazy.nvim a chargé les plugins VimEnter
vim.api.nvim_create_autocmd("VimEnter", {
  group = augroup("startup_dashboard"),
  once = true,
  callback = function()
    if vim.fn.argc(-1) == 0 then
      vim.schedule(function()
        pcall(vim.cmd, "Dashboard")
      end)
    end
  end,
})

-- Dernier buffer fermé via :bd direct (pas via <leader>bd) : fallback
vim.api.nvim_create_autocmd("BufDelete", {
  group = augroup("last_buffer_dashboard"),
  callback = function(event)
    if vim.bo[event.buf].filetype == "dashboard" then return end
    vim.schedule(function()
      -- Vérifie si une fenêtre normale est encore affichée, sinon ouvre le dashboard
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local b = vim.api.nvim_win_get_buf(win)
        if vim.api.nvim_buf_get_name(b) ~= "" then return end
      end
      if not has_real_bufs() then
        pcall(vim.cmd, "Dashboard")
      end
    end)
  end,
})

-- Auto-create parent directories on save
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup("auto_create_dir"),
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})
