extends GutTest
## A marble is a swirl you can see turning, with a shadow under it.


func test_the_swirl_is_not_one_flat_colour() -> void:
	var colour := Palette.get_color(&"glaze", Palette.Scheme.LIGHT)
	var image := MarbleTexture.make_image(colour)
	var seen := {}
	for y in range(0, image.get_height(), 4):
		for x in range(0, image.get_width(), 4):
			seen[image.get_pixel(x, y).to_html()] = true
	assert_gt(seen.size(), 8, "light and dark bands show on the marble")


func test_the_swirl_stays_in_the_sides_colour_family() -> void:
	var colour := Palette.get_color(&"amber", Palette.Scheme.LIGHT)
	var image := MarbleTexture.make_image(colour)
	var average := colour * 0.0
	var count := 0
	for y in image.get_height():
		for x in image.get_width():
			var p := image.get_pixel(x, y)
			average += p
			count += 1
	average /= float(count)
	assert_almost_eq(average.h, colour.h, 0.08, "still amber, not another side's colour")


func test_the_left_and_right_edges_meet() -> void:
	var image := MarbleTexture.make_image(Palette.get_color(&"jade", Palette.Scheme.DARK))
	var width := image.get_width()
	for y in range(0, image.get_height(), 8):
		var a := image.get_pixel(0, y)
		var b := image.get_pixel(width - 1, y)
		assert_lt(absf(a.r - b.r) + absf(a.g - b.g) + absf(a.b - b.b), 0.3, "no seam at row %d" % y)


func test_a_texture_is_made_once_for_each_colour() -> void:
	var colour := Palette.get_color(&"plum", Palette.Scheme.LIGHT)
	assert_same(MarbleTexture.for_colour(colour), MarbleTexture.for_colour(colour))


func test_every_marble_has_a_swirl_and_a_shadow_that_follow_it() -> void:
	var board := Board.new(RuleProfile.kep())
	add_child_autofree(board)
	await wait_physics_frames(2)
	var m := board.place(0, 0, Vector2(0.4, 0.2))
	await wait_physics_frames(3)
	var material := (m.get_child(1) as MeshInstance3D).material_override as StandardMaterial3D
	assert_not_null(material.albedo_texture, "the marble carries its swirl")
	var shadow: MarbleShadow = board._shadows[0]
	assert_almost_eq(shadow.global_position.y, 0.004, 0.02, "the shadow lies on the ground")
	assert_almost_eq(shadow.global_position.x, m.global_position.x, 0.2)
	board.remove_marble(0)
	await wait_physics_frames(2)
	assert_false(board._shadows.has(0), "the shadow goes with the marble")
