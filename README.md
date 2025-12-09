# Float TOC — A Tiny Floating Table-of-Contents for Neovim

![demo](./static/demo.png) A minimal, modern, floating Table-of-Contents (TOC) viewer for Markdown in Neovim. Open a lightweight floating window that shows your document headings, jump instantly, and keep your writing or note‑taking workflow clean.
No heavy UI. No complex setup. Just a smooth TOC.

## ✨ Features

- 🪶 **Floating TOC window** — stays out of your way
- 🧭 **Jump to headings** with a single press
- ⚙️ **Simple configuration** — tweak icons, width/height ratio, and indentation
- 💡 **Great for note‑taking, documentation, technical writing**

## 📦 Installation

Lazy.nvim example:

```lua
{
    "lum1nar/float-toc",
    config = function()
        require("float-toc").setup()
    end,
}
```

## ⚙️ Setup

```lua
require("float-toc").setup({
    bullet_icon = "⁍",   -- Icon used before each heading
    -- Example: `"•"`, `"→"`, `"#"`, `"▸"`
    indent_width = 3,      -- Spaces added per heading level
    width_ratio = 0.4,     -- TOC window width relative to editor
    height_ratio = 0.6,    -- TOC window height relative to editor
})
```

```lua
# Add Custom Keymap
vim.keymap.set("n", "<leader>t", "<cmd>lua require('float-toc').toggle()<cr>")
```

All values are optional — the defaults work out of the box.

:warning: You have to run the setup command for :FloatTOC to work

## 🚀 Usage

Open the floating TOC:

```vim
:FloatTOC
```

Enjoy a blazingly fast Markdown workflow!
