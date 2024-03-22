class_name Surface extends Node2D

signal clicked(action: String, obj: Node)

var action: String
@export var rect: Vector2i

var bubbleEvent: bool = false

func _init(anAction: String):
	action = anAction

func set_rect(aRect: Rect2i):
	position.x = aRect.position.x
	position.y = aRect.position.y
	rect = Vector2i(aRect.size.x, aRect.size.y)

#debug surface
#func _draw():
#	draw_rect(Rect2(0, 0, rect.x, rect.y), Color.GREEN, false, 5.0)
	
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and is_visible_in_tree():
			var local_position = to_local(event.position)
			
			if Rect2(Vector2(0, 0), rect).has_point(local_position):
				if bubbleEvent == false:
					get_viewport().set_input_as_handled()
				clicked.emit(action, self)
