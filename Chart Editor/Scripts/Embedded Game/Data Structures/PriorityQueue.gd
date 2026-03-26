class_name PriorityQueue

var front: LinkedNode
var new_node: LinkedNode
var temp: LinkedNode
var prev: LinkedNode
var max_capacity: int


func _init(capacity: int) -> void:
	front = null
	max_capacity = capacity


func is_empty() -> bool:
	return front == null


func has(value: Node) -> bool:
	var node: LinkedNode = front
	
	while node.next != null:
		if node.value == value:
			return true
		else:
			node = node.next
	
	return false


## Returns LinkedNode with [member NoteManager.held_key] equal to [param key].
func has_held_key(key: Key) -> LinkedNode:
	var node: LinkedNode = front
	if node == null:
		return null
	
	while node:
		var note_manager: NoteManager = node.value
		
		if note_manager.held_key == key:
			return node
			
		node = node.next
		
		if node == null:
			break
		
	
	return null


## Returns first LinkedNode which contains [code]value[/code].
func get_linked_node(value: Node) -> LinkedNode:
	if is_empty():
		return null
	
	var node: LinkedNode = front
	
	while node.next != null:
		if node.value == value:
			return node
		else:
			node = node.next
	
	return null


## Return front on the queue.
func get_front() -> LinkedNode:
	return front


func size() -> int:
	if is_empty():
		return 0
	
	var size_of_queue: int = 0
	var node: LinkedNode = front
	
	while node:
		size_of_queue += 1
		node = node.next
		
		if node == null:
			break
	
	return size_of_queue


func push(value: Node, priority: float) -> void:
	#print("Push %s %s" % [value, priority])
	if priority == NoteManager.MAX_NOTE_DELTA:
		return
	
	if is_empty():
		front = LinkedNode.new(value, priority)
	elif front.priority < priority:
		new_node = LinkedNode.new(value, priority, front)
		new_node.prev = null
		new_node.next = front
		front = new_node
	else:
		temp = front
		
		while temp.next:
			# > Instead of >= to make the new LinkedNode go behind the one in the queue if the have equal priority.
			if priority > temp.next.priority:
				break
			
			prev = temp
			temp = temp.next
		
		new_node = LinkedNode.new(value, priority, temp.next, prev)
		temp.prev = prev
		temp.next = new_node


## Removes first [LinkedNode] in the queue.
func pop() -> LinkedNode: 
	if is_empty():
		return
	
	else:
		temp = front
		front = front.next
		
		return temp


func print_front() -> Node:
	if is_empty():
		return null
	
	return front.value


func print_queue() -> Array:
	if is_empty():
		return []
	
	var node: LinkedNode = front
	var print_array: Array = []
	
	while node:
		print_array.append(node.value)
		node = node.next
		
		if node == null:
			break
	
	return print_array
