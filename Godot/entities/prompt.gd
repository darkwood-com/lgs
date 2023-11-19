class_name Prompt extends Box

var BoxScene = preload("res://entities/box.tscn")
var yes_view: Box
var no_view: Box

func set_rect(x: int, y: int, width: int, height: int):
	super(x, y, width, height)
	yes_view.set_rect(rect.x - 66, rect.y - 34, 60, 27)
	
	if no_view:
		no_view.set_rect(rect.x - 132, rect.y - 34, 60, 27)

func _ready():
	yes_view = BoxScene.instantiate()
	yes_view.text = "Ok"
	yes_view.type = 'button'
	yes_view.clicked.connect(_on_yes_view_clicked)
	add_child(yes_view)
	
	if type == 'bool':
		no_view = BoxScene.instantiate()
		no_view.text = "Annuler"
		no_view.type = 'button'
		no_view.clicked.connect(_on_no_view_clicked)
		add_child(no_view)

func _on_yes_view_clicked(action, _sender):
	clicked.emit(action, self)

func _on_no_view_clicked(action, _sender):
	clicked.emit(action, self)
