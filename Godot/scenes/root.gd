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
	if current_scene != null:
		remove_child(current_scene)
	
	current_scene = scenes[scene].instantiate()
	current_scene.root = self
	add_child(current_scene)
	
	size_changed()

func size_changed():
	var size = Vector2(512, 342)
	
	var current_size = DisplayServer.window_get_size()
	var is_mobile = current_size.x < 342
	
	var scale_factor = Vector2(current_size.x / size.x, current_size.y / size.y)
	set_scale(scale_factor)
	
	if current_scene != null:
		current_scene.update_layout(is_mobile)
