require("float-toc").setup({
    bullet_icon = "⁍",
    indent_width = 4,

})

vim.notify = require("notify")
-- vim.notify("123", vim.log.levels.INFO)
vim.keymap.set("n", "<leader>t", "<cmd>lua require('float-toc').toggle()<cr>")
