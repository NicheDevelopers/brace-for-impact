extends Node

class_name HealthComponent

signal health_changed(new_value: float, by_who: Variant)
signal healed(value: float, by_who: Variant)
signal damaged(value: float, by_who: Variant)
signal fully_healed(by_who: Variant)
signal killed(by_who: Variant)

@export var default_health: float = 100.0
@export var max_health: float = 100.0
@export var can_be_healed: bool = true
@export var can_be_damaged: bool = true

var hp: float

@onready var parent = get_parent()

func _ready() -> void:
	hp = default_health
	parent.add_to_group(Group.HasHealthComponent)

func heal(value: float, by_who: Variant):
	if not can_be_healed:
		return
	hp = clamp(hp + value, 0, max_health)
	
	health_changed.emit(hp, by_who)
	healed.emit(value, by_who)
	if (hp == max_health):
		fully_healed.emit(by_who)

func damage(value: float, by_who: Variant):
	if not can_be_damaged:
		return
	hp = clamp(hp - value, 0, max_health)
	
	health_changed.emit(hp, by_who)
	damaged.emit(value, by_who)
	if (hp == 0):
		killed.emit(by_who)
