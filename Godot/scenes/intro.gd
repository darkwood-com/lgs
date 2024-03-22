class_name IntroScene extends Node2D

var root: RootScene
var currentState: String
var currentSprite: Sprite = null

func _ready():
	change_image("intro1Image")

func change_image(key: String):
	currentState = key
	
	if currentSprite != null:
		remove_child(currentSprite)
	
	currentSprite = Sprite.new("res:/" + root.data.getInit("Intro")[key])
	currentSprite.clicked.connect(_on_action)
	add_child(currentSprite)

func _on_action(_action, sender):
	if sender == currentSprite:
		if currentState == "intro1Image":
			change_image("intro2Image")
		elif currentState == "intro2Image":
			#start the real game
			root.set_current_scene("game")

func update_layout(_is_mobile: bool):
	currentSprite.position = Vector2i(0, 0)
