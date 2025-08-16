extends Node

class_name InventoryComponent

@export var capacity: int = 2

var items: Array[ItemComponent] = []

func is_add_item_posibility() -> bool:
	if(len(items) >= capacity):
		return false
	return true

func add_item(item: ItemComponent) -> void:
	if(!is_add_item_posibility()):
		push_error("Attempt to add item beyond capacity!")
		return
	items.push_back(item)
	print("Added item: " + item.parent.name)

func is_remove_item_posible(item: ItemComponent) -> bool:
	var index = items.find(item)
	if(index == -1):
		return false
	return true

func remove_item(item: ItemComponent) -> void:
	if(!is_remove_item_posible(item)):
		push_error("Attempt to remove not existing item!")
		return
	
	var index = items.find(item)
	items.remove_at(index)
	print("Item removed")
	
