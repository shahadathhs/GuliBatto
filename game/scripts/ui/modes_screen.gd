class_name ModesScreen
extends ScreenBase

signal back_pressed
signal start_pressed(mode_id: StringName)
signal about_pressed

var _selected: StringName = ModeRegistry.ORDER[0]
var _panels: Dictionary = {}


func _init() -> void:
	super()
	add_header("Choose a mode", func() -> void: back_pressed.emit())
	column.add_child(UiKit.spacer(8.0))
	for id in ModeRegistry.ORDER:
		var panel := _row(id)
		_panels[id] = panel
		column.add_child(panel)
	_restyle()
	add_fill()
	var about := UiKit.text_action("About these games")
	about.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	about.pressed.connect(func() -> void: about_pressed.emit())
	column.add_child(about)
	column.add_child(UiKit.spacer(6.0))
	var start := UiKit.primary("Start")
	start.pressed.connect(func() -> void: start_pressed.emit(_selected))
	add_centered(start)


func select(mode_id: StringName) -> void:
	_selected = mode_id
	_restyle()


func selected() -> StringName:
	return _selected


func _restyle() -> void:
	for id in _panels:
		var style := StyleBoxFlat.new()
		var on: bool = id == _selected
		style.bg_color = Appearance.color(&"ground")
		style.border_color = Appearance.color(&"ink") if on else Appearance.color(&"line")
		style.set_border_width_all(4 if on else 2)
		style.set_corner_radius_all(18)
		style.set_content_margin_all(20)
		(_panels[id] as PanelContainer).add_theme_stylebox_override("panel", style)


func _row(id: StringName) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	var box := VBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_constant_override("separation", 6)
	var title := UiKit.label(ModeRegistry.TITLES[id], 21, &"ink", true)
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(title)
	var line := UiKit.label(ModeRegistry.BLURBS[id], 14, &"mute")
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(line)
	panel.add_child(box)
	panel.gui_input.connect(
		func(event: InputEvent) -> void:
			if (
				event is InputEventMouseButton
				and event.pressed
				and event.button_index == MOUSE_BUTTON_LEFT
			):
				select(id)
	)
	return panel
