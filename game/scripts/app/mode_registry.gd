class_name ModeRegistry
extends RefCounted
## The modes that can be played: their order on the menu, a one-line description, and the profile
## and ruleset that build a match. Adding a mode is adding it here.

const ORDER: Array[StringName] = [&"kep", &"batto", &"guli", &"quick"]
const TITLES := {
	&"kep": "KEP",
	&"batto": "BATTO",
	&"guli": "GULI KHELA",
	&"quick": "QUICK DAN",
}
const BLURBS := {
	&"kep": "Toss at the hole. Closest scores.",
	&"batto": "Race three holes and back. A hit earns a shot.",
	&"guli": "Touch exactly one marble, never the baad. Win the ground.",
	&"quick": "One dan of Guli Khela, for a few minutes.",
}


static func profile(mode_id: StringName) -> RuleProfile:
	match mode_id:
		&"batto":
			return RuleProfile.batto()
		&"guli":
			return RuleProfile.guli()
		&"quick":
			return RuleProfile.quick_dan()
	return RuleProfile.kep()


static func rules(mode_id: StringName) -> RuleSet:
	match mode_id:
		&"batto":
			return BattoRules.new()
		&"guli", &"quick":
			return GuliRules.new()
	return KepRules.new()
