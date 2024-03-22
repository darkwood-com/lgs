class_name EndScene extends Node2D

var root: RootScene
var currentState: String
var currentSprite: Sprite = null

func _ready():
	change_image("end1Image")

	root.soundManager.play("alleluia")

func change_image(key: String):
	currentState = key
	
	if currentSprite != null:
		remove_child(currentSprite)
	
	currentSprite = Sprite.new("res:/" + root.data.getInit("End")[key])
	currentSprite.clicked.connect(_on_action)
	add_child(currentSprite)

func _on_action(_action, sender):
	if sender == currentSprite:
		if currentState == "end1Image":
			root.soundManager.stopSounds()
			
			#return to the main menu
			root.set_current_scene("main")

func update_layout(_is_mobile: bool):
	currentSprite.position = Vector2i(0, 0)
