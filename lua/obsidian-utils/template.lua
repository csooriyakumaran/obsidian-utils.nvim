-- lua/obsidian-utils/template.lua

local M = {}

local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local previewers = require('telescope.previewers')
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local conf = require('telescope.config').values

--- Find templates in the template directory
--- @param template_dir obsidian.Path
--- @return table
local function get_templates(template_dir)
  local result = {}
  local handle = vim.uv.fs_scandir(tostring(template_dir))
  while handle do
    local name, type = vim.uv.fs_scandir_next(handle)
    if not name then break end
    if type == 'file' and name:match('%.md$') then
      table.insert(result, name)
    end
  end
  return result
end

--- Prompt the user to select a template
--- @param template_dir obsidian.Path
--- @param callback fun(template: string)
function M.select(template_dir, callback)
  local templates = get_templates(template_dir)
  table.insert(templates, '[no template]')


  pickers.new({}, {
    prompt_title = 'Select Template',
    finder = finders.new_table({
      results = templates,
      entry_maker = function(path)
        return {
          value = path,
          filename = tostring(template_dir / path),
          display = path,
          ordinal = path,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    previewer = previewers.vim_buffer_cat.new({
      define_preview = function(self, entry, status)
        previewers.utils.buffer_previewer_maker(entry.value, self.state.bufnr, {
          bufname = entry.value,
          winid = status.preview_win,
        })
      end,
    }),
    attach_mappings = function(template_bufnr, _)
      actions.select_default:replace(function()
        actions.close(template_bufnr)
        local template = action_state.get_selected_entry()
        if template.value == '[no template]' then
          callback('')
        else
          callback(template.value)
        end
      end)
      return true
    end,
  }):find()
end

return M
