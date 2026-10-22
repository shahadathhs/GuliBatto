class_name PageBlocks
extends RefCounted
## Builds the controls for the blocks of a page (and the lines of a rules card): headings,
## paragraphs, bullet and numbered lists, diagrams, glossary terms, questions and links.


## One block as a control. `on_link` is called with a link's target when it is pressed.
static func build(block: Dictionary, on_link: Callable) -> Control:
	match block["type"]:
		"heading":
			return _heading(block["text"])
		"paragraph":
			return text(block["text"])
		"list":
			return list(block["items"], false)
		"steps":
			return list(block["items"], true)
		"diagram":
			return diagram(block["id"], block.get("caption", ""))
		"term":
			return _term(block["term"], block["text"])
		"qa":
			return _qa(block["q"], block["a"])
		"link":
			return _link(block["label"], block["target"], on_link)
	return Control.new()


static func text(content: String, size: int = 15, token: StringName = &"ink") -> Label:
	var label := UiKit.label(content, size, token)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return label


## Bullets, or numbers when `numbered`.
static func list(items: Array, numbered: bool) -> Control:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	for i in items.size():
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		var marker := UiKit.label("%d." % (i + 1) if numbered else "•", 15, &"mute", true)
		marker.custom_minimum_size = Vector2(22.0 if numbered else 14.0, 0.0)
		marker.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		marker.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		row.add_child(marker)
		row.add_child(text(str(items[i])))
		box.add_child(row)
	return box


static func diagram(
	diagram_id: String, caption: String, max_height: float = DiagramView.DEFAULT_MAX_HEIGHT
) -> Control:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	var view := DiagramView.new(diagram_id, max_height)
	view.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	box.add_child(view)
	if caption != "":
		var line := text(caption, 13, &"mute")
		line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		box.add_child(line)
	return box


static func _heading(content: String) -> Control:
	var box := VBoxContainer.new()
	box.add_child(UiKit.spacer(14.0))
	var label := UiKit.label(content, 19, &"ink", true)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(label)
	return box


static func _term(term: String, meaning: String) -> Control:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 1)
	box.add_child(UiKit.label(term, 15, &"ink", true))
	box.add_child(text(meaning, 14, &"mute"))
	return box


static func _qa(question: String, answer: String) -> Control:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 3)
	box.add_child(UiKit.spacer(4.0))
	var q := text(question, 15)
	q.add_theme_font_override("font", UiKit.bold_font())
	box.add_child(q)
	box.add_child(text(answer, 14, &"mute"))
	return box


static func _link(label: String, target: String, on_link: Callable) -> Control:
	var link := UiKit.text_action(label)
	link.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	link.pressed.connect(func() -> void: on_link.call(target))
	return link
