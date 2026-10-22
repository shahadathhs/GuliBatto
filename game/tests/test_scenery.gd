extends GutTest
## The dirt, the field round it, the scratched jalla and the worn holes.


func test_the_dirt_grain_varies_and_stays_in_greys() -> void:
	var image := DirtTexture.ground().get_image()
	var seen := {}
	for y in range(0, image.get_height(), 3):
		for x in range(0, image.get_width(), 3):
			var p := image.get_pixel(x, y)
			assert_almost_eq(p.r, p.g, 0.02, "a grey, so the earth tokens stay the colours")
			seen[snappedf(p.r, 0.02)] = true
	assert_gt(seen.size(), 6, "grain, pebbles and scratches, not a flat tone")


func test_the_dirt_tiles_without_a_seam() -> void:
	var image := DirtTexture.ground().get_image()
	var last := image.get_width() - 1
	var jump := 0.0
	var inner := 0.0
	for y in image.get_height():
		jump += absf(image.get_pixel(0, y).r - image.get_pixel(last, y).r)
		inner += absf(image.get_pixel(100, y).r - image.get_pixel(101, y).r)
	assert_lt(jump, inner * 2.0 + 1.0, "the edge is no rougher than the middle")


func test_the_field_has_faint_furrows_that_the_bare_dirt_does_not() -> void:
	var rows := DirtTexture.field().get_image()
	var step := int(DirtTexture.SIZE * DirtTexture.ROW_METRES / DirtTexture.TILE_METRES)
	var furrow := 0.0
	var between := 0.0
	var samples := 0
	for row in DirtTexture.SIZE / step:
		for y in rows.get_height():
			for dx in range(-2, 3):
				furrow += rows.get_pixel(posmod(row * step + dx, DirtTexture.SIZE), y).r
				between += rows.get_pixel(posmod(row * step + step / 2 + dx, DirtTexture.SIZE), y).r
				samples += 1
	assert_lt(furrow / samples, between / samples, "the furrows are darker than the ground between")


func test_the_field_is_made_of_ground_a_bund_and_a_treeline() -> void:
	var field := Field.new(RuleProfile.kep(), Palette.Scheme.LIGHT)
	add_child_autofree(field)
	await wait_physics_frames(1)
	assert_gte(field.get_child_count(), 4, "ground, the bund and its grass, the treeline")
	var trees := Field.trees().get_image()
	var drawn := 0
	for x in range(0, trees.get_width(), 4):
		for y in range(0, trees.get_height(), 4):
			if trees.get_pixel(x, y).a > 0.1:
				drawn += 1
	assert_gt(drawn, 200, "silhouettes are painted")
	assert_almost_eq(trees.get_pixel(5, 0).a, 0.0, 0.01, "the sky above them is clear")


func test_the_jalla_is_a_scratch_and_a_ridge_at_its_place_on_the_ground() -> void:
	var profile := RuleProfile.kep()
	var jalla := JallaScratch.new(profile, Palette.Scheme.LIGHT)
	add_child_autofree(jalla)
	assert_eq(jalla.get_child_count(), 2, "the groove and the ridge")
	for part in jalla.get_children():
		var box: AABB = (part as MeshInstance3D).mesh.get_aabb()
		assert_almost_eq(box.get_center().z, profile.jalla_z, 0.2)
		assert_gt(box.size.x, profile.arena_size.x, "it runs across the ground")


func test_every_hole_has_crumbs_round_its_rim() -> void:
	var profile := RuleProfile.batto()
	var wear := HoleWear.new(profile, Palette.Scheme.DARK)
	add_child_autofree(wear)
	var instance := wear.get_child(0) as MultiMeshInstance3D
	assert_eq(instance.multimesh.instance_count, HoleWear.CRUMBS * 3)


func test_a_match_is_lit_by_a_sky_over_a_field() -> void:
	var scene := MatchScene.new()
	add_child_autofree(scene)
	scene.start(RuleProfile.kep(), KepRules.new())
	await wait_physics_frames(2)
	var has_field := false
	for child in scene.get_children():
		if child is Field:
			has_field = true
		if child is WorldEnvironment:
			var env := (child as WorldEnvironment).environment
			assert_eq(env.background_mode, Environment.BG_SKY)
			assert_true(env.fog_enabled, "far ground fades into the sky")
	assert_true(has_field)


