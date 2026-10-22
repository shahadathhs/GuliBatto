class_name PageScreen
extends ScreenBase
## A scrolling page built from the shared content: How to play, a game's page, About, Contact,
## Privacy. A link either opens another page ("page:") or a web address ("url:"); the app decides.

signal back_pressed
signal link_pressed(target: String)

var page_id: String = ""


func _init(id: String = "", on_web: bool = OS.has_feature("web")) -> void:
	super()
	page_id = id
	add_header(Content.title(id), func() -> void: back_pressed.emit())
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scroll)
	# Room on the right so the scrollbar does not sit on the text.
	var inset := MarginContainer.new()
	inset.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inset.add_theme_constant_override("margin_right", 16)
	scroll.add_child(inset)
	var body := VBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 8)
	inset.add_child(body)
	var on_link := func(target: String) -> void: link_pressed.emit(target)
	for block in Content.blocks(id, on_web):
		body.add_child(PageBlocks.build(block, on_link))
	body.add_child(UiKit.spacer(24.0))
