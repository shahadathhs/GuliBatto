class_name Marble
extends RigidBody3D
## A marble: a sphere that rolls under real physics. Only this class applies impulses.

## Emitted once for each contact with another marble. The bench turns these into a ShotReport.
signal touched_marble(marble: Marble, other: Marble)

var marble_id: int = -1
var side: int = -1


func _init() -> void:
	mass = Tuning.MARBLE_MASS
	linear_damp = Tuning.LINEAR_DAMP
	angular_damp = Tuning.ANGULAR_DAMP
	continuous_cd = true
	contact_monitor = true
	max_contacts_reported = 8
	physics_material_override = _make_material()
	body_entered.connect(_on_body_entered)


## Builds the collision shape and a plain coloured sphere. id and side are set before adding.
func setup(id: int, side_index: int, colour: Color) -> void:
	marble_id = id
	side = side_index
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = Tuning.MARBLE_RADIUS
	shape.shape = sphere
	add_child(shape)
	var mesh := MeshInstance3D.new()
	var sphere_mesh := SphereMesh.new()
	sphere_mesh.radius = Tuning.MARBLE_RADIUS
	sphere_mesh.height = Tuning.MARBLE_RADIUS * 2.0
	mesh.mesh = sphere_mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = colour
	material.roughness = 0.15
	mesh.material_override = material
	add_child(mesh)


func apply_shot(command: ShotCommand) -> void:
	apply_central_impulse(command.impulse(Tuning.MAX_SHOT_SPEED, mass))


## Freezes the marble in place at a ground position, with all motion cleared. Every marble is
## held first and released together, so a reset can never leave two marbles overlapping.
func hold_at(ground_position: Vector2) -> void:
	freeze = true
	global_transform = Transform3D(
		Basis.IDENTITY, Vector3(ground_position.x, Tuning.MARBLE_RADIUS, ground_position.y)
	)
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO


func release() -> void:
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	freeze = false
	sleeping = false


func ground_position() -> Vector2:
	return Vector2(global_position.x, global_position.z)


func _on_body_entered(body: Node) -> void:
	if body is Marble:
		touched_marble.emit(self, body)


func _make_material() -> PhysicsMaterial:
	var m := PhysicsMaterial.new()
	m.friction = Tuning.MARBLE_FRICTION
	m.bounce = Tuning.MARBLE_BOUNCE
	return m
