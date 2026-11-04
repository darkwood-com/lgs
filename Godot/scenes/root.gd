class_name RootScene extends Node2D

@onready var viewport = get_viewport()

var current_scene = null
var data: Data
var user: User
var soundManager: SoundManager

var scenes = {
	"main": preload("res://scenes/main.tscn"),
	"intro": preload("res://scenes/intro.tscn"),
	"game": preload("res://scenes/game.tscn"),
	"end": preload("res://scenes/end.tscn"),
}

func _init():
	data = Data.new()
	user = User.new()
	soundManager = SoundManager.new()
	soundManager.root = self

func _ready():
	viewport.connect("size_changed", size_changed)
	
	add_child(soundManager)
	
	set_current_scene("main")
	
	size_changed()

func set_current_scene(scene: String):
	if scene == "game":
		var gamepix = get_node_or_null("/root/GPX")
		if gamepix != null:
			gamepix.gameStart()
	if current_scene != null:
		remove_child(current_scene)
		current_scene.queue_free()
	
	current_scene = scenes[scene].instantiate()
	current_scene.root = self
	add_child(current_scene)
	
	size_changed()

func size_changed():
	# All scenes use the same 512 x 342 logical coordinates. Fit the entire
	# scene uniformly, including inside GamePix's minimum 800 x 450 iframe.
	var logical_size = Vector2(512, 342)
	var available = viewport.get_visible_rect().size
	var factor = min(available.x / logical_size.x, available.y / logical_size.y)
	scale = Vector2.ONE * factor
	position = (available - logical_size * factor) / 2.0
	if current_scene != null:
		current_scene.update_layout(available.x < 342)
