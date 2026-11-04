class_name PromptText extends Prompt

var text_field: LineEdit

func set_rect(x: int, y: int, width: int, height: int):
	super(x, y, width, height)
	
	text_field.offset_left = 6
	text_field.offset_top = rect.y - 74
	text_field.offset_right = rect.x - 6
	text_field.offset_bottom = rect.y - 44

func _ready():
	super._ready()
	
	content_bottom = 80
	text_field = $LineEdit
	text_field.add_theme_font_override("font", preload("res://datas/fonts/lgsfont.ttf"))
	text_field.add_theme_font_size_override("font_size", 16)
	text_field.placeholder_text = "Your name"
	text_field.add_theme_color_override("font_placeholder_color", Color(0.3, 0.3, 0.3))
