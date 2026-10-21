class_name ScreenBase
extends Control
## A full-screen page on the ground colour with a padded column. Screens build their content into
## `column`; the pause overlay and the result screens reuse it.

var column: VBoxContainer


func _init() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(UiKit.ground_background())
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 44)
	margin.add_theme_constant_override("margin_bottom", 36)
	add_child(margin)
	column = VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	margin.add_child(column)


## A back button and a bold title on one row, for the inner pages.
func add_header(title: String, back: Callable) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	var b := IconButton.new(IconButton.Glyph.BACK)
	b.pressed.connect(back)
	row.add_child(b)
	var l := UiKit.label(title.to_upper(), 20, &"ink", true)
	l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(l)
	column.add_child(row)


func add_centered(node: Control) -> void:
	node.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	column.add_child(node)


func add_fill() -> void:
	var c := Control.new()
	c.size_flags_vertical = Control.SIZE_EXPAND_FILL
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(c)
