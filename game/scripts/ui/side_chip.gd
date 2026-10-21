class_name SideChip
extends Control
## A side's marble, drawn with its mark, followed by a short label. Used in the HUD and on results.

const MARBLE_RADIUS := 9.0

var side: int = 0
var text: String = "":
	set(value):
		text = value
		queue_redraw()


func _init(side_index: int = 0, label_text: String = "") -> void:
	side = side_index
	text = label_text
	custom_minimum_size = Vector2(
		MARBLE_RADIUS * 2.0 + 6.0 + 7.5 * maxf(label_text.length(), 1.0), 22.0
	)


static func draw_marble(
	canvas: CanvasItem, centre: Vector2, side_index: int, radius: float
) -> void:
	var scheme := Appearance.scheme()
	var body := SideStyle.colour(side_index, scheme)
	var mark := SideStyle.on_colour(side_index, scheme)
	canvas.draw_circle(centre, radius, body)
	canvas.draw_arc(centre, radius, 0.0, TAU, 32, Appearance.color(&"ink"), 1.5, true)
	match SideStyle.mark(side_index):
		SideStyle.Mark.RING:
			canvas.draw_arc(
				centre, radius * 0.48, 0.0, TAU, 24, mark, maxf(1.5, radius / 6.0), true
			)
		SideStyle.Mark.DOT:
			canvas.draw_circle(centre, radius * 0.24, mark)
		SideStyle.Mark.BAR:
			var bar := Rect2(
				centre + Vector2(-radius * 0.5, -radius * 0.12), Vector2(radius, radius * 0.24)
			)
			canvas.draw_rect(bar, mark)
		SideStyle.Mark.TRIANGLE:
			var tri := [
				Vector2(0, -radius * 0.5),
				Vector2(radius * 0.5, radius * 0.38),
				Vector2(-radius * 0.5, radius * 0.38)
			]
			canvas.draw_colored_polygon(
				PackedVector2Array(tri.map(func(p: Vector2) -> Vector2: return centre + p)), mark
			)


func _draw() -> void:
	draw_marble(self, Vector2(MARBLE_RADIUS + 1.0, 11.0), side, MARBLE_RADIUS)
	if text != "":
		var font := UiKit.bold_font()
		var origin := Vector2(MARBLE_RADIUS * 2.0 + 8.0, 16.0)
		draw_string(
			font, origin, text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 13, Appearance.color(&"ink")
		)
