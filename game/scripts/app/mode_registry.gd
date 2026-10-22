class_name ModeRegistry
extends RefCounted
## The modes that can be played: their order on the menu, a one-line description, and the profile
## and ruleset that build a match. Adding a mode is adding it here.

const ORDER: Array[StringName] = [&"kep", &"batto"]
const BLURBS := {
	&"kep": "Toss at the hole. Closest scores.",
	&"batto": "Race three holes and back. A hit earns a shot.",
}


static func profile(mode_id: StringName) -> RuleProfile:
	match mode_id:
		&"batto":
			return RuleProfile.batto()
	return RuleProfile.kep()


static func rules(mode_id: StringName) -> RuleSet:
	match mode_id:
		&"batto":
			return BattoRules.new()
	return KepRules.new()
