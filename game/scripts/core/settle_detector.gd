class_name SettleDetector
extends RefCounted
## Decides when a board has stopped moving. Fed each physics frame with the marbles' speeds.
## Settled means every marble stays under both thresholds for a continuous window. A hard
## timeout ends settling anyway, so a turn can never be stuck.

var linear_threshold: float = Tuning.SETTLE_LINEAR_SPEED
var angular_threshold: float = Tuning.SETTLE_ANGULAR_SPEED
var window: float = Tuning.SETTLE_WINDOW
var timeout: float = Tuning.SETTLE_TIMEOUT

var elapsed: float = 0.0
var calm_time: float = 0.0
var timed_out: bool = false


func reset() -> void:
	elapsed = 0.0
	calm_time = 0.0
	timed_out = false


## linear_speeds and angular_speeds hold one entry per marble.
func feed(
	delta: float, linear_speeds: PackedFloat32Array, angular_speeds: PackedFloat32Array
) -> void:
	elapsed += delta
	if (
		_all_below(linear_speeds, linear_threshold)
		and _all_below(angular_speeds, angular_threshold)
	):
		calm_time += delta
	else:
		calm_time = 0.0
	if elapsed >= timeout:
		timed_out = true


func is_settled() -> bool:
	return calm_time >= window or timed_out


func _all_below(speeds: PackedFloat32Array, limit: float) -> bool:
	for s in speeds:
		if s > limit:
			return false
	return true
