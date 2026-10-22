class_name WhoPlaysScreen
extends ScreenBase
## After a game is chosen: against the computer (one to three computer sides) or pass and play
## (two to five people on one device). The last choice is remembered.

signal back_pressed
signal play_pressed(setup: MatchSetup)

var _kind: MatchSetup.Kind = Settings.play_kind
var _computers: int = Settings.computers
var _people: int = Settings.people
var _panels: Dictionary = {}
var _rows: Dictionary = {}
var _counts: Dictionary = {}


func _init() -> void:
	super()
	add_header("Who plays?", func() -> void: back_pressed.emit())
	column.add_child(UiKit.spacer(8.0))
	_add_panel(
		MatchSetup.Kind.COMPUTERS,
		"AGAINST THE COMPUTER",
		"You and the computer sides",
		MatchSetup.MAX_COMPUTERS
	)
	_add_panel(
		MatchSetup.Kind.PASS_AND_PLAY,
		"PASS AND PLAY",
		"Hand the device round",
		MatchSetup.MAX_PEOPLE
	)
	column.add_child(UiKit.label("Computers: 1 to 3. People: 2 to 5.", 14, &"mute"))
	add_fill()
	var play := UiKit.primary("Play")
	play.pressed.connect(func() -> void: play_pressed.emit(setup()))
	add_centered(play)
	_refresh()


## The match the screen is set to.
func setup() -> MatchSetup:
	if _kind == MatchSetup.Kind.PASS_AND_PLAY:
		return MatchSetup.pass_and_play(_people)
	return MatchSetup.solo(_computers)


func select(kind: MatchSetup.Kind) -> void:
	_kind = kind
	_refresh()


## Moves the count of the selected kind up or down, within its limits.
func step(kind: MatchSetup.Kind, delta: int) -> void:
	if kind == MatchSetup.Kind.COMPUTERS:
		_computers = clampi(_computers + delta, 1, MatchSetup.MAX_COMPUTERS)
	else:
		_people = clampi(_people + delta, MatchSetup.MIN_PEOPLE, MatchSetup.MAX_PEOPLE)
	_kind = kind
	_refresh()


func _add_panel(kind: MatchSetup.Kind, title: String, line: String, _max: int) -> void:
	var panel := PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	var box := VBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_constant_override("separation", 8)
	var heading := UiKit.label(title, 19, &"ink", true)
	heading.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(heading)
	var sub := UiKit.label(line, 14, &"mute")
	sub.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(sub)
	var bottom := HBoxContainer.new()
	bottom.add_theme_constant_override("separation", 10)
	var marbles := HBoxContainer.new()
	marbles.mouse_filter = Control.MOUSE_FILTER_IGNORE
	marbles.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	marbles.add_theme_constant_override("separation", 6)
	_rows[kind] = marbles
	bottom.add_child(marbles)
	var less := UiKit.secondary("-", 44.0)
	less.pressed.connect(func() -> void: step(kind, -1))
	bottom.add_child(less)
	var count := UiKit.label("0", 24, &"ink", true)
	count.custom_minimum_size = Vector2(28.0, 0.0)
	count.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_counts[kind] = count
	bottom.add_child(count)
	var more := UiKit.secondary("+", 44.0)
	more.pressed.connect(func() -> void: step(kind, 1))
	bottom.add_child(more)
	box.add_child(bottom)
	panel.add_child(box)
	panel.gui_input.connect(
		func(event: InputEvent) -> void:
			if (
				event is InputEventMouseButton
				and event.pressed
				and event.button_index == MOUSE_BUTTON_LEFT
			):
				select(kind)
	)
	_panels[kind] = panel
	column.add_child(panel)


func _refresh() -> void:
	Settings.remember_setup(_kind, _computers, _people)
	for kind in _panels:
		var on: bool = kind == _kind
		var style := StyleBoxFlat.new()
		style.bg_color = Appearance.color(&"ground")
		style.border_color = Appearance.color(&"ink") if on else Appearance.color(&"line")
		style.set_border_width_all(4 if on else 2)
		style.set_corner_radius_all(18)
		style.set_content_margin_all(20)
		(_panels[kind] as PanelContainer).add_theme_stylebox_override("panel", style)
		var sides := 1 + _computers if kind == MatchSetup.Kind.COMPUTERS else _people
		var row: HBoxContainer = _rows[kind]
		for child in row.get_children():
			child.queue_free()
		for side in sides:
			var chip := SideChip.new(side, "")
			chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
			chip.custom_minimum_size = Vector2(SideChip.MARBLE_RADIUS * 2.0 + 4.0, 22.0)
			row.add_child(chip)
		(_counts[kind] as Label).text = str(
			_computers if kind == MatchSetup.Kind.COMPUTERS else _people
		)
