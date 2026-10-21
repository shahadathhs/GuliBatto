class_name ShotCommand
extends RefCounted
## One shot as a value: which side, which marble, a ground-plane direction and a power.
## Built by the aim controller or the AI. It carries no camera or screen data.

const DIRECTION_TOLERANCE := 0.001

var side: int
var marble_id: int
## Unit vector on the ground plane: x maps to world X, y maps to world Z.
var direction: Vector2
## 0..1, a fraction of the full shot speed.
var power: float
## Guli Khela only: the marble the side named as baad. -1 when not used.
var baad_marble_id: int


static func create(
	side_index: int,
	marble: int,
	dir: Vector2,
	shot_power: float,
	baad: int = -1,
) -> ShotCommand:
	var cmd := ShotCommand.new()
	cmd.side = side_index
	cmd.marble_id = marble
	cmd.direction = dir
	cmd.power = shot_power
	cmd.baad_marble_id = baad
	return cmd


## True when the command can be fired: a unit direction and a power in (0, 1].
func is_valid() -> bool:
	if absf(direction.length() - 1.0) > DIRECTION_TOLERANCE:
		return false
	return power > 0.0 and power <= 1.0


## The velocity change to give the marble, on the ground plane.
func impulse(max_speed: float, mass: float) -> Vector3:
	return Vector3(direction.x, 0.0, direction.y) * power * max_speed * mass
