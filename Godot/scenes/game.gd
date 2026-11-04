class_name GameScene extends Node2D

var BoxScene = preload("res://entities/box.tscn")

var root: RootScene

var background: Sprite

var positionView #card position box
var descriptionView #card description box
var actionView #card action box
var msgView #card message box

var cameraView: Sprite #curent card image display
var surfacesView: Array[Surface] = [] #current card surfaces actions
var heroView: Sprite #display hero view
var angelView: Sprite #display angel view
var bagView: Sprite #display bag view
var saveView: Sprite #display save view
var mapView: Sprite #display map view
var mapButtonView: Sprite #display map button view (mobile)

var mode: Dictionary #mode (normal or question + params)
var actions: Dictionary #Dictionary<String => Action> card actions
var boxViewMessages: Dictionary #Dictionary<String => String>, message alterated before display
var boxOriginalViewMessages: Dictionary #Dictionary<String => String>, message original from the card (not alterated)
var boxViews: Dictionary #Dictionary<String => Box>

func _ready():
	mode = {}
	actions = {}
	boxViewMessages = {}
	boxOriginalViewMessages = {}
	
	#background image
	background = Sprite.new("res://datas/images/8980.png")
	add_child(background)
	
	#angel view
	angelView = Sprite.new("res://datas/images/10564.png")
	angelView.visible = true
	angelView.clicked.connect(_on_action)
	add_child(angelView)
	
	#bag view
	bagView = Sprite.new("res://datas/images/10311.png")
	bagView.clicked.connect(_on_action)
	add_child(bagView)
	
	#save view
	saveView = Sprite.new("res://datas/images/13710.png")
	saveView.clicked.connect(_on_action)
	add_child(saveView)
	
	#map button view
	mapButtonView = Sprite.new("res://datas/images/16050.png")
	mapButtonView.clicked.connect(_on_action)
	add_child(mapButtonView)
	
	#map view
	mapView = Sprite.new("res://datas/images/16012.png")
	mapView.clicked.connect(_on_action)
	add_child(mapView)
	
	#hero view
	heroView = Sprite.new("res://datas/images/5738.png")
	add_child(heroView)
	
	#buttons and texts
	positionView = BoxScene.instantiate()
	positionView.text = ""
	positionView.visible = true
	add_child(positionView)
	
	descriptionView = BoxScene.instantiate()
	descriptionView.text = ""
	descriptionView.visible = true
	add_child(descriptionView)
	
	actionView = BoxScene.instantiate()
	actionView.text = ""
	actionView.visible = true
	actionView.clicked.connect(_on_action)
	add_child(actionView)
	
	msgView = BoxScene.instantiate()
	msgView.text = ""
	msgView.visible = false
	msgView.clicked.connect(_on_action)
	add_child(msgView)
	
	boxViews["position"] = positionView
	boxViews["description"] = descriptionView
	boxViews["action"] = actionView
	boxViews["msg"] = msgView
	
	goCard(root.user.cardId)

func goCard(cardId: String):
	#print("current card: " + cardId)
	var lastCardId = root.user.cardId
	
	root.soundManager.stopSounds()
	
	customActions('CloseCard', null)
	
	var card = root.data.getCard(cardId)
	
	root.user.goCard(cardId)
	
	actions = card.actions.duplicate()
	
	for surface in surfacesView:
		remove_child(surface)
		surface.queue_free()
	surfacesView.clear()
	
	boxViewMessages = {
		"position": card.messages["position"],
		"description": card.messages["description"],
		"action": card.messages["action"],
		"msg": card.messages["angel"],
	}
	
	mode = {
		"mode": "normal",
	}
	#question management
	var actionParams = card.messages["action"].split(",") #question,cardReturnId,city,character
	if actionParams[0] == "@question":
		mode = {
			"mode": "question",
			"cardReturnId": actionParams[1],
			"city": actionParams[2],
			"character": actionParams[3],
		}
		
		if mode["cardReturnId"] == "last":
			mode["cardReturnId"] = lastCardId
		
		if root.user.nbQuestionsCharacter[mode["character"]] > 3:
			#4 questions max by characters
			boxViewMessages["description"] = "Sorry, @user! There are no more Talents for you here."
			boxViewMessages["action"] = "#Continue...#"
			
			actions["Continue..."] = Action.new("goCard", mode["cardReturnId"])
		else:
			boxViewMessages["description"] += "\nWhat do you choose?"
			boxViewMessages["action"] = "#2 Talents#\n#3 Talents#\n#4 Talents#\n#Do not answer.#"
			
			actions["2 Talents"] = Action.new("question", "2")
			actions["3 Talents"] = Action.new("question", "3")
			actions["4 Talents"] = Action.new("question", "4")
			actions["Do not answer."] = Action.new("goCard", mode["cardReturnId"])
	
	customActions("OpenCard", null)
	
	refreshTextViews()
	
	if(card.messages["angel"] == ""):
		angelView.visible = false
	else:
		angelView.visible = true
	
	if card.coords.x > 0 or card.coords.y > 0:
		heroView.position = Vector2(card.coords.x - 10, card.coords.y - 8)
	
	if cameraView == null:
		cameraView = Sprite.new("res:/" + card.imagePath)
		add_child(cameraView)
	else:
		cameraView.texture = load("res:/" + card.imagePath)
	
	ArtLabels.apply(cameraView, card.imagePath)

	for surface in card.surfaces:
		for surfaceRect in card.surfaces[surface]:
			var surfaceView = Surface.new(surface)
			surfaceView.clicked.connect(_on_action)
			surfaceView.set_rect(surfaceRect)
			add_child(surfaceView)
			surfacesView.append(surfaceView)
	
func refreshTextViews():
	# Translate original phrases before interpolating values. Choice metadata
	# keeps the original action key so translated labels cannot break navigation.
	var replacements = {
		"@user": root.user.name,
		"@gold": str(root.user.gold),
		"@pieceor": "gold coins" if root.user.gold != 1 else "gold coin",
	}
	var total_points = 0
	for city in root.user.points:
		total_points += root.user.points[city]
		replacements["@point" + city] = str(root.user.points[city])
		replacements["@talent" + city] = "Talents" if root.user.points[city] != 1 else "Talent"
	replacements["@totalPoints"] = str(total_points)
	for key in boxViewMessages:
		boxViews[key].display_replacements = replacements
		boxViews[key].text = boxViewMessages[key]
		boxViews[key].queue_redraw()

