local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

-- open bluetooth settings
local applescript = "open /System/Library/PreferencePanes/Bluetooth.prefPane"

local bluetooth = sbar.add("item", "widgets.bluetooth.button", {
	position = "right",
	icon = {
		padding_left = 2,
		padding_right = 2,
		color = colors.white,
		string = "󰂯",
		font = {
			family = settings.nerd_font,
			size = 18.0,
		},
	},
	label = {
		width = 0,
	},
	background = {
		color = colors.with_alpha(colors.grey, 0.0),
		border_color = colors.with_alpha(colors.bg1, 0.0),
	},
})

-- Background around the item
local bluetooth_bracket = sbar.add("bracket", "widgets.bluetooth.bracket", {
	bluetooth.name,
}, {
	background = { color = colors.bg1 },
	popup = { align = "center", height = 30 },
})

sbar.add("item", "widgets.bluetooth.padding", {
	position = "right",
	width = settings.group_paddings,
})

bluetooth_bracket:subscribe("mouse.entered", function()
	sbar.animate("tanh", ANIMATION_MS, function()
		bluetooth_bracket:set({
			background = {
				color = colors.grey,
			},
		})
		bluetooth:set({
			icon = { color = colors.bg1 },
		})
	end)
end)

bluetooth_bracket:subscribe("mouse.exited", function()
	sbar.animate("tanh", ANIMATION_MS, function()
		bluetooth_bracket:set({
			background = {
				color = colors.bg1,
			},
		})
		bluetooth:set({
			icon = { color = colors.white },
		})
	end)
end)

bluetooth:subscribe("mouse.clicked", function()
	SBAR.exec(applescript)
end)

bluetooth_bracket:subscribe("mouse.clicked", function()
	SBAR.exec(applescript)
end)
