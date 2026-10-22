class_name SideStyle
extends RefCounted
## How a side looks: its colour token, the token for its mark, and the mark itself. Colour is never
## the only signal, so every side also has a mark: ring, dot, bar, triangle, diamond.

enum Mark { RING, DOT, BAR, TRIANGLE, DIAMOND }

## The most sides a match can have (pass and play with five people).
const MAX_SIDES := 5
const NAMES: Array[String] = ["Blue", "Amber", "Jade", "Plum", "Rose"]

## A marble that belongs to no side (the stake and the fines in Guli Khela): bone, with a bar.
const NEUTRAL := -1

const COLOURS: Array[StringName] = [&"glaze", &"amber", &"jade", &"plum", &"rose"]
const ON_COLOURS: Array[StringName] = [&"on_glaze", &"on_amber", &"on_jade", &"on_plum", &"on_rose"]
const MARKS: Array[Mark] = [Mark.RING, Mark.DOT, Mark.BAR, Mark.TRIANGLE, Mark.DIAMOND]


static func colour(side: int, scheme: Palette.Scheme) -> Color:
	if side == NEUTRAL:
		return Palette.get_color(&"bone", scheme)
	return Palette.get_color(COLOURS[_checked(side)], scheme)


static func on_colour(side: int, scheme: Palette.Scheme) -> Color:
	if side == NEUTRAL:
		return Palette.get_color(&"ink", scheme)
	return Palette.get_color(ON_COLOURS[_checked(side)], scheme)


static func mark(side: int) -> Mark:
	if side == NEUTRAL:
		return Mark.BAR
	return MARKS[_checked(side)]


## The side's name ("Blue"), used where a colour alone would not be read aloud.
static func side_name(side: int) -> String:
	return NAMES[_checked(side)]


## A side index that has a style. A sixth side would wrap round to the first and look the same as
## it, so it is an error instead.
static func _checked(side: int) -> int:
	assert(side >= 0 and side < MAX_SIDES, "side %d has no style" % side)
	return clampi(side, 0, MAX_SIDES - 1)
