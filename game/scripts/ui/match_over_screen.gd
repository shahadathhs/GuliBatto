class_name MatchOverScreen
extends ScreenBase
## The end of a match: the ranking, and what to do next.

signal rematch_pressed
signal modes_pressed
signal menu_pressed


func _init(ranking: Array[int] = [], totals: Array[int] = [], human_side: int = 0) -> void:
	super()
	column.add_child(UiKit.spacer(40.0))
	var cap := UiKit.label("MATCH OVER", 14, &"mute", true)
	cap.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(cap)
	var verdict := UiKit.label(
		(
			"YOU WON"
			if ranking[0] == human_side
			else "YOU CAME %s" % _ordinal(ranking.find(human_side) + 1)
		),
		34,
		&"ink",
		true
	)
	verdict.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(verdict)
	column.add_child(UiKit.spacer(18.0))
	for i in ranking.size():
		column.add_child(_row(i + 1, ranking[i], totals[ranking[i]], human_side))
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


func _row(place: int, side: int, total: int, human_side: int) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	row.add_child(UiKit.label(str(place), 32, &"ink" if place < 4 else &"mute", true))
	var chip := SideChip.new(side, "YOU" if side == human_side else "")
	chip.custom_minimum_size = Vector2(80.0, 32.0)
	row.add_child(chip)
	var fill := Control.new()
	fill.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(fill)
	row.add_child(UiKit.label("%d points" % total, 16, &"ink", true))
	return row


func _ordinal(n: int) -> String:
	return ["FIRST", "SECOND", "THIRD", "FOURTH"][clampi(n - 1, 0, 3)]
