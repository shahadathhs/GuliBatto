extends GutTest


func test_snapshot_reports_positions_sides_and_distances() -> void:
	var snap := BoardSnapshot.new()
	snap.add(1, 0, Vector2(0.0, 0.0))
	snap.add(2, 1, Vector2(3.0, 4.0))
	assert_eq(snap.count(), 2)
	assert_eq(snap.side_of(2), 1)
	assert_almost_eq(snap.distance_between(1, 2), 5.0, 0.0001)


func test_is_inside_includes_the_edge_and_excludes_beyond_it() -> void:
	var snap := BoardSnapshot.new()
	snap.add(1, 0, Vector2(1.0, 0.0))
	snap.add(2, 0, Vector2(1.5, 0.0))
	assert_true(snap.is_inside(1, Vector2.ZERO, 1.0))
	assert_false(snap.is_inside(2, Vector2.ZERO, 1.0))


func test_report_keeps_first_contact_order_and_ignores_repeats() -> void:
	var report := ShotReport.new()
	report.shooter_id = 0
	report.add_touch(3)
	report.add_touch(5)
	report.add_touch(3)
	assert_eq(report.touched, [3, 5] as Array[int])
	assert_eq(report.touched_count(), 2)


func test_report_never_counts_the_shooter_itself() -> void:
	var report := ShotReport.new()
	report.shooter_id = 0
	report.add_touch(0)
	assert_eq(report.touched_count(), 0)
