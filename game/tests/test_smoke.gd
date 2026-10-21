extends GutTest
## Milestone 0 smoke test: the main scene loads and a marble settles on the ground.

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")


func test_main_scene_loads() -> void:
	var root: Node = MAIN_SCENE.instantiate()
	add_child_autofree(root)
	assert_not_null(root.get_node_or_null("Marble"), "scene has a marble")
	assert_not_null(root.get_node_or_null("Camera"), "scene has a camera")


func test_marble_comes_to_rest_on_the_ground() -> void:
	var root: Node = MAIN_SCENE.instantiate()
	add_child_autofree(root)
	var marble: RigidBody3D = root.get_node("Marble")
	await wait_physics_frames(180)
	assert_lt(marble.linear_velocity.length(), 0.1, "marble is at rest")
	assert_gt(marble.global_position.y, 0.0, "marble did not fall through the ground")
	assert_lt(marble.global_position.y, 0.5, "marble dropped onto the ground")
