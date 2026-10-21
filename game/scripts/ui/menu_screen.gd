class_name MenuScreen
extends ScreenBase

signal play_pressed
signal how_to_play_pressed
signal about_pressed
signal settings_pressed


func _init() -> void:
	super()
	column.add_child(UiKit.spacer(48.0))
	var name_row := UiKit.label("GULI & BATTO", 38, &"ink", true)
	name_row.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(name_row)
	var sub := UiKit.label("MARBLE GAMES FROM CHILDHOOD", 11, &"mute", true)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(sub)
	column.add_child(UiKit.spacer(24.0))
	add_centered(ArenaArt.new())
	add_fill()
	var play := UiKit.primary("Play")
	play.pressed.connect(func() -> void: play_pressed.emit())
	add_centered(play)
	column.add_child(UiKit.spacer(18.0))
	var links := HBoxContainer.new()
	links.alignment = BoxContainer.ALIGNMENT_CENTER
	links.add_theme_constant_override("separation", 36)
	for entry in [
		["How to play", how_to_play_pressed],
		["About", about_pressed],
		["Settings", settings_pressed]
	]:
		var link := UiKit.text_action(entry[0])
		link.pressed.connect(func() -> void: (entry[1] as Signal).emit())
		links.add_child(link)
	column.add_child(links)
