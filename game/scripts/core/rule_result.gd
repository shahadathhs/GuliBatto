class_name RuleResult
extends RefCounted
## What a rule evaluation decided after one shot. The match applies it; the UI only reads it.

## "toss": a toss landed, the opening goes on. "turn": a race shot was judged and play goes on
## (the same side again when `bonus` is set). "round": the round was scored. "match": the match
## is over.
var kind: StringName = &"toss"
## Points awarded this round by side index (only when kind is round or match, in Kep).
var points: Dictionary = {}
## Short facts for the result cue: for each side, "in_kep", "closest", "second" or "none".
var placing: Dictionary = {}
## Batto: the side that shot, what the shot did ("order", "miss", "hit", "reached", "hit_reached",
## "finished"), the hole number reached (1 to 3) and whether the same side shoots again.
var shooter: int = -1
var cue: StringName = &"toss"
var hole: int = 0
var bonus: bool = false
## A hit or a hole earned a bonus shot but the cap for the turn was already used.
var capped: bool = false
## The side whose marble left the route this shot (it is taken off the board), or -1.
var finished_side: int = -1
## Guli Khela: the side that won the dan, and whether a fine was actually paid (a side with an
## empty purse pays nothing).
var winner: int = -1
var fine_paid: bool = true
## Guli Khela: each side's purse as the dan finished, before the next stake is paid. Empty means
## use the match's totals.
var totals: Array[int] = []
## Marbles to take off the board, and marbles to put on it, once the cue has been shown. Each
## placed marble is {"id": int, "side": int, "pos": Vector2}; a marble with no side is neutral.
var remove_marbles: Array[int] = []
var place_marbles: Array[Dictionary] = []
