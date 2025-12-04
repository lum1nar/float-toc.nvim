-- vim.notify("123456", vim.log.levels.INFO);
--
--
local M = {};

local function generate_toc()
    local toc = {}
    -- read current buffer(0) form line start(0) to end(-1)
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    for _, line in ipairs(lines) do
        -- only the regex insdie the capture group will be returned
        -- %s stands for space
        local level, title = string.match(line, "^(#+)%s+(.*)")
        if level then
            -- create a indent consist of white space of length #level - 1
            -- #level is short for string.len(level)
            local indent = string.rep("  ", #level - 1)
            -- push the element into the table
            table.insert(toc, indent .. "- " .. title);
        end
    end
    return toc
end

local function open_toc_float(toc_table)
    -- whether to put it in the buffer list ? shown in :ls -> false
    -- whether the buffer is throwaway buffer(disposable)  -> true
    local buf = vim.api.nvim_create_buf(false, true)

    -- set win height and width
    local width = 50;
    local height = #toc_table + 2;
    height = 20;
    -- open buffer and enter it as it opens
    print(string.format("line: %d, column: %d", vim.o.lines, vim.o.columns))
    local win = vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = width,
        height = height,
        -- row is the position in Y axis
        -- ( vim_height - win_height ) / 2, create margin for top and bottom, which will center the win
        row = (vim.o.lines - height) / 2,
        col = (vim.o.columns - width) / 2,
        -- style = "minimal",
        border = 'rounded',

    })
end

M.print = function()
    local toc_table = generate_toc();
    open_toc_float(toc_table);
    -- for _, element in ipairs(toc) do
    --     print(element);
    -- end
end

return M
