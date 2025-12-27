return {
	"zbirenbaum/copilot.lua",
	dependencies = {
		"copilotlsp-nvim/copilot-lsp",
	},
	config = function()
		require("copilot").setup({
			suggestion = { enabled = false },
			panel = { enabled = false },
			server_opts_overrides = {
				settings = {
					telemetry = {
						telemetryLevel = "off",
					},
				},
			},
		})
	end,
}
