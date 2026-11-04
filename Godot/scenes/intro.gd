class_name IntroScene extends Node2D

var root: RootScene
var page = 0
var story: Box
const PAGES = [
	"THE KEEPER OF KNOWLEDGE\n\nEncyclopia, keeper of the secrets of knowledge, is looking for a worthy successor. Messengers have carried the news across the land.\n\nYou are a young monk studying in a remote monastery. One day, the abbot calls you to his chamber. You enter nervously, expecting a reprimand.",
	"YOUR QUEST\n\nThe abbot smiles. You have been chosen to seek Encyclopia and prove your courage, wisdom and thirst for knowledge.\n\nHe gives you thirteen gold coins. At dawn you set out, carrying your hopes for the journey ahead.\n\nExplore the towns, answer questions to earn Talents, and collect the three Talismans that open the abbey. Click underlined choices or the scenery to travel. Use the bag to inspect your belongings, the disk to save, and the angel for advice. Scroll any text panel to read longer messages."
]

func _ready():
	story = preload("res://entities/box.tscn").instantiate()
	story.clicked.connect(_on_action)
	add_child(story)
	_show_page()

func _show_page():
	story.text = PAGES[page] + "\n\n#" + ("Continue" if page == 0 else "Begin your quest") + "#"

func _on_action(_action, _sender):
	if page == 0:
		page = 1
		_show_page()
	else:
		root.set_current_scene("game")

func update_layout(_is_mobile: bool):
	story.set_rect(16, 16, 480, 310)
