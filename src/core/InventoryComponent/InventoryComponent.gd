extends Node

class_name InventoryComponent

@export var capacity: int = 2

var items: Array[ItemComponent] = []

func is_store_posibility() -> bool:
	return len(items) < capacity

func store(item: ItemComponent) -> void:
	if !is_store_posibility():
		push_error("Attempt to add item beyond capacity!")
		return
	item.prepare_for_store()
	items.push_back(item)

func is_retrive_posible() -> bool:
	return len(items) > 0

func retrieve(index: int = 0) -> Node3D:
	if !is_retrive_posible():
		push_error("Attempt to remove not existing item!")
		return
	var poped_item = items.pop_at(index)
	poped_item.prepare_for_retrieve()
	return poped_item
