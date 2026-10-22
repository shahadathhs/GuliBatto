class_name SoundDirector
extends Node
## Turns what happens in a match into sound: the shot leaving the finger, marbles and walls
## struck, a marble dropping into a hole, and the end of the match. It only listens; it changes
## nothing in the match. In pass and play it also marks each hand-over and each turn.

## A marble is down in a hole once it is this far below the floor, and is up again above RISEN.
const DROPPED_BELOW := -0.04
const RISEN_ABOVE := -0.01

var board: Board
var controller: MatchController

var _down: Dictionary = {}


func _init(game_board: Board, match_controller: MatchController) -> void:
	board = game_board
	controller = match_controller
	board.marble_hit.connect(
		func(speed: float) -> void: Sfx.play(Sfx.Event.HIT, Sfx.strength_for_speed(speed))
	)
	board.wall_hit.connect(
		func(speed: float) -> void: Sfx.play(Sfx.Event.WALL, Sfx.strength_for_speed(speed))
	)
	controller.shot_started.connect(func(_side: int) -> void: Sfx.play(Sfx.Event.SHOT))
	controller.match_over.connect(_on_match_over)
	controller.handover_needed.connect(func(_side: int) -> void: Sfx.play(Sfx.Event.PASS))
	controller.turn_started.connect(_on_turn_started)


func _physics_process(_delta: float) -> void:
	for m in board.marbles():
		var y := m.global_position.y
		var was_down: bool = _down.get(m.marble_id, false)
		if y < DROPPED_BELOW and not was_down:
			_down[m.marble_id] = true
			Sfx.play(Sfx.Event.DROP, Sfx.strength_for_speed(m.linear_velocity.length() + 3.0))
		elif y > RISEN_ABOVE and was_down:
			_down[m.marble_id] = false


## Pass and play: a soft tock, higher for each side, when its turn begins.
func _on_turn_started(side: int, human: bool) -> void:
	if human and controller.setup.hands_over():
		Sfx.play(Sfx.Event.TURN, 0.8, Sfx.pitch_for_side(side))


func _on_match_over(ranking: Array[int]) -> void:
	var won := ranking.size() > 0 and controller.setup.is_human(ranking[0])
	Sfx.play(Sfx.Event.WIN if won else Sfx.Event.LOSE)
