class_name Hud
extends Control
## The in-match overlay from the concept screens. Top: the mode, whose turn, and the score of each
## side. Bottom: the camera buttons, or the power meter while aiming, or a quiet line while the
## marbles roll. A short result cue appears over the lower arena. It draws and reports intent; it
## never decides anything.

signal pause_pressed
signal view_selected(view: CameraRig.View)
signal reset_pressed
signal cancel_aim_pressed
signal coach_dismissed

var _mode_caption: Label
var _turn_chip: SideChip
var _turn_label: Label
var _chips_row: HBoxContainer
var _bottom: Control
var _camera_bar: HBoxContainer
var _view_buttons: Dictionary = {}
var _aim_bar: VBoxContainer
var _meter: PowerMeter
var _wait_label: Label
var _banner: PanelContainer
var _banner_label: Label
var _coach: PanelContainer
var _banner_token: int = 0


func _init() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_top()
	_build_bottom()
	_build_banner()


func set_mode_caption(text: String) -> void:
	_mode_caption.text = text.to_upper()


func set_turn(side: int, text: String) -> void:
	_turn_chip.side = side
	_turn_chip.queue_redraw()
	_turn_label.text = text


## totals[i] is side i's score; the human side is shown as YOU.
func set_scores(totals: Array[int], human_side: int) -> void:
	for child in _chips_row.get_children():
		child.queue_free()
	for side in totals.size():
		var who := "YOU" if side == human_side else ""
		var chip := SideChip.new(side, ("%s %d" % [who, totals[side]]).strip_edges())
		_chips_row.add_child(chip)


func show_camera_bar() -> void:
	_camera_bar.visible = true
	_aim_bar.visible = false
	_wait_label.visible = false


func show_aim(power: float) -> void:
	_camera_bar.visible = false
	_aim_bar.visible = true
	_wait_label.visible = false
	_meter.power = power


func show_waiting(text: String) -> void:
	_camera_bar.visible = false
	_aim_bar.visible = false
	_wait_label.text = text
	_wait_label.visible = true


func highlight_view(view: CameraRig.View) -> void:
	for v in _view_buttons:
		(_view_buttons[v] as IconButton).selected = v == view


## A one-line result over the lower arena for a moment.
func show_cue(text: String, seconds: float = 1.4) -> void:
	_banner_label.text = text.to_upper()
	_banner.visible = true
	_banner_token += 1
	var token := _banner_token
	await get_tree().create_timer(seconds, false).timeout
	if token == _banner_token:
		_banner.visible = false


func show_coach() -> void:
	_coach.visible = true


func hide_coach() -> void:
	_coach.visible = false


func _build_top() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_TOP_WIDE)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for side in ["left", "right"]:
		margin.add_theme_constant_override("margin_" + side, 24)
	margin.add_theme_constant_override("margin_top", 44)
	add_child(margin)
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(row)
	var left := VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.mouse_filter = Control.MOUSE_FILTER_IGNORE
	left.add_theme_constant_override("separation", 2)
	row.add_child(left)
	_mode_caption = UiKit.caption("")
	left.add_child(_mode_caption)
	var turn := HBoxContainer.new()
	turn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_turn_chip = SideChip.new(0, "")
	_turn_chip.custom_minimum_size = Vector2(28.0, 34.0)
	turn.add_child(_turn_chip)
	_turn_label = UiKit.label("", 28, &"ink", true)
	turn.add_child(_turn_label)
	left.add_child(turn)
	_chips_row = HBoxContainer.new()
	_chips_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_chips_row.add_theme_constant_override("separation", 14)
	left.add_child(_chips_row)
	var pause := IconButton.new(IconButton.Glyph.PAUSE)
	pause.pressed.connect(func() -> void: pause_pressed.emit())
	row.add_child(pause)


func _build_bottom() -> void:
	_bottom = Control.new()
	_bottom.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_bottom.offset_top = -120.0
	_bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_bottom)
	_camera_bar = HBoxContainer.new()
	_camera_bar.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_camera_bar.offset_left = 24.0
	_camera_bar.offset_right = -24.0
	_camera_bar.offset_top = -76.0
	_camera_bar.offset_bottom = -28.0
	_camera_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_camera_bar.add_theme_constant_override("separation", 12)
	_bottom.add_child(_camera_bar)
	var views := {
		CameraRig.View.ANGLED: IconButton.Glyph.ANGLED,
		CameraRig.View.TOP_DOWN: IconButton.Glyph.TOP,
		CameraRig.View.LOW: IconButton.Glyph.LOW,
	}
	for v in views:
		var b := IconButton.new(views[v])
		b.pressed.connect(func() -> void: view_selected.emit(v))
		_camera_bar.add_child(b)
		_view_buttons[v] = b
	var fill := Control.new()
	fill.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_camera_bar.add_child(fill)
	var reset := IconButton.new(IconButton.Glyph.RESET)
	reset.pressed.connect(func() -> void: reset_pressed.emit())
	_camera_bar.add_child(reset)
	_aim_bar = VBoxContainer.new()
	_aim_bar.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_aim_bar.offset_top = -110.0
	_aim_bar.offset_bottom = -20.0
	_aim_bar.alignment = BoxContainer.ALIGNMENT_CENTER
	_aim_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_aim_bar.visible = false
	_bottom.add_child(_aim_bar)
	_meter = PowerMeter.new()
	_meter.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_aim_bar.add_child(_meter)
	var cancel := UiKit.text_action("Cancel")
	cancel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	cancel.pressed.connect(func() -> void: cancel_aim_pressed.emit())
	_aim_bar.add_child(cancel)
	_wait_label = UiKit.label("", 14, &"mute")
	_wait_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_wait_label.offset_top = -64.0
	_wait_label.offset_bottom = -28.0
	_wait_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_wait_label.visible = false
	_bottom.add_child(_wait_label)


func _build_banner() -> void:
	_banner = PanelContainer.new()
	_banner.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_banner.offset_left = 40.0
	_banner.offset_right = -40.0
	_banner.offset_top = -210.0
	_banner.offset_bottom = -140.0
	_banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_banner.visible = false
	var style := StyleBoxFlat.new()
	style.bg_color = Appearance.color(&"ink")
	style.set_corner_radius_all(16)
	_banner.add_theme_stylebox_override("panel", style)
	_banner_label = UiKit.label("", 17, &"ground", true)
	_banner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_banner_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_banner.add_child(_banner_label)
	add_child(_banner)
	_build_coach()


func _build_coach() -> void:
	_coach = PanelContainer.new()
	_coach.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_coach.offset_left = 30.0
	_coach.offset_right = -30.0
	_coach.offset_top = -270.0
	_coach.offset_bottom = -140.0
	_coach.visible = false
	var style := StyleBoxFlat.new()
	style.bg_color = Appearance.color(&"ink")
	style.set_corner_radius_all(16)
	style.set_content_margin_all(16)
	_coach.add_theme_stylebox_override("panel", style)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	var title := UiKit.label("PULL BACK, THEN RELEASE", 15, &"ground", true)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	var body := (
		UiKit
		. label(
			"Press your marble and drag away from where you want it to go. A longer pull means more power.",
			14,
			&"ground"
		)
	)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(body)
	var got_it := UiKit.text_action("Got it")
	got_it.add_theme_color_override("font_color", Appearance.color(&"ground"))
	got_it.add_theme_color_override("font_hover_color", Appearance.color(&"ground"))
	got_it.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	got_it.pressed.connect(
		func() -> void:
			_coach.visible = false
			coach_dismissed.emit()
	)
	box.add_child(got_it)
	_coach.add_child(box)
	add_child(_coach)
