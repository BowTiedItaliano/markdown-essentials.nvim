# Markdown Essentials for LazyVim

A simple Neovim plugin that enhances markdown editing in LazyVim with essential formatting operations in both normal and visual mode.

## Features

- Toggle text formatting:
  - Bold (`**text**`)
  - Italic (`*text*`)
- Manage todo items:
  - Toggle todo status (`- [ ] text`)
  - Toggle todo completion (`- [x] text`)
- Lists management:
  - Toggle bullet lists (`- text`)
  - Toggle numbered lists (`1. text`)
- Headers:
  - Convert text to headers (levels 1-3)
  - Convert formatted text back to normal text

All operations work in both normal mode (on current line) and visual mode (on selected text).

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

Add to your LazyVim configuration:

```lua
return {
  "BowTiedItaliano/markdown-essentials.nvim",
  event = "VeryLazy",
  ft = { "markdown" },
  config = function()
    require("markdown-essentials").setup()
  end,
}
```

## Default Keymappings

| Mode          | Keybinding    | Action                |
|---------------|---------------|----------------------|
| Normal/Visual | `<leader>mb`  | Toggle bold          |
| Normal/Visual | `<leader>mi`  | Toggle italic        |
| Normal/Visual | `<leader>mt`  | Toggle todo          |
| Normal/Visual | `<leader>md`  | Toggle todo done     |
| Normal/Visual | `<leader>ml`  | Toggle bullet list   |
| Normal/Visual | `<leader>mn`  | Toggle numbered list |
| Normal/Visual | `<leader>m1`  | Make header level 1  |
| Normal/Visual | `<leader>m2`  | Make header level 2  |
| Normal/Visual | `<leader>m3`  | Make header level 3  |
| Normal/Visual | `<leader>m0`  | Make normal text     |

## Configuration

You can customize the keymappings:

```lua
require("markdown-essentials").setup({
  keymaps = {
    toggle_bold = "<leader>xb",
    toggle_italic = "<leader>xi",
    toggle_todo = "<leader>xt",
    toggle_todo_done = "<leader>xd",
    toggle_bullet = "<leader>xl",
    toggle_numbered = "<leader>xn",
    make_header1 = "<leader>x1",
    make_header2 = "<leader>x2",
    make_header3 = "<leader>x3",
    make_normal = "<leader>x0",
  },
  -- Set to false to disable auto-commands
  auto_commands = true,
})
```

## License

MIT
