class_name LinkedNode

var value: Node:
	set(new_value):
		value = new_value
var priority: float:
	set(new_priority):
		priority = new_priority
var next: LinkedNode:
	set(new_node):
		next = new_node
var prev: LinkedNode:
	set(new_node):
		prev = new_node


func _init(node_value: Node, node_priority: float, next_node: LinkedNode = null, prev_node: LinkedNode = null) -> void:
	value = node_value
	priority = node_priority
	next = next_node
	prev = prev_node
