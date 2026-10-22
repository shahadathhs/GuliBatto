class_name Content
extends RefCounted
## The pages, rules cards, diagrams and links shown in the game, from data/content.json. That file
## is generated from the content/ folder by scripts/content.mjs, the same source the site will
## read, so the two cannot drift apart.

const PATH := "res://data/content.json"
const BLOCK_TYPES: Array[String] = [
	"heading", "paragraph", "list", "steps", "diagram", "term", "qa", "link"
]

static var _data: Dictionary = {}


## The text of a page title.
static func title(page_id: String) -> String:
	return str(page(page_id).get("title", ""))


## A page: {"title": String, "blocks": Array}. Empty when there is no such page.
static func page(page_id: String) -> Dictionary:
	return _all().get("pages", {}).get(page_id, {})


static func page_ids() -> Array:
	return _all().get("pages", {}).keys()


## The blocks of a page that are shown on this device (a link can be hidden on the web or on
## Android, where it would point back at where you already are).
static func blocks(page_id: String, on_web: bool = OS.has_feature("web")) -> Array:
	var out: Array = []
	for b in page(page_id).get("blocks", []):
		if is_visible(b, on_web, OS.has_feature("android")):
			out.append(b)
	return out


static func is_visible(block: Dictionary, on_web: bool, on_android: bool) -> bool:
	var hide: String = block.get("hide_on", "")
	return not ((hide == "web" and on_web) or (hide == "android" and on_android))


## The short rules card of a mode: {"title", "diagram", "lines"}.
static func card(mode_id: StringName) -> Dictionary:
	return _all().get("cards", {}).get(String(mode_id), {})


static func diagram(diagram_id: String) -> Dictionary:
	return _all().get("diagrams", {}).get(diagram_id, {})


static func link(link_id: String) -> String:
	return str(_all().get("links", {}).get(link_id, ""))


static func _all() -> Dictionary:
	if _data.is_empty():
		var file := FileAccess.open(PATH, FileAccess.READ)
		if file != null:
			var parsed: Variant = JSON.parse_string(file.get_as_text())
			if parsed is Dictionary:
				_data = parsed
	return _data
