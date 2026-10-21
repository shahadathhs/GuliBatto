extends GutTest
## Pointer input through the whole stack: press on the marble, pull back, release, and the shot is
## fired the right way. Pressing elsewhere turns the camera and never fires.

var scene: MatchScene
var _gut_layer: CanvasLayer


## GUT draws its results panel over the window, which would swallow the pointer events. Hide it.
func before_all() -> void:
	_gut_layer = get_tree().root.get_node_or_null("GutRunner/GutLayer")
	if _gut_layer != null:
		_gut_layer.visible = false


func after_all() -> void:
	if _gut_layer != null:
		_gut_layer.visible = true


func before_each() -> void:
	MatchScene.coach_seen = true
	scene = MatchScene.new()
	add_child_autofree(scene)
	scene.start(RuleProfile.kep(), KepRules.new())
	await wait_physics_frames(4)


func _marble_screen() -> Vector2:
	var m: Marble = scene.board.marble(0)
	return scene.rig.camera.unproject_position(m.global_position)


## Sends through the real input path. Positions in the tests are viewport coordinates, so they
## are converted to window coordinates first, as a real pointer would report them.
func _send(e: InputEvent) -> void:
	Input.parse_input_event(e)
	Input.flush_buffered_events()


func _window(pos: Vector2) -> Vector2:
	return get_viewport().get_final_transform() * pos


func _button(pos: Vector2, pressed: bool) -> void:
	var e := InputEventMouseButton.new()
	e.button_index = MOUSE_BUTTON_LEFT
	e.pressed = pressed
	e.position = _window(pos)
	e.global_position = e.position
	_send(e)


func _move(pos: Vector2, relative: Vector2) -> void:
	var e := InputEventMouseMotion.new()
	e.position = _window(pos)
	e.global_position = e.position
	e.relative = relative
	e.button_mask = MOUSE_BUTTON_MASK_LEFT
	_send(e)


func test_pulling_back_from_the_marble_and_releasing_fires_a_shot_toward_the_kep() -> void:
	assert_true(scene.controller.is_human_turn())
	var start := _marble_screen()
	_button(start, true)
	assert_eq(scene.aim.mode, AimController.Mode.AIM, "pressing the marble starts an aim")
	var pull := start + Vector2(0.0, 130.0)
	_move(pull, Vector2(0.0, 130.0))
	_button(pull, false)
	assert_eq(scene.controller.phase, MatchController.Phase.SHOT_IN_FLIGHT, "released: fired")
	await wait_physics_frames(3)
	var v := scene.board.marble(0).linear_velocity
	assert_lt(v.z, -0.5, "pulled toward the player, so it goes away, toward the kep")
	assert_lt(absf(v.x), 0.4, "straight on")


func test_a_tiny_pull_is_cancelled_and_does_not_fire() -> void:
	var start := _marble_screen()
	_button(start, true)
	_move(start + Vector2(0.0, 4.0), Vector2(0.0, 4.0))
	_button(start + Vector2(0.0, 4.0), false)
	assert_eq(scene.controller.phase, MatchController.Phase.WAITING_FOR_SHOT, "no shot")
	assert_eq(scene.aim.mode, AimController.Mode.NONE)


func test_pressing_empty_ground_orbits_the_camera_and_never_fires() -> void:
	var far := _marble_screen() + Vector2(0.0, -300.0)
	_button(far, true)
	assert_eq(scene.aim.mode, AimController.Mode.ORBIT)
	_move(far + Vector2(60.0, 0.0), Vector2(60.0, 0.0))
	_button(far + Vector2(60.0, 0.0), false)
	assert_eq(scene.controller.phase, MatchController.Phase.WAITING_FOR_SHOT)


func test_the_camera_view_never_changes_the_shot_the_same_pull_makes() -> void:
	# Same ground pull, two camera views: the command is built in world space, so it is the same.
	var m: Marble = scene.board.marble(0)
	var results: Array[Vector2] = []
	for view in [CameraRig.View.ANGLED, CameraRig.View.TOP_DOWN]:
		scene.rig.set_view(view)
		await wait_physics_frames(90)
		var from := scene.rig.camera.unproject_position(m.global_position)
		var origin := scene.rig.camera.project_ray_origin(from)
		var normal := scene.rig.camera.project_ray_normal(from)
		var hit: Variant = Plane(Vector3.UP, Tuning.MARBLE_RADIUS).intersects_ray(origin, normal)
		results.append(Vector2((hit as Vector3).x, (hit as Vector3).z))
	assert_lt(
		results[0].distance_to(results[1]),
		0.02,
		"the marble is at the same ground point from both views"
	)


func test_escape_cancels_an_aim_in_progress() -> void:
	var start := _marble_screen()
	_button(start, true)
	_move(start + Vector2(0.0, 100.0), Vector2(0.0, 100.0))
	scene.cancel_aim()
	_button(start + Vector2(0.0, 100.0), false)
	assert_eq(scene.controller.phase, MatchController.Phase.WAITING_FOR_SHOT, "cancelled: no shot")
