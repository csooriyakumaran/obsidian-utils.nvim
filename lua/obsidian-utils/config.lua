-- lua/obsidian-utils/config.lua


local M = {}

M.defaults = {
  exclude_dirs = { '.git', '.obsidian' },
  template_dir = nil,
  open_method = 'floating',
  floating_opts = {
    width = math.floor(vim.o.columns * 0.6),
    height = math.floor(vim.o.lines * 0.8),
    row = math.floor(vim.o.lines * 0.1),
    col = math.floor(vim.o.columns * 0.2),
    border = 'rounded',
  }
}

M.values = {}

--- Setup user configuration.
--- @param opts table?
function M.setup(opts)
  opts = opts or {}
  M.values.open_method = opts.open_method or M.defaults.open_method
  M.values.floating_opts = vim.tbl_deep_extend('force', M.defaults.floating_opts, opts.floating_opts or {})
  M.values.exclude_dirs = opts.exclude_dirs or M.defaults.exclude_dirs
  M.values.template_dir = opts.template_dir or M.defaults.template_dir
end

--- Resolve the effective template directory path
---@param client obsidian.Client
---@param vault_path obsidian.Path
---@return obsidian.Path
function M.get_template_path(client, vault_path)
  local obsidian_opts = client.opts
  local dir = M.values.template_dir
      or (obsidian_opts.templates and obsidian_opts.templates.folder)
      or 'templates'
  return vault_path / dir
end

return M
