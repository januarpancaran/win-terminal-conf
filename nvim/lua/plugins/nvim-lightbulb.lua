return {
	"kosayoda/nvim-lightbulb",
	config = function()
		local lightbulb = require("nvim-lightbulb")

		vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
			group = vim.api.nvim_create_augroup("LightBulb", {}),
			callback = function()
				lightbulb.update_lightbulb()
			end,
		})
	end,
}
