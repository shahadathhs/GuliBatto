extends GutTest
## The generated palette has the same tokens in both themes and keeps text readable.

const REQUIRED: Array[StringName] = [
	&"ground",
	&"ink",
	&"floor",
	&"mute",
	&"line",
	&"glaze",
	&"on_glaze",
	&"amber",
	&"on_amber",
	&"jade",
	&"on_jade",
	&"plum",
	&"on_plum",
	&"bone",
	&"foul",
	&"earth",
	&"earth_rim",
	&"hole",
	&"shadow",
	&"highlight",
]


func _luminance(c: Color) -> float:
	var f := func(v: float) -> float:
		return v / 12.92 if v <= 0.03928 else pow((v + 0.055) / 1.055, 2.4)
	return 0.2126 * f.call(c.r) + 0.7152 * f.call(c.g) + 0.0722 * f.call(c.b)


func _ratio(a: Color, b: Color) -> float:
	var la := _luminance(a)
	var lb := _luminance(b)
	return (maxf(la, lb) + 0.05) / (minf(la, lb) + 0.05)


func test_both_themes_define_every_token() -> void:
	for token in REQUIRED:
		assert_true(Palette.LIGHT.has(token), "light has %s" % token)
		assert_true(Palette.DARK.has(token), "dark has %s" % token)


func test_text_is_readable_on_the_ground_in_both_themes() -> void:
	for scheme in [Palette.Scheme.LIGHT, Palette.Scheme.DARK]:
		var ground := Palette.get_color(&"ground", scheme)
		assert_gt(_ratio(Palette.get_color(&"ink", scheme), ground), 7.0, "ink on ground")
		assert_gt(_ratio(Palette.get_color(&"mute", scheme), ground), 4.5, "mute on ground")


func test_primary_action_text_is_readable_on_glaze() -> void:
	for scheme in [Palette.Scheme.LIGHT, Palette.Scheme.DARK]:
		var glaze := Palette.get_color(&"glaze", scheme)
		assert_gt(_ratio(Palette.get_color(&"on_glaze", scheme), glaze), 4.5, "on_glaze on glaze")
