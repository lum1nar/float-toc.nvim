require("floating-toc")

vim.notify = require("notify")
-- vim.notify("123", vim.log.levels.INFO)
vim.keymap.set("n", "<leader>t", "<cmd>lua require('floating-toc').float_toc_toggle()<cr>")
