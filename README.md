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

LicovimLiveGrepWithPath: open live grep with --iglob options based on copied string

If the copied path is `/etc/` then the string will be

`"" --iglob /etc/**/*`

<b>Example</b>

```
vim.api.nvim_set_keymap("n", "<leader>fp", ":LicovimLiveGrepWithPath<CR>", { noremap = true, silent = true })
```
