class_name BattoAI
extends TossAI
## The computer side for Batto. Each turn it weighs two real choices: aim for the hole it must
## reach next, or hit a rival's marble for a bonus shot (and to send a leader away). It prefers
## whichever looks likelier and more useful, with a little noise, then shoots with the usual
## error, so it sometimes picks badly and sometimes misses.

## Rolling distance at full power, measured (see Tuning); a hit needs a firm push past the rival.
const ROLL_AT_FULL_POWER := 4.5
const HIT_MARGIN := 0.2
const NOISE := 0.15


func choose(
	state: MatchState, profile: RuleProfile, snapshot: BoardSnapshot, side: int
) -> ShotCommand:
	var s := state as BattoState
	var from := snapshot.position_of(side)
	if s.opening:
		return choose_toss(side, side, from, profile.holes[profile.route[0]])
	var target := profile.holes[s.next_hole(side)]
	var best_value := _hole_value(from.distance_to(target)) + rng.randf() * NOISE
	var best_rival := -1
	for id in snapshot.ids():
		if id == side:
			continue
		var value := _hit_value(
			from.distance_to(snapshot.position_of(id)), s.progress[id] - s.progress[side]
		)
		value += rng.randf() * NOISE
		if value > best_value:
			best_value = value
			best_rival = id
	if best_rival == -1:
		return choose_toss(side, side, from, target)
	return _hit(side, from, snapshot.position_of(best_rival))


## Landing in a hole is likely when near and unlikely when far.
func _hole_value(distance: float) -> float:
	return clampf(1.2 - distance * 0.3, 0.3, 0.95)


## A hit is likely when near, and worth more against a side that is ahead.
func _hit_value(distance: float, rival_lead: int) -> float:
	var value := clampf(1.0 - distance * 0.25, 0.1, 0.8)
	return value + (0.15 if rival_lead > 0 else 0.0)


func _hit(side: int, from: Vector2, rival: Vector2) -> ShotCommand:
	var to_rival := rival - from
	var angle := to_rival.angle() + rng.randfn(0.0, direction_error)
	var power := to_rival.length() / ROLL_AT_FULL_POWER + HIT_MARGIN + rng.randfn(0.0, power_error)
	return ShotCommand.create(side, side, Vector2.from_angle(angle), clampf(power, 0.1, 1.0))
