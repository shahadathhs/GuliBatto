class_name SafeArea
extends RefCounted
## Phones have a notch, a camera hole or a status bar over the top of the screen. The game is laid
## out for a 390 pixel wide portrait screen, so the room the system takes at the top is measured in
## those pixels, and the top row of a screen starts below it.

const BASE_WIDTH := 390.0
## The gap the screens leave at the top of a screen with nothing over it.
const TOP_MARGIN := 44.0
const BREATHING := 16.0


## The top margin for a screen: 44 px, or more where the system covers the top.
static func top() -> float:
	return maxf(TOP_MARGIN, inset_top() + BREATHING)


## How much of the top of the screen the system covers, in the game's pixels (0 on a computer).
static func inset_top() -> float:
	var safe := DisplayServer.get_display_safe_area()
	var window := DisplayServer.window_get_size()
	if safe.size.y <= 0 or window.x <= 0:
		return 0.0
	return float(safe.position.y) * BASE_WIDTH / float(window.x)
