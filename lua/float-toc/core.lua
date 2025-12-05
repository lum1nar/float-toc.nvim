local C = {}

C.float_toc_toggle = function(config, state, utils)
    -- Toggle off
    if state.toc_win and vim.api.nvim_win_is_valid(state.toc_win) then
        utils.close_toc(state)
        return
    end

    -- Generate TOC
    local toc_entries, toc_to_source_map = utils.generate_toc(config)

    -- Can't generate TOC
    if next(toc_entries) == nil then
        -- will this cause error if one doens't has nvim-notify.vim installed ?
        -- No, vanilla vim.notify supports opts argument by default, it has no use though
        vim.notify("Cannot Generate TOC !", vim.log.levels.ERROR, { title = "float-toc" })
        return
    end

    -- get the correspondent toc entry
    local toc_win_line_target = utils.find_toc_line_from_source(toc_to_source_map, toc_entries)

    -- whether to put it in the buffer list ? shown in :ls -> false
    -- whether the buffer is throwaway buffer(disposable)  -> true
    state.toc_buf = vim.api.nvim_create_buf(false, true)

    -- write toc_entries to the toc_buf
    vim.api.nvim_buf_set_lines(state.toc_buf, 0, -1, false, toc_entries)

    -- open buffer and enter it as it opens
    utils.win_open(config, state)

    -- enable curosr line highlight
    vim.api.nvim_set_option_value("cursorline", true, { win = state.toc_win })

    -- Jump to correspondent toc element
    vim.api.nvim_win_set_cursor(0, { toc_win_line_target, 0 })

    -- Jumping between toc and source_buf with <cr> key
    vim.keymap.set("n", "<cr>", function()
        local source_win_line_target = utils.find_source_line_from_toc(toc_to_source_map, toc_entries)

        -- close toc win and switch back to original win
        utils.close_toc(state)

        -- {row = target_line, column = 0}
        vim.api.nvim_win_set_cursor(0, { source_win_line_target, 0 })
    end
    -- Make sure to add the keymap in toc_buf instead of the current buf
    , { buffer = state.toc_buf })

    -- disable left,right navigation in toc_buffer
    vim.keymap.set("n", "h", "<NOP>", { buffer = state.toc_buf })
    vim.keymap.set("n", "l", "<NOP>", { buffer = state.toc_buf })
end

return C
