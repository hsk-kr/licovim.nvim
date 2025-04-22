local live_grep = require("live_grep")
local upscope = require("upscope")

vim.api.nvim_create_user_command("LicovimLiveGrepWithClipboard", function()
	live_grep.open_live_grep_with_clipboard()
end, {})

vim.api.nvim_create_user_command("LicovimLiveGrepWithCurrentPath", function()
	live_grep.open_live_grep_with_current_path()
end, {})

vim.api.nvim_create_user_command("LicovimTestRunnerRun", function()
	upscope.upscope_test_current_file()
end, {})

vim.api.nvim_create_user_command("LicovimTestRunnerToggle", function()
	upscope.toggle_sidebar()
end, {})

vim.api.nvim_create_user_command("LicovimTestRunnerClean", function()
	upscope.close_output()
end, {})

vim.api.nvim_create_user_command("LicovimTestRunnerClose", function()
	upscope.close_sidebar()
end, {})