return {
	"nvimtools/none-ls.nvim",
	dependencies = { "nvimtools/none-ls-extras.nvim" },
	config = function()
		local null_ls = require("null-ls")
		local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

		local on_attach = function(client, bufnr)
			if client.supports_method("textDocument/formatting") then
				vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
				vim.api.nvim_create_autocmd("BufWritePre", {
					group = augroup,
					buffer = bufnr,
					callback = function()
						vim.lsp.buf.format({ async = false })
					end,
				})
			end
		end

		null_ls.setup({
			sources = {
				-- Bash
				null_ls.builtins.formatting.shfmt,

				-- C / C++
				null_ls.builtins.formatting.clang_format,

				-- CSS/Markdown/TS/Svelte
				null_ls.builtins.formatting.prettierd,
				null_ls.builtins.formatting.prettier,

				-- Java
				null_ls.builtins.formatting.google_java_format,

				-- Lua
				null_ls.builtins.formatting.stylua,

				-- Go
				null_ls.builtins.formatting.gofumpt,

				-- Python
				null_ls.builtins.formatting.black,
				null_ls.builtins.formatting.isort,

				-- Rust
				require("none-ls.formatting.rustfmt"),

				-- SQL
				null_ls.builtins.formatting.sqlfluff,
			},
			on_attach = on_attach,
		})
	end,
}
