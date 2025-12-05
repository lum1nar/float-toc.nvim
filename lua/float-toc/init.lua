local M = {}

local config = require("float-toc.config")
local utils = require("float-toc.utils")
local core = require("float-toc.core")

M.state = {
    toc_buf = nil,
    toc_win = nil,
}

M.setup = function(opts)
    opts = opts or {}
    -- merge table
    -- force mode, if one key has multiple values, the one from
    -- the rightmost table will be chosen
    config = vim.tbl_deep_extend("force", config, opts)

    -- create :FloatTOC command
    vim.api.nvim_create_user_command("FloatTOC", function()
        M.toggle()
    end, {})
end

M.toggle = function()
    core.float_toc_toggle(config, M.state, utils)
end

return M
