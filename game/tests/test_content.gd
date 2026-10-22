extends GutTest
## The shared content: every page, card, diagram and link is there and builds a screen.


func test_every_game_has_a_page_and_a_rules_card() -> void:
	for id in ModeRegistry.ORDER:
		assert_gt(Content.page(ModeRegistry.page_id(id)).size(), 0, "a page for %s" % id)
		var card := Content.card(id)
		assert_gt(card.get("lines", []).size(), 1, "a card for %s" % id)
		assert_gt(Content.diagram(card["diagram"]).size(), 0, "the card's diagram for %s" % id)


func test_the_pages_the_app_links_to_exist() -> void:
	for id in ["how_to_play", "about", "contact", "privacy"]:
		assert_gt(Content.blocks(id, false).size(), 2, id)
		assert_ne(Content.title(id), "", "%s has a title" % id)


func test_every_page_builds_a_screen_with_every_block() -> void:
	for id in Content.page_ids():
		var screen := PageScreen.new(id, false)
		add_child_autofree(screen)
		assert_not_null(screen.find_children("*", "ScrollContainer", true, false)[0], id)


func test_every_block_type_has_a_builder() -> void:
	for id in Content.page_ids():
		for block in Content.blocks(id, false):
			assert_true(Content.BLOCK_TYPES.has(block["type"]), "%s: %s" % [id, block["type"]])
			var node := PageBlocks.build(block, func(_t: String) -> void: pass)
			add_child_autofree(node)
			assert_true(node is Control)


func test_every_diagram_draws_and_has_a_size() -> void:
	var seen := 0
	for id in Content.page_ids():
		for block in Content.blocks(id, false):
			if block["type"] != "diagram":
				continue
			var view := DiagramView.new(block["id"])
			add_child_autofree(view)
			assert_gt(view.custom_minimum_size.x, 100.0, block["id"])
			assert_gt(view.custom_minimum_size.y, 100.0, block["id"])
			seen += 1
	assert_gt(seen, 5, "the pages carry diagrams")


func test_every_card_builds_with_its_diagram() -> void:
	for id in ModeRegistry.ORDER:
		var card := RulesCard.new(id, "Start", true)
		add_child_autofree(card)
		assert_gt(card.find_children("*", "Label", true, false).size(), 3, str(id))
		assert_gt(card.find_children("*", "Button", true, false).size(), 0, "the primary action")


func test_a_diagram_that_is_not_there_is_empty_not_an_error() -> void:
	assert_eq(Content.diagram("nothing").size(), 0)
	var view := DiagramView.new("nothing")
	add_child_autofree(view)
	assert_not_null(view)


func test_links_to_the_web_and_to_android_are_hidden_where_you_already_are() -> void:
	var to_web := {
		"type": "link", "label": "Play on the web", "target": "url:play", "hide_on": "web"
	}
	var to_android := {
		"type": "link", "label": "Get it", "target": "url:download", "hide_on": "android"
	}
	assert_false(Content.is_visible(to_web, true, false), "no link to the web on the web")
	assert_true(Content.is_visible(to_web, false, true), "but one in the Android app")
	assert_false(Content.is_visible(to_android, false, true), "no Android link on Android")
	assert_true(Content.is_visible(to_android, true, false), "but one on the web")


func test_the_contact_page_shows_one_store_link_on_each_platform() -> void:
	var on_web := Content.blocks("contact", true).filter(
		func(b: Dictionary) -> bool: return b["type"] == "link"
	)
	var on_phone := Content.blocks("contact", false).filter(
		func(b: Dictionary) -> bool: return b["type"] == "link"
	)
	var web_targets := on_web.map(func(b: Dictionary) -> String: return b["target"])
	var phone_targets := on_phone.map(func(b: Dictionary) -> String: return b["target"])
	assert_false(web_targets.has("url:play"))
	assert_true(web_targets.has("url:download"))
	assert_true(phone_targets.has("url:play"))
	assert_true(web_targets.has("url:issues"), "and the way to reach the author is always there")
	assert_true(phone_targets.has("url:issues"))


func test_the_web_addresses_are_there() -> void:
	for name in ["site", "play", "download", "issues"]:
		assert_true(Content.link(name).begins_with("https://"), name)
