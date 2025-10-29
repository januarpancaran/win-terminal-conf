if vim.g.vscode then
	require("plugins.comment-nvim")
	require("plugins.indent-blankline")
	require("plugins.markdown-preview-nvim")
	require("plugins.nvim-treesitter-context")
	require("plugins.rainbow-delimiters-nvim")

	require("config.options")
	require("config.mappings")
else
	require("config.lazy")
	require("config.options")
	require("config.mappings")
end