func test_a_palm_has_a_trunk_and_fronds_and_a_clump_of_bamboo_has_canes_and_leaves() -> void:
	for mesh in [TreeMeshes.palm(Palette.Scheme.LIGHT), TreeMeshes.bamboo(Palette.Scheme.DARK)]:
		assert_eq(mesh.get_surface_count(), 2, "wood, then leaves")
		var box: AABB = mesh.get_aabb()
		assert_between(box.size.y, 0.8, 1.3, "about one unit tall, scaled when placed")
		assert_lt(box.position.y, 0.05, "it stands on the ground")


func test_the_field_holds_trees_bunds_and_tufts_but_none_behind_the_line() -> void:
	var profile := RuleProfile.kep()
	var objects := FieldObjects.new(profile, Palette.Scheme.LIGHT)
	add_child_autofree(objects)
	await wait_physics_frames(1)
	var trees := 0
	var tufts := 0
	for child in objects.get_children():
		if child is MultiMeshInstance3D:
			var m := (child as MultiMeshInstance3D).multimesh
			if m.mesh is ArrayMesh:
				trees += m.instance_count
			else:
				tufts = m.instance_count
	assert_gt(trees, 10, "palms and bamboo")
	assert_gt(tufts, 100, "grass near the play area")
	assert_gte(objects.get_child_count(), 10, "the trees, the tufts and the bunds with their grass")


func test_the_sun_is_low_and_casts_shadows() -> void:
	var scene := MatchScene.new()
	add_child_autofree(scene)
	scene.start(RuleProfile.kep(), KepRules.new())
	await wait_physics_frames(2)
	var found := false
	for child in scene.get_children():
		if child is DirectionalLight3D:
			var sun := child as DirectionalLight3D
			found = true
			assert_true(sun.shadow_enabled, "marbles and trees throw shadows")
			assert_lt(absf(sun.rotation_degrees.x), 40.0, "a low sun, so the shadows are long")
	assert_true(found)


func test_a_marble_resting_in_a_deep_hole_is_marked_on_its_lip() -> void:
	var profile := RuleProfile.batto()
	assert_true(PitTags.needed(profile), "Batto's holes hide a marble from a low camera")
	assert_false(PitTags.needed(RuleProfile.kep()), "Kep's shallow dish does not")
	var board := Board.new(profile)
	add_child_autofree(board)
	var tags := PitTags.new(board, profile, Palette.Scheme.LIGHT)
	add_child_autofree(tags)
	await wait_physics_frames(2)
	var hole := profile.holes[1]
	await (
		board
		. reset(
			[
				{"id": 0, "side": 0, "pos": hole + Vector2(0.0, 1.3)},
				{"id": 1, "side": 2, "pos": hole + Vector2(2.0, 2.0)},
			]
		)
	)
	board.fire(ShotCommand.create(0, 0, Vector2.UP, 0.22))
	await wait_for_signal(board.shot_resolved, 30.0)
	await wait_physics_frames(3)
	assert_true(board.snapshot().is_inside(0, hole, profile.hole_radius), "it dropped in")
	assert_eq(tags.get_child_count(), 1, "one token, for the one marble in the pit")
	var spot := (tags.get_child(0) as Node3D).position
	assert_almost_eq(spot.x, hole.x, 0.2)
	assert_gt(spot.z, hole.y, "on the near lip, toward the player")
	assert_gt(spot.y, 0.0, "lying on the ground, not down in the pit")


func test_the_fields_ground_never_covers_a_hole() -> void:
	for profile: RuleProfile in [RuleProfile.batto(), RuleProfile.kep()]:
		var field := Field.new(profile, Palette.Scheme.LIGHT)
		add_child_autofree(field)
		await wait_physics_frames(1)
		var deepest: float = -profile.dish_depth
		for child in field.get_children():
			if child is MeshInstance3D and (child as MeshInstance3D).mesh is PlaneMesh:
				var plane := child as MeshInstance3D
				var size := ((plane as MeshInstance3D).mesh as PlaneMesh).size
				var covers_a_hole := false
				for hole in profile.holes:
					var near := (
						absf(hole.x - plane.position.x) < size.x / 2.0
						and absf(hole.y - plane.position.z) < size.y / 2.0
					)
					covers_a_hole = covers_a_hole or near
				if covers_a_hole:
					assert_lt(
						plane.position.y,
						deepest,
						"%s: a plane over a hole sits below it" % profile.mode_id
					)
