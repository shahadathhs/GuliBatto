class_name MatchController
extends Node
## Runs a match: whose turn it is, placing the shooter's marble, taking a shot from the player or
## the AI, asking the rules what happened, and moving on. It is the only place turn, score and
## phase change. The UI reads it through signals and sends intent (submit_shot,
## continue_after_result).

signal turn_started(side: int, is_human: bool)
## A shot was fired and the marbles are rolling.
signal shot_started(side: int)
## A toss landed and the round goes on.
signal toss_resolved(side: int)
## A round was scored (the last round of a match too). `match_over` follows for the last.
signal round_scored(result: RuleResult, totals: Array[int])
signal match_over(ranking: Array[int])

enum Phase { IDLE, WAITING_FOR_SHOT, SHOT_IN_FLIGHT, RESULT_CUE, ROUND_RESULT, MATCH_OVER }

var phase: Phase = Phase.IDLE
var state: MatchState
var human_side: int = 0
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
			_ai[side] = TossAI.new(seed_value + side * 7919 if seed_value != 0 else 0)
	if not _board.shot_resolved.is_connected(_on_shot_resolved):
		_board.shot_resolved.connect(_on_shot_resolved)
	state = _rules.start(profile, profile.side_count)
	_board.clear_marbles()
	_begin_turn()


func current_side() -> int:
	return state.current_side()


func is_human_turn() -> bool:
	return phase == Phase.WAITING_FOR_SHOT and current_side() == human_side


## The player's shot. Refused unless it is the player's turn and the command is for their marble.
func submit_shot(command: ShotCommand) -> bool:
	if not is_human_turn() or command.side != human_side or command.marble_id != human_side:
		return false
	return _fire(command)


## The player pressed Next on the round result.
func continue_after_result() -> void:
	if phase != Phase.ROUND_RESULT:
		return
	_board.clear_marbles()
	_begin_turn()


func _begin_turn() -> void:
	var side := state.current_side()
	var spawn := _rules.spawn_position(state, _profile, _board.snapshot())
	_board.place(side, side, spawn)
	phase = Phase.WAITING_FOR_SHOT
	turn_started.emit(side, side == human_side)
	if side != human_side:
		await get_tree().create_timer(ai_delay, false).timeout
		if phase == Phase.WAITING_FOR_SHOT and current_side() == side:
			var ai: TossAI = _ai[side]
			_fire(ai.choose_toss(side, side, spawn, _profile.holes[0]))


func _fire(command: ShotCommand) -> bool:
	if not _board.fire(command):
		return false
	phase = Phase.SHOT_IN_FLIGHT
	shot_started.emit(current_side())
	return true


func _on_shot_resolved(snapshot: BoardSnapshot, report: ShotReport, _timed_out: bool) -> void:
	if phase != Phase.SHOT_IN_FLIGHT:
		return
	var side := state.current_side()
	var result := _rules.evaluate(state, _profile, snapshot, report)
	if result.kind == &"toss":
		phase = Phase.RESULT_CUE
		toss_resolved.emit(side)
		await get_tree().create_timer(cue_delay, false).timeout
		_begin_turn()
		return
	round_scored.emit(result, state.totals)
	if result.kind == &"match":
		phase = Phase.MATCH_OVER
		match_over.emit(state.ranking())
		return
	phase = Phase.ROUND_RESULT
	if auto_continue:
		continue_after_result()
