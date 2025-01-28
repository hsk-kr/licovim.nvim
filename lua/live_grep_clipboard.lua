local M = {}

local telescope = require("telescope")

local function get_recent_clipboard_content()
	local clipboard_content = vim.fn.getreg("+")

	return clipboard_content
end

local function open_live_grep_with_path()
	local copied_path = get_recent_clipboard_content()
	local current_path = vim.fn.getcwd()

	if #copied_path < #current_path then
		vim.notify("Check copied path. The path is supposed to be full path:" .. copied_path, vim.log.levels.ERROR)
		return
	end

	local path = '"" --iglob ' .. string.sub(copied_path, #current_path + 1) .. "**/*"

	telescope.extensions.live_grep_args.live_grep_args({
		default_text = path,
	})
end

M.open_live_grep_with_path = open_live_grep_with_path

return M
