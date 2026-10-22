class_name MatchOverScreen
extends ScreenBase
## The end of a match: the ranking, and what to do next.

signal rematch_pressed
signal modes_pressed
signal menu_pressed


func _init(ranking: Array[int] = [], details: Array[String] = [], setup: MatchSetup = null) -> void:
	super()
	column.add_child(UiKit.spacer(40.0))
	var cap := UiKit.label("MATCH OVER", 14, &"mute", true)
	cap.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(cap)
	var verdict := UiKit.label(_verdict(ranking, setup), 34, &"ink", true)
	verdict.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(verdict)
	column.add_child(UiKit.spacer(18.0))
	for i in ranking.size():
		column.add_child(_row(i + 1, ranking[i], details[ranking[i]], setup))
	add_fill()
	var again := UiKit.primary("Rematch")
	again.pressed.connect(func() -> void: rematch_pressed.emit())
	add_centered(again)
	column.add_child(UiKit.spacer(10.0))
	var modes := UiKit.secondary("Modes")
	modes.pressed.connect(func() -> void: modes_pressed.emit())
	add_centered(modes)
	column.add_child(UiKit.spacer(6.0))
	var menu := UiKit.text_action("Menu")
	menu.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	menu.pressed.connect(func() -> void: menu_pressed.emit())
	column.add_child(menu)


func _row(place: int, side: int, detail: String, setup: MatchSetup) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	row.add_child(UiKit.label(str(place), 32, &"ink" if place < 4 else &"mute", true))
	var chip := SideChip.new(side, setup.label(side) if setup != null else "")
	chip.custom_minimum_size = Vector2(80.0, 32.0)
	row.add_child(chip)
	var fill := Control.new()
	fill.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(fill)
	row.add_child(UiKit.label(detail, 16, &"ink", true))
	return row


## "YOU WON" or "YOU CAME SECOND" for the one person; the winner's name in pass and play.
func _verdict(ranking: Array[int], setup: MatchSetup) -> String:
	if setup != null and setup.hands_over():
		return "%s WON" % SideStyle.side_name(ranking[0]).to_upper()
	var me: int = setup.humans[0] if setup != null and not setup.humans.is_empty() else 0
	if ranking[0] == me:
		return "YOU WON"
	return "YOU CAME %s" % _ordinal(ranking.find(me) + 1)


func _ordinal(n: int) -> String:
	return ["FIRST", "SECOND", "THIRD", "FOURTH", "FIFTH"][clampi(n - 1, 0, 4)]
