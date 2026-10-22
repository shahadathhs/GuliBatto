class_name PauseScreen
extends ScreenBase

signal resume_pressed
signal restart_pressed
signal menu_pressed
signal surrender_pressed


func _init(can_surrender: bool = false) -> void:
	super()
	process_mode = Node.PROCESS_MODE_ALWAYS
	column.add_child(UiKit.spacer(80.0))
	var title := UiKit.label("PAUSED", 30, &"ink", true)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(title)
	column.add_child(UiKit.spacer(24.0))
	var resume := UiKit.primary("Resume")
	resume.pressed.connect(func() -> void: resume_pressed.emit())
	add_centered(resume)
	column.add_child(UiKit.spacer(24.0))
	for entry in [["Restart", restart_pressed]]:
		var b := UiKit.secondary(entry[0])
		b.pressed.connect(func() -> void: (entry[1] as Signal).emit())
		add_centered(b)
	if can_surrender:
		column.add_child(UiKit.spacer(10.0))
		var give_up := UiKit.secondary("Surrender")
		give_up.pressed.connect(func() -> void: surrender_pressed.emit())
		add_centered(give_up)
	column.add_child(UiKit.spacer(10.0))
	var menu := UiKit.text_action("Back to menu")
	menu.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	menu.pressed.connect(func() -> void: menu_pressed.emit())
	column.add_child(menu)
