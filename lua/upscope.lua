local M = {}

local function get_current_file_relative_path()
	local current_file = vim.fn.expand("%:p")
	return vim.fn.fnamemodify(current_file, ":.")
end

local function upscope_test_current_file()
	local relative_path = get_current_file_relative_path()
	if relative_path == "" then
		print("No file detected.")
		return
	end
	local command = "upscope api test -t " .. vim.fn.shellescape(relative_path)
	local output = vim.fn.system(command)
	vim.api.nvim_open_win(vim.api.nvim_create_buf(false, true), true, {
		relative = "editor",
		width = math.floor(vim.o.columns * 0.5),
		height = math.floor(vim.o.lines * 0.3),
		row = math.floor(vim.o.lines * 0.35),
		col = math.floor(vim.o.columns * 0.25),
		style = "minimal",
		border = "single",
	})
	vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(output, "\n"))
end

M.upscope_test_current_file = upscope_test_current_file

return M
