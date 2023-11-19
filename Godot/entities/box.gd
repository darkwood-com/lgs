class_name Box extends Node2D

signal clicked(action: String, obj: Node)

@export_multiline var text: String
@export var type: String = 'text'
@export var rect: Vector2i
var font: Font = preload("res://datas/fonts/lgsfont.ttf")
var actions_rect: Dictionary = {}
var bubbleEvent: bool = false

func set_rect(x: int, y: int, width: int, height: int):
	position.x = x
	position.y = y
	rect = Vector2i(width, height)

func _draw():
	draw_rect(Rect2(1, 1, rect.x - 3, rect.y - 3), Color.WHITE, true)
	draw_polyline(PackedVector2Array([
		Vector2(2.5, rect.y - 1.5),
		Vector2(rect.x - 1.5, rect.y - 1.5),
		Vector2(rect.x - 1.5, 2.5),
	]), Color.BLACK, 1.0)
	draw_rect(Rect2(0.5, 0.5, rect.x - 2.5, rect.y - 2.5), Color.BLACK, false, 1.0)
	
	actions_rect.clear()
	var font_size = 16
	var base_position = Vector2(2, 14)
	var line_height = 16
	var lines = text.split('\n')
	var auto_lines = 0
	for line_index in lines.size():
		var line = lines[line_index]
		var begin_position = base_position
		if type == 'button':
			# calculate center text position for button
			begin_position = font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
			begin_position.x = floor((rect.x - begin_position.x) / 2)
			base_position.y = 24 - floor((rect.y - begin_position.y) / 2)
		
		# we also calculate coords of text action (surrounded beetween #action#)
		var pos: int = 0
		var last_position = begin_position
		var actions = line.split('#')
		for action_index in actions.size():
			var action = actions[action_index]
			if action == '':
				pos += 1
				continue
			
			var action_position = Vector2(last_position.x, base_position.y + (line_index + auto_lines) * line_height)
			var action_rect = Vector2i(abs(last_position.x - action_position.x), 1)
			
			# new line if words are not in draw rect
			var words = action.split(' ')
			for word_index in words.size():
				var word = words[word_index]
				begin_position.x = last_position.x
				begin_position.y = base_position.y + (line_index + auto_lines) * line_height
				
				last_position = font.get_string_size(word, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size) + begin_position
				if last_position.x > rect.x - 2:
					auto_lines += 1
					action_rect.y += 1
					begin_position.x = base_position.x
					begin_position.y = base_position.y + (line_index + auto_lines) * line_height
				
				draw_string(font, begin_position, word, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.BLACK)
				last_position = font.get_string_size(word, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size) + begin_position
				
				var word_length = len(word)
				if len(line) > pos + word_length and line[pos + word_length] == ' ':
					word_length += 1
					last_position.x += 6
				pos += word_length
				
				if abs(last_position.x - action_position.x) > action_rect.x:
					action_rect.x = abs(last_position.x - action_position.x)
			
			# create an action rect
			if action_index % 2 == 1:
				actions_rect[action] = Rect2i(
					action_position.x,
					action_position.y - line_height + 4,
					action_rect.x,
					action_rect.y * line_height
				)
	
	#debug action	
	#for action in actions_rect:
	#	draw_rect(actions_rect[action], Color.RED, false, 1.0)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and is_visible_in_tree():
			var local_position = to_local(event.position)
			for action in actions_rect:
				if actions_rect[action].has_point(local_position):
					if bubbleEvent == false:
						get_viewport().set_input_as_handled()
					clicked.emit(action, self)
					return
			
			if Rect2(Vector2(0, 0), rect).has_point(local_position):
				if bubbleEvent == false:
					get_viewport().set_input_as_handled()
				clicked.emit(text, self)
