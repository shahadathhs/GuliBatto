class_name SettingsScreen
extends ScreenBase

signal back_pressed
## A choice changed, or settings were reset; the app rebuilds the screen so it shows the new state.
signal appearance_changed

## The three volume steps; the one nearest the saved volume is shown as chosen.
const VOLUMES := [["Low", 0.35], ["Medium", 0.7], ["High", 1.0]]


func _init() -> void:
	super()
	add_header("Settings", func() -> void: back_pressed.emit())
	column.add_child(UiKit.spacer(8.0))
	_section("Theme")
	var theme_row := _row()
	for entry in [
		["System", Appearance.Choice.SYSTEM],
		["Light", Appearance.Choice.LIGHT],
		["Dark", Appearance.Choice.DARK]
	]:
		var option: Appearance.Choice = entry[1]
		theme_row.add_child(_choice(entry[0], Appearance.choice == option, _set_theme.bind(option)))
	_section("Sound")
	var sound_row := _row()
	for on in [true, false]:
		sound_row.add_child(
			_choice("On" if on else "Off", Settings.sound_on == on, _set_sound.bind(on))
		)
	_section("Volume")
	var volume_row := _row()
	var nearest := _nearest_volume()
	for entry in VOLUMES:
		var level: float = entry[1]
		volume_row.add_child(
			_choice(entry[0], is_equal_approx(level, nearest), _set_volume.bind(level))
		)
	_section(
		"Follow shots", "The camera follows a shot while it rolls. Tap to skip it for one shot."
	)
	var follow_row := _row()
	for on in [true, false]:
		follow_row.add_child(
			_choice("On" if on else "Off", Settings.follow_shots == on, _set_follow.bind(on))
		)
	column.add_child(UiKit.spacer(24.0))
	_build_reset()


func _set_theme(option: Appearance.Choice) -> void:
	Settings.set_theme(option)


func _set_sound(on: bool) -> void:
	Settings.sound_on = on
	Settings.save()


func _set_volume(level: float) -> void:
	Settings.volume = level
	Settings.save()
	# Let the new volume be heard. The press itself made a tap at the old volume.
	Sfx.play(Sfx.Event.HIT)


func _set_follow(on: bool) -> void:
	Settings.follow_shots = on
	Settings.save()


func _nearest_volume() -> float:
	var best: float = VOLUMES[0][1]
	for entry in VOLUMES:
		var level: float = entry[1]
		if absf(level - Settings.volume) < absf(best - Settings.volume):
			best = level
	return best


func _section(title: String, note: String = "") -> void:
	column.add_child(UiKit.spacer(12.0))
	column.add_child(UiKit.label(title, 17, &"ink", true))
	if note != "":
		var line := UiKit.label(note, 14, &"mute")
		line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		column.add_child(line)


func _row() -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	column.add_child(row)
	return row


## One option of a row: filled when chosen. Pressing it applies the change and redraws the screen.
func _choice(text: String, selected: bool, apply: Callable) -> Button:
	var b := UiKit.secondary(text, 100.0)
	if selected:
		var on := StyleBoxFlat.new()
		on.bg_color = Appearance.color(&"ink")
		on.set_corner_radius_all(UiKit.BUTTON_RADIUS)
		for state in ["normal", "hover", "pressed", "focus"]:
			b.add_theme_stylebox_override(state, on)
		for state in UiKit.FONT_STATES:
			b.add_theme_color_override(state, Appearance.color(&"ground"))
	b.pressed.connect(
		func() -> void:
			apply.call()
			appearance_changed.emit()
	)
	return b


## Reset asks first, in place, so a stray tap cannot wipe the settings.
func _build_reset() -> void:
	var reset := UiKit.secondary("Reset to defaults", 240.0)
	reset.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	column.add_child(reset)
	var confirm := VBoxContainer.new()
	confirm.visible = false
	confirm.add_theme_constant_override("separation", 10)
	var note := UiKit.label(
		"This puts the theme, sound and camera back to their defaults and shows the tips again.",
		14,
		&"mute"
	)
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	confirm.add_child(note)
	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 14)
	var yes := UiKit.secondary("Reset", 120.0)
	yes.pressed.connect(
		func() -> void:
			Settings.reset()
			appearance_changed.emit()
	)
	buttons.add_child(yes)
	var no := UiKit.text_action("Cancel")
	no.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	no.pressed.connect(
		func() -> void:
			confirm.visible = false
			reset.visible = true
	)
	buttons.add_child(no)
	confirm.add_child(buttons)
	column.add_child(confirm)
	reset.pressed.connect(
		func() -> void:
			reset.visible = false
			confirm.visible = true
	)
