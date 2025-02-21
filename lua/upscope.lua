local M = {}

local function get_current_file_relative_path()
	local current_file = vim.fn.expand("%:p")
	return vim.fn.fnamemodify(current_file, ":.")
end

local function get_output_window()
	-- Check if the output buffer and window already exist and are valid
	if
		M.output_buf
		and vim.api.nvim_buf_is_valid(M.output_buf)
		and M.output_win
		and vim.api.nvim_win_is_valid(M.output_win)
	then
		return M.output_buf, M.output_win
	end

	-- Create a new empty buffer
	M.output_buf = vim.api.nvim_create_buf(false, true)

	-- Define window dimensions
	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.8)
	local row = math.floor(vim.o.lines * 0.1)
	local col = math.floor(vim.o.columns * 0.1)

	-- Create a floating window
	M.output_win = vim.api.nvim_open_win(M.output_buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "single",
	})

	-- Set up an autocommand to close the window when the buffer is left
	vim.api.nvim_create_autocmd("BufLeave", {
		buffer = M.output_buf,
		callback = function()
			if vim.api.nvim_win_is_valid(M.output_win) then
				vim.api.nvim_win_close(M.output_win, true)
			end
			-- Invalidate the buffer and window references
			M.output_buf = nil
			M.output_win = nil
		end,
	})

	return M.output_buf, M.output_win
end

local function upscope_test_current_file()
	local relative_path = get_current_file_relative_path()
	if relative_path == "" then
		print("No file detected.")
		return
	end
	local command = { "upscope", "test", "api", "-t", relative_path }

	-- Get or create the output window
	local output_buf, output_win = get_output_window()

	-- Clear previous content
	vim.api.nvim_buf_set_lines(output_buf, 0, -1, false, {})

	-- Start the job asynchronously
	vim.fn.jobstart(command, {
		stdout_buffered = false,
		on_stdout = function(_, data)
			if data then
				-- Append new lines to the buffer
				vim.api.nvim_buf_set_lines(output_buf, -1, -1, false, data)
				-- Scroll to the bottom of the window
				vim.api.nvim_win_set_cursor(output_win, { vim.api.nvim_buf_line_count(output_buf), 0 })
			end
		end,
		on_stderr = function(_, data)
			if data then
				-- Append error lines to the buffer
				vim.api.nvim_buf_set_lines(output_buf, -1, -1, false, data)
				-- Scroll to the bottom of the window
				vim.api.nvim_win_set_cursor(output_win, { vim.api.nvim_buf_line_count(output_buf), 0 })
			end
		end,
		on_exit = function()
			-- Optionally, you can handle actions after the process exits
			vim.api.nvim_buf_set_lines(output_buf, -1, -1, false, { "\nProcess exited." })
		end,
	})
end

M.upscope_test_current_file = upscope_test_current_file

return M
