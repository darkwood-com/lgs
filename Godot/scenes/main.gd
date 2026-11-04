class_name MainScene extends Node2D

var BoxScene = preload("res://entities/box.tscn")
var PromptScene = preload("res://entities/prompt.tscn")
var PromptTextScene = preload("res://entities/prompt_text.tscn")

var root: RootScene
var info: Sprite
var info_message: Box
var student_view: Box
var student_menu_view: Box
var new_user_prompt_view: PromptText
var load_user_prompt_view: Box

func _ready():
	root.soundManager.play("lgs")
	
	var background = Sprite.new("res:/" + root.data.getInit("Main").backgroundImage)
	background.bubbleEvent = true
	add_child(background)
	# Replace only the baked French title; keep the original castle illustration.
	var title_background = ColorRect.new()
	title_background.position = Vector2(400, 12)
	title_background.size = Vector2(112, 180)
	title_background.color = Color.WHITE
	title_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(title_background)
	var title = Label.new()
	title.text = "THE\nKEEPER\nOF\nKNOWLEDGE"
	title.position = Vector2(402, 26)
	title.size = Vector2(106, 156)
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font", preload("res://datas/fonts/lgsfont.ttf"))
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color.BLACK)
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(title)

	info = Sprite.new("res://datas/images/19678.png")
	info.clicked.connect(_on_action)
	add_child(info)
	
	info_message = BoxScene.instantiate()
	info_message.text = "\n".join([
		"The Keeper of Knowledge Version 1.0",
		"",
		"      Adapted to Mac OS X, iPhone and iPad",
		"              by Mathieu Ledru",
		"",
		"    Original version on Hypercard (Mac OS 9)",
		"       by Monic and Bernard Grienenberger"
	])
	info_message.visible = false
	info_message.clicked.connect(_on_action)
	add_child(info_message)
	
	student_view = BoxScene.instantiate()
	student_view.text = "Menu"
	student_view.type = 'button'
	student_view.clicked.connect(_on_action)
	add_child(student_view)
	
	student_menu_view = BoxScene.instantiate()
	student_menu_view.text = "#Start a new adventure.#\n#Resume a saved adventure.#\n\n#Cancel.#"
	student_menu_view.visible = false
	student_menu_view.clicked.connect(_on_action)
	add_child(student_menu_view)
	
	new_user_prompt_view = PromptTextScene.instantiate()
	new_user_prompt_view.text = "What is your name, adventurer?"
	new_user_prompt_view.visible = false
	new_user_prompt_view.bubbleEvent = true
	new_user_prompt_view.clicked.connect(_on_action)
	add_child(new_user_prompt_view)
	
	load_user_prompt_view = PromptScene.instantiate()
	load_user_prompt_view.text = ""
	load_user_prompt_view.visible = false
	load_user_prompt_view.clicked.connect(_on_action)
	add_child(load_user_prompt_view)

func _on_action(senderAction, sender):
	if sender == info or sender == info_message:
		student_menu_view.visible = false
		new_user_prompt_view.visible = false
		load_user_prompt_view.visible = false
		
		info_message.visible = !info_message.visible
	elif sender == student_view:
		info_message.visible = false
		
		student_menu_view.visible = !student_menu_view.visible
	elif sender == student_menu_view:
		if senderAction == "Start a new adventure.":
			new_user_prompt_view.visible = true
		elif senderAction == "Resume a saved adventure.":
			var user = User.new()
			var loadResult = user.load()
			if loadResult['success']:
				# load success
				var promptValue = "Load your adventure saved on "
				promptValue += str(loadResult['savedate']['day'])
				promptValue += '/'
				promptValue += str(loadResult['savedate']['month'])
				promptValue += '/'
				promptValue += str(loadResult['savedate']['year'])
				promptValue += ' ?'
				
				load_user_prompt_view.text = promptValue
			else:
				# load fail
				load_user_prompt_view.text = "No saved game was found."
			
			load_user_prompt_view.visible = true
		
		student_menu_view.visible = false
	elif sender == new_user_prompt_view:
		if senderAction == "OK" and new_user_prompt_view.text_field.text != "":
			root.user = User.new()
			root.user.name = new_user_prompt_view.text_field.text
			root.user.cardId = root.data.getInit("Main").statupCard
			root.set_current_scene("intro")
	elif sender == load_user_prompt_view:
		load_user_prompt_view.visible = false
		
		if senderAction == "OK" and root.user.load()['success']:
			root.set_current_scene('game')

func update_layout(_is_mobile: bool):
	info.position = Vector2i(512 - 24, 342 - 20)
	info_message.set_rect(185, 185, 300, 125)
	student_view.set_rect(12, 311, 113, 27)
	student_menu_view.set_rect(12, 220, 230, 84)
	new_user_prompt_view.set_rect(106, 131, 300, 110)
	load_user_prompt_view.set_rect(106, 131, 300, 80)
