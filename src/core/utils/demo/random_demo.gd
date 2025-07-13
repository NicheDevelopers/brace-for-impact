extends Node

@onready var success_label = $SuccessLabel
@onready var error_log = $ScrollContainer/ErrorLog

# A mapping between an error text and how many times it occured
var errors: Dictionary[String, int] = {}

func _ready():
	test_rand_bool()
	test_rand_int()
	test_rand_float()
	test_rand_index_empty_array()
	
	for error in errors:
		error_log.text += error + " (" + str(errors[error]) + ")\n"
	if errors.size() == 0:
		error_log.visible = false
	else: success_label.visible = false

func _assert(cond: bool, error_text: String):
	if not cond:
		push_error(error_text)
		if not errors.has(error_text):
			errors[error_text] = 0
		errors[error_text] += 1
	
func test_rand_bool():
	var seen_true = false
	var seen_false = false
	for i in 100:
		var result = Random.bool()
		_assert(typeof(result) == TYPE_BOOL, "Result not bool")
		if result: seen_true = true
		else: seen_false = true
	_assert(seen_true and seen_false, "Not seen both false and true")

func test_rand_int():
	for i in 100:
		var result = Random.int(5, 10)
		_assert(result >= 5 and result <= 10, "Int out of range")

func test_rand_float():
	for i in 100:
		var result = Random.float(-2.5, 3.5)
		_assert(result >= -2.5 and result <= 3.5, "Float out of range")

func test_rand_index():
	var array = ["a", "b", "c"]
	for i in 100:
		var index = Random.rand_index(array)
		_assert(index >= 0 and index < array.size(), "Array index out of range")

func test_rand_index_empty_array():
	var index = Random.index([])
	_assert(index == -1, "Random index of empty array not equal to -1")
