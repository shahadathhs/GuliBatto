class_name Tuning
extends RefCounted
## Starting values for shot feel and settling. They are tuned in Milestone 1 and recorded in
## docs/README_ARCHITECTURE.md. Units are metres and seconds; the world is scaled so a marble
## is about a fifteenth of the arena radius.

const MARBLE_RADIUS := 0.2
const MARBLE_MASS := 1.0
## Speed given to a marble by a power-1.0 shot (mass 1, so impulse equals speed).
const MAX_SHOT_SPEED := 6.0
const LINEAR_DAMP := 1.1
const ANGULAR_DAMP := 0.15
const MARBLE_FRICTION := 0.4
const MARBLE_BOUNCE := 0.5
const WALL_BOUNCE := 0.4

const ARENA_RADIUS := 3.0
const WALL_THICKNESS := 0.6
const WALL_HEIGHT := 0.8

## A board is settled when every marble stays under both speeds for the whole window.
const SETTLE_LINEAR_SPEED := 0.1
const SETTLE_ANGULAR_SPEED := 1.0
const SETTLE_WINDOW := 0.3
## A hard stop: after this long the board is treated as settled whatever it is doing.
const SETTLE_TIMEOUT := 8.0

## A pull shorter than this (as a fraction of full power) cancels instead of firing.
const AIM_DEAD_ZONE := 0.08

## Kep (the hole). The jalla is the line to stand behind; the kep is a smooth dish in the ground.
const JALLA_Z := 2.2
const KEP_POSITION := Vector2(0.0, -0.3)
## A marble counts as in the kep when it rests with its centre inside this radius.
const KEP_RADIUS := 0.3
## The dish is wider and deeper than the kep radius so a slow marble drops in and a fast one
## rolls through.
const DISH_RADIUS := 0.45
const DISH_DEPTH := 0.04
## Batto: three holes in a line away from the jalla, H1 nearest.
const BATTO_H1 := Vector2(0.0, 0.8)
const BATTO_H2 := Vector2(0.0, -0.45)
const BATTO_H3 := Vector2(0.0, -1.7)
## Ground heights are sampled on a grid this fine for the collision shape.
const GROUND_CELL := 0.05
