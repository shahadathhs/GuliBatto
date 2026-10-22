class_name GuliText
extends RefCounted
## The words Guli Khela shows: the line over the arena, whose turn it is, each side's purse, the cue
## after a shot and the line for each side when the match is over.


static func caption(s: GuliState, profile: RuleProfile) -> String:
	var dan := "" if s.dan_limit == 1 else " · dan %d" % (s.dan_index + 1)
	if s.stage == GuliState.Stage.OPENING:
		return "%s%s · opening toss" % [profile.title, dan]
	return "%s%s · pass %d of %d" % [profile.title, dan, s.pass_index + 1, s.passes_limit]


static func turn_text(s: GuliState, owner: String) -> String:
	if s.stage == GuliState.Stage.OPENING:
		return "%s toss" % owner
	return "%s throw" % owner


static func standings(s: GuliState) -> Array[String]:
	var out: Array[String] = []
	for side in s.side_count:
		out.append("OUT" if s.out[side] or side == s.surrendered else str(s.totals[side]))
	return out


static func cue_text(result: RuleResult, profile: RuleProfile, snapshot: BoardSnapshot) -> String:
	var text := "No touch"
	match result.cue:
		&"toss":
			var d := snapshot.position_of(result.shooter).distance_to(profile.holes[0])
			text = "In the kep" if d <= profile.hole_radius else "%.1f m from the kep" % d
		&"scatter":
			text = "Closest side scatters the stake"
		&"dan_won":
			text = "Dan won"
		&"held":
			text = "Nobody won. The scatterer keeps the ground"
		&"fine_baad":
			text = _fined("Fine: touched the baad marble", result)
		&"fine_many":
			text = _fined("Fine: touched more than one marble", result)
	return text


static func final_text(s: GuliState, side: int) -> String:
	if side == s.surrendered:
		return "GAVE UP"
	return "OUT" if s.out[side] else "%d MARBLES" % s.totals[side]


static func _fined(text: String, result: RuleResult) -> String:
	return text if result.fine_paid else text + " (nothing to pay)"
