@tool
extends Node3D

enum CorridorType {
	STRAIGHT,
	JUNCTION_T,
	JUNCTION_X,
	TURN
}

const Doors = preload("res://src/MapGenerator/parts/doors/Doors.tscn")
const Corridors =  {
	CorridorType.STRAIGHT: preload("res://src/MapGenerator/parts/corridors/CorridorStraight.tscn"),
	CorridorType.JUNCTION_T: preload("res://src/MapGenerator/parts/corridors/CorridorJunctionT.tscn"),
	CorridorType.JUNCTION_X: preload("res://src/MapGenerator/parts/corridors/CorridorJunctionX.tscn"),
	CorridorType.TURN: preload("res://src/MapGenerator/parts/corridors/CorridorTurn.tscn"),
}

var _corridor_scene: Node3D

@export var _corridor_type: CorridorType:
	get():
		return _corridor_type
	set(new_type):
		_corridor_type = new_type
		if _corridor_scene != null:
			remove_child(_corridor_scene)
			_corridor_scene.queue_free()
		
		_refresh_doors()
		
		_corridor_scene = Corridors[new_type].instantiate()
		add_child(_corridor_scene)

enum DoorLocation {
	NORTH,
	SOUTH,
	WEST,
	EAST
}

var _locations = [
	DoorLocation.NORTH, DoorLocation.SOUTH,
	DoorLocation.WEST, DoorLocation.EAST
]

var _door_scenes = {
	DoorLocation.NORTH: null,
	DoorLocation.SOUTH: null,
	DoorLocation.WEST: null,
	DoorLocation.EAST: null
}

@onready var _door_mount_points = {
	DoorLocation.NORTH: $NorthDoorPoint,
	DoorLocation.SOUTH: $SouthDoorPoint,
	DoorLocation.WEST: $WestDoorPoint,
	DoorLocation.EAST: $EastDoorPoint
}

@export var _north_doors: bool:
	get():
		return _north_doors
	set(doors_are_on):
		_north_doors = doors_are_on
		_toggle_door(DoorLocation.NORTH, doors_are_on)

@export var _south_doors: bool:
	get():
		return _south_doors
	set(doors_are_on):
		_south_doors = doors_are_on
		_toggle_door(DoorLocation.SOUTH, doors_are_on)

@export var _west_doors: bool:
	get():
		return _west_doors
	set(doors_are_on):
		_west_doors = doors_are_on
		_toggle_door(DoorLocation.WEST, doors_are_on)

@export var _east_doors: bool:
	get():
		return _east_doors
	set(doors_are_on):
		_east_doors = doors_are_on
		_toggle_door(DoorLocation.EAST, doors_are_on)

func _refresh_doors():
	var doors = [_north_doors, _south_doors, _west_doors, _east_doors]
	
	for location in _locations:
		if not doors[location]: continue
		
		if not _doors_available(location):
			_remove_door_scene(location)
			continue
		
		if _door_scenes[location] == null:
			_add_door_scene(location)

func _toggle_door(door_location: DoorLocation, on: bool) -> void:
	if _door_scenes == null: return
	if _door_mount_points == null: return
	
	var door_scene = _door_scenes[door_location]
	
	if door_scene != null:
		_remove_door_scene(door_location)
		
	if on == false: return
	if not _doors_available(door_location): return
	
	_add_door_scene(door_location)

func _remove_door_scene(door_location: DoorLocation):
	if _door_scenes[door_location] == null: return
	
	_door_scenes[door_location].queue_free()
	_door_scenes[door_location] = null

func _add_door_scene(door_location: DoorLocation):
	if _door_mount_points == null: return
	
	var door_scene = Doors.instantiate()
	_door_scenes[door_location] = door_scene
	_door_mount_points[door_location].add_child(door_scene)

## Whether doors at the specified location are compatible with
## the current corridor type
func _doors_available(door_location: DoorLocation) -> bool:
	if _corridor_type == CorridorType.JUNCTION_T:
		if door_location == DoorLocation.WEST:
			return false
	if _corridor_type == CorridorType.TURN:
		if door_location == DoorLocation.WEST:
			return false
		if door_location == DoorLocation.SOUTH:
			return false
	if _corridor_type == CorridorType.STRAIGHT:
		if door_location == DoorLocation.WEST:
			return false
		if door_location == DoorLocation.EAST:
			return false
	return true

func _ready() -> void:
	if _corridor_type == null:
		_corridor_type = CorridorType.STRAIGHT
	_refresh_doors()
