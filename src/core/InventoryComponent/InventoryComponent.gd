extends Node

class_name InventoryComponent

@export var capacity: int = 2

var items: Array[ItemComponent] = []

func is_store_possibility() -> bool:
	return len(items) < capacity

func store(item: ItemComponent) -> void:
	if !is_store_possibility():
		push_error("Attempt to add item beyond capacity!")
		return
	item.prepare_for_store()
	items.push_back(item)

func is_retrive_possible() -> bool:
	return len(items) > 0

func retrieve(index: int = 0) -> Node3D:
	if !is_retrive_possible():
		push_error("Attempt to remove not existing item!")
		return
	var popped_item = items.pop_at(index)
	popped_item.prepare_for_retrieve()
	return popped_item
