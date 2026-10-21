class_name PhysicsTest
extends GutTest
## Base for tests that step real physics for a long time. When physics is stepped flat out (the
## tests run with --fixed-fps), Jolt now and then logs "job system exceeded the maximum number of
## jobs ... Waiting for jobs to become available". It waits and carries on, the results are right,
## and it has not shown up in play or in the browser, but GUT counts any engine warning as a
## failure. This marks that one message as handled and prints how many it ignored. Every other
## engine error still fails the test.

const MARKER := "Jolt Physics job system exceeded the maximum number of jobs"

static var ignored: int = 0

var _filter: JoltWarningFilter


class JoltWarningFilter:
	extends Logger

	var tracker: GutErrorTracker

	func _log_error(
		_function: String,
		_file: String,
		_line: int,
		code: String,
		rationale: String,
		_editor_notify: bool,
		_error_type: int,
		_script_backtraces: Array[ScriptBacktrace]
	) -> void:
		if not (code.contains(PhysicsTest.MARKER) or rationale.contains(PhysicsTest.MARKER)):
			return
		# The tracker logged it just before this runs; find it and mark it handled.
		var errors: Array = tracker.get_current_test_errors()
		for i in range(errors.size() - 1, -1, -1):
			var e: GutTrackedError = errors[i]
			if e.code.contains(PhysicsTest.MARKER) or e.rationale.contains(PhysicsTest.MARKER):
				e.handled = true
				PhysicsTest.ignored += 1
				break


func before_all() -> void:
	_filter = JoltWarningFilter.new()
	_filter.tracker = gut.error_tracker
	OS.add_logger(_filter)


func after_all() -> void:
	OS.remove_logger(_filter)
	if ignored > 0:
		gut.p("Ignored %d benign Jolt job-queue warning(s) in this run." % ignored)
