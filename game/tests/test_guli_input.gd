extends PhysicsTest
## Naming the baad with a tap, through the aim controller: a tap on a stake marble names it, the
## thrower's own marble is still aimed, and empty ground still turns the camera.

var scene: MatchScene


func before_each() -> void:
	Settings.mark_coach_seen()
	scene = MatchScene.new()
	add_child_autofree(scene)
	scene.start(RuleProfile.guli(), GuliRules.new())
	await wait_physics_frames(4)
	# Put the match where the attempts begin, without playing the tosses.
	var s := scene.controller.state as GuliState
	scene.board.clear_marbles()
	s.stage = GuliState.Stage.PASSES
	var order: Array[int] = [0, 1]
	s.order = order
	s.turn_index = 0
	s.scatterer = 2
	s.pot = 9
	var spots := StakeLayout.scatter(9, s.kep, scene.profile, s.rng, [] as Array[Vector2])
	for i in spots.size():
		s.ground.append(100 + i)
		scene.board.place(100 + i, SideStyle.NEUTRAL, spots[i])
	scene.controller._begin_turn()
	await wait_physics_frames(4)


func _on_screen(marble_id: int) -> Vector2:
	return scene.rig.camera.unproject_position(scene.board.marble(marble_id).global_position)


func test_the_player_is_waiting_to_name_a_baad() -> void:
	assert_eq(scene.controller.phase, MatchController.Phase.WAITING_FOR_BAAD)


func test_a_tap_on_a_stake_marble_names_it_the_baad() -> void:
	scene.aim._press(_on_screen(103))
	assert_eq(scene.controller.named_baad, 103)
	assert_eq(scene.controller.phase, MatchController.Phase.WAITING_FOR_SHOT)
	assert_eq(scene.aim.mode, AimController.Mode.NONE, "a tap, not the start of a gesture")
	assert_true(scene.baad_marker.visible, "and the baad is marked")


func test_a_tap_on_another_marble_changes_the_baad() -> void:
	scene.aim._press(_on_screen(103))
	scene.aim._press(_on_screen(105))
	assert_eq(scene.controller.named_baad, 105)


func test_pressing_the_throwing_marble_still_starts_an_aim() -> void:
	scene.aim._press(_on_screen(103))
	scene.aim._press(_on_screen(0))
	assert_eq(scene.aim.mode, AimController.Mode.AIM)
	scene.aim.cancel()


func test_pressing_empty_ground_turns_the_camera_and_names_nothing() -> void:
	var far := Vector2(20.0, 400.0)
	var named_before := scene.controller.named_baad
	scene.aim._press(far)
	assert_eq(scene.aim.mode, AimController.Mode.ORBIT)
	assert_eq(scene.controller.named_baad, named_before)
	scene.aim.cancel()


func test_the_hint_asks_for_a_baad_until_one_is_named() -> void:
	assert_true(scene.hud._hint.visible)
	assert_string_contains(scene.hud._hint.text, "baad")


func test_the_baad_stays_marked_when_the_throw_goes() -> void:
	scene.aim._press(_on_screen(103))
	assert_true(scene.controller.submit_shot(ShotCommand.create(0, 0, Vector2.UP, 0.4)))
	await wait_physics_frames(3)
	assert_true(scene.baad_marker.visible)
	assert_false(scene.hud._hint.visible, "the hint goes once the marble is thrown")
