class_name ArtLabels extends RefCounted

# English labels cover the baked French lettering without changing the original
# illustrations or their click targets. Coordinates are local to the 344x214 art.
static func apply(sprite: Sprite, image_path: String):
	for child in sprite.get_children():
		sprite.remove_child(child)
		child.queue_free()
	match image_path.get_file():
		"7243.png":
			var board = Polygon2D.new()
			board.polygon = PackedVector2Array([Vector2(224, 16), Vector2(267, 5), Vector2(257, 62), Vector2(218, 67)])
			board.color = Color.WHITE
			sprite.add_child(board)
			_label(sprite, Rect2(224, 22, 33, 41), "SAGE\nHERE", 8, Color.BLACK)
		"17421.png":
			_patch(sprite, Rect2(84, 132, 32, 25), "BUY\nSELL", 8)
		"2072.png":
			_patch(sprite, Rect2(49, 20, 44, 19), "HERBS", 9, Color.BLACK, Color.WHITE)
		"5233.png":
			_patch(sprite, Rect2(115, 68, 123, 13), "GENERAL STORE", 9)
		"25524.png":
			_patch(sprite, Rect2(276, 12, 61, 141), "Glossary\n5 gold\n\nAtlas\n3 gold\n\nAbacus\n4 gold", 10)
		"23971.png":
			_patch(sprite, Rect2(20, 25, 50, 71), "Water\nBeer\nRed wine\nSpirits", 8)
		"21914.png":
			_patch(sprite, Rect2(0, 24, 58, 83), "Water\nBeer\nRed wine\nSpirits", 9)
		"18508.png":
			_patch(sprite, Rect2(34, 33, 270, 168), "Traveller, I was told you would pass this way.\n\nI will not be here. Read this scroll; it will help you.\n\nThe gatekeeper", 12)

static func _patch(parent: Node, bounds: Rect2, text: String, font_size: int, background = Color.WHITE, foreground = Color.BLACK):
	var patch = ColorRect.new()
	patch.position = bounds.position
	patch.size = bounds.size
	patch.color = background
	patch.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(patch)
	_label(parent, Rect2(bounds.position + Vector2(2, 0), bounds.size - Vector2(4, 0)), text, font_size, foreground)

static func _label(parent: Node, bounds: Rect2, text: String, font_size: int, color: Color):
	var label = Label.new()
	label.position = bounds.position
	label.size = bounds.size
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.clip_text = true
	label.add_theme_font_override("font", preload("res://datas/fonts/lgsfont.ttf"))
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
