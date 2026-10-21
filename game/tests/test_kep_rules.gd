extends GutTest
## Kep scoring on hand-built boards, with no physics.

var profile: RuleProfile
var kep: Vector2


func before_each() -> void:
	profile = RuleProfile.kep()
	kep = profile.holes[0]


func _board(positions: Array) -> BoardSnapshot:
	var snap := BoardSnapshot.new()
	for i in positions.size():
		snap.add(i, i, positions[i])
	return snap


func _score(snap: BoardSnapshot) -> Dictionary:
	var tossed: Array[int] = []
	for id in snap.ids():
		tossed.append(id)
	return KepRules.score_round(tossed, snap, profile)


func test_a_marble_in_the_kep_scores_three() -> void:
	var r := _score(
		_board([kep + Vector2(0.05, 0.0), kep + Vector2(1.0, 0.0), kep + Vector2(2.0, 0.0)])
	)
	assert_eq(r["points"][0], 3)
	assert_eq(r["placing"][0], &"in_kep")


func test_without_anyone_in_the_kep_the_closest_scores_two_and_the_next_one() -> void:
	var r := _score(
		_board([kep + Vector2(2.0, 0.0), kep + Vector2(0.6, 0.0), kep + Vector2(1.2, 0.0)])
	)
	assert_eq(r["points"][1], 2, "closest")
	assert_eq(r["points"][2], 1, "second")
	assert_eq(r["points"][0], 0, "third scores nothing")


func test_the_closest_outside_the_kep_still_scores_two_when_another_is_in() -> void:
	var r := _score(_board([kep, kep + Vector2(0.7, 0.0), kep + Vector2(1.4, 0.0)]))
	assert_eq(r["points"][0], 3)
	assert_eq(r["points"][1], 2)
	assert_eq(r["points"][2], 1)


func test_marbles_tied_for_closest_share_the_higher_score() -> void:
	var r := _score(
		_board([kep + Vector2(0.8, 0.0), kep + Vector2(-0.8, 0.0), kep + Vector2(1.6, 0.0)])
	)
	assert_eq(r["points"][0], 2)
	assert_eq(r["points"][1], 2)
	assert_eq(r["points"][2], 1, "the next place after a tie is second")


func test_every_marble_in_the_kep_scores_three() -> void:
	var r := _score(_board([kep, kep + Vector2(0.1, 0.0)]))
	assert_eq(r["points"][0], 3)
	assert_eq(r["points"][1], 3)


func test_the_kep_edge_counts_as_in() -> void:
	var r := _score(_board([kep + Vector2(Tuning.KEP_RADIUS, 0.0), kep + Vector2(1.0, 0.0)]))
	assert_eq(r["points"][0], 3)


func test_every_toss_gets_a_score_even_zero() -> void:
	var r := _score(
		_board(
			[
				kep + Vector2(0.5, 0.0),
				kep + Vector2(1.0, 0.0),
				kep + Vector2(1.5, 0.0),
				kep + Vector2(2.0, 0.0)
			]
		)
	)
	assert_eq(r["points"].size(), 4)
	assert_eq(r["points"][3], 0)


func test_a_match_runs_the_rounds_and_orders_tosses_worst_first() -> void:
	var rules := KepRules.new()
	var state := rules.start(profile, 3)
	assert_eq(state.order, [0, 1, 2] as Array[int], "first round in side order")
	var snap := _board([kep, kep + Vector2(0.7, 0.0), kep + Vector2(1.4, 0.0)])
	for id in 3:
		var report := ShotReport.new()
		report.shooter_id = id
		var result := rules.evaluate(state, profile, snap, report)
		assert_eq(result.kind, &"toss" if id < 2 else &"round")
	assert_eq(state.totals, [3, 2, 1] as Array[int])
	assert_eq(state.order, [2, 1, 0] as Array[int], "the leader tosses last next round")
	assert_eq(state.round_index, 1)


func test_the_last_round_ends_the_match_and_ranks_the_sides() -> void:
	profile.rounds = 1
	var rules := KepRules.new()
	var state := rules.start(profile, 3)
	var snap := _board([kep + Vector2(2.0, 0.0), kep, kep + Vector2(0.9, 0.0)])
	var last: RuleResult
	for id in 3:
		var report := ShotReport.new()
		report.shooter_id = id
		last = rules.evaluate(state, profile, snap, report)
	assert_eq(last.kind, &"match")
	assert_eq(state.ranking(), [1, 2, 0] as Array[int])
