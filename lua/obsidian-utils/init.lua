-- lua/obsidian-utils/init.lua

local M = {}

local config = require('obsidian-utils.config')
local note = require('obsidian-utils.note')
local dir = require('obsidian-utils.directory')
local template = require('obsidian-utils.template')


--- Setup the plugin with user-defined configuration.
--- @param opts table?
function M.setup(opts)
  config.setup(opts)
end

--- launce the interactive note creation workflow
function M.create_note()
  local client = require('obsidian').get_client()
  local vault_path = require('obsidian.path'):new(client:vault_root())
  local template_path = config.get_template_path(client, vault_path)

  dir.select(vault_path, function(selected_dir)
    template.select(template_path, function(selected_template)
      note.create(client, selected_dir, selected_template)
    end)
  end)
end

return M
