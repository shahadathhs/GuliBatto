class_name RoundResultScreen
extends ScreenBase
## The score of one round: where each marble ended, the points, and the running totals.

signal next_pressed

const PLACING_TEXT := {
	&"in_kep": "IN THE KEP",
	&"closest": "CLOSEST",
	&"second": "NEXT CLOSEST",
	&"none": "",
}


func _init(
	result: RuleResult = null,
	totals: Array[int] = [],
	human_side: int = 0,
	round_no: int = 1,
	rounds: int = 1
) -> void:
	super()
	column.add_child(UiKit.spacer(40.0))
	var cap := UiKit.label("ROUND %d OF %d" % [round_no, rounds], 13, &"mute", true)
	cap.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(cap)
	var title := UiKit.label("RESULT", 30, &"ink", true)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(title)
	column.add_child(UiKit.spacer(16.0))
	for side in result.points:
		column.add_child(_row(side, result, totals, human_side))
	add_fill()
	var next := UiKit.primary("Next")
	next.pressed.connect(func() -> void: next_pressed.emit())
	add_centered(next)
	column.add_child(UiKit.spacer(40.0))


func _row(side: int, result: RuleResult, totals: Array[int], human_side: int) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	var chip := SideChip.new(side, "YOU" if side == human_side else "")
	chip.custom_minimum_size = Vector2(70.0, 28.0)
	row.add_child(chip)
	var placing := UiKit.label(PLACING_TEXT.get(result.placing[side], ""), 15, &"ink", true)
	placing.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(placing)
	row.add_child(UiKit.label("+%d" % result.points[side], 20, &"ink", true))
	row.add_child(UiKit.label("total %d" % totals[side], 14, &"mute"))
	return row
