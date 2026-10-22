class_name BattoAI
extends TossAI
## The computer side for Batto. Each turn it weighs two real choices: aim for the hole it must
## reach next, or hit a rival's marble for a bonus shot (and to send a leader away). It prefers
## whichever looks likelier and more useful, with a little noise, then shoots with the usual
## error, so it sometimes picks badly and sometimes misses.

## A hit needs a firm push past the rival.
const HIT_MARGIN := 0.2
const NOISE := 0.15
## Each bonus shot already taken this turn makes another hit less attractive by this much.
const HIT_CHAIN_PENALTY := 0.25
## A rival is a small target, so the computer aims a hit more carefully than a toss at a hole.
const HIT_DIRECTION_ERROR := 0.04


func choose(
	state: MatchState, profile: RuleProfile, snapshot: BoardSnapshot, side: int
) -> ShotCommand:
	var s := state as BattoState
	var from := snapshot.position_of(side)
	if s.opening:
		return choose_toss(side, side, from, profile.holes[profile.route[0]], profile.shot_speed)
	var target := profile.holes[s.next_hole(side)]
	var reach := profile.shot_speed * ROLL_FRACTION
	var best_value := _hole_value(from.distance_to(target) / reach) + rng.randf() * NOISE
	var best_rival := -1
	for id in snapshot.ids():
		# A marble down in a hole cannot be knocked away, so it is not worth hitting.
		if id == side or _in_a_hole(profile, snapshot.position_of(id)):
			continue
		var value := _hit_value(
			from.distance_to(snapshot.position_of(id)) / reach, s.progress[id] - s.progress[side]
		)
		# After a bonus shot the computer gets on with the route instead of hitting again.
		value += rng.randf() * NOISE - HIT_CHAIN_PENALTY * s.bonus_chain
		if value > best_value:
			best_value = value
			best_rival = id
	if best_rival == -1:
		return choose_toss(side, side, from, target, profile.shot_speed)
	return _hit(side, from, snapshot.position_of(best_rival), profile.shot_speed)


func _in_a_hole(profile: RuleProfile, at: Vector2) -> bool:
	for hole in profile.holes:
		if at.distance_to(hole) <= profile.dish_radius:
			return true
	return false


## Distances are a share of how far a full-power shot rolls. Landing in a hole is likely when
## near and unlikely when far.
func _hole_value(distance: float) -> float:
	return clampf(1.1 - distance * 0.9, 0.35, 0.95)


## A hit is likely when near, and only worth much against a side that is ahead on the route.
func _hit_value(distance: float, rival_lead: int) -> float:
	var value := clampf(0.9 - distance * 1.1, 0.05, 0.7)
	return value if rival_lead > 0 else value * 0.4


func _hit(side: int, from: Vector2, rival: Vector2, shot_speed: float) -> ShotCommand:
	var to_rival := rival - from
	var angle := to_rival.angle() + rng.randfn(0.0, HIT_DIRECTION_ERROR)
	var power := (
		to_rival.length() / (shot_speed * ROLL_FRACTION) + HIT_MARGIN + rng.randfn(0.0, power_error)
	)
	return ShotCommand.create(side, side, Vector2.from_angle(angle), clampf(power, 0.1, 1.0))
