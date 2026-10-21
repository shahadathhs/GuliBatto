class_name TextScreen
extends ScreenBase
## A page of headed paragraphs with a back button: About, How to play.

signal back_pressed


func _init(title: String = "", sections: Array[Array] = []) -> void:
	super()
	add_header(title, func() -> void: back_pressed.emit())
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scroll)
	var body := VBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 6)
	scroll.add_child(body)
	for section in sections:
		body.add_child(UiKit.spacer(10.0))
		body.add_child(UiKit.caption(section[0]))
		var p := UiKit.label(section[1], 15)
		p.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		body.add_child(p)
