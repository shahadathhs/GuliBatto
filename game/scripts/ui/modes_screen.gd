class_name ModesScreen
extends ScreenBase

signal back_pressed
signal start_pressed(mode_id: StringName)
signal about_pressed


func _init() -> void:
	super()
	add_header("Choose a mode", func() -> void: back_pressed.emit())
	column.add_child(UiKit.spacer(8.0))
	column.add_child(_row(&"kep", "KEP", "Toss at the hole. Closest scores.", true))
	column.add_child(UiKit.spacer(4.0))
	var more := UiKit.label("More modes are built next.", 14, &"mute")
	more.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(more)
	add_fill()
	var about := UiKit.text_action("About these games")
	about.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	about.pressed.connect(func() -> void: about_pressed.emit())
	column.add_child(about)
	column.add_child(UiKit.spacer(6.0))
	var start := UiKit.primary("Start")
	start.pressed.connect(func() -> void: start_pressed.emit(&"kep"))
	add_centered(start)


func _row(_id: StringName, title: String, line: String, selected: bool) -> Control:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Appearance.color(&"ground")
	style.border_color = Appearance.color(&"ink") if selected else Appearance.color(&"line")
	style.set_border_width_all(4 if selected else 2)
	style.set_corner_radius_all(18)
	style.set_content_margin_all(20)
	panel.add_theme_stylebox_override("panel", style)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	box.add_child(UiKit.label(title, 21, &"ink", true))
	box.add_child(UiKit.label(line, 14, &"mute"))
	panel.add_child(box)
	return panel
