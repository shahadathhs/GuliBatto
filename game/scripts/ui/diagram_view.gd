class_name DiagramView
extends Control
## Draws one diagram from the content data: the ground, the jalla, holes, marbles with their
## marks, arrows and labels, in the game's own colours. The same description will be drawn as SVG
## on the site. Positions are metres on the ground, x to the right and z toward the player, so
## down the screen.

const WIDTH := 318.0
const DEFAULT_MAX_HEIGHT := 380.0

var _diagram: Dictionary
var _scale: float = 1.0
var _origin: Vector2 = Vector2.ZERO


func _init(diagram_id: String = "", max_height: float = DEFAULT_MAX_HEIGHT) -> void:
	_diagram = Content.diagram(diagram_id)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var half: Array = _diagram.get("half", [3.0, 3.0])
	_scale = minf(WIDTH / (2.0 * float(half[0])), max_height / (2.0 * float(half[1])))
	custom_minimum_size = Vector2(WIDTH, 2.0 * float(half[1]) * _scale)


func _draw() -> void:
	_origin = Vector2(size.x / 2.0, size.y / 2.0)
	for item in _diagram.get("items", []):
		match item["kind"]:
			"arena":
				_draw_arena(item)
			"line":
				_draw_line(item)
			"hole":
				_draw_hole(item)
			"marble":
				_draw_marble(item)
			"arrow":
				_draw_arrow(item)
			"cross":
				_draw_cross(item)
			"finger":
				draw_circle(_p(item["at"]), 9.0, Appearance.color(&"mute"))
			"label":
				_draw_label(item)


## A ground position on the control.
func _p(at: Array) -> Vector2:
	return _origin + Vector2(float(at[0]), float(at[1])) * _scale


func _draw_arena(item: Dictionary) -> void:
	var rim := Appearance.color(&"earth_rim")
	var earth := Appearance.color(&"earth")
	if item["shape"] == "circle":
		var r: float = float(item["r"]) * _scale
		draw_circle(_origin, r + 5.0, rim)
		draw_circle(_origin, r, earth)
	else:
		var half := Vector2(float(item["half"][0]), float(item["half"][1])) * _scale
		draw_rect(Rect2(_origin - half - Vector2(5.0, 5.0), half * 2.0 + Vector2(10.0, 10.0)), rim)
		draw_rect(Rect2(_origin - half, half * 2.0), earth)


func _draw_line(item: Dictionary) -> void:
	var a := _p(item["from"])
	var b := _p(item["to"])
	if item["style"] == "pull":
		draw_dashed_line(a, b, Appearance.color(&"ink"), 2.0, 6.0)
	else:
		draw_dashed_line(a, b, Appearance.color(&"ink"), 3.0, 12.0)


func _draw_hole(item: Dictionary) -> void:
	var at := _p(item["at"])
	var r: float = float(item["r"]) * _scale
	draw_circle(at, r, Appearance.color(&"hole"))
	if item.has("label"):
		_text(str(item["label"]), at + Vector2(r + 8.0, 5.0), 15, Appearance.color(&"ink"))


func _draw_marble(item: Dictionary) -> void:
	var at := _p(item["at"])
	var r: float = maxf(float(item["r"]) * _scale, 7.0)
	SideChip.draw_marble(self, at, int(item["side"]), r)
	if item.has("label"):
		# Centred under the marble, so it never lands on a hole or a neighbour.
		var below := at + Vector2(-30.0, r + 15.0)
		draw_string(
			UiKit.bold_font(),
			below,
			str(item["label"]),
			HORIZONTAL_ALIGNMENT_CENTER,
			60.0,
			13,
			Appearance.color(&"ink")
		)


func _draw_arrow(item: Dictionary) -> void:
	var a := _p(item["from"])
	var b := _p(item["to"])
	var style: String = item["style"]
	var colour := Appearance.color(&"glaze")
	if style == "away" or style == "route_back":
		colour = Appearance.color(&"ink")
	var width := 3.0
	if style == "route" or style == "route_back":
		width = 2.5
	if style == "away" or style == "route_back":
		draw_dashed_line(a, b - (b - a).normalized() * 6.0, colour, width, 8.0)
	else:
		draw_line(a, b - (b - a).normalized() * 6.0, colour, width, true)
	var dir := (b - a).normalized()
	var side := Vector2(-dir.y, dir.x)
	var head := PackedVector2Array([b, b - dir * 13.0 + side * 6.5, b - dir * 13.0 - side * 6.5])
	draw_colored_polygon(head, colour)


func _draw_cross(item: Dictionary) -> void:
	var at := _p(item["at"]) + Vector2(0.0, -2.0)
	var colour := Appearance.color(&"hole")
	draw_line(at + Vector2(-9.0, -9.0), at + Vector2(9.0, 9.0), colour, 3.0, true)
	draw_line(at + Vector2(-9.0, 9.0), at + Vector2(9.0, -9.0), colour, 3.0, true)


func _draw_label(item: Dictionary) -> void:
	_text(str(item["text"]), _p(item["at"]), 13, Appearance.color(&"ink"))


func _text(text: String, at: Vector2, font_size: int, colour: Color) -> void:
	draw_string(UiKit.bold_font(), at, text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size, colour)
