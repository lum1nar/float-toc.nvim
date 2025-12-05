local U = {};

U.generate_toc = function(config)
    local toc_entries = {}
    local toc_to_source_map = {}

    -- read current buffer(0) form line start(0) to end(-1)
    local source_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    for line_num, line_text in ipairs(source_lines) do -- only the regex insdie the capture group will be returned %s stands for space
        -- if the string only contains hash, or there's no space between hash and title
        -- the match will fail, e.g #, ##, #h1, ##h2
        local heading_level, title = string.match(line_text, "^(#+)%s+(.*)")
        if heading_level and title then
            -- create a indent consist of white space of length #level - 1
            -- #level is an abbr for string.len(level)
            local indent = string.rep(" ", config.indent_width)
            local full_indent = string.rep(indent, #heading_level - 1)
            -- push the element into the table
            table.insert(toc_entries, full_indent .. config.bullet_icon .. " " .. title)
            -- create mapping between toc buffer and current buffer
            toc_to_source_map[#toc_entries] = line_num
        end
    end
    return toc_entries, toc_to_source_map
end

U.close_toc = function(state)
    vim.api.nvim_win_close(state.toc_win, true)
    state.toc_win = nil
    state.toc_buf = nil
end

U.find_toc_line_from_source = function(toc_to_source_map, toc_entries)
    local source_win_cur_line = vim.api.nvim_win_get_cursor(0)[1]
    local toc_win_line_target = 1
    local prev_toc_index = 1
    local has_toc_target = false

    for toc_index, toc_buf_line in ipairs(toc_to_source_map) do
        if toc_buf_line == source_win_cur_line then
            toc_win_line_target = toc_index
            has_toc_target = true
            break
        elseif toc_buf_line > source_win_cur_line then
            toc_win_line_target = prev_toc_index
            has_toc_target = true
            break
        end
        prev_toc_index = toc_index
    end

    -- EDGE CASE: the last hash
    if not has_toc_target then
        toc_win_line_target = #toc_entries
    end
    return toc_win_line_target
end

U.find_source_line_from_toc = function(toc_to_source_map, toc_entries)
    local toc_win_cur_line = vim.api.nvim_win_get_cursor(0)[1];
    local source_win_line_target = toc_to_source_map[toc_win_cur_line]
    return source_win_line_target
end

U.win_open = function(config, state)
    -- Set up height and width of the new win
    -- use math.floor to ensure an integer value
    local toc_win_width = math.floor(vim.o.columns * config.width_ratio)
    local toc_win_height = math.floor(vim.o.lines * config.height_ratio)

    state.toc_win = vim.api.nvim_open_win(state.toc_buf, true, {
        relative = 'editor',
        width = toc_win_width,
        height = toc_win_height,
        -- row is the position in Y axis
        -- ( vim_height - win_height ) / 2, create margin for top and bottom, which will center the win
        row = (vim.o.lines - toc_win_height) / 2,
        col = (vim.o.columns - toc_win_width) / 2,
        style = "minimal",
        border = 'rounded',
        title = " Table of Content ",
        title_pos = "center",
    })
end

return U
