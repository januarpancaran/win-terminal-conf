vim.keymap.set("n", "j", "jzz")
vim.keymap.set("n", "k", "kzz")
vim.keymap.set("n", "{", "{zz")
vim.keymap.set("n", "}", "}zz")

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "<C-h>", "wincmd h<CR>")
vim.keymap.set("n", "<C-j>", "wincmd j<CR>")
vim.keymap.set("n", "<C-k>", "wincmd k<CR>")
vim.keymap.set("n", "<C-l>", "wincmd l<CR>")

-- lsp
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "LSP Hover" })
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
vim.keymap.set("n", "<leader>gf", function()
	vim.lsp.buf.format({ async = true })
end, { desc = "Format" })

-- telescope
vim.keymap.set("n", "<leader>ff", require("telescope.builtin").find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>fg", require("telescope.builtin").live_grep, { desc = "Telescope live grep" })

-- oil
vim.keymap.set("n", "<leader>pp", "<CMD>Oil<CR>", { desc = "Open parent directory" })

-- tresitter-context
vim.keymap.set("n", "[c", function()
	require("treesitter-context").go_to_context(vim.v.count1)
end, { silent = true })

-- markdown-preview
vim.keymap.set("n", "<C-m", "<CMD>MarkdownPreview<CR>", { desc = "Open markdown in browser" })

-- bufferline
local bufferline = require("bufferline")

vim.keymap.set("n", "<leader>1", function()
	bufferline.go_to(1, true)
end)
vim.keymap.set("n", "<leader>2", function()
	bufferline.go_to(2, true)
end)
vim.keymap.set("n", "<leader>3", function()
	bufferline.go_to(3, true)
end)
vim.keymap.set("n", "<leader>4", function()
	bufferline.go_to(4, true)
end)
vim.keymap.set("n", "<leader>5", function()
	bufferline.go_to(5, true)
end)
vim.keymap.set("n", "<leader>6", function()
	bufferline.go_to(6, true)
end)
vim.keymap.set("n", "<leader>7", function()
	bufferline.go_to(7, true)
end)
vim.keymap.set("n", "<leader>8", function()
	bufferline.go_to(8, true)
end)
vim.keymap.set("n", "<leader>9", function()
	bufferline.go_to(9, true)
end)
vim.keymap.set("n", "<leader>$", function()
	bufferline.go_to(-1, true)
end)

vim.keymap.set("n", "[b", "<CMD>BufferLineCycleNext<CR>")
vim.keymap.set("n", "b]", "<CMD>BufferLineCycleNext<CR>")
vim.keymap.set("n", "<leader>bmn", "<CMD>BufferLineMoveNext<CR>")
vim.keymap.set("n", "<leader>bmp", "<CMD>BufferLineMovePrev<CR>")
vim.keymap.set("n", "<leader>bse", "<CMD>BufferLineSortByExtension<CR>")
vim.keymap.set("n", "<leader>bsd", "<CMD>BufferLineSortByDirectory<CR>")
vim.keymap.set("n", "<leader>bw", function()
	vim.api.nvim_buf_delete(0, { force = false })
end, { desc = "Close current buffer" })
vim.keymap.set("n", "<leader>bsi", function()
	bufferline.sort_by(function(buf_a, buf_b)
		return buf_a.id < buf_b.id
	end)
end)
