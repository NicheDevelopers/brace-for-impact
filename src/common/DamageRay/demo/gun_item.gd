extends Item

@onready var ray = $Node3D/DamageRay
@onready var laser = $Node3D/LaserMesh

var laser_timer: Timer

func _ready() -> void:
	super()
	laser.hide()
	
	laser_timer = Timer.new()
	laser_timer.one_shot = true
	laser_timer.wait_time = 0.1
	laser_timer.timeout.connect(_on_laser_timeout)
	add_child(laser_timer)

func _on_used(body: Variant) -> void:
	ray.trigger(body)
	laser.show()
	laser_timer.start()

func _on_laser_timeout():
	laser.hide()
