class_name MatchController
extends Node
## Runs a match: whose turn it is, placing the shooter's marble, taking a shot from the player or
## the AI, asking the rules what happened, and moving on. It is the only place turn, score and
## phase change. The UI reads it through signals and sends intent (submit_shot,
## continue_after_result).

signal turn_started(side: int, is_human: bool)
## A shot was fired and the marbles are rolling.
signal shot_started(side: int)
## A shot was judged and play goes on: the next toss, the next side, or a bonus shot.
signal shot_judged(side: int, result: RuleResult)
## A round was scored (the last round of a match too). `match_over` follows for the last.
signal round_scored(result: RuleResult, totals: Array[int])
signal match_over(ranking: Array[int])
## Guli Khela: the player must name a baad before throwing, and has named one.
signal baad_needed
signal baad_named(marble_id: int)

enum Phase {
	IDLE, WAITING_FOR_BAAD, WAITING_FOR_SHOT, SHOT_IN_FLIGHT, RESULT_CUE, ROUND_RESULT, MATCH_OVER
}

var phase: Phase = Phase.IDLE
var state: MatchState
var human_side: int = 0
## The marble the player has named as baad for this throw, or -1.
var named_baad: int = -1
## The baad of the shot in flight (the player's or a computer side's), or -1.
var last_baad: int = -1
## Seconds an AI side waits before it shoots, and the pause after a toss lands.
var ai_delay: float = 0.9
var cue_delay: float = 1.0
## When true a round result continues by itself (tests and all-AI matches).
var auto_continue: bool = false

var _board: Board
var _profile: RuleProfile
var _rules: RuleSet
var _ai: Dictionary = {}


func start(
	board: Board, profile: RuleProfile, rules: RuleSet, human: int = 0, seed_value: int = 0
) -> void:
	_board = board
	_profile = profile
	_rules = rules
	human_side = human
	_ai.clear()
	for side in profile.side_count:
		if side != human:
			_ai[side] = _rules.make_ai(seed_value + side * 7919 if seed_value != 0 else 0)
	if not _board.shot_resolved.is_connected(_on_shot_resolved):
		_board.shot_resolved.connect(_on_shot_resolved)
	state = _rules.start(profile, profile.side_count)
	_rules.seed_state(state, seed_value)
	_board.clear_marbles()
	_begin_turn()


func current_side() -> int:
	return state.current_side()


func is_human_turn() -> bool:
	return phase == Phase.WAITING_FOR_SHOT and current_side() == human_side


## The player's shot. Refused unless it is the player's turn and the command is for their marble,
## and, when the rules want a baad, unless one has been named (it is added to the command here).
func submit_shot(command: ShotCommand) -> bool:
	if not is_human_turn() or command.side != human_side or command.marble_id != human_side:
		return false
	if _rules.needs_baad(state):
		if named_baad < 0:
			return false
		command.baad_marble_id = named_baad
	return _fire(command)


## True while the player may tap a marble to name it as baad.
func can_name_baad() -> bool:
	var waiting := phase == Phase.WAITING_FOR_BAAD or phase == Phase.WAITING_FOR_SHOT
	return waiting and current_side() == human_side and _rules.needs_baad(state)


## The marbles the player may name as baad now.
func baad_choices() -> Array[int]:
	return _rules.baad_choices(state, _board.snapshot())


## The player names (or changes) the baad. Only a marble the rules allow can be named.
func name_baad(marble_id: int) -> bool:
	if not can_name_baad():
		return false
	if not baad_choices().has(marble_id):
		return false
	named_baad = marble_id
	phase = Phase.WAITING_FOR_SHOT
	baad_named.emit(marble_id)
	return true


## The player gives up: the match ends and they are last.
func surrender() -> bool:
	if not _rules.can_surrender() or phase == Phase.MATCH_OVER or phase == Phase.IDLE:
		return false
	_rules.surrender(state, human_side)
	phase = Phase.MATCH_OVER
	match_over.emit(_rules.ranking(state))
	return true


## The player pressed Next on the round result.
func continue_after_result() -> void:
	if phase != Phase.ROUND_RESULT:
		return
	_board.clear_marbles()
	_begin_turn()


func _begin_turn() -> void:
	if _rules.is_out(state, human_side):
		# The player cannot go on (they could not pay a stake): nothing is left to play for.
		phase = Phase.MATCH_OVER
		match_over.emit(_rules.ranking(state))
		return
	var side := state.current_side()
	named_baad = -1
	# Kep starts each toss on the line; in Batto a marble stays where it came to rest.
	if _board.marble(side) == null:
		_board.place(side, side, _rules.spawn_position(state, _profile, _board.snapshot()))
	else:
		# A marble resting in a hole is shot from the edge of the hole, not from inside it.
		var start: Variant = _rules.shot_start(state, _profile, _board.snapshot(), side)
		if start != null:
			await _board.move_marble(side, start as Vector2)
	phase = Phase.WAITING_FOR_SHOT
	if side == human_side and _rules.needs_baad(state):
		phase = Phase.WAITING_FOR_BAAD
	turn_started.emit(side, side == human_side)
	if phase == Phase.WAITING_FOR_BAAD:
		baad_needed.emit()
	if side != human_side:
		await get_tree().create_timer(ai_delay, false).timeout
		if phase == Phase.WAITING_FOR_SHOT and current_side() == side:
			var ai: TossAI = _ai[side]
			_fire(ai.choose(state, _profile, _board.snapshot(), side))


func _fire(command: ShotCommand) -> bool:
	if not _board.fire(command):
		return false
	phase = Phase.SHOT_IN_FLIGHT
	last_baad = command.baad_marble_id
	shot_started.emit(current_side())
	return true


func _on_shot_resolved(snapshot: BoardSnapshot, report: ShotReport, _timed_out: bool) -> void:
	if phase != Phase.SHOT_IN_FLIGHT:
		return
	var side := state.current_side()
	var result := _rules.evaluate(state, _profile, snapshot, report)
	if result.kind == &"toss" or result.kind == &"turn":
		phase = Phase.RESULT_CUE
		shot_judged.emit(side, result)
		await get_tree().create_timer(cue_delay, false).timeout
		if phase == Phase.MATCH_OVER:
			return
		# Marbles the rules took off the board or put on it (a finished side, a returned throw,
		# the scattered stake, a fine).
		for id in result.remove_marbles:
			_board.remove_marble(id)
		for placed in result.place_marbles:
			_board.place(placed["id"], placed["side"], placed["pos"])
		_begin_turn()
		return
	round_scored.emit(result, state.totals)
	if result.kind == &"match":
		phase = Phase.MATCH_OVER
		match_over.emit(_rules.ranking(state))
		return
	phase = Phase.ROUND_RESULT
	if auto_continue:
		continue_after_result()
