extends Node

var points: int = 0
signal points_changed(new_value: int)

func add_points(amount: int) -> void:
	points += amount
	emit_signal("points_changed", points)

func subtract_points(amount: int) -> void:
	points = max(points - amount, 0)
	emit_signal("points_changed", points)

func reset_points() -> void:
	points = 0
	emit_signal("points_changed", points)
