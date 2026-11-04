class_name EndScene extends Node2D

var root: RootScene
var story: Box

func _ready():
	root.soundManager.play("alleluia")
	story = preload("res://entities/box.tscn").instantiate()
	story.text = "THE KEEPER OF KNOWLEDGE\n\nCongratulations, " + root.user.name + "!\n\nYou have completed your quest and brought the three Talismans to Encyclopia. Your knowledge and perseverance have earned you the right to become the new Keeper of Knowledge.\n\nEncyclopia places the Great Book of Knowledge in your hands, the symbol of your new responsibility.\n\n#Return to the main menu#"
	story.clicked.connect(_on_action)
	add_child(story)

func _on_action(_action, _sender):
	root.soundManager.stopSounds()
	root.set_current_scene("main")

func update_layout(_is_mobile: bool):
	story.set_rect(16, 16, 480, 310)
