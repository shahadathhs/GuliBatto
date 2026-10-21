class_name ShotApplier
extends RefCounted
## The one place a ShotCommand becomes motion. Callers have already validated the command.


static func apply(marble: Marble, command: ShotCommand) -> void:
	marble.apply_shot(command)
