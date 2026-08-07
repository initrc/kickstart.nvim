-- User configuration for Neovim
--
-- This module is loaded at the end of init.lua, after the Kickstart defaults
-- and plugin configuration. Put independent personal options, keymaps, and
-- late overrides here. Keep settings that a plugin must read during setup next
-- to that plugin's setup call in init.lua.

-- [[ Options ]]
vim.o.cmdheight = 0

-- [[ Keymaps ]]
vim.keymap.set({ 'n', 'x' }, 'H', '^', { desc = 'Move cursor to the start of line' })
vim.keymap.set({ 'n', 'x' }, 'L', '$', { desc = 'Move cursor to the end of line' })
vim.keymap.set({ 'n', 'x' }, 'K', '<C-b>M', { desc = 'Page up and keep cursor in the middle' })
vim.keymap.set({ 'n', 'x' }, 'J', '<C-f>M', { desc = 'Page down and keep cursor in the middle' })
vim.keymap.set('n', '+', 'J', { desc = 'Connect lines' })
vim.keymap.set('n', 'U', '<C-r>', { desc = 'Redo' })
vim.keymap.set('n', '<leader>vs', '<cmd>vsplit | wincmd h | buffer # | wincmd l<CR>', { desc = 'Vertical split no dups' })
vim.keymap.set('x', '<leader>mf', "<cmd>'<,'>!pandoc -t commonmark_x<CR><CR>", { desc = '[M]arkdown [F]ormatter' })
vim.keymap.set({ 'i', 'c' }, '<C-h>', '<Left>', { desc = 'Move curosr left' })
vim.keymap.set({ 'i', 'c' }, '<C-l>', '<Right>', { desc = 'Move cursor right' })

-- [[ User commands ]]

-- Run commands in NeoVim's built-in terminal to interpret ANSI colors
-- Usage: `:T python3 script.py`
vim.api.nvim_create_user_command("T", function(opts)
  vim.cmd("botright 15split") -- horizontal split at the bottom
  vim.cmd("terminal " .. opts.args)
end, {
  nargs = "+", -- one or more args
  complete = "shellcmd", -- provide tab completion for shell commands
})

-- [[ Auto commands ]]

-- When started with a directory, use it as the working directory and open
-- an empty buffer. This keeps file pickers rooted there without opening a
-- file browser (netrw or Neo-tree).
vim.api.nvim_create_autocmd('VimEnter', {
  desc = 'Start directory arguments in an empty buffer',
  group = vim.api.nvim_create_augroup('initrc-directory-startup', { clear = true }),
  callback = function()
    if vim.fn.argc() ~= 1 then return end

    local directory = vim.fn.argv(0)
    if type(directory) ~= 'string' or vim.fn.isdirectory(directory) ~= 1 then return end

    local directory_buffer = vim.api.nvim_get_current_buf()
    vim.api.nvim_set_current_dir(vim.fn.fnamemodify(directory, ':p'))
    vim.cmd.enew()

    if directory_buffer ~= vim.api.nvim_get_current_buf() and vim.api.nvim_buf_is_valid(directory_buffer) then
      vim.api.nvim_buf_delete(directory_buffer, { force = true })
    end
  end,
})

vim.api.nvim_create_autocmd('User', {
  desc = 'Show absolute line numbers in Telescope previews',
  group = vim.api.nvim_create_augroup('initrc-telescope-preview', { clear = true }),
  pattern = 'TelescopePreviewerLoaded',
  callback = function()
    vim.wo.number = true
  end,
})

-- [[ Plugin: mini.tabline ]]
require('mini.tabline').setup()

local function update_tabline_visibility()
  local listed_buffers = vim.fn.getbufinfo { buflisted = 1 }
  vim.o.showtabline = #listed_buffers > 1 and 2 or 0
end

vim.api.nvim_create_autocmd({ 'BufAdd', 'BufDelete', 'BufEnter' }, {
  desc = 'Show the tabline only when multiple buffers are listed',
  group = vim.api.nvim_create_augroup('initrc-tabline-visibility', { clear = true }),
  callback = function() vim.schedule(update_tabline_visibility) end,
})

update_tabline_visibility()

-- [[ Plugin: redpen ]]
vim.pack.add { 'https://github.com/initrc/redpen.nvim' }
-- For local development, comment the line above and uncomment this one:
-- vim.opt.runtimepath:prepend(vim.fn.expand '~/code/redpen.nvim')

local redpen = require 'redpen'

-- `x` maps Visual mode only; unlike `v`, it does not include Select mode.
vim.keymap.set({ 'n', 'x' }, '<leader>ra', redpen.add_comment, { desc = '[R]edpen [A]dd comment' })
vim.keymap.set('n', '<leader>rd', redpen.open_diff, { desc = '[R]edpen [D]iff' })
vim.keymap.set('n', '<leader>rD', redpen.open_diff_head, { desc = '[R]edpen HEAD [D]iff' })
vim.keymap.set('n', '<leader>rf', redpen.finish_review, { desc = '[R]edpen [F]inish review' })

-- These mappings exist only in a Redpen diff buffer.
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'redpen-diff',
  callback = function(event)
    vim.keymap.set('n', '<CR>', redpen.jump_to_source, {
      buffer = event.buf,
      desc = 'Open source file from Redpen diff',
    })
    vim.keymap.set('n', 'q', redpen.close_diff, {
      buffer = event.buf,
      desc = 'Close Redpen diff',
    })
  end,
})

-- [[ Plugin: runner ]]
vim.pack.add { 'https://github.com/initrc/runner' }
vim.keymap.set("n", "<leader>rc", "<cmd>RunnerRun<CR>", { desc = "[R]un [C]ode" })

-- [[ Plugin: colorizer ]]
vim.pack.add { 'https://github.com/norcalli/nvim-colorizer.lua' }
require('colorizer').setup()
