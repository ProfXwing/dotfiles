-- TODO: popup window for menu bar items.
-- bartender allows querying and clicking?

local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local applescript =
	"osascript -e 'ignoring application responses\ntell application \"Bartender 5\" to quick search\nend ignoring'"

local bartender = sbar.add("item", "widgets.bartender.button", {
	position = "right",
	icon = {
		padding_left = 2,
		padding_right = 2,
		color = colors.grey,
		string = ":down_arrow:",
		font = "sketchybar-app-font:Regular:16.0",
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
local bartender_bracket = sbar.add("bracket", "widgets.bartender.bracket", {
	bartender.name,
}, {
	background = { color = colors.bg1 },
	popup = { align = "center", height = 30 },
})

bartender_bracket:subscribe("mouse.entered", function()
	sbar.animate("tanh", ANIMATION_MS, function()
		bartender_bracket:set({
			background = {
				color = colors.grey,
			},
		})
		bartender:set({
			icon = { color = colors.bg1 },
		})
	end)
end)

bartender_bracket:subscribe("mouse.exited", function()
	sbar.animate("tanh", ANIMATION_MS, function()
		bartender_bracket:set({
			background = {
				color = colors.bg1,
			},
		})
		bartender:set({
			icon = { color = colors.grey },
		})
	end)
end)

bartender:subscribe("mouse.clicked", function()
	SBAR.exec(applescript)
end)

bartender_bracket:subscribe("mouse.clicked", function()
	SBAR.exec(applescript)
end)
