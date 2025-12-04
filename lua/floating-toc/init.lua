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
end

M.float_toc_toggle = function()
    local s = M.state
    -- Toggle off
    if s.toc_win and vim.api.nvim_win_is_valid(s.toc_win) then
        close_toc()
        return
    end

    -- Set up height and width of the new win
    -- use math.floor to ensure an integer value
    local width = math.floor(vim.o.columns * s.width_ratio)
    local height = math.floor(vim.o.lines * s.height_ratio)

    -- Generate TOC
    local toc_lines, mapping = generate_toc()

    if next(toc_lines) == nil then
        -- will this cause error if one doens't has nvim-notify.vim installed ?
        -- No, vanilla vim.notify supports opts argument by default, it has no use though
        vim.notify("Cannot Generate TOC !", vim.log.levels.ERROR, { title = "float-toc" })
        return
    end

    -- get the correspondent toc element of current line
    local cur_line = vim.api.nvim_win_get_cursor(0)[1]
    local toc_target = 1
    local last_toc_idx = 1
    local found_toc_target = false

    for toc_idx, buf_line in ipairs(mapping) do
        if buf_line == cur_line then
            toc_target = toc_idx
            found_toc_target = true
            break
        elseif buf_line > cur_line then
            toc_target = last_toc_idx
            found_toc_target = true
            break
        end
        last_toc_idx = toc_idx
    end

    -- EDGE CASE: the last hash
    if not found_toc_target then
        toc_target = #toc_lines
    end

    -- whether to put it in the buffer list ? shown in :ls -> false
    -- whether the buffer is throwaway buffer(disposable)  -> true
    s.toc_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(s.toc_buf, 0, -1, false, toc_lines)

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
        title = " Table of Content ",
        title_pos = "center",
    })

    -- enable curosr line highlight
    vim.api.nvim_set_option_value("cursorline", true, { win = s.toc_win })

    -- make the cursor invisible

    -- Jump to correspondent toc element
    vim.api.nvim_win_set_cursor(0, { toc_target, 0 })

    --debug: mapping
    -- for key, value in pairs(mapping) do
    --     print(key .. ":" .. value)
    -- end

    -- Jumping with <cr> key
    vim.keymap.set("n", "<cr>", function()
        local cursor = vim.api.nvim_win_get_cursor(s.toc_win);
        local toc_line = cursor[1]
        local ori_target = mapping[toc_line]

        -- close toc win and switch back to original win
        close_toc()

        -- 12.04.2025, remove `ori_win` variable
        -- Since the toc_buf, toc_win is now closed, win 0 is now
        -- the main buffer, we don't need to keep track of the ori_win anymore
        vim.api.nvim_set_current_win(0)
        -- {row = target_line, column = 0}
        vim.api.nvim_win_set_cursor(0, { ori_target, 0 })
    end
    -- Make sure to add the keymap in toc_buf instead of the current buf
    , { buffer = s.toc_buf })
end

return M
