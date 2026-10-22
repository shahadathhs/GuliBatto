class_name TossAI
extends RefCounted
## A simple computer side. It aims at the target with a little error in direction and power, so it
## is usually close and sometimes misses. It builds a ShotCommand like the player does.

## How far a marble rolls at full power, as a fraction of its shot speed (measured).
const ROLL_FRACTION := 0.75

var direction_error: float = 0.11
var power_error: float = 0.10
var rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _init(seed_value: int = 0) -> void:
	if seed_value != 0:
		rng.seed = seed_value
	else:
		rng.randomize()


## The shot for `side` from where its marble lies. Kep: toss at the kep.
func choose(
	_state: MatchState, profile: RuleProfile, snapshot: BoardSnapshot, side: int
) -> ShotCommand:
	return choose_toss(side, side, snapshot.position_of(side), profile.holes[0], profile.shot_speed)


## Chooses a toss from `from` at `target`. Power follows the measured roll of about 4.5 m at full
## power (see Tuning), then error is added.
func choose_toss(
	side: int,
	marble_id: int,
	from: Vector2,
	target: Vector2,
	shot_speed: float = Tuning.MAX_SHOT_SPEED
) -> ShotCommand:
	var to_target := target - from
	var angle := to_target.angle() + rng.randfn(0.0, direction_error)
	var power := to_target.length() / (shot_speed * ROLL_FRACTION) + rng.randfn(0.0, power_error)
	return ShotCommand.create(side, marble_id, Vector2.from_angle(angle), clampf(power, 0.08, 1.0))
