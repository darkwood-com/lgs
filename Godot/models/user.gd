class_name User extends Object

var name: String
var nbSteps: int
var gold: int
var cardId: String #curent card id position
var points: Dictionary; #points acquired in cities
var askedQuestions: Array[Question]; #nb of asked questions in cities Array<Questions>
var objects: Dictionary; #objects acquired or not
var adventures: Dictionary; #adventure to pass or that have passed
var nbQuestionsCharacter: Dictionary; #number of question asked by characters

func _init():
	#initiation code - original from LGS hypercard
	#put it into nom
	#put 1 into nbdep
	#put 13 into fortune
	#put "card id 4101" into endroit
	#put "0,0,0,0" into points
	#put "-,-,-,-" into questionsposees
	#put "false,false,false,false,false,false,false,false,false,false,"
	#    "false,false,false,false,false" into objets
	#put "false,0,1,0,true,0,false,false,false,0" into peripeties
	#put "0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0" into nbquestpers
	#put false into effacerchamps
	#put "0,0,0,0,0,0,0,0" into pourcentages
	
	#default user params
	name = "Matyo"
	nbSteps = 0
	gold = 13
	cardId = "0"
	points = {
		"Litter": 0,
		"Matem": 0,
		"Histora": 0,
		"Encyclopia": 0
	}
	askedQuestions = []
	objects = {
		"lexique": false,
		"boulier": false,
		"atlas": false,
		"croix_celtique": false,
		"sablier": false,
		"piece_roi": false,
		"sac_or": false,
		"herbes": false,
		"pepite": false,
		"pommes": false,
		"bouteille": false,
		"lait": false,
		"joncs": false,
		"fleurs": false,
		"collier": false,
		"torche": false
	}
	adventures = {
		"mendiant": false,
		"taverne": 0,
		"nbAdviceBoutique": 1,
		"vente_herbes": 0,
		"lueur_pepite": true,
		"gnome": 0,
		"lexique_prete": false,
		"boulier_notable": false,
		"atlas_sage": false,
		"nbStepsCat": 0,
		"coupDePied_chien": 0
	}
	nbQuestionsCharacter = {
		"1": 0,
		"2": 0,
		"3": 0,
		"4": 0,
		"5": 0,
		"6": 0,
		"7": 0,
		"8": 0,
		"9": 0,
		"10": 0,
		"11": 0,
		"12": 0,
		"13": 0,
		"14": 0,
		"15": 0,
		"16": 0,
		"17": 0,
		"18": 0,
		"19": 0,
		"20": 0,
		"21": 0,
		"22": 0,
		"23": 0,
		"24": 0,
		"25": 0,
		"26": 0,
		"ange": 0
	}

func load() -> Dictionary:
	if not FileAccess.file_exists("user://lgs.save"):
		return {'success': false}
	
	var save_game = FileAccess.open("user://lgs.save", FileAccess.READ)
	var json = JSON.new()
	var parse_result = json.parse(save_game.get_as_text())
	save_game.close()
	
	if not parse_result == OK:
		return {'success': false}
	var json_data = json.get_data()
	
	name = json_data['user']['name']
	gold = json_data['user']['gold']
	cardId = json_data['user']['cardId']
	points = json_data['user']['points']
	objects = json_data['user']['objects']
	adventures = json_data['user']['adventures']
	nbQuestionsCharacter = json_data['user']['nbQuestionsCharacter']
	
	for questionData in json_data['user']['askedQuestions']:
		var question = Question.new()
		question.points = questionData.points
		question.ask = questionData.ask
		question.answers = questionData.answers
		askedQuestions.append(question)
	
	return {
		'success': true,
		'savedate': json_data['savedate'],
	}
	
func save():
	var save_game = FileAccess.open("user://lgs.save", FileAccess.WRITE)
	
	var askedQuestionsData = []
	for question in askedQuestions:
		askedQuestionsData.append({
			'points': question.points,
			'ask': question.ask,
			'answers': question.answers,
		})
	
	var json_string = JSON.stringify({
		'savedate': Time.get_date_dict_from_system(),
		'user': {
			'name': name,
			'gold': gold,
			'cardId': cardId,
			'points': points,
			'askedQuestions': askedQuestionsData,
			'objects': objects,
			'adventures': adventures,
			'nbQuestionsCharacter': nbQuestionsCharacter,
		}
	})
	
	save_game.store_string(json_string)
	save_game.close()

func goCard(aCardId: String):
	nbSteps += 1
	cardId = aCardId

func didAnswer(question: Question):
	for askedQuestion in askedQuestions:
		if askedQuestion.ask == question.ask:
			return true
	
	return false

func answer(rAnswer: String, question: Question, character: String, city: String):
	var answerResult = {
		"isValid": false,
		"points": 0,
		"validAnswer": ""
	}
	
	askedQuestions.append(question)
	nbQuestionsCharacter[character] += 1

	for qAnswer in question.answers:
		if question.answers[qAnswer] == true:
			answerResult.validAnswer = qAnswer
			
			if rAnswer == qAnswer:
				answerResult.isValid = true
				answerResult.points = question.points
				points[city] += question.points
				return answerResult
	
	#no valid answer given
	if points[city] > 0:
		points[city] -= 1
		answerResult.points = -1;
	
	return answerResult;
