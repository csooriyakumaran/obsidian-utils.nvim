# obsidian-utils.nvim

Supplies helper functions for the [`obsidian.nvim`](https://github.com/epwalsh/obsidian.nvim) plugin. User configurations are largely imported from `obsidian.nvim`. 

[!NOTE] This does not need to be a plugin, but I wanted to learn to author plugins for [`Neovim`](https://neovim.io/)

## Installation

##### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
    'csooriyakumaran/obsidian-utils.nvim',
    dependencies = {
        'epwalsh/obsidian.nvim',
        'nvim-telescope/telescope.nvim',
    },
    opts = {
            -- optional overrides
            -- template_dir = 'templates',
            -- exclude_dirs = { '.git', '.obsidian'}
    }
    config = function(_, opts)
        require('obsidian-utils').setup(opts)

        vim.keymap.set('n', '<leader>on', function()
            require('obsidian-utils').create_note()
            end, { desc = '[O]bsidian [N]ew note from template'}
        )
    end,

}
```

## Configuration

```lua
-- default opts
{
    -- an override to obisidian.nvim templates.folder
    template_dir = nil, 

    -- directories to exclude from the search when selecting note directory
    exclude_dirs = {'.git', '.obsidian'}
}
```

## Note Creation

I found it difficult to create a note in a desired subdirectory so this uses telescope to provide a picker for existing subdirectories in the active workspace vault. 

- 📁 Select or create subdirectories interactively
- 🧩 Choose from available templates with preview
- ✍️ Prompt for a note title and open it in a new split
- 🔌 Integrates directly with `obsidian.nvim` workspaces and config
