-- create :FloatTOC command
vim.api.nvim_create_user_command("FloatTOC", function()
    require("float-toc").toggle()
end, {})
