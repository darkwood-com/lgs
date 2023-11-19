class_name Sprite extends Sprite2D

signal clicked(action: String, obj: Node)

var bubbleEvent: bool = false

func _init(texturePath: String):
	centered = false
	texture = load(texturePath)
	
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and get_rect().has_point(to_local(event.position)) and is_visible_in_tree():
			if bubbleEvent == false:
				get_viewport().set_input_as_handled()
			clicked.emit("", self)
