class_name HandoverScreen
extends ScreenBase
## Pass and play: shown before a different person shoots, so nobody takes a shot meant for the
## next side. It names the side with its marble, colour and mark, and waits for one tap.

signal ready_pressed

const MARBLE_RADIUS := 52.0


func _init(side: int = 0, caption: String = "") -> void:
	super()
	column.add_child(UiKit.spacer(40.0))
	var cap := UiKit.label(caption.to_upper(), 12, &"mute", true)
	cap.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(cap)
	add_fill()
	var pass_to := UiKit.label("PASS TO", 15, &"mute", true)
	pass_to.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(pass_to)
	var marble := _Disc.new(side)
	marble.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	column.add_child(marble)
	var who := UiKit.label(SideStyle.side_name(side).to_upper(), 44, &"ink", true)
	who.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(who)
	var line := UiKit.label(
		"The %s side shoots next." % SideStyle.side_name(side).to_lower(), 15, &"mute"
	)
	line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(line)
	add_fill()
	var ready := UiKit.primary("Ready")
	ready.pressed.connect(func() -> void: ready_pressed.emit())
	add_centered(ready)
	column.add_child(UiKit.spacer(40.0))


## A large marble with the ring that marks whose turn it is.
class _Disc:
	extends Control

	var side: int = 0

	func _init(side_index: int) -> void:
		side = side_index
		custom_minimum_size = Vector2(MARBLE_RADIUS * 3.4, MARBLE_RADIUS * 2.8)
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var c := size / 2.0
		# The ring under the marble, seen at a slant: a flat ellipse.
		var ring := PackedVector2Array()
		for i in 49:
			var a := TAU * float(i) / 48.0
			ring.append(
				(
					c
					+ Vector2(
						cos(a) * MARBLE_RADIUS * 1.55,
						MARBLE_RADIUS * 0.7 + sin(a) * MARBLE_RADIUS * 0.62
					)
				)
			)
		draw_polyline(ring, Appearance.color(&"ink"), 3.0, true)
		SideChip.draw_marble(self, c, side, MARBLE_RADIUS)