func _on_action(senderAction, sender):
	#print("action: " + senderAction)
	if sender == msgView:
		root.soundManager.stopSound("angel")
		msgView.visible = false
	
	if msgView.visible == true:
		return
	
	#default actions
	var currentAction = null
	if sender == msgView:
		#special action when click on message view
		currentAction = "action_message"
	elif sender is Surface:
		currentAction = sender.action
	elif sender is Box:
		currentAction = senderAction
	elif sender == angelView:
		match randi_range(0, 4):
			0:
				goCard('11660')
			1:
				goCard('11661')
			2:
				goCard('11662')
			3:
				goCard('11663')
			4:
				msgView.visible = true
				root.soundManager.play("angel", true)
	elif sender == bagView:
		var objectsTranslation = {
			"lexique": "a lexicon",
			"boulier": "an abacus",
			"atlas": "an atlas",
			"croix_celtique": "Litter's Talisman",
			"sablier": "Matem's Talisman",
			"piece_roi": "Histora's Talisman",
			"sac_or": "a coin purse",
			"herbes": "some herbs",
			"pepite": "a nugget",
			"pommes": "apples",
			"bouteille": "a bottle",
			"lait": "a pot of milk",
			"joncs": "rushes",
			"fleurs": "a bouquet of flowers",
			"collier": "a necklace",
			"torche": "a torch"
		}
		var msgValue = "Talents: Litter @pointLitter @talentLitter, Matem @pointMatem @talentMatem, Histora @pointHistora @talentHistora, Encyclopia @pointEncyclopia @talentEncyclopia.\n"
		msgValue += "You own @gold @pieceor "
		
		var objectsDesc = []
		for object in root.user.objects:
			if root.user.objects[object]:
				objectsDesc.append(objectsTranslation[object])
		
		if objectsDesc.size() > 0:
			msgValue += "and there is in your bag:\n"
			msgValue += ", ".join(objectsDesc)
			msgValue += "."
		else:
			msgValue += "and there is nothing in your bag."
		
		boxViewMessages['msg'] = msgValue
		msgView.visible = true
	elif sender == saveView:
		root.user.save()
		
		boxViewMessages['msg'] = "@user, your journey has been recorded."
		msgView.visible = true
	elif sender == mapButtonView or (sender == mapView and mapButtonView.visible):
		mapView.visible = !mapView.visible
		heroView.visible = !heroView.visible
	
	for anAction in actions:
		if currentAction == anAction:
			var action = actions[anAction]
			if action.type == "goCard":
				goCard(action.value)
			elif action.type == "printMsg":
				boxViewMessages['msg'] = action.value
				msgView.visible = true
			elif action.type == "customAction":
				currentAction = action.value
			elif action.type == "question" and mode['mode'] == 'question':
				currentAction = ""
				actions.clear()

				#find a question with the same amount of point and that the user do not have already answered
				var questions: Array = root.data.getQuestionsFromCity(mode["city"])
				var chosenQuestion: Question = null
				for question in questions:
					if str(question.points) == action.value and not root.user.didAnswer(question):
						chosenQuestion = question
				
				#@todo : reset all asked question when user have seen all question (and points) from this city
				#message : Tu as déjà vu toutes les questions correspondant à 'city'.
				#          Je veux tout de même te donner une nouvelle chance : nous allons reprendre parmi les questions déjà vues.
				
				if chosenQuestion:
					#display question chosen and create answer actions
					var answers: Array = []
					for answer in chosenQuestion.answers:
						actions[answer] = Action.new("answer", answer)
						answers.append("#" + answer + "#")
					
					boxViewMessages['description'] = chosenQuestion.ask
					boxViewMessages['action'] = "\n".join(answers)
					
					#save chosenQuestion for the next response action
					mode['chosenQuestion'] = chosenQuestion
				else:
					#no more question found for that kind of points
					var description: String = "@user, you have already seen all the questions of "
					description += action.value
					description += " talents for "
					description += mode["city"]
					
					boxViewMessages['description'] = description
					boxViewMessages['action'] = "#Continue...#"
					
					actions["Continue..."] = Action.new("goCard", mode["cardReturnId"])
			elif action.type == "answer" and mode['mode'] == 'question':
				var responseSounds: Array = []
				var result = root.user.answer(action.value, mode["chosenQuestion"], mode["character"], mode["city"])
				
				if result.isValid:
					responseSounds = ["juste1", "juste2", "juste3", "juste4", "juste5", "juste6", "juste7"]
					var description: String = "Well done, @user!\n“"
					description += result.validAnswer
					description += "” is correct.\nYou earn "
					description += str(result.points)
					description += " Talents."
					
					boxViewMessages['description'] = description
				else:
					responseSounds = ["faux1", "faux2", "faux3", "faux4", "faux5", "faux6", "faux7"]
					var description: String = "No, you're wrong, @user.\nThe correct answer was: “"
					description += result.validAnswer
					description += "”"
					if result.points < 0:
						description += "\nI'm taking away a Talent from you."
					
					boxViewMessages['description'] = description
				
				var responseSound: String = responseSounds[randi() % responseSounds.size()]
				root.soundManager.play(responseSound, false)
				
				boxViewMessages['action'] = "#Continue...#"
				actions["Continue..."] = Action.new("goCard", mode["cardReturnId"])
	
	customActions('Current', currentAction)
	
	refreshTextViews()

