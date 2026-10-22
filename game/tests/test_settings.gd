extends GutTest
## Settings survive a restart, fall back safely, and reset.

const PATH := "user://test_settings_unit.cfg"


func before_each() -> void:
	Settings.path = PATH
	DirAccess.remove_absolute(PATH)
	Settings.load_from_disk()


func after_each() -> void:
	DirAccess.remove_absolute(PATH)
	Settings.path = Settings.DEFAULT_PATH
	Settings.load_from_disk()


func _write(text: String) -> void:
	var f := FileAccess.open(PATH, FileAccess.WRITE)
	f.store_string(text)
	f.close()


func test_a_missing_file_gives_the_defaults() -> void:
	assert_eq(Appearance.choice, Appearance.Choice.SYSTEM)
	assert_true(Settings.sound_on)
	assert_almost_eq(Settings.volume, Settings.DEFAULT_VOLUME, 0.0001)
	assert_true(Settings.follow_shots)
	assert_false(Settings.coach_seen)
	assert_eq(Settings.rules_seen.size(), 0)


func test_what_is_chosen_is_there_after_a_restart() -> void:
	Settings.set_theme(Appearance.Choice.DARK)
	Settings.sound_on = false
	Settings.volume = 0.3
	Settings.follow_shots = false
	Settings.mark_coach_seen()
	Settings.mark_rules_seen(&"batto")
	Settings.save()
	# A restart: the in-memory values are lost, the file is read.
	Appearance.choice = Appearance.Choice.SYSTEM
	Settings.sound_on = true
	Settings.volume = 1.0
	Settings.follow_shots = true
	Settings.coach_seen = false
	Settings.rules_seen = PackedStringArray()
	Settings.load_from_disk()
	assert_eq(Appearance.choice, Appearance.Choice.DARK)
	assert_false(Settings.sound_on)
	assert_almost_eq(Settings.volume, 0.3, 0.0001)
	assert_false(Settings.follow_shots)
	assert_true(Settings.coach_seen)
	assert_true(Settings.has_seen_rules(&"batto"))
	assert_false(Settings.has_seen_rules(&"kep"))


func test_a_file_that_is_not_a_settings_file_gives_the_defaults() -> void:
	_write("this is not a config file {{{ \n ]]] = = =")
	Settings.load_from_disk()
	assert_engine_error("ConfigFile parse error", "the engine logs the damage, and carries on")
	assert_eq(Appearance.choice, Appearance.Choice.SYSTEM)
	assert_true(Settings.sound_on)
	assert_false(Settings.coach_seen)


func test_values_of_the_wrong_type_or_out_of_range_are_not_trusted() -> void:
	_write(
		'[settings]\ntheme=9\nsound_on="yes"\nvolume=5.0\nfollow_shots=3\ncoach_seen="no"\nrules_seen=7\n'
	)
	Settings.load_from_disk()
	assert_eq(Appearance.choice, Appearance.Choice.SYSTEM, "an unknown theme")
	assert_true(Settings.sound_on, "a string where a bool belongs")
	assert_almost_eq(Settings.volume, 1.0, 0.0001, "a volume above 1 is clamped")
	assert_true(Settings.follow_shots)
	assert_false(Settings.coach_seen)
	assert_eq(Settings.rules_seen.size(), 0)


func test_a_negative_volume_is_clamped_to_silence() -> void:
	_write("[settings]\nvolume=-2.0\n")
	Settings.load_from_disk()
	assert_almost_eq(Settings.volume, 0.0, 0.0001)


func test_reset_restores_the_defaults_and_keeps_them_on_disk() -> void:
	Settings.set_theme(Appearance.Choice.LIGHT)
	Settings.sound_on = false
	Settings.mark_coach_seen()
	Settings.mark_rules_seen(&"kep")
	Settings.reset()
	assert_eq(Appearance.choice, Appearance.Choice.SYSTEM)
	assert_true(Settings.sound_on)
	assert_false(Settings.coach_seen)
	assert_false(Settings.has_seen_rules(&"kep"))
	Settings.load_from_disk()
	assert_eq(Appearance.choice, Appearance.Choice.SYSTEM, "and it stays reset after a restart")
	assert_false(Settings.has_seen_rules(&"kep"))


func test_marking_the_same_rules_twice_keeps_one_entry() -> void:
	Settings.mark_rules_seen(&"kep")
	Settings.mark_rules_seen(&"kep")
	assert_eq(Settings.rules_seen.size(), 1)
