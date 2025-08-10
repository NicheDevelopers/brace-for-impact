extends Node3D

@onready var time_label: Label3D = $TimeLabel
var run_start_time: float = 0.0

func _ready() -> void:
	time_label.hide()

func _on_start_area_body_entered(body: Node3D) -> void:
	if body is not Player:
		return
	run_start_time = Time.get_ticks_msec() / 1000.0
	time_label.hide()

func _on_end_area_body_entered(body: Node3D) -> void:
	if body is not Player:
		return
	if run_start_time == 0:
		return
	var run_end_time = Time.get_ticks_msec() / 1000.0
	var elapsed = run_end_time - run_start_time
	run_start_time = 0
	time_label.text = "Course finished!\nTime: " + str(elapsed)
	time_label.show()
	
	for i in range(5):
		await get_tree().create_timer(0.2).timeout
		time_label.hide()
		await get_tree().create_timer(0.2).timeout
		time_label.show()
	
