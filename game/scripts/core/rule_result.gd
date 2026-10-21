class_name RuleResult
extends RefCounted
## What a rule evaluation decided after one shot. The match applies it; the UI only reads it.

## "toss": a toss landed, the round goes on. "round": the round was scored. "match": the last
## round was scored and the match is over.
var kind: StringName = &"toss"
## Points awarded this round by side index (only when kind is round or match).
var points: Dictionary = {}
## Short facts for the result cue: for each side, "in_kep", "closest", "second" or "none".
var placing: Dictionary = {}
