extends GutTest
## Who plays: the setups, the labels they give, the five side styles and the remembered choice.

const PATH := "user://test_settings_unit.cfg"


func before_each() -> void:
	Settings.path = PATH
	DirAccess.remove_absolute(PATH)
	Settings.load_from_disk()


func after_each() -> void:
	DirAccess.remove_absolute(PATH)
	Settings.path = Settings.DEFAULT_PATH
	Settings.load_from_disk()


func test_against_the_computer_you_are_side_zero_and_the_rest_are_computers() -> void:
	var s := MatchSetup.solo(2)
	assert_eq(s.side_count, 3)
	assert_true(s.is_human(0))
	assert_false(s.is_human(1))
	assert_true(s.is_solo())
	assert_false(s.hands_over())
	assert_eq(s.label(0), "YOU")
	assert_eq(s.label(1), "")
	assert_eq(s.owner_word(0), "Your")
	assert_eq(s.owner_word(2), "Their")


func test_the_number_of_computers_stays_between_one_and_three() -> void:
	assert_eq(MatchSetup.solo(0).side_count, 2)
	assert_eq(MatchSetup.solo(9).side_count, 4)


func test_in_pass_and_play_every_side_is_a_person_with_a_name() -> void:
	var s := MatchSetup.pass_and_play(5)
	assert_eq(s.side_count, 5)
	for side in 5:
		assert_true(s.is_human(side))
	assert_true(s.hands_over())
	assert_false(s.is_solo())
	assert_eq(s.label(1), "AMBER")
	assert_eq(s.owner_word(4), "Rose's")


func test_pass_and_play_needs_two_to_five_people() -> void:
	assert_eq(MatchSetup.pass_and_play(1).side_count, 2)
	assert_eq(MatchSetup.pass_and_play(8).side_count, 5)


func test_no_two_sides_share_a_colour_or_a_mark_in_either_theme() -> void:
	for scheme in [Palette.Scheme.LIGHT, Palette.Scheme.DARK]:
		var colours: Array[Color] = []
		var marks: Array[int] = []
		for side in SideStyle.MAX_SIDES:
			colours.append(SideStyle.colour(side, scheme))
			marks.append(SideStyle.mark(side))
		for i in colours.size():
			for j in range(i + 1, colours.size()):
				assert_ne(colours[i], colours[j], "sides %d and %d differ in colour" % [i, j])
				assert_ne(marks[i], marks[j], "sides %d and %d differ in mark" % [i, j])
		var bone := SideStyle.colour(SideStyle.NEUTRAL, scheme)
		assert_false(colours.has(bone), "the stake marble is not any side's colour")


func test_every_side_has_its_own_name() -> void:
	var seen := {}
	for side in SideStyle.MAX_SIDES:
		seen[SideStyle.side_name(side)] = true
	assert_eq(seen.size(), SideStyle.MAX_SIDES)


func test_the_last_choice_is_remembered_and_builds_the_setup() -> void:
	Settings.remember_setup(MatchSetup.Kind.PASS_AND_PLAY, 3, 4)
	Settings.load_from_disk()
	assert_eq(Settings.play_kind, MatchSetup.Kind.PASS_AND_PLAY)
	var s := Settings.match_setup()
	assert_eq(s.side_count, 4)
	assert_true(s.hands_over())
	Settings.remember_setup(MatchSetup.Kind.COMPUTERS, 3, 4)
	assert_eq(Settings.match_setup().side_count, 4, "you and three computers")
	assert_true(Settings.match_setup().is_solo())


func test_a_damaged_choice_falls_back_to_the_defaults() -> void:
	var f := FileAccess.open(PATH, FileAccess.WRITE)
	f.store_string('[settings]\nplay_kind=9\ncomputers=99\npeople="x"\n')
	f.close()
	Settings.load_from_disk()
	assert_eq(Settings.play_kind, MatchSetup.Kind.COMPUTERS)
	assert_eq(Settings.computers, MatchSetup.MAX_COMPUTERS, "clamped")
	assert_eq(Settings.people, 3)


func test_reset_puts_the_choice_back() -> void:
	Settings.remember_setup(MatchSetup.Kind.PASS_AND_PLAY, 1, 5)
	Settings.reset()
	assert_eq(Settings.play_kind, MatchSetup.Kind.COMPUTERS)
	assert_eq(Settings.computers, 2)
	assert_eq(Settings.people, 3)
