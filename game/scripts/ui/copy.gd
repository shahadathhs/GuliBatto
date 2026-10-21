class_name Copy
extends RefCounted
## Words shown in the game, loaded from data/copy.json. The About text mirrors docs/README_ABOUT.md
## and web/src/app/about; change all three together.

const PATH := "res://data/copy.json"


static func about() -> Array[Array]:
	return _section("about")


static func how_to_play() -> Array[Array]:
	return _section("how_to_play")


static func _section(key: String) -> Array[Array]:
	var out: Array[Array] = []
	var file := FileAccess.open(PATH, FileAccess.READ)
	if file == null:
		return out
	var data: Variant = JSON.parse_string(file.get_as_text())
	if data is Dictionary and data.has(key):
		for entry in data[key]:
			out.append([entry[0], entry[1]])
	return out
