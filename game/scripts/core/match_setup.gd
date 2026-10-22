class_name MatchSetup
extends RefCounted
## Who plays a match: how many sides there are and which of them are people. The other sides are
## computer sides. Against the computer one person plays; in pass and play every side is a person
## and the device is handed round.

enum Kind { COMPUTERS, PASS_AND_PLAY }

const MAX_COMPUTERS := 3
const MIN_PEOPLE := 2
const MAX_PEOPLE := SideStyle.MAX_SIDES

var kind: Kind = Kind.COMPUTERS
var side_count: int = 3
var humans: Array[int] = [0]


## You (side 0) against `computers` computer sides.
static func solo(computers: int = 2) -> MatchSetup:
	var s := MatchSetup.new()
	s.side_count = 1 + clampi(computers, 1, MAX_COMPUTERS)
	return s


## `people` people, one side each, passing the device.
static func pass_and_play(people: int) -> MatchSetup:
	var s := MatchSetup.new()
	s.kind = Kind.PASS_AND_PLAY
	s.side_count = clampi(people, MIN_PEOPLE, MAX_PEOPLE)
	s.humans = []
	for side in s.side_count:
		s.humans.append(side)
	return s


## No people at all: every side is a computer (tests and demonstrations).
static func computers_only(sides: int = 3) -> MatchSetup:
	var s := MatchSetup.new()
	s.side_count = sides
	s.humans = []
	return s


## A custom set of human sides, for tests.
static func with_humans(people: Array[int], sides: int) -> MatchSetup:
	var s := MatchSetup.new()
	s.side_count = sides
	s.humans = people
	return s


func is_human(side: int) -> bool:
	return humans.has(side)


func hands_over() -> bool:
	return kind == Kind.PASS_AND_PLAY


## True when the one person at the device is "you".
func is_solo() -> bool:
	return humans.size() == 1


## The short label the scoreboard and results show beside a side: "YOU" for the one person, the
## side's name in pass and play, and nothing for a computer side.
func label(side: int) -> String:
	if hands_over():
		return SideStyle.side_name(side).to_upper()
	return "YOU" if is_solo() and is_human(side) else ""


## The label on the scoreboard chips at the top of the match: "YOU" for the one person, nothing
## otherwise (a marble's colour and mark say which side it is, and five names would not fit).
func chip_label(side: int) -> String:
	return "YOU" if is_solo() and is_human(side) else ""


## How the side is named in a sentence: "Your" for the one person, "Blue's" in pass and play, and
## "Their" for a computer side.
func owner_word(side: int) -> String:
	if hands_over():
		return "%s's" % SideStyle.side_name(side)
	return "Your" if is_human(side) else "Their"
