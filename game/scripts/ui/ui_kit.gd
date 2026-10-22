class_name UiKit
extends RefCounted
## The planned control styles: one primary disc per screen, outlined secondary buttons, underlined
## text actions, bold labels. Everything takes its colours from Appearance, never a literal.

const PRIMARY_SIZE := 112.0
const BUTTON_RADIUS := 14
const FONT_STATES := ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]


static func bold_font() -> Font:
	var f := FontVariation.new()
	f.base_font = ThemeDB.fallback_font
	f.variation_embolden = 0.9
	return f


static func label(text: String, size: int, token: StringName = &"ink", bold: bool = false) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", Appearance.color(token))
	if bold:
		l.add_theme_font_override("font", bold_font())
	return l


## A caption in capitals: small, muted, bold.
static func caption(text: String) -> Label:
	return label(text.to_upper(), 12, &"mute", true)


static func _style(fill: Color, border: Color, border_width: int, radius: int) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = fill
	s.border_color = border
	s.set_border_width_all(border_width)
	s.set_corner_radius_all(radius)
	s.content_margin_left = 16
	s.content_margin_right = 16
	return s


static func _apply_states(button: Button, normal: StyleBoxFlat, pressed: StyleBoxFlat) -> void:
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", normal)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("focus", normal)
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


## The one primary action: a solid glaze disc with its label inside.
static func primary(text: String, size: float = PRIMARY_SIZE) -> Button:
	var b := Button.new()
	b.text = text.to_upper()
	b.custom_minimum_size = Vector2(size, size)
	b.add_theme_font_size_override("font_size", 16 if text.length() <= 6 else 13)
	b.add_theme_font_override("font", bold_font())
	for state in FONT_STATES:
		b.add_theme_color_override(state, Appearance.color(&"on_glaze"))
	var fill := Appearance.color(&"glaze")
	var radius := int(size / 2.0)
	_apply_states(b, _style(fill, fill, 0, radius), _style(fill.darkened(0.15), fill, 0, radius))
	b.pressed.connect(_tap)
	return b


## A secondary action: an outlined rounded rectangle on the ground colour.
static func secondary(text: String, width: float = 220.0) -> Button:
	var b := Button.new()
	b.text = text.to_upper()
	b.custom_minimum_size = Vector2(width, 48.0)
	b.add_theme_font_size_override("font_size", 15)
	b.add_theme_font_override("font", bold_font())
	for state in FONT_STATES:
		b.add_theme_color_override(state, Appearance.color(&"ink"))
	var ink := Appearance.color(&"ink")
	var ground := Appearance.color(&"ground")
	var pressed := Appearance.color(&"floor")
	_apply_states(b, _style(ground, ink, 2, BUTTON_RADIUS), _style(pressed, ink, 2, BUTTON_RADIUS))
	b.pressed.connect(_tap)
	return b


## A tertiary action: underlined text.
static func text_action(text: String) -> LinkButton:
	var l := LinkButton.new()
	l.text = text
	l.underline = LinkButton.UNDERLINE_MODE_ALWAYS
	l.add_theme_font_size_override("font_size", 15)
	l.add_theme_color_override("font_color", Appearance.color(&"ink"))
	l.add_theme_color_override("font_hover_color", Appearance.color(&"ink"))
	l.add_theme_color_override("font_pressed_color", Appearance.color(&"mute"))
	l.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	l.focus_mode = Control.FOCUS_NONE
	l.pressed.connect(_tap)
	return l


static func _tap() -> void:
	Sfx.play(Sfx.Event.TAP)


static func spacer(height: float) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(0.0, height)
	return c


static func ground_background() -> ColorRect:
	var r := ColorRect.new()
	r.color = Appearance.color(&"ground")
	r.set_anchors_preset(Control.PRESET_FULL_RECT)
	r.mouse_filter = Control.MOUSE_FILTER_STOP
	return r
