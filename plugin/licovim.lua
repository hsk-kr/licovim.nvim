local live_grep_clipboard = require("live_grep_clipboard")
local upscope = require("upscope")

vim.api.nvim_create_user_command("LicovimLiveGrepWithPath", function()
	live_grep_clipboard.open_live_grep_with_path()
end, {})

vim.api.nvim_create_user_command("LicovimUpscopeTestCurrentFile", function()
	upscope.upscope_test_current_file()
end, {})
