class_name Settings
extends RefCounted
## What the player has chosen, kept between runs in a small file on the device (browser storage in
## the web build). A missing, unreadable or odd value falls back to its default, so a damaged
## file never stops the game from starting. The theme lives in Appearance and is saved here.

const DEFAULT_PATH := "user://settings.cfg"
const SECTION := "settings"
const DEFAULT_VOLUME := 0.7

## Where the file is; tests point it somewhere else.
static var path: String = DEFAULT_PATH
static var sound_on: bool = true
## 0 to 1.
static var volume: float = DEFAULT_VOLUME
## Whether the camera follows a shot while it rolls.
static var follow_shots: bool = true
## The first-use aiming prompt has been dismissed.
static var coach_seen: bool = false
## How the next match is played: against the computer or pass and play, and how many of each.
static var play_kind: MatchSetup.Kind = MatchSetup.Kind.COMPUTERS
static var computers: int = 2
static var people: int = 3
## Modes whose rules card has been shown (so it is not shown again).
static var rules_seen: PackedStringArray = PackedStringArray()


## Reads the file. Anything missing or the wrong type keeps its default.
static func load_from_disk() -> void:
	_use_defaults()
	var cfg := ConfigFile.new()
	if cfg.load(path) != OK:
		return
	var theme: Variant = cfg.get_value(SECTION, "theme", Appearance.Choice.SYSTEM)
	if typeof(theme) == TYPE_INT and theme >= 0 and theme < Appearance.Choice.size():
		Appearance.choice = theme as Appearance.Choice
	var sound: Variant = cfg.get_value(SECTION, "sound_on", true)
	if typeof(sound) == TYPE_BOOL:
		sound_on = sound
	var vol: Variant = cfg.get_value(SECTION, "volume", DEFAULT_VOLUME)
	if typeof(vol) == TYPE_FLOAT or typeof(vol) == TYPE_INT:
		volume = clampf(float(vol), 0.0, 1.0)
	var follow: Variant = cfg.get_value(SECTION, "follow_shots", true)
	if typeof(follow) == TYPE_BOOL:
		follow_shots = follow
	var coach: Variant = cfg.get_value(SECTION, "coach_seen", false)
	if typeof(coach) == TYPE_BOOL:
		coach_seen = coach
	var kind: Variant = cfg.get_value(SECTION, "play_kind", MatchSetup.Kind.COMPUTERS)
	if typeof(kind) == TYPE_INT and kind >= 0 and kind < MatchSetup.Kind.size():
		play_kind = kind as MatchSetup.Kind
	var computer_count: Variant = cfg.get_value(SECTION, "computers", 2)
	if typeof(computer_count) == TYPE_INT:
		computers = clampi(computer_count, 1, MatchSetup.MAX_COMPUTERS)
	var people_count: Variant = cfg.get_value(SECTION, "people", 3)
	if typeof(people_count) == TYPE_INT:
		people = clampi(people_count, MatchSetup.MIN_PEOPLE, MatchSetup.MAX_PEOPLE)
	var seen: Variant = cfg.get_value(SECTION, "rules_seen", PackedStringArray())
	if typeof(seen) == TYPE_PACKED_STRING_ARRAY:
		rules_seen = seen


static func save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value(SECTION, "theme", int(Appearance.choice))
	cfg.set_value(SECTION, "sound_on", sound_on)
	cfg.set_value(SECTION, "volume", volume)
	cfg.set_value(SECTION, "follow_shots", follow_shots)
	cfg.set_value(SECTION, "coach_seen", coach_seen)
	cfg.set_value(SECTION, "play_kind", int(play_kind))
	cfg.set_value(SECTION, "computers", computers)
	cfg.set_value(SECTION, "people", people)
	cfg.set_value(SECTION, "rules_seen", rules_seen)
	cfg.save(path)


## Back to the defaults, and saved that way.
static func reset() -> void:
	_use_defaults()
	save()


static func set_theme(choice: Appearance.Choice) -> void:
	Appearance.choice = choice
	save()


static func has_seen_rules(mode_id: StringName) -> bool:
	return rules_seen.has(String(mode_id))


static func mark_rules_seen(mode_id: StringName) -> void:
	if not has_seen_rules(mode_id):
		rules_seen.append(String(mode_id))
		save()


## The match the saved choices describe.
static func match_setup() -> MatchSetup:
	if play_kind == MatchSetup.Kind.PASS_AND_PLAY:
		return MatchSetup.pass_and_play(people)
	return MatchSetup.solo(computers)


## Remembers how the last match was set up.
static func remember_setup(kind: MatchSetup.Kind, computer_count: int, people_count: int) -> void:
	play_kind = kind
	computers = clampi(computer_count, 1, MatchSetup.MAX_COMPUTERS)
	people = clampi(people_count, MatchSetup.MIN_PEOPLE, MatchSetup.MAX_PEOPLE)
	save()


static func mark_coach_seen() -> void:
	if not coach_seen:
		coach_seen = true
		save()


static func _use_defaults() -> void:
	Appearance.choice = Appearance.Choice.SYSTEM
	sound_on = true
	volume = DEFAULT_VOLUME
	follow_shots = true
	coach_seen = false
	play_kind = MatchSetup.Kind.COMPUTERS
	computers = 2
	people = 3
	rules_seen = PackedStringArray()
