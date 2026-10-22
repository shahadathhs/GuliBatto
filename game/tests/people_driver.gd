class_name PeopleDriver
extends Node
## Test helper: plays the sides that are people the way the computer would, so a pass-and-play
## match can run to its end. It confirms every hand-over and shoots each person's turn.

var controller: MatchController
var board: Board
var rules: RuleSet
var profile: RuleProfile
var handovers: Array[int] = []
var _ais: Dictionary = {}


func _init(
	match_controller: MatchController,
	match_board: Board,
	rule_set: RuleSet,
	rule_profile: RuleProfile
) -> void:
	controller = match_controller
	board = match_board
	rules = rule_set
	profile = rule_profile
	controller.handover_needed.connect(_on_handover)
	controller.turn_started.connect(_on_turn)


func _on_handover(side: int) -> void:
	handovers.append(side)
	controller.confirm_handover.call_deferred()


func _on_turn(side: int, human: bool) -> void:
	if not human:
		return
	await get_tree().create_timer(0.03, false).timeout
	if controller.current_side() != side or controller.phase == MatchController.Phase.MATCH_OVER:
		return
	if not _ais.has(side):
		_ais[side] = rules.make_ai(side * 31 + 7)
	var ai: TossAI = _ais[side]
	var command := ai.choose(controller.state, profile, board.snapshot(), side)
	if rules.needs_baad(controller.state):
		controller.name_baad(command.baad_marble_id)
	controller.submit_shot(command)
