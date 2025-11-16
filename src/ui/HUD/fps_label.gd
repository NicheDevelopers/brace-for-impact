extends Label

func _physics_process(_delta: float) -> void:
	self.text = str(int(Engine.get_frames_per_second()))
