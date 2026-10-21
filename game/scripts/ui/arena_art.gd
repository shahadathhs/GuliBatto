class_name ArenaArt
extends Control
## A flat drawing of the arena for the menu: the ground, a ring of rim, the kep, the jalla and a few
## marbles. It is an illustration, not the 3D scene.


func _init() -> void:
	custom_minimum_size = Vector2(342.0, 250.0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
	var c := Vector2(size.x / 2.0, 125.0)
	var rx := 165.0
	var ry := 112.0
	_ellipse(c + Vector2(0.0, 7.0), rx + 5.0, ry + 5.0, Appearance.color(&"earth_rim"))
	_ellipse(c, rx, ry, Appearance.color(&"earth"))
	_ellipse(c + Vector2(0.0, -34.0), 17.0, 9.0, Appearance.color(&"hole"))
	var ink := Appearance.color(&"ink")
	var y := c.y + 58.0
	for i in 6:
		var x := c.x - 90.0 + i * 36.0
		draw_line(Vector2(x, y), Vector2(x + 20.0, y), ink, 3.0, true)
	SideChip.draw_marble(self, c + Vector2(-48.0, -6.0), 1, 11.0)
	SideChip.draw_marble(self, c + Vector2(44.0, -16.0), 2, 11.0)
	SideChip.draw_marble(self, c + Vector2(0.0, 66.0), 0, 13.0)


func _ellipse(centre: Vector2, rx: float, ry: float, colour: Color) -> void:
	var pts := PackedVector2Array()
	for i in 64:
		var a := TAU * float(i) / 64.0
		pts.append(centre + Vector2(cos(a) * rx, sin(a) * ry))
	draw_colored_polygon(pts, colour)
