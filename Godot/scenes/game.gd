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
	
	actions = card.actions
	
	for surface in surfacesView:
		remove_child(surface)
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
			boxViewMessages["description"] = "Désolé, @user ! Il n'y a plus de Talents pour toi ici."
			boxViewMessages["action"] = "#Suite...#"
			
			actions["Suite..."] = Action.new("goCard", mode["cardReturnId"])
		else:
			boxViewMessages["description"] += "\nQue choisis-tu ?"
			boxViewMessages["action"] = "#2 Talents#\n#3 Talents#\n#4 Talents#\n#Ne pas répondre.#"
			
			actions["2 Talents"] = Action.new("question", "2")
			actions["3 Talents"] = Action.new("question", "3")
			actions["4 Talents"] = Action.new("question", "4")
			actions["Ne pas répondre."] = Action.new("goCard", mode["cardReturnId"])
	
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
	
	for surface in card.surfaces:
		for surfaceRect in card.surfaces[surface]:
			var surfaceView = Surface.new(surface)
			surfaceView.clicked.connect(_on_action)
			surfaceView.set_rect(surfaceRect)
			add_child(surfaceView)
			surfacesView.append(surfaceView)
	
func refreshTextViews():
	#update and replace keywords in boxviews
	for boxView in boxViewMessages:
		var textValue: String = boxViewMessages[boxView]
		textValue = textValue.replace("@user", root.user.name)
		textValue = textValue.replace("@gold", str(root.user.gold))
		if root.user.gold > 1:
			textValue = textValue.replace("@pieceor", "pièces d'or")
		else:
			textValue = textValue.replace("@pieceor", "pièce d'or")
		
		var totalPoints: int = 0
		for city in root.user.points:
			totalPoints += root.user.points[city]
			
			var pointKey: String = "@point" + city
			var talentKey: String = "@talent" + city
			
			textValue = textValue.replace(pointKey, str(root.user.points[city]))
			if int(root.user.points[city]) > 1:
				textValue = textValue.replace(talentKey, "talents")
			else:
				textValue = textValue.replace(talentKey, "talent")
		textValue = textValue.replace("@totalPoints", str(totalPoints))
		
		boxViews[boxView].text = textValue
		boxViews[boxView].queue_redraw()

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
			"lexique": "un lexique",
			"boulier": "un boulier",
			"atlas": "un atlas",
			"croix_celtique": "le Talisman de Litter",
			"sablier": "le Talisman de Matem",
			"piece_roi": "le Talisman de Histora",
			"sac_or": "une bourse",
			"herbes": "quelques herbes",
			"pepite": "une pépite",
			"pommes": "des pommes",
			"bouteille": "une bouteille",
			"lait": "un pot de lait",
			"joncs": "des joncs",
			"fleurs": "un bouquet de fleurs",
			"collier": "un collier",
			"torche": "une torche"
		}
		var msgValue = "Talents : Litter @pointLitter @talentLitter, Matem @pointMatem @talentMatem, Histora @pointHistora @talentHistora, Encyclopia @pointEncyclopia @talentEncyclopia.\n"
		msgValue += "Vous possédez @gold @pieceor "
		
		var objectsDesc = []
		for object in root.user.objects:
			if root.user.objects[object]:
				objectsDesc.append(objectsTranslation[object])
		
		if objectsDesc.size() > 0:
			msgValue += "et il y a dans votre sac :\n"
			msgValue += ", ".join(objectsDesc)
			msgValue += "."
		else:
			msgValue += "et il n'y a rien dans votre sac."
		
		boxViewMessages['msg'] = msgValue
		msgView.visible = true
	elif sender == saveView:
		root.user.save()
		
		boxViewMessages['msg'] = "@user, ton périple a été enregistré."
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
					var description: String = "@user, tu as déjà vu toutes les questions de "
					description += action.value
					description += " talents pour "
					description += mode["city"]
					
					boxViewMessages['description'] = description
					boxViewMessages['action'] = "#Suite...#"
					
					actions["Suite..."] = Action.new("goCard", mode["cardReturnId"])
			elif action.type == "answer" and mode['mode'] == 'question':
				var responseSounds: Array = []
				var result = root.user.answer(action.value, mode["chosenQuestion"], mode["character"], mode["city"])
				
				if result.isValid:
					responseSounds = ["juste1", "juste2", "juste3", "juste4", "juste5", "juste6", "juste7"]
					var description: String = "Bravo, @user !\n«"
					description += result.validAnswer
					description += "» est en effet la bonne réponse.\nJe t'accorde donc les "
					description += str(result.points)
					description += " Talents que tu mérites."
					
					boxViewMessages['description'] = description
				else:
					responseSounds = ["faux1", "faux2", "faux3", "faux4", "faux5", "faux6", "faux7"]
					var description: String = "Non, tu fais erreur, @user.\nUne bonne réponse était: «"
					description += result.validAnswer
					description += "»"
					if result.points < 0:
						description += "\nJe te retire un Talent."
					
					boxViewMessages['description'] = description
				
				var responseSound: String = responseSounds[randi() % responseSounds.size()]
				root.soundManager.play(responseSound, false)
				
				boxViewMessages['action'] = "#Suite...#"
				actions["Suite..."] = Action.new("goCard", mode["cardReturnId"])
	
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
					boxViewMessages["msg"] = "Les puces de ce satané chat vous dévorent. Cela vous démange sur tout le corps. Allez-vous finir par vous en débarrasser ?"
					msgView.visible = true
		
		if root.user.cardId == "4651":
			root.soundManager.play("oiseau", true)
		elif root.user.cardId == "5725":
			root.soundManager.play("clochettes", false)
		elif root.user.cardId == "11322":
			root.soundManager.play("fermeporte", false)
			if root.user.objects["atlas"]:
				var actionValue: String = boxViewMessages["action"]
				actionValue += "\n#proposer votre atlas au sage.#"
				boxViewMessages["action"] = actionValue
		elif root.user.cardId == "4929":
			if !root.user.adventures["lueur_pepite"]:
				var description: String = boxViewMessages["description"]
				description = description.replace("Une vive lueur sur le bord du chemin attire votre attention. ", "")
				boxViewMessages["description"] = description
				
				var action: String = boxViewMessages["action"]
				action = action.replace("\n#examiner cette lueur.#", "")
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
				msgValue += "En entrant dans l'auberge, vous trébuchez et le contenu de votre sac se répand sur le sol. Les pommes que vous avez cueillies"
				msgValue += " roulent sur le sol. A leur vue, le patron de l'auberge se met en colère et vous traite de voleur."
				msgValue += " En effet, ces pommes proviennent de son verger et vous les avez cueillies sans autorisation."
				msgValue += " Vous vous sortez de ce mauvais pas en "
				
				if root.user.gold > 1:
					msgValue += "lui rendant les pommes accompagnées d'une pièce d'or."
					root.user.gold = root.user.gold - 1
				else:
					msgValue += "lui rendant les pommes responsables de sa colère."
				
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
		elif root.user.cardId == "20556" or root.user.cardId == "7367":
			root.soundManager.play("mouette_boucle", true)
		elif root.user.cardId == "27845":
			root.soundManager.play("ermite", false)
			if !root.user.objects["pommes"]:
				var action: String = boxViewMessages["action"]
				action = action.replace("\n#donner vos pommes à l'ermite.#", "")
				boxViewMessages["action"] = action
		elif root.user.cardId == "31118":
			root.soundManager.play("brasse_boucle", true)
			
			var msgValue: String = ""
			msgValue += "La rivière est très agitée. Vous êtes entraîné par un courant furieux. Plusieurs fois,"
			msgValue += " vous vous croyez perdu. Heureusement, les cours de natation que vous avez suivis,"
			msgValue += " pourtant avec réticence, au monastère, vous permettent de surnager sans trop de dommage."
			
			if root.user.gold > 1:
				root.user.gold = floor(root.user.gold / 2.0)
				msgValue += " Pendant que vous nagez, vous sentez que vous perdez une partie de vos pièces d'or."
			
			boxViewMessages["msg"] = msgValue
			msgView.visible = true
		elif root.user.cardId == "3573":
			root.soundManager.play("oiseaux_boucle", true)
		elif root.user.cardId == "4548":
			if root.user.objects["pepite"]:
				var action: String = boxViewMessages["action"]
				action += "\n#montrer votre pépite au joaillier.#"
				boxViewMessages["action"] = action
			elif !root.user.objects["collier"]:
				var action: String = boxViewMessages["action"]
				action += "\n#acheter un collier.#"
				boxViewMessages["action"] = action
		elif root.user.cardId == "4686":
			if root.user.gold == 0:
				var action: String = boxViewMessages["action"]
				action = action.replace("\n#donner une pièce d'or#\n#à la servante.#", "")
				boxViewMessages["action"] = action
		elif root.user.cardId == "5261":
			root.soundManager.play("rires_boucle", true)
		elif root.user.cardId == "7100":
			if root.user.gold == 0 or root.user.objects["bouteille"]:
				var action: String = boxViewMessages["action"]
				action += "\n#acheter une bouteille de vin.#"
				boxViewMessages["action"] = action
		elif root.user.cardId == "82770":
			root.soundManager.play("fermeporte", false)
			if !root.user.objects["lexique"]:
				var action: String = boxViewMessages["action"]
				action = action.replace("\n#proposer votre lexique au prêtre.#", "")
				boxViewMessages["action"] = action
		elif root.user.cardId == "6197":
			root.soundManager.play("haltela", false)
		elif root.user.cardId == "7855":
			var description: String = ""
			
			if root.user.points["Matem"] > 20:
				description = "Vous avez @pointMatem @talentMatem. Cela vous permet d'entrer dans la demeure de Matica."
				
				var action: String = boxViewMessages["action"]
				action += "\n#Entrer dans la demeure.#"
				boxViewMessages["action"] = action
			else:
				description = "Vous n'avez que @pointMatem @talentMatem. Cela n'est pas suffisant pour entrer dans la demeure de Matica."

			
			boxViewMessages["description"] = description
		elif root.user.cardId == "9150":
			root.soundManager.play("flute2", false)
		elif root.user.cardId == "8027":
			if !root.user.objects["fleurs"]:
				var action: String = boxViewMessages["action"]
				action = action.replace("\n#Donner vos fleurs#\n#à la dame de la fenêtre.#", "")
				boxViewMessages["action"] = action
		elif root.user.cardId == "9432" or root.user.cardId == "9627" or root.user.cardId == "10567" or root.user.cardId == "11590" or root.user.cardId == "12941" or root.user.cardId == "7004" or root.user.cardId == "10308" or root.user.cardId == "11340" or root.user.cardId == "15930":
			root.soundManager.play("seagulls_boucle", true)
		elif root.user.cardId == "13183":
			root.soundManager.play("aaaah", false)
			if root.user.gold == 0:
				var action: String = boxViewMessages["action"]
				action = action.replace("\n#donner une pièce d'or au pêcheur#\n#pour le réconforter.#", "")
				boxViewMessages["action"] = action
		elif root.user.cardId == "15565":
			root.soundManager.play("goutte", true)
			
			if !root.user.objects["joncs"]:
				var action: String = boxViewMessages["action"]
				action = action.replace("\n#confectionner une torche#\n#avec vos joncs.#", "")
				boxViewMessages["action"] = action
		elif root.user.cardId == "13877":
			var description: String = ""
			
			if root.user.points["Histora"] > 20:
				description = "Vous avez @pointHistora @talentHistora. Cela vous permet d'entrer dans la demeure de Kronolos."
				
				var action: String = boxViewMessages["action"]
				action += "\n#Entrer dans la demeure.#"
				boxViewMessages["action"] = action
			else:
				description = "Vous n'avez que @pointHistora @talentHistora. Cela n'est pas suffisant pour entrer dans la demeure de Kronolos."
			
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
				action = action.replace("\n#Proposer votre boulier au notable.#", "")
				boxViewMessages["action"] = action
		elif root.user.cardId == "9914":
			if root.user.gold == 0:
				var action: String = boxViewMessages["action"]
				action = action.replace("\n#donner une pièce d'or#\n#à la vieille femme.#", "")
				boxViewMessages["action"] = action
		elif root.user.cardId == "5974":
			var description: String = ""
			
			if root.user.points["Litter"] > 20:
				description = "Vous avez @pointLitter @talentLitter. Cela vous permet d'entrer dans la demeure de Lingus."
				
				var action: String = boxViewMessages["action"]
				action += "\n#Entrer dans la demeure.#"
				boxViewMessages["action"] = action
			else:
				description = "Vous n'avez que @pointLitter @talentLitter. Cela n'est pas suffisant pour entrer dans la demeure de Lingus."
			
			boxViewMessages["description"] = description
		elif root.user.cardId == "8034":
			root.soundManager.play("grillejardin", false)
			if !root.user.objects["lait"]:
				var action: String = boxViewMessages["action"]
				action = action.replace("\n#Vendre votre pot de lait.#", "")
				boxViewMessages["action"] = action
		elif root.user.cardId == "8277":
			root.soundManager.play("clochettes2", false)
			if !root.user.objects["herbes"]:
				var action: String = boxViewMessages["action"]
				action = action.replace("\n#montrer vos herbes.#", "")
				boxViewMessages["action"] = action
		elif root.user.cardId == "11876":
			if !root.user.objects["fleurs"]:
				var action: String = boxViewMessages["action"]
				action = action.replace("\n#Donner vos fleurs à la nonne.#", "")
				boxViewMessages["action"] = action
		elif root.user.cardId == "25754":
			if !root.user.objects["lait"]:
				var action: String = boxViewMessages["action"]
				action = action.replace("\n#donner votre pot de lait#\n#à la cuisinière.#", "")
				boxViewMessages["action"] = action
	elif actionEvent == 'Current':
		if root.user.cardId == "5725":
			if currentAction == "commerçant":
				var msgValue: String = "C'est toi, @user"

				var nbAdviceBoutique: int = root.user.adventures["nbAdviceBoutique"]
				if nbAdviceBoutique < 4:
					msgValue += "?\nJe peux te dire qu'"

					var msgChoice = {
						1: "un lexique te sera bien utile dans la ville de Litter.",
						2: "un boulier te sera bien utile dans la ville de Matem.",
						3: "un atlas te sera bien utile dans la ville d'Histora."
					}

					msgValue += msgChoice[nbAdviceBoutique]

					root.user.adventures["nbAdviceBoutique"] = nbAdviceBoutique + 1

					if !(root.user.objects["lexique"] and root.user.objects["boulier"] and root.user.objects["atlas"]):
						msgValue += "\nQue vas-tu m'acheter ?"
				else:
					msgValue += ".\nTu m'as déjà suffisamment dérangé comme cela ! Finiras-tu par me laisser travailler en paix ?"

					if !(root.user.objects["lexique"] and root.user.objects["boulier"] and root.user.objects["atlas"]):
						msgValue += "\nAchète-moi plutôt quelque chose !"

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
				actionTextView += "#revendre le lexique.#\n"
			else:
				actionTextView += "#acheter un lexique.#\n"
			if root.user.objects["boulier"]:
				actionTextView += "#revendre le boulier.#\n"
			else:
				actionTextView += "#acheter un boulier.#\n"
			if root.user.objects["atlas"]:
				actionTextView += "#revendre l'atlas.#\n"
			else:
				actionTextView += "#acheter un atlas.#\n"
			actionTextView += "#parler au commerçant.#\n#sortir de la boutique.#"
			boxViewMessages["action"] = actionTextView
		elif root.user.cardId == "5535" or root.user.cardId == "9819":
			if currentAction == "fleurs":
				var msgValue: String = ""
				
				if root.user.objects["fleurs"]:
					msgValue = "Il y a déjà suffisamment de fleurs dans votre sac ! Elles vont finir par se faner."
				else:
					msgValue = "Vous passez un agréable moment dans les champs à choisir les plus jolies fleurs que vous ayez vues depuis bien longtemps. Leurs couleurs et leur odeur vous enchantent."
					root.user.objects["fleurs"] = true
				
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
		elif root.user.cardId == "11322":
			if currentAction == "atlas_sage" and root.user.objects["atlas"]:
				var msgValue: String = ""
				if root.user.adventures["atlas_sage"]:
					msgValue += "Vous n'avez guère de mémoire ! Vous avez déjà vendu un atlas "
					msgValue += "semblable au sage il n'y a pas si longtemps. Il vous explique qu'un "
					msgValue += "deuxième exemplaire du même ouvrage ne présente guère d'intérêt "
					msgValue += "pour lui et vous conseille de garder ce falseuvel atlas pour un "
					msgValue += "meilleur usage. Il pense d'ailleurs que cela pourrait vous "
					msgValue += "servir sur l'île d'Histora."
				else:
					msgValue += "Votre atlas intéresse le sage au plus haut point. Il vous en "
					msgValue += "donne 5 pièces d'or, ce qui vous fait un bon bénéfice. Il formule "
					msgValue += "l'espoir que cet atlas ne vous manquera pas dans le reste de votre périple."
					
					root.user.objects["atlas"] = false
					root.user.gold = root.user.gold + 5
					root.user.adventures["atlas_sage"] = true
					
					var actionValue: String = boxViewMessages["action"]
					actionValue = actionValue.replace("\n#proposer votre atlas au sage.#", "")
					boxViewMessages["action"] = actionValue

				boxViewMessages["msg"] = msgValue
				msgView.visible = true
		elif root.user.cardId == "4929":
			if currentAction == "lueur" and root.user.adventures["lueur_pepite"]:
				root.user.adventures["lueur_pepite"] = false
				root.user.objects["pepite"] = true
				
				var description: String = boxViewMessages["description"]
				description = description.replace("Une vive lueur sur le bord du chemin attire votre attention. ", "")
				boxViewMessages["description"] = description
				
				var action: String = boxViewMessages["action"]
				action = action.replace("\n#examiner cette lueur.#", "")
				boxViewMessages["action"] = action
				
				var msgValue: String = "En fouillant bien le fossé, vous découvrez ce qui avait attiré votre attention : une pépite !"
				msgValue += " Cette découverte vous paraît suffisamment intéressante et vous la mettez dans votre sac."
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
		elif root.user.cardId == "15536":
			if currentAction == "lit":
				var msgValue: String = "A peine allongé, vous vous endormez. Vous êtes victime d'un affreux cauchemar dans lequel un professeur sadique vous oblige"
				msgValue += " à accomplir un périlleux voyage dans un pays imaginaire."
				msgValue += " Heureusement, l'air frais vous réveille et vous réalisez que tout ceci n'était qu'un rêve."
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
			elif currentAction == "armoire":
				if root.user.objects["sac_or"]:
					var msgValue: String = "Vous avez déjà fouillé cette armoire et vous avez déjà pris le sac d'or qui s'y trouve. Il n'y a plus rien à l'intérieur."
					msgValue += "\nVous n'espériez tout de même pas en trouver un deuxième, non ?"
					boxViewMessages["msg"] = msgValue
					msgView.visible = true
				else:
					goCard("22568")
			elif currentAction == "coffre":
				if root.user.adventures["gnome"] > 1:
					var msgValue: String = "Vous avez fait fuir le gnome ! Ne vous en souvenez-vous pas ? Il aurait fallu être un peu plus gentil avec lui."
					msgValue += " Maintenant, il n'y a plus personne dans le coffre. Il est donc parfaitement inutile de vous escrimer dessus."
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
					
					description += "Cette fois-ci, le gnome vous a vu arriver à temps, il s'est mis rapidement hors de votre portée, puis il s'est sauvé au plus"
					description += " profond de la forêt environnante. Vous risquez de ne jamais le revoir !"
					boxViewMessages["description"] = description
				elif nbSaisie == 0:
					root.soundManager.play("argn", false)
					
					description += "Le gnome ne s'est pas laissé faire facilement ! Il vous a mordu le petit doigt pendant la bagarre.\nVous allez souffrir pendant "
					description += "plusieurs heures. Il vaudrait mieux ne pas recommencer ce genre de plaisanteries !"
					boxViewMessages["description"] = description
				
				root.user.adventures["gnome"] = (nbSaisie+1)
				
				boxViewMessages["description"] = description
				boxViewMessages["action"] = "#Suite...#"
				
				actions["Suite..."] = Action.new("goCard", "15536")
		elif root.user.cardId == "9383":
			if currentAction == "pommes":
				if root.user.objects["pommes"]:
					var msgValue: String = "Vous avez déjà plusieurs de ces pommes dans votre sac. Il n'est pas nécessaire de tout prendre !"
					boxViewMessages["msg"] = msgValue
					msgView.visible = true
				else:
					var msgValue: String = "Après avoir goûté un de ces merveilleux fruits, vous décidez d'en emporter avec vous pour le reste de votre périple. Vous mettez quelques pommes au fond de votre sac."
					boxViewMessages["msg"] = msgValue
					msgView.visible = true
					
					root.user.objects["pommes"] = true
		elif root.user.cardId == "27845":
			if currentAction == "pommes_ermite":
				root.user.objects["pommes"] = false
				
				var action: String = boxViewMessages["action"]
				action = action.replace("\n#donner vos pommes à l'ermite.#", "")
				boxViewMessages["action"] = action
				
				var msgValue: String = "Le vieil ermite vous remercie de votre don et range soigneusement les pommes dans un coin de sa grotte."
				msgValue += " Pour vous remercier de votre générosité, il vous promet de choisir parmi les questions les plus faciles"
				msgValue += " si vous décidez de tenter votre chance auprès de lui."
				
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
				
				var msgValue: String = "Le joaillier confirme ce que vous pensiez : il s'agit bien d'une pépite d'or ! Elle semble d'ailleurs contenir une masse "
				msgValue += "importante du précieux métal. En échange, le joaillier vous remet"
				msgValue += " trois pièces d'or et un collier de pierres serties."
				
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
				
				var action: String = boxViewMessages["action"]
				action = action.replace("\n#montrer votre pépite au joaillier.#", "")
				boxViewMessages["action"] = action
			elif currentAction == "acheter_collier":
				var msgValue: String = ""
				
				if root.user.gold >= 2:
					msgValue += "Le joaillier vous montre une impressionnante collection de"
					msgValue += " superbes colliers de pierres serties qu'il a créés lui-même."
					msgValue += " vous en choisissez un, aux reflets argentés, que vous payez deux pièces d'or."
					
					root.user.objects["collier"] = true
					root.user.gold = root.user.gold - 2
				else:
					msgValue += "Vous n'avez pas assez de pièces d'or pour cela."
				
				boxViewMessages["msg"] = msgValue
				msgView.visible = true

				var action: String = boxViewMessages["action"]
				action = action.replace("\n#acheter un collier.#", "")
				boxViewMessages["action"] = action
			elif currentAction == "chat":
				var msgValue: String = "Miiiaaaahhhhhh !"
				
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
			elif currentAction == "diplome":
				var msgValue: String = "Ceci est un diplôme du meilleur bijoutier de Matem. Aucun intérêt pour vous."
				
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
		elif root.user.cardId == "4686":
			if currentAction == "pieceor_servante" and root.user.gold >= 1:
				root.user.gold = root.user.gold - 1
				
				var msgValue: String = "La servante vous remercie de votre générosité. Elle va pouvoir enfin s'acheter les bijoux dont elle rêvait et"
				msgValue += " qu'elle a vu chez son voisin le joaillier. Pour vous remercier, elle vous "
				msgValue += "indique qu'on peut trouver un boulier dans la boutique qui "
				msgValue += "se trouve au sud de l'abbaye d'Encyclopia."
				
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
				
				var action: String = boxViewMessages["action"]
				action = action.replace("\n#donner une pièce d'or#\n#à la servante.#", "")
				boxViewMessages["action"] = action
			elif currentAction == "fenetre":
				var msgValue: String = "Par la fenêtre, vous voyez une place de Matem."
				
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
		elif root.user.cardId == "7100":
			if currentAction == "acheter_bouteille":
				if root.user.gold >= 2 and !root.user.objects["bouteille"]:
					root.user.gold = root.user.gold - 2
					root.user.objects["bouteille"] = true
					
					var msgValue: String = "Le patron de la taverne semble très surpris de voir un jeune moine lui faire une telle demande."
					msgValue += " Mais il ne peut plus refuser de vous vendre son vin lorsque vous"
					msgValue += " lui expliquez que ce n'est pas pour vous. Cela vous coûte 2 pièces d'or."
					
					boxViewMessages["msg"] = msgValue
					msgView.visible = true
					
					var action: String = boxViewMessages["action"]
					action = action.replace("\n#acheter une bouteille de vin.#", "")
					boxViewMessages["action"] = action
			elif currentAction == "acheter_tonneau":
				var msgValue: String = "Une bouteille de vin suffira largement. Vous n'allez tout de même pas acheter un tonneau !"
				
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
		elif root.user.cardId == "82770":
			if currentAction == "vepres":
				root.soundManager.play("deogratias", false)
				
				var msgValue: String = "Vous assistez, avec votre habituel émerveillement, à l'office vespral. Les chants grégoriens qui l'accommpagnent sont d'une "
				msgValue += "pureté que vous avez rarement rencontrée. Lorsque le Deo Gratias "
				msgValue += "final rententit dans la grande église de Matem, vous avez les larmes aux yeux."
				
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
			elif currentAction == "lexique_prete" and root.user.objects["lexique"]:
				if root.user.adventures["lexique_prete"]:
					var msgValue: String = "Vous n'avez guère de mémoire ! Vous avez déjà vendu un lexique semblable au prêtre. Un seul lexique lui suffit amplement et "
					msgValue += "il n'a vraiment pas besoin de ce deuxième ouvrage. Vous en "
					msgValue += "trouverez sûrement un meilleur usage. Allez donc voir à Litter."
					
					boxViewMessages["msg"] = msgValue
					msgView.visible = true
				else:
					root.user.gold = root.user.gold + 5
					root.user.objects["lexique"] = false
					root.user.adventures["lexique_prete"] = true
					
					var msgValue: String = "Voilà qui va permettre au prêtre de vérifier les traductions de ses clercs."
					msgValue += " Il vous offre 5 pièces d'or de ce lexique. Vous faites une bonne affaire."
					msgValue += " Sauf, peut-être, si ce lexique vous est nécessaire ailleurs."
					
					boxViewMessages["msg"] = msgValue
					msgView.visible = true
					
					var action: String = boxViewMessages["action"]
					action = action.replace("\n#proposer votre lexique au prêtre.#", "")
					boxViewMessages["action"] = action
		elif root.user.cardId == "6197":
			if currentAction == "entrer_caserne":
				if root.user.objects["bouteille"]:
					root.user.objects["bouteille"] = false
					
					var description: String = "Le garde vous laisse passer en échange de votre bouteille de vin.\nBien entendu, vous ne devez pas en parler aux chevaliers !"
					boxViewMessages["description"] = description
					boxViewMessages["action"] = "#Suite...#"
					
					actions["Suite..."] = Action.new("goCard", "7533")
				else:
					var msgValue: String = "Le garde refuse de vous laisser passer. Vous essayez de parlementer avec lui mais il est inflexible car, dit-il, "
					msgValue += "les consignes que lui ont données les chevaliers sont très strictes."
					msgValue += " Par exemple, il n'a rien à boire pendant toute la durée de sa garde et cela lui est très pénible."
					boxViewMessages["msg"] = msgValue
					msgView.visible = true
		elif root.user.cardId == "7533":
			if currentAction == "aaarghh":
				var msgValue: String = "Aaaarghh !"
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
					msgValue += "Ah, c'est toi, @user. Je vois que tu continues ta quête."
					msgValue += " Je n'ai malheureusement pas le temps de m'occuper de toi en ce"
					msgValue += " moment. Depuis que tu m'as apporté ce merveilleux boulier, je"
					msgValue += " travaille sans arrêter.\nBon courage, @user !"
				elif root.user.objects["boulier"]:
					msgValue += "Bonjour, @user. Je vois que tu m'as apporté le boulier que"
					msgValue += " je cherchais depuis si longtemps.\nJe vais enfin "
					msgValue += "pouvoir terminer mes recherches !\nPour te récompenser,"
					msgValue += " je t'offre un talisman qui te permettra d'entrer dans l'abbaye d'Encyclopia."
				else:
					msgValue += "Qui vient me déranger pendant mon travail ?"
					msgValue += "\nC'est toi, @user ! M'as-tu apporté l'objet que j'ai envoyé quérir ?"
					msgValue += "\nnon !?!\nAlors, ne reviens que lorsque tu l'auras trouvé !"

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
				var msgValue: String = "Bonjour mignon moinillon... Que la chance soit avec toi dans ta quête."
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
			elif currentAction == "caresser_chien":
				var msgValue: String = "Ce chien ne semble pas très propre. Méfiez-vous."
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
			elif currentAction == "fleurs_dame":
				var msgValue: String = "La dame est très flattée de l'hommage que vous lui rendez par ce magnifique bouquet de fleurs. Pour vous "
				
				msgValue += " remercier, elle vous recommande d'aller voir de sa part le chevalier"
				msgValue += " dans sa caserne. Elle vous précise que le garde à l'entrée se laisse"
				msgValue += " facilement soudoyer par une bouteille de vin."
				
				if root.user.gold < 2:
					msgValue += " De plus, elle vous donne 3 pièces d'or pour votre peine."
					root.user.gold = root.user.gold + 3
				
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
				
				root.user.objects["fleurs"] = false
				
				var action: String = boxViewMessages["action"]
				action = action.replace("\n#Donner vos fleurs#\n#à la dame de la fenêtre.#", "")
				boxViewMessages["action"] = action
		elif root.user.cardId == "5497":
			if currentAction == "pencher_rambarde":
				var msgValue: String = "Vue d'ici, l'île d'Histora paraît magnifique."
				
				if root.user.objects["lexique"] or root.user.objects["boulier"] or root.user.objects["atlas"]:
					msgValue += " Pour mieux voir, vous vous penchez un peu trop et vous vous apercevez "
					msgValue += "que votre sac s'est ouvert au-dessus du vide. En essayant de le ramener vers vous, vous voyez"
					
					var objectsFallen: int = 0
					var tempMsgValue: String = ""
					if root.user.objects["lexique"]:
						root.user.objects["lexique"] = false
						
						tempMsgValue += ", votre lexique"
						objectsFallen += 1
					if root.user.objects["boulier"]:
						root.user.objects["boulier"] = false
						
						tempMsgValue += ", votre boulier"
						objectsFallen += 1
					if root.user.objects["atlas"]:
						root.user.objects["atlas"] = false
						
						tempMsgValue += ", votre atlas"
						objectsFallen += 1
					
					if objectsFallen == 1:
						tempMsgValue = tempMsgValue.replace(",", "")
					elif objectsFallen == 2:
						tempMsgValue = tempMsgValue.replace(",", " et")
						tempMsgValue = tempMsgValue.replace(" et", "")
					elif objectsFallen == 3:
						tempMsgValue = tempMsgValue.replace(",", "")
						tempMsgValue = tempMsgValue.replace(",", " et")
					
					msgValue += tempMsgValue
					msgValue += " tomber au milieu des vagues, cinquante mètres plus bas."
				
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
		elif root.user.cardId == "12941" or root.user.cardId == "15930":
			if currentAction == "aller_nord" or currentAction == "aller_ouest"or currentAction == "aller_est":
				var description: String = "Après une traversée sans problème, vous débarquez "
				if currentAction == "aller_nord":
					description += "sur l'île d'Histora."
				elif currentAction == "aller_ouest":
					description += "dans la ville de Litter."
				elif currentAction == "aller_est":
					description += "dans la ville de Matem."
				
				description += " Le vaisseau est déjà reparti au loin."
				
				if root.user.gold >= 2:
					root.user.gold = root.user.gold - 2
					description += " Cela vous a coûté deux pièces d'or."
				else:
					description += " Vous n'avez pas pu payer votre traversée, vous avez été obligé de laver le pont et la soute."
				
				boxViewMessages["description"] = description
				boxViewMessages["action"] = "#Suite...#"
				
				if currentAction == "aller_nord":
					actions["Suite..."] = Action.new("goCard", "10084")
				elif currentAction == "aller_ouest":
					actions["Suite..."] = Action.new("goCard", "7004")
				elif currentAction == "aller_est":
					actions["Suite..."] = Action.new("goCard", "9627")
		elif root.user.cardId == "10084":
			if currentAction == "barque_litter" or currentAction == "barque_matem":
				var description: String = "Après une longue traversée, vous arrivez enfin "
				if currentAction == "barque_litter":
					description += "sur le port de Litter. Un marin qui se trouve là accepte de rapporter la barque à Histora."
				elif currentAction == "barque_matem":
					description += "sur le port de Matem. Un pêcheur qui se trouve là accepte de rapporter la barque à Histora."
				
				description += " Le vaisseau est déjà reparti au loin."
				
				if root.user.gold >= 1:
					root.user.gold = root.user.gold - 1
					description += " Vous le payez d'une pièce d'or."
				
				boxViewMessages["description"] = description
				boxViewMessages["action"] = "#Suite...#"
				
				if currentAction == "barque_litter":
					actions["Suite..."] = Action.new("goCard", "7004")
				elif currentAction == "barque_matem":
					actions["Suite..."] = Action.new("goCard", "9627")
		elif root.user.cardId == "12274":
			if currentAction == "joncs":
				if root.user.objects["joncs"]:
					var msgValue: String = "A force de bourrer votre sac avec ces joncs, vous allez finir par le faire craquer."
					boxViewMessages["msg"] = msgValue
					msgView.visible = true
				else:
					root.user.objects["joncs"] = true
					
					var msgValue: String = "Avec bien des difficultés, vous réussissez finalement à couper quelques tiges dures et sèches de ces joncs."
					msgValue += " Vous les tressez avant de les mettre dans votre sac."
					boxViewMessages["msg"] = msgValue
					msgView.visible = true
		elif root.user.cardId == "11997":
			if currentAction == "frapper_porte":
				root.soundManager.play("knock", false)
		elif root.user.cardId == "13183":
			if currentAction == "piece_or" and root.user.gold >= 1:
				root.user.gold = root.user.gold - 1
				
				var msgValue: String = "Le pêcheur, tout étonné de votre générosité, se remet de ses émotions et pense déjà au falseuveau filet qu'il va pouvoir "
				msgValue += "s'acheter avec cet argent. Pour vous remercier, il vous "
				msgValue += "indique qu'on peut trouver un atlas dans la boutique qui "
				msgValue += "se trouve au sud de l'abbaye d'Encyclopia."
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
				
				if root.user.gold >= 1:
					var action: String = boxViewMessages["action"]
					action = action.replace("\n#donner une pièce d'or au pêcheur#\n#pour le réconforter.#", "")
					boxViewMessages["action"] = action
		elif root.user.cardId == "12302":
			root.soundManager.stopSounds()
			root.soundManager.play("vache", true)
			if currentAction == "traire_vache":
				if root.user.objects["lait"]:
					var msgValue: String = "Vous avez déjà rempli votre pot de lait et vous n'avez aucun autre récipient."
					msgValue += " De toutes façons, on ne trait pas une vache toutes les cinq minutes !"
					boxViewMessages["msg"] = msgValue
					msgView.visible = true
				else:
					root.soundManager.stopSounds()
					root.soundManager.play("traite", true)
					root.user.objects["lait"] = true
					
					var msgValue: String = "Un pot se trouvait justement sur le sol, au bord du chemin. Vous vous installez, et vous trayez la vache. Le lait que"
					msgValue += " vous en tirez semble riche et onctueux. Il est vrai que les pâturages"
					msgValue += " alentour sont três verts. Aprês vous être délecté de ce breuvage"
					msgValue += ", vous décidez d'en garder un peu avec vous pour la route."
					boxViewMessages["msg"] = msgValue
					msgView.visible = true
		elif root.user.cardId == "15565":
			if currentAction == "dechiffrer_inscriptions":
				if root.user.objects["torche"]:
					var description: String = "Effectivement, votre briquet d'amadou a réussi sans problème a enflammer la torche de jonc."
					description += " On y voit tout de suite plus clair ! Voyons donc ces inscriptions..."
					
					root.user.objects["torche"] = false
					
					boxViewMessages["description"] = description
					boxViewMessages["action"] = "#Suite...#"
					actions["Suite..."] = Action.new("goCard", "15762")
				elif root.user.objects["joncs"]:
					var msgValue: String = "Il fait bien trop sombre dans cette caverne !"
					boxViewMessages["msg"] = msgValue
					msgView.visible = true
				else:
					var msgValue: String = "Il fait bien trop sombre dans cette caverne ! Même avec votre briquet d'amadou, vous ne pouvez pas déchiffrer"
					msgValue += " ce qui est écrit sur la paroi. Il vous faudrait une torche..."
					boxViewMessages["msg"] = msgValue
					msgView.visible = true
			elif currentAction == "confectionner_torche":
				if root.user.objects["torche"]:
					var msgValue: String = "Une seule torche suffira largement !"
					boxViewMessages["msg"] = msgValue
					msgView.visible = true
				else:
					root.user.objects["torche"] = true
					root.user.objects["joncs"] = false
					
					var msgValue: String = "Avec votre briquet d'amadou, il vous sera facile d'enflammer cette torche improviste."
					msgValue += " Vous avez encore des joncs au fond de votre sac."
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
					msgValue += "Ah, c'est toi, @user. Je vois que tu continues ta quête."
					msgValue += " Je n'ai malheureusement pas le temps de m'occuper de toi en ce"
					msgValue += " moment. Depuis que tu m'as apporté ce merveilleux atlas, je"
					msgValue += " travaille sans arrêter.\nBon courage, @user !"
				elif root.user.objects["atlas"]:
					msgValue += "Bonjour, @user. Je vois que tu m'as apporté l'atlas que"
					msgValue += " je cherchais depuis si longtemps.\nJe vais enfin "
					msgValue += "pouvoir terminer mes recherches !\nPour te récompenser,"
					msgValue += " je t'offre un talisman qui te permettra d'entrer dans l'abbaye d'Encyclopia."
				else:
					msgValue += "Qui vient me déranger pendant mon travail ?"
					msgValue += "\nC'est toi, @user ! M'as-tu apporté l'objet que j'ai envoyé quérir ?"
					msgValue += "\nnon !?!\nAlors, ne reviens que lorsque tu l'auras trouvé !"
				
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
					msgValue += "Le chat refuse de se laisser approcher. Vous courez après lui"
					msgValue += " pendant quelques instants sans jamais pouvoir le toucher. Lassé,"
					msgValue += " vous finissez par abandonner. C'est aussi bien, vu ce qui vous "
					msgValue += "est arrivé la dernière fois."
				else:
					root.soundManager.play("chat", false)
					
					msgValue += "Vous caressez le chat pendant quelques instants. Celui-ci se "
					msgValue += "laisse faire sans réaction apparente. Tout à coup, vous sursautez "
					msgValue += "et jetez le chat loin de vous ! horreur ! Il grouille de puces !"
					msgValue += " vous voilà infesté vous-même."
				
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
				
				root.user.adventures["nbStepsCat"] = 15 #15 = temps de se débarrasser des puces] = 15
			elif currentAction == "coup_de_pied_chien":
				var nbCoupDePieds: int = root.user.adventures["coupDePied_chien"]
				
				var msgValue: String = ""
				
				if nbCoupDePieds % 3 == 0:
					msgValue += "Sous le coup, le chien se sauve le long de la rue en hurlant de douleur."
					root.soundManager.play("ouah5", false)
				elif nbCoupDePieds % 3 == 1:
					msgValue += "Sous le coup, le chien est projeté à deux mêtres et reste inerte comme si vous aviez tapé dans  un caillou."
					root.soundManager.play("claps", false)
				elif nbCoupDePieds % 3 == 2:
					msgValue += "Le chien s'accroche à votre mollet et tout en poussant de féroces grognements, "
					msgValue += "il  vous mord sauvagement. Vous risquez d'en avoir une marque pour longtemps !"
					root.soundManager.play("grognements", false)
				
				if nbCoupDePieds >= 3:
					msgValue += " Quelques minutes plus tard, il revient, semblant avoir tout oublié."
				
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
				root.user.adventures["coupDePied_chien"] = (nbCoupDePieds + 1)
		elif root.user.cardId == "9635":
			if currentAction == "boulier_notable":
				var msgValue: String = ""
				
				if root.user.adventures["boulier_notable"]:
					msgValue += "Auriez-vous perdu la mémoire ! Vous avez déjà vendu un boulier "
					msgValue += "semblable au notable. Le premier "
					msgValue += "lui convient parfaitement et il n'a nul besoin d'un autre boulier. Gardez-le "
					msgValue += "donc sur vous, il pourra sûrement vous être utile. Surtout si "
					msgValue += "vous devez encore aller à Matem."
				else:
					msgValue += "Le notable est enchanté par la qualité de votre boulier."
					msgValue += " Vous n'avez même pas besoin de parlementer pour en tirer 5 belles "
					msgValue += "pièces d'or. Espérons que cet objet ne vous manquera pas par la suite."
					
					root.user.gold = root.user.gold + 5
					root.user.objects["boulier"] = false
					root.user.adventures["boulier_notable"] = true
					
					var action: String = boxViewMessages["action"]
					action = action.replace("\n#Proposer votre boulier au notable.#", "")
					boxViewMessages["action"] = action
				
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
		elif root.user.cardId == "9914":
			if currentAction == "pieceor_femme":
				var msgValue: String = "La vieille femme se jette à gefalseux devant vous et rend grâce à votre générosité. Elle va pouvoir embellir le trousseau de"
				msgValue += " sa fille qui danse en ce moment même à la fête organisée chez "
				msgValue += " ses voisins de derrière. Pour vous remercier, elle vous "
				msgValue += "indique qu'on peut trouver un lexique dans la boutique qui "
				msgValue += "se trouve au sud de l'abbaye d'Encyclopia."
				
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
				
				root.user.gold = root.user.gold - 1
				
				if root.user.gold == 0:
					var action: String = boxViewMessages["action"]
					action = action.replace("\n#donner une pièce d'or#\n#à la vieille femme.#", "")
					boxViewMessages["action"] = action
		elif root.user.cardId == "7872":
			if currentAction == "cueillir_herbes":
				var msgValue: String = ""
				
				if root.user.adventures["vente_herbes"] == 2:
					msgValue += "Vous avez déjà revendu deux fois votre cueillette ! Ce qui"
					msgValue += " reste au bord du chemin n'est pas suffisant pour une autre revente. De toutes"
					msgValue += " façons, vous n'êtes pas là pour faire du commerce ! Laissez"
					msgValue += " donc cette herbe à sa place !"
				elif root.user.objects["herbes"]:
					msgValue += "Il y a déjà suffisamment d'herbes dans votre sac !"
				else:
					root.user.objects["herbes"] = true
					
					msgValue += "Vous cueillez quelques brins de cette herbe dont l'odeur est"
					msgValue += " envoûtante. Vous décidez de garder un peu de votre cueillette "
					msgValue += " dans votre sac."
				
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
				
				var msgValue: String = "Le mendiant vous remercie de votre générosité et il vous"
				msgValue += " indique que la maison du seigneur Lingus se trouve un peu plus loin au nord."
				
				if currentAction == "une_piece" and root.user.gold >= 1:
					msgValue += "\nIl se lève et disparaît en claudiquant."
					root.user.gold = root.user.gold - 1
				elif currentAction == "deux_pieces" and root.user.gold >= 2:
					msgValue += "Il ajoute que l'un des gardes lui a dit que la possession "
					msgValue += "d'un lexique est très utile dans la demeure de ce seigneur."
					msgValue += "\nIl se lève et disparaît en claudiquant."
					root.user.gold = root.user.gold - 2
				else:
					msgValue += "Vous n'avez pas assez de pièces pour cela."
				
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
			elif currentAction == "travailler":
				root.user.adventures["mendiant"] = true
				
				var msgValue: String = "Le mendiant se précipite sur vous en vous abreuvant d'insultes."
				msgValue += " Vous vous défendez du mieux que vous pouvez. Dans la bagarre, "
				msgValue += "vous êtes étourdi par un choc."
				
				if root.user.objects["pepite"]:
					msgValue += "Le mendiant profite de votre étourdissement pour vous voler votre pépite et"
					
					root.user.objects["pepite"] = false
				else:
					msgValue += "Le mendiant vous voyant groggy prend peur et"
				
				msgValue += "se sauve en courant.\nIl aurait mieux valu lui faire l'aumône."
				
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
					msgValue += "Ah, c'est toi, @user. Je vois que tu continues ta quête."
					msgValue += " Je n'ai malheureusement pas le temps de m'occuper de toi en ce"
					msgValue += " moment. Depuis que tu m'as apporté ce merveilleux lexique, je"
					msgValue += " travaille sans arrêter.\nBon courage, @user !"
				elif root.user.objects["lexique"]:
					msgValue += "Bonjour, @user. Je vois que tu m'as apporté le lexique que"
					msgValue += " je cherchais depuis si longtemps.\nJe vais enfin "
					msgValue += "pouvoir terminer mes recherches !\nPour te récompenser,"
					msgValue += " je t'offre un talisman qui te permettra d'entrer dans l'abbaye d'Encyclopia."
				else:
					msgValue += "Qui vient me déranger pendant mon travail ?"
					msgValue += "\nC'est toi, @user ! M'as-tu apporté l'objet que j'ai envoyé quérir ?"
					msgValue += "\nnon !?!\nAlors, ne reviens que lorsque tu l'auras trouvé !"
				
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
				var msgValue: String = "Le damoiseau vous remercie fort pour ce bon lait qui provient,"
				msgValue += " à n'en pas douter, de l'île d'Histora. Il vous le paie de trois"
				msgValue += " pièces d'or qui se rajoutent à votre fortune. Vous avez donc "
				msgValue += "maintenant @gold @pieceor."
				
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
				
				var action: String = boxViewMessages["action"]
				action = action.replace("\n#Vendre votre pot de lait.#", "")
				boxViewMessages["action"] = action
				
				root.user.objects["lait"] = false
				root.user.gold = root.user.gold + 3
			elif currentAction == "regarder_mirroir":
				var msgValue: String = "Vous voyez dans le miroir l'image d'un moinillon harassé par sa déjà longue marche. Devinez de qui il s'agit..."
				
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
		elif root.user.cardId == "8277":
			if currentAction == "montrer_herbes":
				var msgValue: String = "L'herboriste est extrèmement satisfait de la qualité des "
				msgValue += "herbes que vous lui apportez. Il vous en offre 3 pièces d'or."
				
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
				
				var action: String = boxViewMessages["action"]
				action = action.replace("\n#montrer vos herbes.#", "")
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
				var msgValue: String = "Une musique céleste retentit dans votre esprit.\n"
				msgValue += "Un calme impressionnant vous envahit.\nVous allez "
				msgValue += "pouvoir reprendre votre parcours, l'esprit serein, prêt à affronter"
				msgValue += " les falsembreuses épreuves qui vous attendent."
				
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
				
				root.soundManager.play("gloria", false)
			elif currentAction == "piece_tronc":
				var msgValue: String = ""
				if root.user.gold >= 1:
					msgValue += "Le bedeau vous remercie, et vous assure que le Bon Dieu "
					msgValue += "vous le rendra au centuple."
					
					root.user.gold = root.user.gold - 1
				else:
					msgValue += "Vous n'avez plus de pièce !\n(mais c'était une bonne intention)"
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
				
				root.soundManager.play("piece_tronc", false)
		elif root.user.cardId == "6740":
			if currentAction == "commander_boire":
				var msgValue: String = ""
				if root.user.adventures["taverne"] > 2:
					root.user.adventures["taverne"] = 4
					
					msgValue += "Le tavernier refuse de vous donner une troisième fois à"
					msgValue += " boire de son vin. Il vous jette dehors comme un ivrogne."
				elif root.user.gold >= 1:
					msgValue += "Le tavernier vous sert le plus délicieux des vins de pays."
					msgValue += "\nVous vous délectez de ce nectar, et c'est la joie"
					msgValue += " au coeur que vous continuez votre périple.\n"
					msgValue += "Il vous en a coûté une pièce d'or, mais cela valait la peine !"
					
					root.user.adventures["taverne"] = (root.user.adventures["taverne"] + 1)
					
					root.soundManager.play("bierre", false)
				else:
					msgValue += "Vous commandez à boire au tavernier. Celui-ci vous demande"
					msgValue += " d'abord votre argent. Malheureusement vous n'avez plus de "
					msgValue += "pièce.\nLe tavernier refuse donc de vous servir."
				
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
			elif currentAction == "action_message" and root.user.adventures["taverne"] > 3:
				goCard("4710")
			elif currentAction == "spiritueux":
				if root.user.adventures["taverne"] > 3:
					root.user.adventures["taverne"] = 3
				var msgValue: String = "Un jeune moine comme vous ne devrait pas toucher à ce genre de spiritueux."
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
			elif currentAction == "assoir":
				if root.user.adventures["taverne"] > 3:
					root.user.adventures["taverne"] = 3
				var msgValue: String = "D'accord. Rien ne vous empêche de vous mettre assis un instant."
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
		elif root.user.cardId == "6816":
			if currentAction == "entrer_abbaye":
				if root.user.objects["croix_celtique"] and root.user.objects["sablier"] and root.user.objects["piece_roi"]:
					goCard("8813")
				else:
					var msgValue: String = "Le frère portier vous demande de lui montrer vos Talismans, gages de vos mérites."
					msgValue += " Comme vous ne possédez pas les trois Talismans qui sont indispensables,"
					msgValue += " il vous reconduit sans ménagement à la sortie."
					boxViewMessages["msg"] = msgValue
					msgView.visible = true

		elif root.user.cardId == "11876":
			if currentAction == "fleurs_nonne":
				root.user.objects["fleurs"] = false
				
				var msgValue: String = "La nonne vous remercie grandement de ce charmant bouquet qui va lui permettre de décorer l'autel de façon magnifique. Pour vous "
				msgValue += "remercier, elle vous recommande d'aller voir de sa part la soeur "
				msgValue += "cuisinière dans la tour Est de l'abbaye pour lui demander un peu de sa fameuse soupe."
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
				
				var action: String = boxViewMessages["action"]
				action = action.replace("\n#Donner vos fleurs à la nonne.#", "")
				boxViewMessages["action"] = action
		elif root.user.cardId == "12973":
			if currentAction == "entrer_bibliotheque":
				if root.user.points["Encyclopia"] > 20:
					goCard("18460")
				else:
					var msgValue: String = "Vous n'avez pas récolté suffisament de Talents pour pouvoir entrer dans ce lieu."
					msgValue += " Il vous faut encore subir quelques épreuves."
					boxViewMessages["msg"] = msgValue
					msgView.visible = true
				
		elif root.user.cardId == "25754":
			if currentAction == "donner_lait":
				root.user.objects["lait"] = false
				
				var msgValue: String = "La cuisinière vous remercie de votre présent qui ne pouvait pas mieux tomber, et, en échange,"
				msgValue += " vous donne un bol de la soupe de légumes qu'elle vient juste"
				msgValue += " de préparer. Avec une cuillère de lait pour la rendre encore plus"
				msgValue += " onctueuse, cette soupe est savoureuse. Vous vous régalez !"
				boxViewMessages["msg"] = msgValue
				msgView.visible = true
				
				var action: String = boxViewMessages["action"]
				action = action.replace("\n#donner votre pot de lait#\n#à la cuisinière.#", "")
				boxViewMessages["action"] = action
		elif root.user.cardId == "18460":
			if currentAction == "saluer_encyclopia":
				var msgValue: String = "Bravo, @user. Tu as fini ton périple et tu as pu me rapporter"
				msgValue += " les trois Talismans. Grâce à tes connaissances, tu as récolté @totalPoints Talents, durant ta quête."
				msgValue += "\nJe pense donc que tu es capable de prendre ma difficile succession au poste de Gardien du Savoir."
				msgValue += "\nEn signe de ta falsemination, je vais maintenant te donner le Livre du Savoir."
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
