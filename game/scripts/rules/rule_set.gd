class_name RuleSet
extends RefCounted
## The interface every mode implements. A ruleset reads a profile, the state the match keeps, the
## settled board and the shot report, and decides. It never touches nodes. The text methods say
## what the HUD and the result screens show, so the UI holds no mode branches.


func start(_profile: RuleProfile, _side_count: int) -> MatchState:
	return MatchState.new()


## Where the current side's marble starts its turn, given what already rests on the board. Only
## asked when the side has no marble on the board yet.
func spawn_position(_state: MatchState, _profile: RuleProfile, _snapshot: BoardSnapshot) -> Vector2:
	return Vector2.ZERO


## Where the side's marble is set down before it shoots, or null to shoot from where it lies.
func shot_start(
	_state: MatchState, _profile: RuleProfile, _snapshot: BoardSnapshot, _side: int
) -> Variant:
	return null


## The ground point the side is playing toward (its next hole), or null. The camera looks that way.
func aim_point(_state: MatchState, _profile: RuleProfile, _side: int) -> Variant:
	return null


## Called once per shot, after the board settles. Updates the state and says what happened.
func evaluate(
	_state: MatchState, _profile: RuleProfile, _snapshot: BoardSnapshot, _report: ShotReport
) -> RuleResult:
	return RuleResult.new()


## Seeds whatever randomness the state uses (0 leaves it random).
func seed_state(_state: MatchState, _seed_value: int) -> void:
	pass


## True when a side can no longer play (it could not pay a stake).
func is_out(_state: MatchState, _side: int) -> bool:
	return false


## True when a side must name a marble to avoid (the baad) before it shoots.
func needs_baad(_state: MatchState) -> bool:
	return false


## The marbles a side may name as baad right now.
func baad_choices(_state: MatchState, _snapshot: BoardSnapshot) -> Array[int]:
	return []


## Whether a side may give up, and what giving up does: the match ends and that side is last.
func can_surrender() -> bool:
	return false


func surrender(_state: MatchState, _side: int) -> RuleResult:
	return RuleResult.new()


## The heading of the screen shown when a round or a dan is scored, and the word for the running
## total ("total" for points, "purse" for marbles).
func round_caption(state: MatchState) -> String:
	return "ROUND %d OF %d" % [state.round_index, state.rounds]


func total_word() -> String:
	return "total"


## Sides best first, once the match is over.
func ranking(state: MatchState) -> Array[int]:
	return state.ranking()


## The computer side that plays this mode.
func make_ai(seed_value: int) -> TossAI:
	return TossAI.new(seed_value)


## A short line over the arena: the mode and where the match is.
func caption(_state: MatchState, profile: RuleProfile) -> String:
	return profile.title


## What the turn label says for the side about to shoot.
func turn_text(_state: MatchState, is_human: bool) -> String:
	return "Your shot" if is_human else "Their shot"


## One short label per side for the scoreboard chips.
func standings(state: MatchState) -> Array[String]:
	var out: Array[String] = []
	for side in state.side_count:
		out.append(str(state.totals[side]))
	return out


## The cue shown when a shot has been judged and play goes on.
func cue_text(_result: RuleResult, _profile: RuleProfile, _snapshot: BoardSnapshot) -> String:
	return ""


## One line per side for the match-over screen.
func final_text(state: MatchState, side: int) -> String:
	return "%d points" % state.totals[side]
