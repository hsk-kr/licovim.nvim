local M = {}

local telescope = require("telescope")

local function get_recent_clipboard_content()
	local clipboard_content = vim.fn.getreg("+")

	return clipboard_content
end

local function open_live_grep(path)
	local default_text = '"" --iglob ' .. path

	telescope.extensions.live_grep_args.live_grep_args({
		default_text = default_text,
	})
end

local function get_current_file_relative_path()
	local current_file = vim.fn.expand("%:p")
	return vim.fn.fnamemodify(current_file, ":.")
end

local function open_live_grep_with_current_path()
	open_live_grep(get_current_file_relative_path())
end

local function open_live_grep_with_clipboard()
	local copied_path = get_recent_clipboard_content()
	local current_path = vim.fn.getcwd()

	local starts_with_root = string.sub(copied_path, 1, #current_path) == current_path

	local path = starts_with_root and string.sub(copied_path, #current_path + 1) or copied_path

	if string.sub(path, -1) ~= "/" then
		path = path .. "/"
	end

	open_live_grep(path .. "**/*")
end

M.open_live_grep_with_clipboard = open_live_grep_with_clipboard
M.open_live_grep_with_current_path = open_live_grep_with_current_path
return M
