class_name IntroScene extends Node2D

var root: RootScene
var page = 0
var story: Box
var parchment: Sprite
var text_mask: ColorRect
const TEXT_BOUNDS = [Rect2(44, 72, 432, 244), Rect2(44, 3, 432, 300)]
const PAGES = [
	"LE GARDIEN DU SAVOIR\n\nEncyclopia, keeper of the secrets of knowledge, is looking for a worthy successor. Messengers have carried the news across the land.\n\nYou are a young monk studying in a remote monastery. One day, the abbot calls you to his chamber. You enter nervously, expecting a reprimand.",
	"YOUR QUEST\n\nThe abbot smiles. You have been chosen to seek Encyclopia and prove your courage, wisdom and thirst for knowledge.\n\nHe gives you thirteen gold coins. At dawn you set out, carrying your hopes for the journey ahead.\n\nExplore the towns, answer questions to earn Talents, and collect the three Talismans that open the abbey. Click choices or the scenery to travel. Use the bag for inventory, the disk to save, and the angel for advice."
]

func _ready():
	parchment = Sprite.new("res:/" + root.data.getInit("Intro").intro1Image)
	add_child(parchment)
	# Cover only the baked French lettering, keeping the original scroll edges.
	text_mask = ColorRect.new()
	text_mask.color = Color.WHITE
	text_mask.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(text_mask)
	story = preload("res://entities/box.tscn").instantiate()
	story.type = "button"
	story.draw_background = false
	story.clicked.connect(_on_action)
	add_child(story)
	story.content.add_theme_font_size_override("normal_font_size", 14)
	_show_page()

func _show_page():
	var image_key = "intro1Image" if page == 0 else "intro2Image"
	parchment.texture = load("res:/" + root.data.getInit("Intro")[image_key])
	var bounds = TEXT_BOUNDS[page]
	text_mask.position = bounds.position
	text_mask.size = bounds.size
	story.text = PAGES[page] + "\n\n#" + ("Continue" if page == 0 else "Begin your quest") + "#"

	update_layout(false)

func _center_story():
	var bounds = TEXT_BOUNDS[page]
	var text_height = minf(story.content.get_content_height(), bounds.size.y - 8)
	story.set_rect(int(bounds.position.x), int(bounds.position.y + (bounds.size.y - text_height - 8) / 2), int(bounds.size.x), int(text_height + 8))

func _on_action(_action, _sender):
	if page == 0:
		page = 1
		_show_page()
	else:
		root.set_current_scene("game")

func update_layout(_is_mobile: bool):
	var bounds = TEXT_BOUNDS[page]
	story.set_rect(int(bounds.position.x), int(bounds.position.y), int(bounds.size.x), int(bounds.size.y))
	_center_story.call_deferred()
