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

	info = Sprite.new("res://datas/images/19678.png")
	info.clicked.connect(_on_action)
	add_child(info)
	
	info_message = BoxScene.instantiate()
	info_message.text = "\n".join([
		"Le gardien du Savoir                 Version 1.0",
		"",
		"      Adapté sur Mac OS X, iPhone et iPad",
		"              par Mathieu Ledru",
		"",
		"    Version originale sur Hypercard (Mac OS 9)",
		"       par Monic et Bernard Grienenberger"
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
	student_menu_view.text = "#Commencer une nouvelle aventure.#\n#Reprendre une ancienne.#\n\n#Annuler.#"
	student_menu_view.visible = false
	student_menu_view.clicked.connect(_on_action)
	add_child(student_menu_view)
	
	new_user_prompt_view = PromptTextScene.instantiate()
	new_user_prompt_view.text = "Quel est ton prénom, aventurier."
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
		if senderAction == "Commencer une nouvelle aventure.":
			new_user_prompt_view.visible = true
		elif senderAction == "Reprendre une ancienne.":
			var user = User.new()
			var loadResult = user.load()
			if loadResult['success']:
				# load success
				var promptValue = "Voulez vous charger le périple du "
				promptValue += str(loadResult['savedate']['day'])
				promptValue += '/'
				promptValue += str(loadResult['savedate']['month'])
				promptValue += '/'
				promptValue += str(loadResult['savedate']['year'])
				promptValue += ' ?'
				
				load_user_prompt_view.text = promptValue
			else:
				# load fail
				load_user_prompt_view.text = "Aucune sauvegarde n'a été trouvée."
			
			load_user_prompt_view.visible = true
		
		student_menu_view.visible = false
	elif sender == new_user_prompt_view:
		if senderAction == "Ok" and new_user_prompt_view.text_field.text != "":
			root.user = User.new()
			root.user.name = new_user_prompt_view.text_field.text
			root.user.cardId = root.data.getInit("Main").statupCard
			root.set_current_scene("intro")
	elif sender == load_user_prompt_view:
		load_user_prompt_view.visible = false
		
		if senderAction == "Ok" and root.user.load()['success']:
			root.set_current_scene('game')

func update_layout(_is_mobile: bool):
	info.position = Vector2i(512 - 24, 342 - 20)
	info_message.set_rect(185, 185, 300, 125)
	student_view.set_rect(12, 311, 113, 27)
	student_menu_view.set_rect(12, 227, 208, 71)
	new_user_prompt_view.set_rect(106, 131, 300, 110)
	load_user_prompt_view.set_rect(106, 131, 300, 80)
