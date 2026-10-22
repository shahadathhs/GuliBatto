class_name IconButton
extends Control
## A 48 px round control with a drawn glyph: outlined, or filled when selected. The glyphs are the
## ones in the concept renders: pause, three camera views, reset, back.

signal pressed

enum Glyph { PAUSE, ANGLED, TOP, LOW, RESET, BACK, HELP }

const SIZE := 48.0

var glyph: Glyph = Glyph.PAUSE
var selected: bool = false:
	set(value):
		selected = value
		queue_redraw()


func _init(which: Glyph = Glyph.PAUSE) -> void:
	glyph = which
	custom_minimum_size = Vector2(SIZE, SIZE)
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		Sfx.play(Sfx.Event.TAP)
		pressed.emit()
		accept_event()


func _draw() -> void:
	var c := size / 2.0
	var ink := Appearance.color(&"ink")
	var ground := Appearance.color(&"ground")
	var fill := ink if selected else ground
	var line := ground if selected else ink
	draw_circle(c, SIZE / 2.0 - 2.0, fill)
	draw_arc(c, SIZE / 2.0 - 2.0, 0.0, TAU, 48, ink, 2.0, true)
	match glyph:
		Glyph.PAUSE:
			draw_rect(Rect2(c + Vector2(-7.0, -8.0), Vector2(5.0, 16.0)), line)
			draw_rect(Rect2(c + Vector2(2.0, -8.0), Vector2(5.0, 16.0)), line)
		Glyph.ANGLED:
			var pts := [
				Vector2(-10, 5), Vector2(0, -6), Vector2(10, 5), Vector2(0, 10), Vector2(-10, 5)
			]
			draw_polyline(
				PackedVector2Array(pts.map(func(p: Vector2) -> Vector2: return c + p)),
				line,
				2.0,
				true
			)
		Glyph.TOP:
			draw_arc(c, 9.0, 0.0, TAU, 24, line, 2.0, true)
			draw_circle(c, 2.5, line)
		Glyph.LOW:
			draw_line(c + Vector2(-11, 5), c + Vector2(11, 5), line, 2.0, true)
			draw_arc(c + Vector2(0, -2), 5.0, 0.0, TAU, 16, line, 2.0, true)
		Glyph.RESET:
			draw_arc(c, 9.0, deg_to_rad(40), deg_to_rad(330), 24, line, 2.0, true)
			var head := [Vector2(8, -11), Vector2(8, -3), Vector2(0, -3)]
			draw_polyline(
				PackedVector2Array(head.map(func(p: Vector2) -> Vector2: return c + p)),
				line,
				2.0,
				true
			)
		Glyph.HELP:
			draw_arc(c + Vector2(0, -4), 6.0, deg_to_rad(180), deg_to_rad(450), 16, line, 2.5, true)
			draw_line(c + Vector2(0, 2), c + Vector2(0, 5), line, 2.5, true)
			draw_circle(c + Vector2(0, 10), 1.8, line)
		Glyph.BACK:
			var chevron := [Vector2(4, -9), Vector2(-5, 0), Vector2(4, 9)]
			draw_polyline(
				PackedVector2Array(chevron.map(func(p: Vector2) -> Vector2: return c + p)),
				line,
				2.5,
				true
			)
