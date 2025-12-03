-- vim.notify("123456", vim.log.levels.INFO);
--
--
local M = {};

M.print = function()
    vim.notify("Inside print function")
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    for _, line in ipairs(lines) do
        print(line);
    end
end

return M
