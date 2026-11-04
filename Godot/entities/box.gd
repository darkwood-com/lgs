class_name Box extends Node2D

signal clicked(action: String, obj: Node)

@export_multiline var text: String:
	set(value):
		text = value
		if is_instance_valid(content):
			_refresh_content()
@export var type: String = 'text'
@export var rect: Vector2i
var bubbleEvent: bool = false
var content: RichTextLabel
var content_bottom: int = 4
var display_replacements: Dictionary = {}
var action_keys: Array[String] = []

func _ready():
	content = RichTextLabel.new()
	content.bbcode_enabled = true
	content.meta_underlined = false
	content.scroll_active = true
	content.add_theme_font_override("normal_font", preload("res://datas/fonts/lgsfont.ttf"))
	content.add_theme_font_size_override("normal_font_size", 16)
	content.add_theme_color_override("default_color", Color.BLACK)
	content.add_theme_color_override("font_selected_color", Color.BLACK)
	content.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
	content.meta_clicked.connect(_on_link)
	content.gui_input.connect(_on_content_input)
	add_child(content)
	_refresh_content()

func set_rect(x: int, y: int, width: int, height: int):
	position = Vector2(x, y)
	rect = Vector2i(width, height)
	_layout_content()
	queue_redraw()

func _layout_content():
	if is_instance_valid(content):
		content.position = Vector2(5, 4)
		content.size = Vector2(max(1, rect.x - 10), max(1, rect.y - content_bottom - 4))

func _refresh_content():
	content.clear()
	action_keys.clear()
	var parts = text.split('#')
	if type == 'button':
		content.push_paragraph(HORIZONTAL_ALIGNMENT_CENTER)
	for i in parts.size():
		if i % 2 == 1:
			action_keys.append(parts[i])
			content.push_meta(str(action_keys.size() - 1))
			content.push_color(Color(0.05, 0.18, 0.35))
		var label = parts[i]
		for key in display_replacements:
			label = label.replace(key, str(display_replacements[key]))
		content.add_text(label)
		if i % 2 == 1:
			content.pop()
			content.pop()
	if type == 'button':
		content.pop()
	content.scroll_to_line(0)
	_layout_content()

func _on_link(meta):
	clicked.emit(action_keys[int(str(meta))], self)

func _on_content_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# Linked action text emits its original key; ordinary messages can be dismissed.
		if action_keys.is_empty():
			clicked.emit(text, self)

func _draw():
	draw_rect(Rect2(Vector2.ZERO, Vector2(rect)), Color.WHITE)
	draw_rect(Rect2(Vector2(0.5, 0.5), Vector2(rect) - Vector2.ONE), Color.BLACK, false, 1.0)
