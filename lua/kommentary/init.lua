--[[--
Initialization.

This module handles the initialization of the plugin.
]]
local kommentary = require("kommentary.kommentary")

--[[--
Toggle comment on current line, selection or motion.
@tparam string ... Optional string indicating the mode to choose, 'single_line'
	will operate on the current line, 'visual' will use the current visual
	selection, otherwise it will assume a motion (Arguments will be
	automatically passed by operatorfunc).
@treturn ?string|nil If called without arguments, it sets itself as operatorfunc
	and returns 'g@' to be used in an expression mapping, otherwise it will
	comment out and not return anything.
]]
local function toggle_comment(...)
    local args = {...}
    --[[ When called without any arguments (gc), return g@ (Which will be inserted
    into the mapping literaly, since the mapping is an <expr>, so you have gc
    will enter g@), before that set operatorfunc, which is the function that
    will be called after a motion, when you entered g@ before. So finally,
    typing gc will be as if you typed g@, then you can do a motion like 5j,
    now the operatorfunc gets called and has information about the motion,
    such as the range on which the motion operated. See :h operatorfunc. ]]
    if #args <= 0 then
        vim.api.nvim_set_option('operatorfunc', 'v:lua.kommentary.toggle_comment')
        return "g@"
    end
    --[[ Special argument passed by <Plug>KommentaryLine (gcc) to operate
    on just the current line ]]
    if args[1] == "single_line" then
        local row = vim.api.nvim_win_get_cursor(0)[1]
        kommentary.toggle_comment_line(row)
    elseif args[1] == "visual" then
        local line_number_start = vim.fn.getpos('v')[2]
        local line_number_end = vim.fn.getcurpos()[2]
        kommentary.toggle_comment_range(line_number_start, line_number_end)
    else
        --[[ When using g@, the marks [ and ] will contain the position of the
        start and the end of the motion, respectively. vim.fn.getpos() returns
        a tuple with the line and column of the position. ]]
        local line_number_start = vim.fn.getpos("'[")[2]
        local line_number_end = vim.fn.getpos("']")[2]
        kommentary.toggle_comment_range(line_number_start, line_number_end)
    end
end

return {
    toggle_comment = toggle_comment,
}
