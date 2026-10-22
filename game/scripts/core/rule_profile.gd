class_name RuleProfile
extends Resource
## The data a mode needs: how many sides, rounds, where the line and holes are. A profile holds
## data only; the decisions are in the rules scripts.

@export var mode_id: StringName = &"bench"
@export var title: String = ""
## The marble, and the speed a full-power shot gives it.
@export var marble_radius: float = Tuning.MARBLE_RADIUS
@export var shot_speed: float = Tuning.MAX_SHOT_SPEED
## The floor: a circle (arena_size.x is the radius) or, with arena_rect, a rectangle whose half
## width and half length are arena_size.
@export var arena_rect: bool = false
@export var arena_size: Vector2 = Vector2(Tuning.ARENA_RADIUS, Tuning.ARENA_RADIUS)
## How far the finger is pulled for full power, and how the camera frames the floor.
@export var max_pull: float = 2.4
@export var camera_focus: Vector2 = Vector2(0.0, 0.3)
@export var camera_scale: float = 1.0
## A board bigger than the screen: the camera follows the marble about to shoot, looking a little
## toward its target. The top-down view then stands `camera_overview` back to show the whole board,
## and the view can zoom out to `camera_max_distance`. Zero keeps the defaults.
@export var camera_follow: bool = false
@export var camera_look_ahead: float = 0.0
@export var camera_overview: float = 0.0
@export var camera_max_distance: float = 0.0
@export var side_count: int = 3
@export var rounds: int = 1
## Z of the line to stand behind; marbles are tossed from here toward negative Z.
@export var jalla_z: float = Tuning.JALLA_Z
## Ground positions of the holes (the kep, or H1 to H3).
@export var holes: PackedVector2Array = PackedVector2Array()
@export var hole_radius: float = Tuning.KEP_RADIUS
@export var dish_radius: float = Tuning.DISH_RADIUS
@export var dish_depth: float = Tuning.DISH_DEPTH
## Points for a marble in the kep, and for the closest and next closest outside it (Kep).
@export var points_in_hole: int = 3
@export var points_closest: int = 2
@export var points_second: int = 1
## Batto: the order of hole indices a side must reach, the most bonus shots in one turn, and the
## most turns a side may take before the race is stopped.
@export var route: PackedInt32Array = PackedInt32Array()
@export var bonus_cap: int = 3
@export var turn_cap: int = 40


## Flat arena, no holes: the physics test bench.
static func bench() -> RuleProfile:
	var p := RuleProfile.new()
	p.mode_id = &"bench"
	return p


static func kep() -> RuleProfile:
	var p := RuleProfile.new()
	p.mode_id = &"kep"
	p.title = "Kep"
	p.side_count = 3
	p.rounds = 5
	p.holes = PackedVector2Array([Tuning.KEP_POSITION])
	return p


static func batto() -> RuleProfile:
	var p := RuleProfile.new()
	p.mode_id = &"batto"
	p.title = "Batto"
	p.side_count = 3
	p.marble_radius = Tuning.BATTO_MARBLE_RADIUS
	p.shot_speed = Tuning.BATTO_SHOT_SPEED
	p.arena_rect = true
	p.arena_size = Tuning.BATTO_HALF_SIZE
	p.jalla_z = Tuning.BATTO_JALLA_Z
	p.holes = PackedVector2Array([Tuning.BATTO_H1, Tuning.BATTO_H2, Tuning.BATTO_H3])
	p.hole_radius = Tuning.BATTO_HOLE_RADIUS
	p.dish_radius = Tuning.BATTO_DISH_RADIUS
	p.dish_depth = Tuning.BATTO_DISH_DEPTH
	p.max_pull = Tuning.BATTO_MAX_PULL
	p.camera_focus = Vector2.ZERO
	p.camera_scale = Tuning.BATTO_CAMERA_SCALE
	p.camera_follow = true
	p.camera_look_ahead = Tuning.BATTO_LOOK_AHEAD
	p.camera_overview = Tuning.BATTO_OVERVIEW_DISTANCE
	p.camera_max_distance = Tuning.BATTO_CAMERA_MAX_DISTANCE
	p.route = PackedInt32Array([0, 1, 2, 1, 0])
	return p
