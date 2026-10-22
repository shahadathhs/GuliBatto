# Generated from design/tokens.json by scripts/tokens.mjs. Do not edit.
class_name Palette
extends RefCounted
## Light and dark colour tokens. Names use snake_case (on_glaze, earth_rim).

enum Scheme { LIGHT, DARK }

const LIGHT := {
	"ground": Color(0.9529, 0.9216, 0.8667),
	"ink": Color(0.1647, 0.1255, 0.0902),
	"floor": Color(0.9843, 0.9647, 0.9255),
	"mute": Color(0.3961, 0.3333, 0.2471),
	"line": Color(0.5490, 0.4627, 0.3451),
	"glaze": Color(0.1059, 0.3451, 0.7216),
	"on_glaze": Color(1.0000, 1.0000, 1.0000),
	"amber": Color(0.8902, 0.6039, 0.0706),
	"on_amber": Color(0.1647, 0.1255, 0.0902),
	"jade": Color(0.1216, 0.4784, 0.3608),
	"on_jade": Color(1.0000, 1.0000, 1.0000),
	"plum": Color(0.4784, 0.2431, 0.5569),
	"on_plum": Color(1.0000, 1.0000, 1.0000),
	"rose": Color(0.7216, 0.2196, 0.4314),
	"on_rose": Color(1.0000, 1.0000, 1.0000),
	"bone": Color(0.9098, 0.8627, 0.7686),
	"foul": Color(0.6980, 0.2275, 0.1412),
	"earth": Color(0.7882, 0.6471, 0.4784),
	"earth_rim": Color(0.6627, 0.5216, 0.3451),
	"hole": Color(0.3569, 0.2549, 0.1569),
	"shadow": Color(0.1647, 0.1255, 0.0902, 0.2784),
	"highlight": Color(1.0000, 1.0000, 1.0000),
}

const DARK := {
	"ground": Color(0.0902, 0.0745, 0.0627),
	"ink": Color(0.9529, 0.9176, 0.8588),
	"floor": Color(0.1333, 0.1098, 0.0863),
	"mute": Color(0.7098, 0.6392, 0.5451),
	"line": Color(0.5490, 0.4627, 0.3451),
	"glaze": Color(0.4314, 0.6588, 1.0000),
	"on_glaze": Color(0.0588, 0.0784, 0.1098),
	"amber": Color(0.9490, 0.6588, 0.1490),
	"on_amber": Color(0.0902, 0.0745, 0.0627),
	"jade": Color(0.3608, 0.7686, 0.6275),
	"on_jade": Color(0.0510, 0.1020, 0.0824),
	"plum": Color(0.7804, 0.6039, 0.8471),
	"on_plum": Color(0.1020, 0.0627, 0.1255),
	"rose": Color(0.9490, 0.5412, 0.7098),
	"on_rose": Color(0.1216, 0.0588, 0.0902),
	"bone": Color(0.8471, 0.7882, 0.6745),
	"foul": Color(0.9412, 0.5412, 0.4471),
	"earth": Color(0.4196, 0.3216, 0.2196),
	"earth_rim": Color(0.3059, 0.2314, 0.1569),
	"hole": Color(0.1412, 0.1020, 0.0627),
	"shadow": Color(0.0000, 0.0000, 0.0000, 0.4510),
	"highlight": Color(1.0000, 1.0000, 1.0000),
}


static func get_color(token: StringName, scheme: Scheme) -> Color:
	var table: Dictionary = LIGHT if scheme == Scheme.LIGHT else DARK
	assert(table.has(token), "unknown colour token: %s" % token)
	return table[token]
