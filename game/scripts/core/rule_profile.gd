class_name RuleProfile
extends Resource
## The data a mode needs: how many sides, rounds, where the line and holes are. A profile holds
## data only; the decisions are in the rules scripts.

@export var mode_id: StringName = &"bench"
@export var title: String = ""
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
	p.holes = PackedVector2Array([Tuning.BATTO_H1, Tuning.BATTO_H2, Tuning.BATTO_H3])
	p.route = PackedInt32Array([0, 1, 2, 1, 0])
	return p
