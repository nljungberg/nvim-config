# Neovim Configuration Cheat Sheet

This README documents all the custom key mappings defined in your `init.lua` so you can quickly reference what each one does.

---

## Leader Key

* **`<Space>`**: Set as the global leader key in Normal and Visual modes.

---

## General Key Mappings

| Keybinding   | Mode   | Action                              |
| ------------ | ------ | ----------------------------------- |
| `<leader>e`  | Normal | Toggle NvimTree file explorer       |
| `<leader>ff` | Normal | Telescope: Find files               |
| `<leader>fg` | Normal | Telescope: Live grep                |
| `<leader>fb` | Normal | Telescope: List open buffers        |
| `<leader>fh` | Normal | Telescope: Search help tags         |
| `<C-z>`      | Normal | Undo last change                    |
| `<C-S-z>`    | Normal | Redo last undone change             |
| `<leader>gp` | Normal | Gitsigns: Preview current hunk      |
| `<leader>gb` | Normal | Gitsigns: Toggle current line blame |

---

## LSP Key Mappings (Buffer-local)

*(Active when an LSP attaches to the buffer)*

| Keybinding   | Mode   | Action                             |
| ------------ | ------ | ---------------------------------- |
| `gd`         | Normal | Go to definition                   |
| `gD`         | Normal | Go to declaration                  |
| `gr`         | Normal | Find references                    |
| `K`          | Normal | Hover documentation                |
| `<leader>rn` | Normal | Rename symbol                      |
| `<leader>ca` | Normal | Code action                        |
| `<leader>sd` | Normal | Show diagnostics (floating window) |
| `[d`         | Normal | Jump to previous diagnostic        |
| `]d`         | Normal | Jump to next diagnostic            |

---

## Additional Configuration Notes

* **Treesitter**: Provides enhanced syntax highlighting and indentation. Parsers auto-install on file open.
* **True-color support**: Enabled via `vim.opt.termguicolors = true` for themes and plugins.
* **Theme**: Dracula color scheme applied automatically on startup.
* **Autocompletion**: Powered by `nvim-cmp` with snippet support (`LuaSnip`) and various sources (LSP, buffer, path, Copilot).
* **UI Tweaks**: Line numbers, relative numbers, sign column, and cursor line are enabled by default.

---

Feel free to customize or rebind any of these keys by editing your `~/.config/nvim/init.lua`.

