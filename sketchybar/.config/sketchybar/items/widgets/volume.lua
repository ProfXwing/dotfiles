local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local popup_width = 250
SBAR = sbar

local volume_percent = SBAR.add("item", "widgets.volume1", {
	position = "right",
	icon = { drawing = false },
	label = {
		string = "??%",
		padding_left = -1,
		font = { family = settings.font.numbers },
	},
})

local volume_icon = SBAR.add("item", "widgets.volume2", {
	position = "right",
	padding_right = -1,
	icon = {
		string = icons.volume._100,
		width = 0,
		align = "left",
		color = colors.grey,
		font = {
			style = settings.font.style_map["Regular"],
			size = 14.0,
		},
	},
	label = {
		width = 25,
		align = "left",
		font = {
			style = settings.font.style_map["Regular"],
			size = 14.0,
		},
	},
})

local volume_bracket = SBAR.add("bracket", "widgets.volume.bracket", {
	volume_icon.name,
	volume_percent.name,
}, {
	background = { color = colors.bg1 },
	popup = { align = "center" },
})

SBAR.add("item", "widgets.volume.padding", {
	position = "right",
	width = settings.group_paddings,
})

local volume_slider = SBAR.add("slider", popup_width, {
	position = "popup." .. volume_bracket.name,
	slider = {
		highlight_color = colors.blue,
		background = {
			height = 6,
			corner_radius = 3,
			color = colors.bg2,
		},
		knob = {
			string = "􀀁",
			drawing = true,
		},
	},
	background = { color = colors.bg1, height = 2, y_offset = -20 },
	click_script = 'osascript -e "set volume output volume $PERCENTAGE"',
})

volume_percent:subscribe("volume_change", function(env)
	local volume = tonumber(env.INFO)
	local icon = icons.volume._0
	if volume > 60 then
		icon = icons.volume._100
	elseif volume > 30 then
		icon = icons.volume._66
	elseif volume > 10 then
		icon = icons.volume._33
	elseif volume > 0 then
		icon = icons.volume._10
	end

	local lead = ""
	if volume < 10 then
		lead = "0"
	end

	volume_icon:set({ label = icon })
	volume_percent:set({ label = lead .. volume .. "%" })
	volume_slider:set({ slider = { percentage = volume } })
end)

local function contains(table, element)
	for _, value in pairs(table) do
		if value == element then
			return true
		end
	end
	return false
end

local function volume_collapse_details()
	local drawing = volume_bracket:query().popup.drawing == "on"
	if not drawing then
		return
	end
	volume_bracket:set({ popup = { drawing = false } })
	SBAR.remove("/volume.device\\.*/")
end

local selected_audio_device = ""
local all_audio_devices = {}
local function add_output_device(device, counter, color)
	local item = SBAR.add("item", "volume.device." .. counter, {
		position = "popup." .. volume_bracket.name,
		width = popup_width,
		align = "center",
		label = { string = string.sub(device, 0, 35), color = color },
		click_script = 'SwitchAudioSource -s "'
			.. device
			.. '" && sketchybar --set /volume.device\\.*/ label.color='
			.. colors.grey
			.. " --set $NAME label.color="
			.. colors.white,
	})
	item:subscribe("mouse.clicked", function()
		selected_audio_device = device
	end)
end

local function create_output_devices()
	for index, device in pairs(all_audio_devices) do
		local color = colors.grey
		if device == selected_audio_device then
			color = colors.white
		end

		add_output_device(device, index, color)
	end

	SBAR.exec("SwitchAudioSource -t output -c", function(result)
		local new_audio_device = result:sub(1, -2)

		SBAR.exec("SwitchAudioSource -a -t output", function(available)
			local new_audio_devices = {}
			for device in string.gmatch(available, "[^\r\n]+") do
				table.insert(new_audio_devices, device)
			end

			for index, device in pairs(new_audio_devices) do
				local color = colors.grey
				if new_audio_device == device then
					color = colors.white
				end

				if not contains(all_audio_devices, device) then
					add_output_device(device, index, color)
				else
					SBAR.set("volume.device." .. index, { label = { color = color } })
				end
			end

			all_audio_devices = new_audio_devices
			selected_audio_device = new_audio_device
		end)
	end)
end

local function volume_toggle_details(env)
	if env.BUTTON == "right" then
		SBAR.exec("open /System/Library/PreferencePanes/Sound.prefpane")
		return
	end

	local should_draw = volume_bracket:query().popup.drawing == "off"
	if not should_draw then
		volume_collapse_details()
		return
	end

	volume_bracket:set({ popup = { drawing = true } })

	create_output_devices()
end

local function volume_scroll(env)
	local delta = env.SCROLL_DELTA
	SBAR.exec('osascript -e "set volume output volume (output volume of (get volume settings) + ' .. delta .. ')"')
end

volume_icon:subscribe("mouse.clicked", volume_toggle_details)
volume_icon:subscribe("mouse.scrolled", volume_scroll)
volume_percent:subscribe("mouse.clicked", volume_toggle_details)
volume_percent:subscribe("mouse.exited.global", volume_collapse_details)
volume_percent:subscribe("mouse.scrolled", volume_scroll)
