local live_grep_clipboard = require("custom_plugins.licovim.lua.live_grep_clipboard")

vim.api.nvim_create_user_command("LicovimLiveGrepWithPath", function()
	live_grep_clipboard.open_live_grep_with_path()
end, {})
