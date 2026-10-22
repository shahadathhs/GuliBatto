class_name PitTags
extends Node3D
## A deep hole hides what is in it from a low camera, so a marble resting in one is marked on the
## lip: a small flat token in its side's colour and mark, lying on the near rim of that hole. The
## marble itself stays in the pit and keeps rolling under real physics; the token only says who is
## down there.

const LIFT := 0.014
## How far from the hole's centre the tokens lie, as a share of the dish radius, and how far
## apart they sit.
const RIM := 1.12
const GAP := 4.0
## A marble is in a pit once its centre is this far below the ground.
const IN_PIT := -0.05

var board: Board
var profile: RuleProfile
var scheme: Palette.Scheme

var _tags: Dictionary = {}


func _init(game_board: Board, rule_profile: RuleProfile, colour_scheme: Palette.Scheme) -> void:
	board = game_board
	profile = rule_profile
	scheme = colour_scheme


## Whether this profile has holes deep enough to hide a marble.
static func needed(rule_profile: RuleProfile) -> bool:
	return rule_profile.dish_depth > rule_profile.marble_radius * 1.5


func _physics_process(_delta: float) -> void:
	var inside: Dictionary = {}
	for hole in profile.holes.size():
		var ids: Array[int] = []
		for m in board.marbles():
			if _in_pit(m, profile.holes[hole]):
				ids.append(m.marble_id)
		ids.sort()
		for i in ids.size():
			inside[ids[i]] = _spot(profile.holes[hole], i, ids.size())
	for id in _tags.keys():
		if not inside.has(id):
			_tags[id].queue_free()
			_tags.erase(id)
	for id in inside:
		if not _tags.has(id):
			_tags[id] = _make(board.marble(id))
		(_tags[id] as Node3D).position = inside[id]


func _in_pit(m: Marble, hole: Vector2) -> bool:
	var at := m.ground_position()
	return at.distance_to(hole) < profile.dish_radius and m.global_position.y < IN_PIT


func _spot(hole: Vector2, index: int, count: int) -> Vector3:
	var step := profile.marble_radius * GAP
	var x := (float(index) - float(count - 1) / 2.0) * step
	return Vector3(
		hole.x + x, LIFT, hole.y + profile.dish_radius * RIM + profile.marble_radius * 1.6
	)


func _make(marble: Marble) -> Node3D:
	var tag := Node3D.new()
	var radius := profile.marble_radius * 1.9
	var disc := MeshInstance3D.new()
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = radius
	cylinder.bottom_radius = radius
	cylinder.height = 0.012
	disc.mesh = cylinder
	var material := StandardMaterial3D.new()
	material.albedo_color = SideStyle.colour(marble.side, scheme)
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	disc.material_override = material
	tag.add_child(disc)
	var mark := MarbleBadge.mark_instance(marble.side, radius * 1.6, scheme)
	mark.position = Vector3(0.0, 0.012, 0.0)
	tag.add_child(mark)
	add_child(tag)
	return tag
