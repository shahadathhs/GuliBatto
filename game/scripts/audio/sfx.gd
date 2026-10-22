class_name Sfx
extends Node
## Plays the sound effects. One instance lives in the app; everything else calls the static
## functions, which do nothing when there is no instance (a test, a headless run) or when sound is
## off in Settings. Sound is only ever a reaction to something that happened: it never decides a
## shot, a result or a turn.

enum Event { TAP, SHOT, HIT, WALL, DROP, WIN, LOSE }

const FILES := {
	Event.TAP: "res://audio/tap.wav",
	Event.SHOT: "res://audio/shot.wav",
	Event.HIT: "res://audio/hit.wav",
	Event.WALL: "res://audio/wall.wav",
	Event.DROP: "res://audio/drop.wav",
	Event.WIN: "res://audio/win.wav",
	Event.LOSE: "res://audio/lose.wav",
}
## At most this many sounds at once; a new one reuses the oldest voice.
const VOICES := 8
## The same sound will not start again within this many milliseconds (a rolling marble can touch
## the same thing several times in a moment).
const THROTTLE_MS := 60
## Pitch is varied a little for the sounds that repeat, so they do not sound mechanical.
const VARIED := [Event.HIT, Event.WALL]

static var instance: Sfx
## Tests turn this on to see which events were asked for.
static var record: bool = false
static var played: Array[Event] = []
## How many sounds actually started, after sound-off, volume and throttling.
static var started: int = 0

var _streams: Dictionary = {}
var _voices: Array[AudioStreamPlayer] = []
var _next: int = 0
var _last_ms: Dictionary = {}
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _init() -> void:
	# Taps in the pause menu still make their sound while the match is paused.
	process_mode = Node.PROCESS_MODE_ALWAYS
	for event in FILES:
		_streams[event] = load(FILES[event])
	for i in VOICES:
		var voice := AudioStreamPlayer.new()
		add_child(voice)
		_voices.append(voice)


func _enter_tree() -> void:
	instance = self


func _exit_tree() -> void:
	if instance == self:
		instance = null


## Asks for a sound. `strength` is 0 to 1 and scales the volume (a hard hit is louder).
static func play(event: Event, strength: float = 1.0) -> void:
	if record:
		played.append(event)
	if instance == null or not Settings.sound_on:
		return
	instance._start(event, strength)


## How loud a contact at this speed (metres per second) is, 0.1 to 1.
static func strength_for_speed(speed: float) -> float:
	return 0.1 + 0.9 * clampf(speed / 8.0, 0.0, 1.0)


func _start(event: Event, strength: float) -> void:
	var level := clampf(Settings.volume * strength, 0.0, 1.0)
	if level <= 0.001:
		return
	var now := Time.get_ticks_msec()
	if now - int(_last_ms.get(event, -THROTTLE_MS)) < THROTTLE_MS:
		return
	_last_ms[event] = now
	var voice := _voices[_next]
	_next = (_next + 1) % VOICES
	voice.stream = _streams[event]
	voice.volume_db = linear_to_db(level)
	voice.pitch_scale = _rng.randf_range(0.94, 1.06) if VARIED.has(event) else 1.0
	voice.play()
	started += 1