# custom action, that depends on card id
# no time to make a perfect and generic action catcher!
# so all custom actions are grouped here
func customActions(actionEvent: String, currentAction):
	if actionEvent == 'OpenCard':
		if root.user.cardId == "4101" or root.user.cardId == "5535" or root.user.cardId == "2149" or root.user.cardId == "14986" or root.user.cardId == "13563" or root.user.cardId == "9383" or root.user.cardId == "13968" or root.user.cardId == "7004" or root.user.cardId == "5079" or root.user.cardId == "7367" or root.user.cardId == "9464" or root.user.cardId == "7548" or root.user.cardId == "9635" or root.user.cardId == "7872" or root.user.cardId == "4269" or root.user.cardId == "11594" or root.user.cardId == "3901" or root.user.cardId == "5463" or root.user.cardId == "5683" or root.user.cardId == "3515" or root.user.cardId == "4519" or root.user.cardId == "4710":
			var nbStepsCat: int = root.user.adventures["nbStepsCat"]
			if nbStepsCat > 0:
				root.user.adventures["nbStepsCat"] = nbStepsCat - 1
				
				if randi_range(0, 2):
					boxViewMessages["msg"] = "That damn cat's fleas are eating you. It itch all over your body. Will you end up getting rid of it?"
					msgView.visible = true
		
		if root.user.cardId == "4651":
			root.soundManager.play("oiseau", true)
		elif root.user.cardId == "5725":
			root.soundManager.play("clochettes", false)
		elif root.user.cardId == "11322":
			root.soundManager.play("fermeporte", false)
			if root.user.objects["atlas"]:
				var actionValue: String = boxViewMessages["action"]
				actionValue += "\n#offer your atlas to the wise.#"
				boxViewMessages["action"] = actionValue
		elif root.user.cardId == "4929":
			if !root.user.adventures["lueur_pepite"]:
				var description: String = boxViewMessages["description"]
				description = description.replace("A bright glow at the side of the path catches your eye. ", "")
				boxViewMessages["description"] = description
				
				var action: String = boxViewMessages["action"]
				action = action.replace("\n#examine this glow.#", "")
				boxViewMessages["action"] = action
		elif root.user.cardId == "10279":
			root.soundManager.play("coucou_boucle", false)
		elif root.user.cardId == "22568":
			root.soundManager.play("grincements_armoire", false)
			
			root.user.objects["sac_or"] = true
			root.user.gold = root.user.gold + 20
		elif root.user.cardId == "22179":
			root.soundManager.play("grincements_coffre", false)
		elif root.user.cardId == "9819":
			root.soundManager.play("corbeau_boucle", true)
		elif root.user.cardId == "19631":
			if root.user.objects["pommes"]:
				root.soundManager.play("chute", false)
				root.user.objects["pommes"] = false
				
				var msgValue: String = ""
				msgValue += "As you enter the inn, you trip and the contents of your bag spill onto the floor. The apples you picked"
				msgValue += " roll on the ground. When he sees them, the hostel owner gets angry and calls you a thief."
				msgValue += " Indeed, these apples come from his orchard and you picked them without authorization."
				msgValue += " You get out of this mess by "
				
				if root.user.gold > 1:
					msgValue += "returning the apples to him along with a gold coin."
					root.user.gold = root.user.gold - 1
				else:
					msgValue += "making the apples responsible for his anger."
				
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
		elif root.user.cardId == "20556" or root.user.cardId == "7367":
			root.soundManager.play("mouette_boucle", true)
		elif root.user.cardId == "27845":
			root.soundManager.play("ermite", false)
			if !root.user.objects["pommes"]:
				var action: String = boxViewMessages["action"]
				action = action.replace("\n#give your apples to the hermit.#", "")
				boxViewMessages["action"] = action
		elif root.user.cardId == "31118":
			root.soundManager.play("brasse_boucle", true)
			
			var msgValue: String = ""
			msgValue += "The river is very rough. You are carried by a furious current. Several times,"
			msgValue += " you think you are lost. Fortunately, the swimming lessons you took,"
			msgValue += " yet reluctantly, at the monastery, allow you to float without too much harm."
			
			if root.user.gold > 1:
				root.user.gold = floor(root.user.gold / 2.0)
				msgValue += " As you swim, you feel that you are losing some of your gold coins."
			
			boxViewMessages["msg"] = msgValue
			msgView.visible = true
		elif root.user.cardId == "3573":
			root.soundManager.play("oiseaux_boucle", true)
		elif root.user.cardId == "4548":
			if root.user.objects["pepite"]:
				var action: String = boxViewMessages["action"]
				action += "\n#show your nugget to the jeweler.#"
				boxViewMessages["action"] = action
			elif !root.user.objects["collier"]:
				var action: String = boxViewMessages["action"]
				action += "\n#buy a necklace.#"
				boxViewMessages["action"] = action
		elif root.user.cardId == "4686":
			if root.user.gold == 0:
				var action: String = boxViewMessages["action"]
				action = action.replace("\n#give a gold coin#\n#to the maid.#", "")
				boxViewMessages["action"] = action
		elif root.user.cardId == "5261":
			root.soundManager.play("rires_boucle", true)
		elif root.user.cardId == "7100":
			if root.user.gold == 0 or root.user.objects["bouteille"]:
				var action: String = boxViewMessages["action"]
				action += "\n#buy a bottle of wine.#"
				boxViewMessages["action"] = action
		elif root.user.cardId == "82770":
			root.soundManager.play("fermeporte", false)
			if !root.user.objects["lexique"]:
				var action: String = boxViewMessages["action"]
				action = action.replace("\n#offer your glossary to the priest.#", "")
				boxViewMessages["action"] = action
		elif root.user.cardId == "6197":
			root.soundManager.play("haltela", false)
		elif root.user.cardId == "7855":
			var description: String = ""
			
			if root.user.points["Matem"] > 20:
				description = "You have @pointMatem @talentMatem. This allows you to enter Matica's abode."
				
				var action: String = boxViewMessages["action"]
				action += "\n#Enter the residence.#"
				boxViewMessages["action"] = action
			else:
				description = "You only have @pointMatem @talentMatem. This is not enough to enter Matica's home."

			
			boxViewMessages["description"] = description
		elif root.user.cardId == "9150":
			root.soundManager.play("flute2", false)
		elif root.user.cardId == "8027":
			if !root.user.objects["fleurs"]:
				var action: String = boxViewMessages["action"]
				action = action.replace("\n#Give your flowers#\n#to the woman at the window.#", "")
				boxViewMessages["action"] = action
		elif root.user.cardId == "9432" or root.user.cardId == "9627" or root.user.cardId == "10567" or root.user.cardId == "11590" or root.user.cardId == "12941" or root.user.cardId == "7004" or root.user.cardId == "10308" or root.user.cardId == "11340" or root.user.cardId == "15930":
			root.soundManager.play("seagulls_boucle", true)
		elif root.user.cardId == "13183":
			root.soundManager.play("aaaah", false)
			if root.user.gold == 0:
				var action: String = boxViewMessages["action"]
				action = action.replace("\n#give a gold coin to the fisherman#\n#to comfort him.#", "")
				boxViewMessages["action"] = action
		elif root.user.cardId == "15565":
			root.soundManager.play("goutte", true)
			
			if !root.user.objects["joncs"]:
				var action: String = boxViewMessages["action"]
				action = action.replace("\n#make a torch#\n#with your rushes.#", "")
				boxViewMessages["action"] = action
		elif root.user.cardId == "13877":
			var description: String = ""
			
			if root.user.points["Histora"] > 20:
				description = "You have @pointHistora @talentHistora. This allows you to enter Kronolos' home."
				
				var action: String = boxViewMessages["action"]
				action += "\n#Enter the residence.#"
				boxViewMessages["action"] = action
			else:
				description = "You only have @pointHistora @talentHistora. This is not enough to enter Kronolos's home."
			
			boxViewMessages["description"] = description
		elif root.user.cardId == "15213":
			root.soundManager.play("leroi", false)
		elif root.user.cardId == "10877":
			root.soundManager.play("oiseau", true)
		elif root.user.cardId == "12274":
			root.soundManager.play("piu2", true)
		elif root.user.cardId == "13399":
			root.soundManager.play("morceau_flute", true)
		elif root.user.cardId == "13659":
			root.soundManager.play("enclume", true)
		elif root.user.cardId == "15762":
			root.soundManager.play("goutte", true)
		elif root.user.cardId == "2990" or root.user.cardId == "3814" or root.user.cardId == "5204" or root.user.cardId == "7729":
			root.soundManager.play("fete", true)
		elif root.user.cardId == "4269" or root.user.cardId == "11594":
			root.soundManager.play("coq", true)
		elif root.user.cardId == "6640":
			root.soundManager.play("portes_eglise", false)
		elif root.user.cardId == "9635":
			if !root.user.objects["boulier"]:
				var action: String = boxViewMessages["action"]
				action = action.replace("\n#Offer your abacus to the notable.#", "")
				boxViewMessages["action"] = action
		elif root.user.cardId == "9914":
			if root.user.gold == 0:
				var action: String = boxViewMessages["action"]
				action = action.replace("\n#give a gold coin#\n#to the old woman.#", "")
				boxViewMessages["action"] = action
		elif root.user.cardId == "5974":
			var description: String = ""
			
			if root.user.points["Litter"] > 20:
				description = "You have @pointLitter @talentLitter. This allows you to enter Lingus' abode."
				
				var action: String = boxViewMessages["action"]
				action += "\n#Enter the residence.#"
				boxViewMessages["action"] = action
			else:
				description = "You only have @pointLitter @talentLitter. This is not enough to enter Lingus's home."
			
			boxViewMessages["description"] = description
		elif root.user.cardId == "8034":
			root.soundManager.play("grillejardin", false)
			if !root.user.objects["lait"]:
				var action: String = boxViewMessages["action"]
				action = action.replace("\n#Sell ​​your jar of milk.#", "")
				boxViewMessages["action"] = action
		elif root.user.cardId == "8277":
			root.soundManager.play("clochettes2", false)
			if !root.user.objects["herbes"]:
				var action: String = boxViewMessages["action"]
				action = action.replace("\n#show your herbs.#", "")
				boxViewMessages["action"] = action
		elif root.user.cardId == "11876":
			if !root.user.objects["fleurs"]:
				var action: String = boxViewMessages["action"]
				action = action.replace("\n#Give your flowers to the nun.#", "")
				boxViewMessages["action"] = action
		elif root.user.cardId == "25754":
			if !root.user.objects["lait"]:
				var action: String = boxViewMessages["action"]
				action = action.replace("\n#give your pot of milk#\n#to the cook.#", "")
				boxViewMessages["action"] = action
	elif actionEvent == 'Current':
		if root.user.cardId == "5725":
			if currentAction == "trader":
				var msgValue: String = "It's you, @user"

				var nbAdviceBoutique: int = root.user.adventures["nbAdviceBoutique"]
				if nbAdviceBoutique < 4:
					msgValue += "?\nI can tell you that"

					var msgChoice = {
						1: "a glossary will come in handy in the town of Litter.",
						2: "an abacus will be very useful to you in the town of Matem.",
						3: "an atlas will be very useful to you in the city of Histora."
					}

					msgValue += msgChoice[nbAdviceBoutique]

					root.user.adventures["nbAdviceBoutique"] = nbAdviceBoutique + 1

					if !(root.user.objects["lexique"] and root.user.objects["boulier"] and root.user.objects["atlas"]):
						msgValue += "\nWhat are you going to buy me?"
				else:
					msgValue += ".\nYou've already bothered me enough! Will you end up letting me work in peace?"

					if !(root.user.objects["lexique"] and root.user.objects["boulier"] and root.user.objects["atlas"]):
						msgValue += "\nBuy me something instead!"

				boxViewMessages["msg"] = msgValue
				msgView.visible = true
			elif currentAction == "lexique" or currentAction == "boulier" or currentAction == "atlas":
				var prices = {
					"lexique": 5,
					"boulier": 4,
					"atlas": 3
				}

				if root.user.objects[currentAction]:
					#sell
					root.user.objects[currentAction] = false
					root.user.gold = root.user.gold + prices[currentAction]
				elif root.user.gold - prices[currentAction] >= 0:
					#buy
					root.user.objects[currentAction] = true
					root.user.gold = root.user.gold - prices[currentAction]

			#update actionView 'buy' or 'sell'
			var actionTextView: String = ""
			if root.user.objects["lexique"]:
				actionTextView += "#resell the lexicon.#\n"
			else:
				actionTextView += "#buy a glossary.#\n"
			if root.user.objects["boulier"]:
				actionTextView += "#resell the abacus.#\n"
			else:
				actionTextView += "#buy an abacus.#\n"
			if root.user.objects["atlas"]:
				actionTextView += "#resell the atlas.#\n"
			else:
				actionTextView += "#buy an atlas.#\n"
			actionTextView += "#talk to the shopkeeper.#\n#leave the store.#"
			boxViewMessages["action"] = actionTextView
		elif root.user.cardId == "5535" or root.user.cardId == "9819":
			if currentAction == "fleurs":
				var msgValue: String = ""
				
				if root.user.objects["fleurs"]:
					msgValue = "There are already enough flowers in your bag! They will eventually wither."
				else:
					msgValue = "You spend a pleasant time in the fields choosing the prettiest flowers you have seen in a long time. Their colors and smell enchant you."
					root.user.objects["fleurs"] = true
				
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
		elif root.user.cardId == "11322":
			if currentAction == "atlas_sage" and root.user.objects["atlas"]:
				var msgValue: String = ""
				if root.user.adventures["atlas_sage"]:
					msgValue += "You have little memory! You have already sold an atlas "
					msgValue += "similar to the wise man not so long ago. He explains to you that a "
					msgValue += "second copy of the same work is of little interest "
					msgValue += "for him and advises you to keep this false atlas for a "
					msgValue += "best use. He also thinks that this could "
					msgValue += "serve on the island of Histora."
				else:
					msgValue += "Your atlas interests the wise to the greatest extent. It gives you "
					msgValue += "gives 5 gold coins, which gives you a good profit. He formulates "
					msgValue += "the hope that you will not miss this atlas during the rest of your journey."
					
					root.user.objects["atlas"] = false
					root.user.gold = root.user.gold + 5
					root.user.adventures["atlas_sage"] = true
					
					var actionValue: String = boxViewMessages["action"]
					actionValue = actionValue.replace("\n#offer your atlas to the wise.#", "")
					boxViewMessages["action"] = actionValue

				boxViewMessages["msg"] = msgValue
				msgView.visible = true
		elif root.user.cardId == "4929":
			if currentAction == "lueur" and root.user.adventures["lueur_pepite"]:
				root.user.adventures["lueur_pepite"] = false
				root.user.objects["pepite"] = true
				
				var description: String = boxViewMessages["description"]
				description = description.replace("A bright glow at the side of the path catches your eye. ", "")
				boxViewMessages["description"] = description
				
				var action: String = boxViewMessages["action"]
				action = action.replace("\n#examine this glow.#", "")
				boxViewMessages["action"] = action
				
				var msgValue: String = "By searching the ditch carefully, you discover what had caught your attention: a nugget!"
				msgValue += " This discovery seems interesting enough to you and you put it in your bag."
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
		elif root.user.cardId == "15536":
			if currentAction == "lit":
				var msgValue: String = "As soon as you lie down, you fall asleep. You are the victim of a horrible nightmare in which a sadistic professor forces you"
				msgValue += " to make a perilous journey into an imaginary country."
				msgValue += " Luckily, the fresh air wakes you up and you realize it was all a dream."
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
			elif currentAction == "armoire":
				if root.user.objects["sac_or"]:
					var msgValue: String = "You've already searched this cupboard and you've already taken the bag of gold inside. There's nothing left inside."
					msgValue += "\nYou weren't hoping to find a second one, were you?"
					boxViewMessages["msg"] = msgValue
					msgView.visible = true
				else:
					goCard("22568")
			elif currentAction == "coffre":
				if root.user.adventures["gnome"] > 1:
					var msgValue: String = "You scared the gnome away! Do not you remember ? Should have been a little nicer to him."
					msgValue += " Now there's no one in the trunk. There is therefore no point in fighting over it."
					boxViewMessages["msg"] = msgValue
					msgView.visible = true
				else:
					goCard("22179")

		elif root.user.cardId == "22179":
			if currentAction == "saisir_gnome":
				var nbSaisie: int = root.user.adventures["gnome"]
				var description: String = ""
				
				if nbSaisie > 0:
					root.soundManager.play("pascourant", false)
					
					description += "This time, the gnome saw you arrive in time, he quickly moved out of your reach, then he ran away as quickly as possible."
					description += " deep in the surrounding forest. You might never see him again!"
					boxViewMessages["description"] = description
				elif nbSaisie == 0:
					root.soundManager.play("argn", false)
					
					description += "The gnome did not give in easily! He bit your little finger during the fight.\nYou will suffer during "
					description += "several hours. It would be better not to start these kinds of jokes again!"
					boxViewMessages["description"] = description
				
				root.user.adventures["gnome"] = (nbSaisie+1)
				
				boxViewMessages["description"] = description
				boxViewMessages["action"] = "#Continue...#"
				
				actions["Continue..."] = Action.new("goCard", "15536")
		elif root.user.cardId == "9383":
			if currentAction == "pommes":
				if root.user.objects["pommes"]:
					var msgValue: String = "You already have several of these apples in your bag. There is no need to take everything!"
					boxViewMessages["msg"] = msgValue
					msgView.visible = true
				else:
					var msgValue: String = "After tasting one of these wonderful fruits, you decide to take some with you for the rest of your journey. You put a few apples at the bottom of your bag."
					boxViewMessages["msg"] = msgValue
					msgView.visible = true
					
					root.user.objects["pommes"] = true
		elif root.user.cardId == "27845":
			if currentAction == "pommes_ermite":
				root.user.objects["pommes"] = false
				
				var action: String = boxViewMessages["action"]
				action = action.replace("\n#give your apples to the hermit.#", "")
				boxViewMessages["action"] = action
				
				var msgValue: String = "The old hermit thanks you for your gift and carefully stores the apples in a corner of his cave."
				msgValue += " To thank you for your generosity, he promises to choose from the easiest questions"
				msgValue += " if you decide to try your luck with him."
				
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
		elif root.user.cardId == "31118":
			if msgView.visible == false:
				goCard("2921")
		elif root.user.cardId == "4548":
			if currentAction == "pepite_joaillier":
				root.user.objects["pepite"] = false
				root.user.objects["collier"] = true
				root.user.gold = root.user.gold + 3
				
				var msgValue: String = "The jeweler confirms what you thought: it is indeed a gold nugget! It also seems to contain a mass "
				msgValue += "importance of the precious metal. In exchange, the jeweler gives you"
				msgValue += " three gold coins and a necklace of set stones."
				
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
				
				var action: String = boxViewMessages["action"]
				action = action.replace("\n#show your nugget to the jeweler.#", "")
				boxViewMessages["action"] = action
			elif currentAction == "acheter_collier":
				var msgValue: String = ""
				
				if root.user.gold >= 2:
					msgValue += "The jeweler shows you an impressive collection of"
					msgValue += " superb necklaces of set stones that he created himself."
					msgValue += " you choose one, with silver highlights, for which you pay two gold coins."
					
					root.user.objects["collier"] = true
					root.user.gold = root.user.gold - 2
				else:
					msgValue += "You don't have enough gold coins for this."
				
				boxViewMessages["msg"] = msgValue
				msgView.visible = true

				var action: String = boxViewMessages["action"]
				action = action.replace("\n#buy a necklace.#", "")
				boxViewMessages["action"] = action
			elif currentAction == "chat":
				var msgValue: String = "Miaaaaahhhhhh!"
				
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
			elif currentAction == "diplome":
				var msgValue: String = "This is a diploma from the best jeweler in Matem. No interest for you."
				
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
		elif root.user.cardId == "4686":
			if currentAction == "pieceor_servante" and root.user.gold >= 1:
				root.user.gold = root.user.gold - 1
				
				var msgValue: String = "The servant thanks you for your generosity. She will finally be able to buy the jewelry she dreamed of and"
				msgValue += " that she saw at her neighbor's jeweler's house. To thank you, she "
				msgValue += "indicates that you can find an abacus in the store which "
				msgValue += "is located south of Encyclopia Abbey."
				
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
				
				var action: String = boxViewMessages["action"]
				action = action.replace("\n#give a gold coin#\n#to the maid.#", "")
				boxViewMessages["action"] = action
			elif currentAction == "fenetre":
				var msgValue: String = "Through the window you see a Matem square."
				
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
		elif root.user.cardId == "7100":
			if currentAction == "acheter_bouteille":
				if root.user.gold >= 2 and !root.user.objects["bouteille"]:
					root.user.gold = root.user.gold - 2
					root.user.objects["bouteille"] = true
					
					var msgValue: String = "The owner of the tavern seems very surprised to see a young monk make such a request."
					msgValue += " But he can no longer refuse to sell you his wine when you"
					msgValue += " Explain to him that it’s not for you. This costs you 2 gold."
					
					boxViewMessages["msg"] = msgValue
					msgView.visible = true
					
					var action: String = boxViewMessages["action"]
					action = action.replace("\n#buy a bottle of wine.#", "")
					boxViewMessages["action"] = action
			elif currentAction == "acheter_tonneau":
				var msgValue: String = "A bottle of wine will be more than enough. You're still not going to buy a barrel!"
				
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
		elif root.user.cardId == "82770":
			if currentAction == "vepres":
				root.soundManager.play("deogratias", false)
				
				var msgValue: String = "You attend, with your usual amazement, the evening service. The Gregorian chants which accompany it are of "
				msgValue += "purity that you have rarely encountered. When the Deo Gratias "
				msgValue += "The finale sounds in the large church of Matem, you have tears in your eyes."
				
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
			elif currentAction == "lexique_prete" and root.user.objects["lexique"]:
				if root.user.adventures["lexique_prete"]:
					var msgValue: String = "You have little memory! You already sold a similar lexicon to the priest. A single glossary is more than enough and "
					msgValue += "he really doesn't need this second book. You "
					msgValue += "will surely find a better use. So go see Litter."
					
					boxViewMessages["msg"] = msgValue
					msgView.visible = true
				else:
					root.user.gold = root.user.gold + 5
					root.user.objects["lexique"] = false
					root.user.adventures["lexique_prete"] = true
					
					var msgValue: String = "This will allow the priest to check the translations of his clerics."
					msgValue += " He gives you 5 gold coins from this lexicon. You're getting a good deal."
					msgValue += " Unless, perhaps, you need this glossary elsewhere."
					
					boxViewMessages["msg"] = msgValue
					msgView.visible = true
					
					var action: String = boxViewMessages["action"]
					action = action.replace("\n#offer your glossary to the priest.#", "")
					boxViewMessages["action"] = action
		elif root.user.cardId == "6197":
			if currentAction == "entrer_caserne":
				if root.user.objects["bouteille"]:
					root.user.objects["bouteille"] = false
					
					var description: String = "The guard lets you pass in exchange for your bottle of wine.\nOf course, you must not tell the knights about this!"
					boxViewMessages["description"] = description
					boxViewMessages["action"] = "#Continue...#"
					
					actions["Continue..."] = Action.new("goCard", "7533")
				else:
					var msgValue: String = "The guard refuses to let you pass. You try to negotiate with him but he is inflexible because, he says, "
					msgValue += "the instructions given to him by the knights are very strict."
					msgValue += " For example, he has nothing to drink for the entire duration of his custody and this is very painful for him."
					boxViewMessages["msg"] = msgValue
					msgView.visible = true
		elif root.user.cardId == "7533":
			if currentAction == "aaarghh":
				var msgValue: String = "Aaaarghh!"
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
		elif root.user.cardId == "7855":
			if currentAction == "retourner_entrer":
				if root.user.points["Matem"] > 20:
					goCard("9150")
				else:
					goCard("6581")
		elif root.user.cardId == "9150":
			if currentAction == "matica":
				var msgValue: String = ""
				
				if root.user.objects["sablier"]:
					msgValue += "Ah, it's you, @user. I see you continue your quest."
					msgValue += " Unfortunately, I don't have time to take care of you right now."
					msgValue += " moment. Since you brought me this wonderful abacus, I"
					msgValue += " works without stopping.\nGood luck, @user!"
				elif root.user.objects["boulier"]:
					msgValue += "Hello, @user. I see you brought me the abacus that"
					msgValue += " I have been looking for so long.\nI will finally "
					msgValue += "be able to finish my research!\nTo reward you,"
					msgValue += " I offer you a talisman that will allow you to enter Encyclopia Abbey."
				else:
					msgValue += "Who comes to disturb me during my work?"
					msgValue += "\nIt's you, @user! Did you bring me the item I sent for?"
					msgValue += "\nNo !?!\nSo don't come back until you find it!"

				boxViewMessages["msg"] = msgValue
				msgView.visible = true
			elif currentAction == "action_message":
				if root.user.objects["sablier"]:
					goCard("7855")
				elif root.user.objects["boulier"]:
					root.user.objects["boulier"] = false
					root.user.objects["sablier"] = true
					goCard("2183")
				else:
					goCard("7855")
		elif root.user.cardId == "8027":
			if currentAction == "parler_dame":
				var msgValue: String = "Hello cute mink... May luck be with you in your quest."
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
			elif currentAction == "caresser_chien":
				var msgValue: String = "This dog doesn't seem very clean. Beware."
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
			elif currentAction == "fleurs_dame":
				var msgValue: String = "The lady is very flattered by the tribute you pay her with this magnificent bouquet of flowers. For you "
				
				msgValue += " thank you, she recommends that you go see the knight for her"
				msgValue += " in his barracks. She tells you that the guard at the entrance leaves"
				msgValue += " easily bribed with a bottle of wine."
				
				if root.user.gold < 2:
					msgValue += " Additionally, she gives you 3 gold for your trouble."
					root.user.gold = root.user.gold + 3
				
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
				
				root.user.objects["fleurs"] = false
				
				var action: String = boxViewMessages["action"]
				action = action.replace("\n#Give your flowers#\n#to the woman at the window.#", "")
				boxViewMessages["action"] = action
		elif root.user.cardId == "5497":
			if currentAction == "pencher_rambarde":
				var msgValue: String = "Seen from here, the island of Histora looks magnificent."
				
				if root.user.objects["lexique"] or root.user.objects["boulier"] or root.user.objects["atlas"]:
					msgValue += " To see better, you lean a little too far and you notice "
					msgValue += "that your bag has opened above the void. Trying to bring him back to you, you see"
					
					var objectsFallen: int = 0
					var tempMsgValue: String = ""
					if root.user.objects["lexique"]:
						root.user.objects["lexique"] = false
						
						tempMsgValue += ", your lexicon"
						objectsFallen += 1
					if root.user.objects["boulier"]:
						root.user.objects["boulier"] = false
						
						tempMsgValue += ", your abacus"
						objectsFallen += 1
					if root.user.objects["atlas"]:
						root.user.objects["atlas"] = false
						
						tempMsgValue += ", your atlas"
						objectsFallen += 1
					
					if objectsFallen == 1:
						tempMsgValue = tempMsgValue.replace(",", "")
					elif objectsFallen == 2:
						tempMsgValue = tempMsgValue.replace(",", " And")
						tempMsgValue = tempMsgValue.replace(" And", "")
					elif objectsFallen == 3:
						tempMsgValue = tempMsgValue.replace(",", "")
						tempMsgValue = tempMsgValue.replace(",", " And")
					
					msgValue += tempMsgValue
					msgValue += " falling into the middle of the waves, fifty meters below."
				
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
		elif root.user.cardId == "12941" or root.user.cardId == "15930":
			if currentAction == "aller_nord" or currentAction == "aller_ouest"or currentAction == "aller_est":
				var description: String = "After a problem-free crossing, you disembark "
				if currentAction == "aller_nord":
					description += "on the island of Histora."
				elif currentAction == "aller_ouest":
					description += "in the town of Litter."
				elif currentAction == "aller_est":
					description += "in the town of Matem."
				
				description += " The ship has already gone far away."
				
				if root.user.gold >= 2:
					root.user.gold = root.user.gold - 2
					description += " It cost you two gold coins."
				else:
					description += " You were unable to pay for your crossing, you were forced to wash the deck and the hold."
				
				boxViewMessages["description"] = description
				boxViewMessages["action"] = "#Continue...#"
				
				if currentAction == "aller_nord":
					actions["Continue..."] = Action.new("goCard", "10084")
				elif currentAction == "aller_ouest":
					actions["Continue..."] = Action.new("goCard", "7004")
				elif currentAction == "aller_est":
					actions["Continue..."] = Action.new("goCard", "9627")
		elif root.user.cardId == "10084":
			if currentAction == "barque_litter" or currentAction == "barque_matem":
				var description: String = "After a long crossing, you finally arrive "
				if currentAction == "barque_litter":
					description += "on the port of Litter. A sailor who is there agrees to bring the boat back to Histora."
				elif currentAction == "barque_matem":
					description += "on the port of Matem. A fisherman who is there agrees to bring the boat back to Histora."
				
				description += " The ship has already gone far away."
				
				if root.user.gold >= 1:
					root.user.gold = root.user.gold - 1
					description += " You pay for it with a gold coin."
				
				boxViewMessages["description"] = description
				boxViewMessages["action"] = "#Continue...#"
				
				if currentAction == "barque_litter":
					actions["Continue..."] = Action.new("goCard", "7004")
				elif currentAction == "barque_matem":
					actions["Continue..."] = Action.new("goCard", "9627")
		elif root.user.cardId == "12274":
			if currentAction == "joncs":
				if root.user.objects["joncs"]:
					var msgValue: String = "By stuffing your bag with these rushes, you will end up making it crack."
					boxViewMessages["msg"] = msgValue
					msgView.visible = true
				else:
					root.user.objects["joncs"] = true
					
					var msgValue: String = "With much difficulty, you finally succeed in cutting a few hard and dry stems from these rushes."
					msgValue += " You braid them before putting them in your bag."
					boxViewMessages["msg"] = msgValue
					msgView.visible = true
		elif root.user.cardId == "11997":
			if currentAction == "frapper_porte":
				root.soundManager.play("knock", false)
		elif root.user.cardId == "13183":
			if currentAction == "piece_or" and root.user.gold >= 1:
				root.user.gold = root.user.gold - 1
				
				var msgValue: String = "The fisherman, astonished at your generosity, recovers from his emotions and is already thinking of the false new fillet he will be able to "
				msgValue += "buy yourself with this money. To thank you, he "
				msgValue += "indicates that you can find an atlas in the store which "
				msgValue += "is located south of Encyclopia Abbey."
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
				
				if root.user.gold >= 1:
					var action: String = boxViewMessages["action"]
					action = action.replace("\n#give a gold coin to the fisherman#\n#to comfort him.#", "")
					boxViewMessages["action"] = action
		elif root.user.cardId == "12302":
			root.soundManager.stopSounds()
			root.soundManager.play("vache", true)
			if currentAction == "traire_vache":
				if root.user.objects["lait"]:
					var msgValue: String = "You have already filled your jug ​​with milk and you have no other container."
					msgValue += " In any case, we don't milk a cow every five minutes!"
					boxViewMessages["msg"] = msgValue
					msgView.visible = true
				else:
					root.soundManager.stopSounds()
					root.soundManager.play("traite", true)
					root.user.objects["lait"] = true
					
					var msgValue: String = "A pot happened to be on the ground, at the side of the path. You sit down and milk the cow. The milk that"
					msgValue += " What you get from it seems rich and creamy. It is true that the pastures"
					msgValue += " surroundings are very green. After enjoying this beverage"
					msgValue += ", you decide to keep some with you for the road."
					boxViewMessages["msg"] = msgValue
					msgView.visible = true
		elif root.user.cardId == "15565":
			if currentAction == "dechiffrer_inscriptions":
				if root.user.objects["torche"]:
					var description: String = "Indeed, your tinder lighter succeeded without any problem in igniting the rush torch."
					description += " We can immediately see more clearly! So let's see these inscriptions..."
					
					root.user.objects["torche"] = false
					
					boxViewMessages["description"] = description
					boxViewMessages["action"] = "#Continue...#"
					actions["Continue..."] = Action.new("goCard", "15762")
				elif root.user.objects["joncs"]:
					var msgValue: String = "It's way too dark in this cave!"
					boxViewMessages["msg"] = msgValue
					msgView.visible = true
				else:
					var msgValue: String = "It's way too dark in this cave! Even with your tinder lighter you can't decipher"
					msgValue += " what is written on the wall. You need a torch..."
					boxViewMessages["msg"] = msgValue
					msgView.visible = true
			elif currentAction == "confectionner_torche":
				if root.user.objects["torche"]:
					var msgValue: String = "A single torch will be more than enough!"
					boxViewMessages["msg"] = msgValue
					msgView.visible = true
				else:
					root.user.objects["torche"] = true
					root.user.objects["joncs"] = false
					
					var msgValue: String = "With your tinder lighter, it will be easy for you to ignite this improvised torch."
					msgValue += " You still have rushes at the bottom of your bag."
					boxViewMessages["msg"] = msgValue
					msgView.visible = true

		elif root.user.cardId == "13877":
			if currentAction == "retourner_entrer":
				if root.user.points["Histora"] > 20:
					goCard("15213")
				else:
					goCard("12591")
		elif root.user.cardId == "15213":
			if currentAction == "kronolos":
				var msgValue: String = ""
				
				if root.user.objects["piece_roi"]:
					msgValue += "Ah, it's you, @user. I see you continue your quest."
					msgValue += " Unfortunately, I don't have time to take care of you right now."
					msgValue += " moment. Since you brought me this wonderful atlas, I"
					msgValue += " works without stopping.\nGood luck, @user!"
				elif root.user.objects["atlas"]:
					msgValue += "Hello, @user. I see that you brought me the atlas that"
					msgValue += " I have been looking for so long.\nI will finally "
					msgValue += "be able to finish my research!\nTo reward you,"
					msgValue += " I offer you a talisman that will allow you to enter Encyclopia Abbey."
				else:
					msgValue += "Who comes to disturb me during my work?"
					msgValue += "\nIt's you, @user! Did you bring me the item I sent for?"
					msgValue += "\nNo !?!\nSo don't come back until you find it!"
				
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
			elif currentAction == "action_message":
				if root.user.objects["piece_roi"]:
					goCard("13877")
				elif root.user.objects["atlas"]:
					root.user.objects["atlas"] = false
					root.user.objects["piece_roi"] = true
					goCard("29757")
				else:
					goCard("13877")
		elif root.user.cardId == "5079":
			if currentAction == "caresser_chat":
				var nbStepsCat: int = root.user.adventures["nbStepsCat"]
				
				var msgValue: String = ""
				if nbStepsCat > 0:
					msgValue += "The cat refuses to be approached. You run after him"
					msgValue += " for a few moments without ever being able to touch him. Tired,"
					msgValue += " you end up giving up. It's also good, considering what you "
					msgValue += "happened last time."
				else:
					root.soundManager.play("chat", false)
					
					msgValue += "You pet the cat for a few moments. This one "
					msgValue += "lets it happen without any apparent reaction. Suddenly you jump "
					msgValue += "and throw the cat away from you! horror ! It's crawling with fleas!"
					msgValue += " you are infested yourself."
				
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
				
				root.user.adventures["nbStepsCat"] = 15 #15 = temps de se débarrasser des puces] = 15
			elif currentAction == "coup_de_pied_chien":
				var nbCoupDePieds: int = root.user.adventures["coupDePied_chien"]
				
				var msgValue: String = ""
				
				if nbCoupDePieds % 3 == 0:
					msgValue += "Under the blow, the dog runs away along the street, howling in pain."
					root.soundManager.play("ouah5", false)
				elif nbCoupDePieds % 3 == 1:
					msgValue += "Under the blow, the dog is thrown two meters and remains inert as if you had kicked a stone."
					root.soundManager.play("claps", false)
				elif nbCoupDePieds % 3 == 2:
					msgValue += "The dog clings to your calf and while uttering fierce growls, "
					msgValue += "he bites you savagely. You risk having a mark for a long time!"
					root.soundManager.play("grognements", false)
				
				if nbCoupDePieds >= 3:
					msgValue += " A few minutes later, he returns, seeming to have forgotten everything."
				
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
				root.user.adventures["coupDePied_chien"] = (nbCoupDePieds + 1)
		elif root.user.cardId == "9635":
			if currentAction == "boulier_notable":
				var msgValue: String = ""
				
				if root.user.adventures["boulier_notable"]:
					msgValue += "Would you have lost your memory! You have already sold an abacus "
					msgValue += "similar to notable. The first "
					msgValue += "suits him perfectly and he has no need for another abacus. keep it "
					msgValue += "so on you, it will surely be useful to you. Especially if "
					msgValue += "you still have to travel to Matem."
				else:
					msgValue += "The notable is delighted by the quality of your abacus."
					msgValue += " You don't even need to parley to get 5 nice ones "
					msgValue += "gold coins. Hopefully you won't miss this item later."
					
					root.user.gold = root.user.gold + 5
					root.user.objects["boulier"] = false
					root.user.adventures["boulier_notable"] = true
					
					var action: String = boxViewMessages["action"]
					action = action.replace("\n#Offer your abacus to the notable.#", "")
					boxViewMessages["action"] = action
				
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
		elif root.user.cardId == "9914":
			if currentAction == "pieceor_femme":
				var msgValue: String = "The old woman throws herself on her knees in front of you and thanks you for your generosity. She will be able to embellish the trousseau of"
				msgValue += " her daughter who is dancing at this very moment at the party organized at "
				msgValue += " his neighbors behind. To thank you, she "
				msgValue += "indicates that you can find a glossary in the store which "
				msgValue += "is located south of Encyclopia Abbey."
				
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
				
				root.user.gold = root.user.gold - 1
				
				if root.user.gold == 0:
					var action: String = boxViewMessages["action"]
					action = action.replace("\n#give a gold coin#\n#to the old woman.#", "")
					boxViewMessages["action"] = action
		elif root.user.cardId == "7872":
			if currentAction == "cueillir_herbes":
				var msgValue: String = ""
				
				if root.user.adventures["vente_herbes"] == 2:
					msgValue += "You have already sold your harvest twice! What"
					msgValue += " left by the wayside is not enough for another resale. Of all"
					msgValue += " ways, you are not here to trade! Let"
					msgValue += " so this grass in its place!"
				elif root.user.objects["herbes"]:
					msgValue += "There are already enough herbs in your bag!"
				else:
					root.user.objects["herbes"] = true
					
					msgValue += "You pick a few blades of this herb whose smell is"
					msgValue += " bewitching. You decide to keep some of your pickings "
					msgValue += " in your bag."
				
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
		elif root.user.cardId == "4269":
			if root.user.adventures["mendiant"]:
				goCard("11594")
		elif root.user.cardId == "6164":
			if root.user.adventures["mendiant"]:
				goCard("11594")
			
			if currentAction == "une_piece" or currentAction == "deux_pieces":
				root.user.adventures["mendiant"] = true
				
				var msgValue: String = "The beggar thanks you for your generosity and he"
				msgValue += " indicates that Lord Lingus' house is a little further north."
				
				if currentAction == "une_piece" and root.user.gold >= 1:
					msgValue += "\nHe gets up and limps away."
					root.user.gold = root.user.gold - 1
				elif currentAction == "deux_pieces" and root.user.gold >= 2:
					msgValue += "He adds that one of the guards told him that possession "
					msgValue += "of a lexicon is very useful in the residence of this lord."
					msgValue += "\nHe gets up and limps away."
					root.user.gold = root.user.gold - 2
				else:
					msgValue += "You don't have enough coins for this."
				
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
			elif currentAction == "travailler":
				root.user.adventures["mendiant"] = true
				
				var msgValue: String = "The beggar rushes at you, showering you with insults."
				msgValue += " You defend yourself as best you can. In the fight, "
				msgValue += "a blow leaves you dazed."
				
				if root.user.objects["pepite"]:
					msgValue += "The beggar takes advantage of your daze to steal your nugget and"
					
					root.user.objects["pepite"] = false
				else:
					msgValue += "The beggar seeing you groggy gets scared and"
				
				msgValue += "runs away.\nIt would have been better to give him alms."
				
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
		elif root.user.cardId == "5974":
			if currentAction == "entrer":
				if root.user.points["Litter"] > 20:
					goCard("8607")
		elif root.user.cardId == "8607":
			if currentAction == "lingus":
				var msgValue: String = ""
				
				if root.user.objects["croix_celtique"]:
					msgValue += "Ah, it's you, @user. I see you continue your quest."
					msgValue += " Unfortunately, I don't have time to take care of you right now."
					msgValue += " moment. Since you brought me this wonderful lexicon, I"
					msgValue += " works without stopping.\nGood luck, @user!"
				elif root.user.objects["lexique"]:
					msgValue += "Hello, @user. I see that you brought me the lexicon that"
					msgValue += " I have been looking for so long.\nI will finally "
					msgValue += "be able to finish my research!\nTo reward you,"
					msgValue += " I offer you a talisman that will allow you to enter Encyclopia Abbey."
				else:
					msgValue += "Who comes to disturb me during my work?"
					msgValue += "\nIt's you, @user! Did you bring me the item I sent for?"
					msgValue += "\nNo !?!\nSo don't come back until you find it!"
				
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
			elif currentAction == "action_message":
				if root.user.objects["croix_celtique"]:
					goCard("5974")
				elif root.user.objects["lexique"]:
					root.user.objects["lexique"] = false
					root.user.objects["croix_celtique"] = true
					goCard("10697")
				else:
					goCard("5974")
		elif root.user.cardId == "8034":
			if currentAction == "vendre_lait":
				var msgValue: String = "The gentleman thanks you very much for this good milk which comes from,"
				msgValue += " undoubtedly from the island of Histora. He pays you three"
				msgValue += " gold coins that add to your fortune. So you have "
				msgValue += "now @gold @pieceor."
				
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
				
				var action: String = boxViewMessages["action"]
				action = action.replace("\n#Sell ​​your jar of milk.#", "")
				boxViewMessages["action"] = action
				
				root.user.objects["lait"] = false
				root.user.gold = root.user.gold + 3
			elif currentAction == "regarder_mirroir":
				var msgValue: String = "You see in the mirror the image of a youngster exhausted by his already long walk. Guess who it is..."
				
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
		elif root.user.cardId == "8277":
			if currentAction == "montrer_herbes":
				var msgValue: String = "The herbalist is extremely satisfied with the quality of the "
				msgValue += "herbs that you bring to him. He gives you 3 gold coins."
				
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
				
				var action: String = boxViewMessages["action"]
				action = action.replace("\n#show your herbs.#", "")
				boxViewMessages["action"] = action
				
				root.user.objects["herbes"] = false
				root.user.adventures["vente_herbes"] =  root.user.adventures["vente_herbes"] + 1
				root.user.gold = root.user.gold + 3
			elif currentAction == "sonner_clochettes":
				root.soundManager.play("clochettes2", false)
		elif root.user.cardId == "10465":
			if currentAction == "sonner_clochettes":
				root.soundManager.play("clochettes2", false)
		elif root.user.cardId == "6640":
			if currentAction == "prier":
				var msgValue: String = "Heavenly music resounds in your mind.\n"
				msgValue += "An impressive calm invades you.\nYou go "
				msgValue += "be able to resume your journey, with a calm mind, ready to face"
				msgValue += " the many trials that await you."
				
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
				
				root.soundManager.play("gloria", false)
			elif currentAction == "piece_tronc":
				var msgValue: String = ""
				if root.user.gold >= 1:
					msgValue += "The beadle thanks you, and assures you that the Good Lord "
					msgValue += "will repay you a hundredfold."
					
					root.user.gold = root.user.gold - 1
				else:
					msgValue += "You have no more coins!\n(but it was a good intention)"
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
				
				root.soundManager.play("piece_tronc", false)
		elif root.user.cardId == "6740":
			if currentAction == "commander_boire":
				var msgValue: String = ""
				if root.user.adventures["taverne"] > 2:
					root.user.adventures["taverne"] = 4
					
					msgValue += "The innkeeper refuses to give you a third time"
					msgValue += " drink his wine. He throws you out like a drunk."
				elif root.user.gold >= 1:
					msgValue += "The tavern keeper serves you the most delicious local wines."
					msgValue += "\nYou delight in this nectar, and it is joy"
					msgValue += " in the heart as you continue your journey.\n"
					msgValue += "It cost you a gold coin, but it was worth it!"
					
					root.user.adventures["taverne"] = (root.user.adventures["taverne"] + 1)
					
					root.soundManager.play("bierre", false)
				else:
					msgValue += "You order a drink from the tavern keeper. This one asks you"
					msgValue += " your money first. Unfortunately you no longer have "
					msgValue += "piece.\nThe innkeeper therefore refuses to serve you."
				
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
			elif currentAction == "action_message" and root.user.adventures["taverne"] > 3:
				goCard("4710")
			elif currentAction == "spiritueux":
				if root.user.adventures["taverne"] > 3:
					root.user.adventures["taverne"] = 3
				var msgValue: String = "A young monk like you shouldn't touch this kind of spirits."
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
			elif currentAction == "assoir":
				if root.user.adventures["taverne"] > 3:
					root.user.adventures["taverne"] = 3
				var msgValue: String = "All right. Nothing stops you from sitting down for a moment."
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
		elif root.user.cardId == "6816":
			if currentAction == "entrer_abbaye":
				if root.user.objects["croix_celtique"] and root.user.objects["sablier"] and root.user.objects["piece_roi"]:
					goCard("8813")
				else:
					var msgValue: String = "The brother doorman asks you to show him your Talismans, tokens of your merits."
					msgValue += " As you do not have the three Talismans which are essential,"
					msgValue += " he unceremoniously escorts you back to the exit."
					boxViewMessages["msg"] = msgValue
					msgView.visible = true

		elif root.user.cardId == "11876":
			if currentAction == "fleurs_nonne":
				root.user.objects["fleurs"] = false
				
				var msgValue: String = "The nun thanks you very much for this charming bouquet which will allow her to decorate the altar in a magnificent way. For you "
				msgValue += "thank you, she recommends that you go see her sister "
				msgValue += "cook in the east tower of the abbey to ask him for some of his famous soup."
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
				
				var action: String = boxViewMessages["action"]
				action = action.replace("\n#Give your flowers to the nun.#", "")
				boxViewMessages["action"] = action
		elif root.user.cardId == "12973":
			if currentAction == "entrer_bibliotheque":
				if root.user.points["Encyclopia"] > 20:
					goCard("18460")
				else:
					var msgValue: String = "You have not collected enough Talents to be able to enter this place."
					msgValue += " You still have to undergo some tests."
					boxViewMessages["msg"] = msgValue
					msgView.visible = true
				
		elif root.user.cardId == "25754":
			if currentAction == "donner_lait":
				root.user.objects["lait"] = false
				
				var msgValue: String = "The cook thanks you for your present which could not have come at a better time, and, in exchange,"
				msgValue += " gives you a bowl of the vegetable soup she just came from"
				msgValue += " to prepare. With a spoon of milk to make it even more"
				msgValue += " creamy, this soup is tasty. You're enjoying yourself!"
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
				
				var action: String = boxViewMessages["action"]
				action = action.replace("\n#give your pot of milk#\n#to the cook.#", "")
				boxViewMessages["action"] = action
		elif root.user.cardId == "18460":
			if currentAction == "saluer_encyclopia":
				var msgValue: String = "Well done, @user. You finished your journey and you were able to bring me back"
				msgValue += " the three Talismans. Thanks to your knowledge, you collected @totalPoints Talents during your quest."
				msgValue += "\nI therefore think that you are capable of taking over my difficult succession as Keeper of Knowledge."
				msgValue += "\nAs a sign of your appointment, I will now give you the Book of Knowledge."
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
			elif currentAction == "action_message":
				#end game!!
				#go to endViewController
				root.set_current_scene("end")
	elif actionEvent == 'CloseCard':
		if root.user.cardId == "22568":
			root.soundManager.play("fermeporte", false)

