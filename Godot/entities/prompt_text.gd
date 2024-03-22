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
	
	text_field = $LineEdit
