local M = {};

M.state = {
    bullet_icon = "✤",
    toc_buf = nil,
    toc_win = nil,
    width_ratio = 0.4,
    height_ratio = 0.6,
}

local function generate_toc()
    local s = M.state
    local toc_lines = {}
    local mapping = {}

    -- read current buffer(0) form line start(0) to end(-1)
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    for line_num, line_content in ipairs(lines) do -- only the regex insdie the capture group will be returned %s stands for space
        local hashes, title = string.match(line_content, "^(#+)%s+(.*)")
        if hashes then
            -- create a indent consist of white space of length #level - 1
            -- #level is short for string.len(level)
            local indent = string.rep("   ", #hashes - 1)
            -- push the element into the table
            table.insert(toc_lines, indent .. s.bullet_icon .. "  " .. title)
            -- create mapping between toc buffer and current buffer
            mapping[#toc_lines] = line_num
        end
    end
    return toc_lines, mapping
end

local function close_toc()
    local s = M.state
    -- Toggle off
    vim.api.nvim_win_close(s.toc_win, true)
    s.toc_win = nil
    s.toc_buf = nil
    return
end

M.float_toc_toggle = function()
    local s = M.state
    -- Toggle off
    if s.toc_win and vim.api.nvim_win_is_valid(s.toc_win) then
        close_toc()
        return
    end

    -- Set up height and width of the new win
    local width = math.floor(vim.o.columns * s.width_ratio)
    local height = math.floor(vim.o.lines * s.height_ratio)

    -- generate TOC
    local toc_lines, mapping = generate_toc()

    -- whether to put it in the buffer list ? shown in :ls -> false
    -- whether the buffer is throwaway buffer(disposable)  -> true
    s.toc_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(s.toc_buf, 0, -1, false, toc_lines)

    -- get the correspondent toc element of current line
    local cur_line = vim.api.nvim_win_get_cursor(0)[1]

    -- open buffer and enter it as it opens
    s.toc_win = vim.api.nvim_open_win(s.toc_buf, true, {
        relative = 'editor',
        width = width,
        height = height,
        -- row is the position in Y axis
        -- ( vim_height - win_height ) / 2, create margin for top and bottom, which will center the win
        row = (vim.o.lines - height) / 2,
        col = (vim.o.columns - width) / 2,
        style = "minimal",
        border = 'rounded',
        title = " TOC ",
        title_pos = "center",
    })

    --debug: mapping
    -- for key, value in pairs(mapping) do
    --     print(key .. ":" .. value)
    -- end

    -- Jumping with <cr> key
    vim.keymap.set("n", "<cr>", function()
        local cursor = vim.api.nvim_win_get_cursor(s.toc_win);
        -- _ is the table index, cursor[1] = row, cursor[2] = column

        -- for _, content in ipairs(cursor) do
        --     print(_ .. "?\n")
        --     print(content)
        -- end
        local toc_line = cursor[1]
        local target_line = mapping[toc_line]

        -- Close TOC
        close_toc()

        -- 12.04.2025, remove `ori_win` variable
        -- Since the toc_buf, toc_win is now closed, win 0 is now
        -- the main buffer, we don't need to keep track of the ori_win anymore
        vim.api.nvim_set_current_win(0)
        -- {row = target_line, column = 0}
        vim.api.nvim_win_set_cursor(0, { target_line, 0 })
    end
    -- Make sure to add the keymap in toc_buf
    , { buffer = s.toc_buf })
end

return M
