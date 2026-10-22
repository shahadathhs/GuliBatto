class_name RulesCard
extends ScreenBase
## The short rules of a game, with its picture: shown the first time a game is started, and again
## from the "?" in a match. One primary action; the full rules are a link.

signal back_pressed
signal primary_pressed
signal full_rules_pressed


## `with_back` adds a back button: the first-start card has one, the card opened in a match not.
func _init(
	mode_id: StringName = &"kep", primary_text: String = "Start", with_back: bool = false
) -> void:
	super()
	var card := Content.card(mode_id)
	if with_back:
		add_header("", func() -> void: back_pressed.emit())
	column.add_child(UiKit.spacer(8.0 if with_back else 24.0))
	var cap := UiKit.label("HOW IT WORKS", 13, &"mute", true)
	cap.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(cap)
	var title := UiKit.label(str(card.get("title", "")).to_upper(), 30, &"ink", true)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(title)
	column.add_child(UiKit.spacer(10.0))
	column.add_child(PageBlocks.list(card.get("lines", []), false))
	column.add_child(UiKit.spacer(10.0))
	var picture := PageBlocks.diagram(str(card.get("diagram", "")), "", 230.0)
	picture.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	column.add_child(picture)
	add_fill()
	var go := UiKit.primary(primary_text)
	go.pressed.connect(func() -> void: primary_pressed.emit())
	add_centered(go)
	column.add_child(UiKit.spacer(8.0))
	var full := UiKit.text_action("Full rules")
	full.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	full.pressed.connect(func() -> void: full_rules_pressed.emit())
	column.add_child(full)