func update_layout(is_mobile: bool):
	var card = root.data.getCard(root.user.cardId)
	
	background.position = Vector2(0, 0)
	cameraView.position = Vector2(167, 1)
	angelView.position = Vector2(135, 308)
	bagView.position = Vector2(78, 308)
	saveView.position = Vector2(28, 307)
	saveView.set_scale(Vector2(1, 1))
	mapView.position = Vector2(0, 0)
	mapButtonView.position = Vector2(1, 1)
	mapButtonView.set_scale(Vector2(1, 1))
	bagView.set_scale(Vector2(1, 1))
	angelView.set_scale(Vector2(1, 1))
	heroView.position = Vector2(card.coords.x - 10, card.coords.y - 8)
	positionView.set_rect(2, 147, 162, 70)
	descriptionView.set_rect(2, 219, 298, 87)
	actionView.set_rect(300, 219, 211, 87)
	msgView.set_rect(2, 219, (300 - 2) + 211, 87)
	
	if is_mobile:
		saveView.position = Vector2(24, 24)
		saveView.set_scale(Vector2(1.4, 1.4))
		mapButtonView.position = Vector2(98, 24)
		mapButtonView.set_scale(Vector2(1.4, 1.4))
		mapButtonView.visible = true
		bagView.position = Vector2(24, 90)
		bagView.set_scale(Vector2(1.4, 1.4))
		angelView.position = Vector2(98, 90)
		angelView.set_scale(Vector2(1.4, 1.4))
		mapView.visible = false
		heroView.visible = false
		descriptionView.set_rect(2, 219, 298, 120)
		actionView.set_rect(300, 219, 211, 120)
		msgView.set_rect(2, 219, (300 - 2) + 211, 120)
	else:
		mapButtonView.visible = false
		mapView.visible = true
		heroView.visible = true
	
	pass
