extends Control

@export var player: Player = null

@onready var health: HealthComponent = player.get_node("HealthComponent")
@onready var health_bar = $HealthBar
@onready var health_label = $HealthBar/HealthLabel
@onready var crosshair = $Crosshair
@onready var developer_cheatsheet: DeveloperCheatsheet = $DeveloperCheatsheet

var alt_pressed: bool = false
var alt_press_timer: float = 0.0
var alt_show_delay: float = 0.1  # Small delay to prevent accidental showing

func _ready() -> void:
	health.health_changed.connect(_on_health_changed)

func _process(delta: float) -> void:
	# Handle Alt key timing for cheatsheet
	if alt_pressed:
		alt_press_timer += delta
		if alt_press_timer >= alt_show_delay and not developer_cheatsheet.visible:
			developer_cheatsheet.show_cheatsheet()

func _input(event: InputEvent) -> void:
	# Detect Alt key press/release to show/hide developer cheatsheet
	if event is InputEventKey:
		# Check for both left and right Alt keys
		if event.physical_keycode == KEY_ALT or event.keycode == KEY_ALT:
			if event.pressed and not alt_pressed:
				alt_pressed = true
				alt_press_timer = 0.0
			elif not event.pressed and alt_pressed:
				alt_pressed = false
				alt_press_timer = 0.0
				developer_cheatsheet.hide_cheatsheet()

func _on_health_changed(new_value: float, _by_who: Variant) -> void:
	health_bar.value = new_value
	health_label.text = str(int(new_value))

func hide_crosshair():
	crosshair.hide()

func show_crosshair():
	crosshair.show()
