class_name SettingsScreen
extends ScreenBase

signal back_pressed
signal appearance_changed


func _init() -> void:
	super()
	add_header("Settings", func() -> void: back_pressed.emit())
	column.add_child(UiKit.spacer(16.0))
	column.add_child(UiKit.label("Theme", 17, &"ink", true))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	for entry in [
		["System", Appearance.Choice.SYSTEM],
		["Light", Appearance.Choice.LIGHT],
		["Dark", Appearance.Choice.DARK]
	]:
		row.add_child(_segment(entry[0], entry[1]))
	column.add_child(row)
	var note := UiKit.label(
		"Sound, vibration and saved progress come with the full game.", 14, &"mute"
	)
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(UiKit.spacer(12.0))
	column.add_child(note)


func _segment(text: String, option: Appearance.Choice) -> Button:
	var b := UiKit.secondary(text, 100.0)
	if Appearance.choice == option:
		var ink := Appearance.color(&"ink")
		var on := StyleBoxFlat.new()
		on.bg_color = ink
		on.set_corner_radius_all(UiKit.BUTTON_RADIUS)
		for state in ["normal", "hover", "pressed", "focus"]:
			b.add_theme_stylebox_override(state, on)
		for state in UiKit.FONT_STATES:
			b.add_theme_color_override(state, Appearance.color(&"ground"))
	b.pressed.connect(
		func() -> void:
			Appearance.choice = option
			appearance_changed.emit()
	)
	return b
