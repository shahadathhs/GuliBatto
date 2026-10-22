class_name GuliAI
extends TossAI
## The computer side for Guli Khela. It tosses at the kep like any side. On an attempt it picks
## the marble that looks easiest to touch alone (far from the others, with a clear line to it),
## names as baad the marble most likely to be touched by mistake (the one nearest its target),
## and throws just hard enough to arrive. It aims with the usual error, so it sometimes touches
## the wrong marble, two, or none.

## How much the choice of target is shaken by chance.
const NOISE := 0.25
## A throw arrives with this much to spare, so it touches rather than stops short.
const ARRIVE_MARGIN := 0.06


func _init(seed_value: int = 0) -> void:
	super(seed_value)
	# A marble is a small target in a crowd, so the computer is a little less sure than at the kep.
	direction_error = 0.17
	power_error = 0.16


func choose(
	state: MatchState, profile: RuleProfile, snapshot: BoardSnapshot, side: int
) -> ShotCommand:
	var s := state as GuliState
	var from := snapshot.position_of(side)
	if s.stage == GuliState.Stage.OPENING:
		return choose_toss(side, side, from, s.kep, profile.shot_speed)
	var ground: Array[int] = []
	for id in s.ground:
		if snapshot.has_marble(id):
			ground.append(id)
	var target := _pick_target(snapshot, from, ground)
	var baad := _pick_baad(snapshot, target, ground)
	var to_target := snapshot.position_of(target) - from
	var angle := to_target.angle() + rng.randfn(0.0, direction_error)
	var reach := profile.shot_speed * ROLL_FRACTION
	var power := (
		(to_target.length() - profile.marble_radius * 2.0) / reach
		+ ARRIVE_MARGIN
		+ rng.randfn(0.0, power_error)
	)
	return ShotCommand.create(side, side, Vector2.from_angle(angle), clampf(power, 0.08, 1.0), baad)


## The marble that is far from the rest and has nothing in the way, near the line, with a little
## chance in the choice.
func _pick_target(snapshot: BoardSnapshot, from: Vector2, ground: Array[int]) -> int:
	var best := ground[0]
	var best_score := -INF
	for id in ground:
		var at := snapshot.position_of(id)
		var apart := INF
		var in_the_way := INF
		for other in ground:
			if other == id:
				continue
			var there := snapshot.position_of(other)
			apart = minf(apart, at.distance_to(there))
			var closest := Geometry2D.get_closest_point_to_segment(there, from, at)
			in_the_way = minf(in_the_way, closest.distance_to(there))
		var score := minf(apart, 1.0) + minf(in_the_way, 0.6) - 0.05 * at.distance_to(from)
		score += rng.randf() * NOISE
		if score > best_score:
			best_score = score
			best = id
	return best


## The marble nearest the target that is not the target.
func _pick_baad(snapshot: BoardSnapshot, target: int, ground: Array[int]) -> int:
	var best := -1
	var best_distance := INF
	for id in ground:
		if id == target:
			continue
		var d := snapshot.distance_between(id, target)
		if d < best_distance:
			best_distance = d
			best = id
	return best
