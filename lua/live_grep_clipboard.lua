local M = {}

local telescope = require("telescope")

local function get_recent_clipboard_content()
	local clipboard_content = vim.fn.getreg("+")

	return clipboard_content
end

local function open_live_grep_with_path()
	local copied_path = get_recent_clipboard_content()
	local current_path = vim.fn.getcwd()

	local starts_with_root = string.sub(copied_path, 1, #current_path) == current_path

	local path = starts_with_root and string.sub(copied_path, #current_path + 1) or copied_path

	local default_text = '"" --iglob ' .. path .. "**/*"

	telescope.extensions.live_grep_args.live_grep_args({
		default_text = default_text,
	})
end

M.open_live_grep_with_path = open_live_grep_with_path

return M
