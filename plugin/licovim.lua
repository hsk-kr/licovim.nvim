local live_grep = require("live_grep")
local upscope = require("upscope")

vim.api.nvim_create_user_command("LicovimLiveGrepWithClipboard", function()
	live_grep.open_live_grep_with_clipboard()
end, {})

vim.api.nvim_create_user_command("LicovimLiveGrepWithCurrentPath", function()
	live_grep.open_live_grep_with_current_path()
end, {})

vim.api.nvim_create_user_command("LicovimUpscopeTestCurrentFile", function()
	upscope.upscope_test_current_file()
end, {})
