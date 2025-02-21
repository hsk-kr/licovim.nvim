# Install

```
return {
	{
		"hsk-kr/licovim.nvim",
		dependencies = {
			"nvim-telescope/telescope.nvim",
			"nvim-telescope/telescope-live-grep-args.nvim",
		},
	},
}
```

# Commands

| Name                           | Description                                            |
| ------------------------------ | ------------------------------------------------------ |
| LicovimLiveGrepWithClipboard   | open live grep with clipboard string as --iglob option |
| LicovimLiveGrepWithCurrentPath | open live grep with current path as --iglob option     |

If the copied path is `/etc/` then the string will be

`"" --iglob /etc/**/*`

<b>Example</b>

```
vim.api.nvim_set_keymap("n", "<leader>fp", ":LicovimLiveGrepWithClipboard<CR>", { noremap = true, silent = true })
```
