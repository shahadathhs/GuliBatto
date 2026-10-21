class_name SideStyle
extends RefCounted
## How a side looks: its colour token, the token for its mark, and the mark itself. Colour is never
## the only signal, so every side also has a mark: ring, dot, bar, triangle.

enum Mark { RING, DOT, BAR, TRIANGLE }

const COLOURS: Array[StringName] = [&"glaze", &"amber", &"jade", &"plum"]
const ON_COLOURS: Array[StringName] = [&"on_glaze", &"on_amber", &"on_jade", &"on_plum"]
const MARKS: Array[Mark] = [Mark.RING, Mark.DOT, Mark.BAR, Mark.TRIANGLE]


static func colour(side: int, scheme: Palette.Scheme) -> Color:
	return Palette.get_color(COLOURS[side % COLOURS.size()], scheme)


static func on_colour(side: int, scheme: Palette.Scheme) -> Color:
	return Palette.get_color(ON_COLOURS[side % ON_COLOURS.size()], scheme)


static func mark(side: int) -> Mark:
	return MARKS[side % MARKS.size()]
