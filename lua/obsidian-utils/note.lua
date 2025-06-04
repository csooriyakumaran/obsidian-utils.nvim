-- lua/obsidian-utils/note.lua

local config = require('obsidian-utils.config')

local M = {}

--- Open the note in the configured window layout
--- @param path obsidian.Path
local function open_note_path(path)
  local method = config.values.open_method
  local valid_methods = {
    vsplit = true,
    hsplit = true,
    floating = true,
    edit = true
  }

  if not valid_methods[method] then
    vim.notify('Invalid note open method: `' .. method .. '` falling back to `floating`', vim.log.levels.WARN)
    method = 'floating'
  end

  if method == 'vsplit' then
    vim.cmd('vsplit ' .. tostring(path))
  elseif method == 'hsplit' then
    vim.cmd('split ' .. tostring(path))
  elseif method == 'floating' then
    local opts = config.values.floating_opts or {}
    local width = opts.width or math.floor(vim.o.columns * 0.6)
    local height = opts.height or math.floor(vim.o.lines * 0.8)
    local row = opts.row or math.floor((vim.o.lines - height) / 2)
    local col = opts.col or math.floor((vim.o.columts - width) / 2)
    local border = opts.border or 'rounded'

    local buf = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_buf_set_name(buf, tostring(path))

    local win = vim.api.nvim_open_win(buf, true, {
      relative = 'editor',
      width = width,
      height = height,
      row = row,
      col = col,
      border = border,
    })

    vim.bo[buf].buflisted = true
    vim.wo[win].wrap = true
    vim.wo[win].number = true
    vim.wo[win].relativenumber = true

    vim.cmd('edit ' .. tostring(path))

    local last_line = vim.api.nvim_buf_line_count(buf)
    vim.api.nvim_win_set_cursor(win, { last_line, 0 })

    vim.keymap.set('n', 'q', function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end, { buffer = buf, nowait = true, silent = true })
  else
    vim.cmd('edit ' .. tostring(path))
  end
end

--- Prompt the user for a title and create a new note
--- @param client obsidian.Client
--- @param dir obsidian.Path
--- @param template string
function M.create(client, dir, template)
  vim.ui.input({ prompt = 'Title: ' }, function(title)
    if not title or title == '' then return end
    if template == '' then template = nil end
    local note = client:create_note({
      title = title,
      dir = dir,
      template = template,
    })
    if note and note.path then
      open_note_path(note.path)
    else
      vim.notify("Failed to create note", vim.log.levels.ERROR)
    end
  end)
end

return M
