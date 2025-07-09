extends Node

static func bool() -> bool:
	return randi() % 2 == 0

static func int(min_val: int, max_val: int) -> int:
	return randi_range(min_val, max_val)

static func float(min_val: float, max_val: float) -> float:
	return randf_range(min_val, max_val)

# Returns a random index of the provided function
static func index(array: Array) -> int:
	if array.is_empty():
		push_error("rand_index() called on empty array")
		return -1
	return randi() % array.size()
