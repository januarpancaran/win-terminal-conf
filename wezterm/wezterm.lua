local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

-- Appearance
config.color_scheme = "Tokyo Night"
config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 12.0
config.window_decorations = "TITLE | RESIZE"

-- Start maximized
wezterm.on("gui-startup", function()
	local _, _, window = wezterm.mux.spawn_window({})
	window:gui_window():maximize()
end)
config.default_cwd = wezterm.home_dir

-- Shell
config.default_prog = { "pwsh.exe", "-NoLogo" }

-- Mouse
config.mouse_bindings = {
	{
		event = { Down = { streak = 1, button = "Right" } },
		mods = "NONE",
		action = act.PasteFrom("Clipboard"),
	},
}

-- Tab bar
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.hide_tab_bar_if_only_one_tab = false
config.tab_max_width = 32

-- Catppuccin Mocha-inspired tab bar colors
config.colors = {
	tab_bar = {
		background = "#1e1e2e",
		active_tab = {
			bg_color = "#cba6f7",
			fg_color = "#1e1e2e",
			intensity = "Bold",
		},
		inactive_tab = {
			bg_color = "#313244",
			fg_color = "#cdd6f4",
		},
		inactive_tab_hover = {
			bg_color = "#45475a",
			fg_color = "#cdd6f4",
		},
		new_tab = {
			bg_color = "#1e1e2e",
			fg_color = "#6c7086",
		},
		new_tab_hover = {
			bg_color = "#313244",
			fg_color = "#cdd6f4",
		},
	},
}

-- Status bar: show workspace (session) and active pane title on the right
wezterm.on("update-status", function(window, pane)
	local workspace = window:active_workspace()
	local pane_title = pane:get_title()
	window:set_right_status(wezterm.format({
		{ Foreground = { Color = "#1e1e2e" } },
		{ Background = { Color = "#89b4fa" } },
		{ Text = "  " .. pane_title .. " " },
		{ Foreground = { Color = "#1e1e2e" } },
		{ Background = { Color = "#cba6f7" } },
		{ Text = "  " .. workspace .. " " },
	}))
end)

-- Keyboard bindings
-- All use CTRL+SPACE as prefix equivalent (Leader)
config.leader = { key = "Space", mods = "CTRL", timeout_milliseconds = 1000 }

config.keys = {
	-- Reload config: Leader + r
	{
		key = "r",
		mods = "LEADER",
		action = act.ReloadConfiguration,
	},

	-- Split vertically (horizontal bar): Leader + "
	{
		key = '"',
		mods = "LEADER",
		action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
	},

	-- Split horizontally (vertical bar): Leader + %
	{
		key = "%",
		mods = "LEADER",
		action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},

	-- Pane navigation: Leader + hjkl
	{
		key = "h",
		mods = "LEADER",
		action = act.ActivatePaneDirection("Left"),
	},
	{
		key = "j",
		mods = "LEADER",
		action = act.ActivatePaneDirection("Down"),
	},
	{
		key = "k",
		mods = "LEADER",
		action = act.ActivatePaneDirection("Up"),
	},
	{
		key = "l",
		mods = "LEADER",
		action = act.ActivatePaneDirection("Right"),
	},

	-- vim-tmux-navigator style: CTRL+hjkl without leader
	{
		key = "h",
		mods = "CTRL",
		action = act.ActivatePaneDirection("Left"),
	},
	{
		key = "j",
		mods = "CTRL",
		action = act.ActivatePaneDirection("Down"),
	},
	{
		key = "k",
		mods = "CTRL",
		action = act.ActivatePaneDirection("Up"),
	},
	{
		key = "l",
		mods = "CTRL",
		action = act.ActivatePaneDirection("Right"),
	},

	-- New tab: Leader + c
	{
		key = "c",
		mods = "LEADER",
		action = act.SpawnTab("CurrentPaneDomain"),
	},

	-- Next/prev tab: Leader + n/p
	{
		key = "n",
		mods = "LEADER",
		action = act.ActivateTabRelative(1),
	},
	{
		key = "p",
		mods = "LEADER",
		action = act.ActivateTabRelative(-1),
	},

	-- Jump to tab by number (1-9): Leader + 1..9
	{ key = "1", mods = "LEADER", action = act.ActivateTab(0) },
	{ key = "2", mods = "LEADER", action = act.ActivateTab(1) },
	{ key = "3", mods = "LEADER", action = act.ActivateTab(2) },
	{ key = "4", mods = "LEADER", action = act.ActivateTab(3) },
	{ key = "5", mods = "LEADER", action = act.ActivateTab(4) },
	{ key = "6", mods = "LEADER", action = act.ActivateTab(5) },
	{ key = "7", mods = "LEADER", action = act.ActivateTab(6) },
	{ key = "8", mods = "LEADER", action = act.ActivateTab(7) },
	{ key = "9", mods = "LEADER", action = act.ActivateTab(8) },

	-- Rename tab: Leader + ,
	{
		key = ",",
		mods = "LEADER",
		action = act.PromptInputLine({
			description = "Rename tab:",
			action = wezterm.action_callback(function(window, _, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},

	-- Close pane: Leader + x
	{
		key = "x",
		mods = "LEADER",
		action = act.CloseCurrentPane({ confirm = false }),
	},

	-- New window: CTRL+SHIFT+n
	{
		key = "n",
		mods = "CTRL|SHIFT",
		action = act.SpawnWindow,
	},
}

return config
