class_name SideStyle
extends RefCounted
## How a side looks: its colour token, the token for its mark, and the mark itself. Colour is never
## the only signal, so every side also has a mark: ring, dot, bar, triangle.

enum Mark { RING, DOT, BAR, TRIANGLE }

## A marble that belongs to no side (the stake and the fines in Guli Khela): bone, with a bar.
const NEUTRAL := -1

const COLOURS: Array[StringName] = [&"glaze", &"amber", &"jade", &"plum"]
const ON_COLOURS: Array[StringName] = [&"on_glaze", &"on_amber", &"on_jade", &"on_plum"]
const MARKS: Array[Mark] = [Mark.RING, Mark.DOT, Mark.BAR, Mark.TRIANGLE]


static func colour(side: int, scheme: Palette.Scheme) -> Color:
	if side == NEUTRAL:
		return Palette.get_color(&"bone", scheme)
	return Palette.get_color(COLOURS[side % COLOURS.size()], scheme)


static func on_colour(side: int, scheme: Palette.Scheme) -> Color:
	if side == NEUTRAL:
		return Palette.get_color(&"ink", scheme)
	return Palette.get_color(ON_COLOURS[side % ON_COLOURS.size()], scheme)


static func mark(side: int) -> Mark:
	if side == NEUTRAL:
		return Mark.BAR
	return MARKS[side % MARKS.size()]
