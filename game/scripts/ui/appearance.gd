class_name Appearance
extends RefCounted
## The player's theme choice and the colours it resolves to. System follows the device.

enum Choice { SYSTEM, LIGHT, DARK }

static var choice: Choice = Choice.SYSTEM


static func scheme() -> Palette.Scheme:
	match choice:
		Choice.LIGHT:
			return Palette.Scheme.LIGHT
		Choice.DARK:
			return Palette.Scheme.DARK
	if DisplayServer.is_dark_mode_supported() and DisplayServer.is_dark_mode():
		return Palette.Scheme.DARK
	return Palette.Scheme.LIGHT


static func color(token: StringName) -> Color:
	return Palette.get_color(token, scheme())
