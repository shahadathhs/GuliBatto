class_name PowerMeter
extends Control
## The power bar shown while aiming: an outlined rounded bar filled with glaze, and the percentage.

var power: float = 0.0:
	set(value):
		power = value
		queue_redraw()


func _init() -> void:
	custom_minimum_size = Vector2(220.0, 52.0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
	var ink := Appearance.color(&"ink")
	var bar := Rect2(10.0, 4.0, size.x - 20.0, 14.0)
	var back := StyleBoxFlat.new()
	back.bg_color = Appearance.color(&"ground")
	back.border_color = ink
	back.set_border_width_all(2)
	back.set_corner_radius_all(7)
	draw_style_box(back, bar)
	if power > 0.0:
		var fill := StyleBoxFlat.new()
		fill.bg_color = Appearance.color(&"glaze")
		fill.set_corner_radius_all(7)
		draw_style_box(fill, Rect2(bar.position, Vector2(bar.size.x * power, bar.size.y)))
	var text := "POWER %d%%" % int(round(power * 100.0))
	var font := UiKit.bold_font()
	var width := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 14).x
	draw_string(
		font, Vector2((size.x - width) / 2.0, 42.0), text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 14, ink
	)
