-- lua/obsidian-utils/directory.lua

local config = require('obsidian-utils.config')
local Path = require('obsidian.path')

local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local previewers = require('telescope.previewers')
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local conf = require('telescope.config').values

local M = {}

--- Get all subdirectories in the vault
--- @param root obsidian.Path
--- @param excluded_dirs table?
--- @return table
local function get_all_subdirs(root, excluded_dirs)
  excluded_dirs = excluded_dirs or {}

  local function is_excluded(name)
    return vim.tbl_contains(excluded_dirs, name)
  end

  local result = {}

  local function scan_dir(dir, prefix)
    local handle = vim.uv.fs_scandir(tostring(dir))

    while handle do
      local name, type = vim.uv.fs_scandir_next(handle)
      if not name then break end

      if type == 'directory' and not is_excluded(name) then
        local rel = prefix and (prefix .. '/' .. name) or name
        table.insert(result, rel)
        scan_dir(tostring(Path:new(dir) / name), rel)
      end
    end
  end

  scan_dir(root)
  return result
end


local function directory_file_listner(self, entry, status)
  local dir = Path:new(entry.value or entry)
  local results = {}

  if dir:is_dir() then
    local handle = vim.uv.fs_scandir(tostring(dir))
    if handle then
      while true do
        local name, t = vim.uv.fs_scandir_next(handle)
        if not name then break end
        table.insert(results, name .. (t == 'directory' and '/' or ''))
      end
    end
  end

  local bufnr = self.state.bufnr
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, results)
end

local dir_previewer = previewers.new_buffer_previewer({
  define_preview = directory_file_listner
})

--- Select or create new subdirectory for the note
--- @param vault_path obsidian.Path
--- @param callback fun(path: obsidian.Path)
function M.select(vault_path, callback)
  local exclude_dirs = config.values.exclude_dirs or {}
  local subdirs = get_all_subdirs(vault_path, exclude_dirs)
  table.insert(subdirs, 1, '[root]')
  table.insert(subdirs, '[Create directory ...]')

  pickers.new({}, {
    prompt_title = 'Select Directory',
    finder = finders.new_table({
      results = subdirs,
      entry_maker = function(entry)
        if entry == '[root]' then
          entry = '.'
        end
        if entry == '[Create directory ...]' then
          return {
            value = entry,
            display = entry,
            ordinal = entry,
          }
        end
        local path = Path:new(entry)
        return {
          value = tostring(vault_path / path),
          display = tostring(path),
          ordinal = tostring(path),
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    previewer = dir_previewer,
    attach_mappings = function(prompt_bufnr, _)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry().value

        print(selection)
        if selection == tostring(vault_path) then
          callback(vault_path)
        elseif selection == '[Create directory ...]' then
          vim.ui.input({ prompt = "New subdirectory (relative to vault): " }, function(input)
            if not input or input == '' then return end
            local new_dir = vault_path / input
            vim.fn.mkdir(tostring(new_dir), 'p')
            callback(new_dir)
          end)
        else
          callback(vault_path / selection)
        end
      end)
      return true
    end,
  }):find()
end

return M
