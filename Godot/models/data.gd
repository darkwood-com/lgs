class_name Data extends Object

var inits: Dictionary = {} #Dictionary<String, Dictionary<String, String>>
var sounds: Dictionary = {} #Dictionary<String(name) => String(path)>
var cards: Dictionary = {} #Dictionary<String(cardId) => Card>
var questions: Dictionary = {} #Dictionary<String(city) => Array<Question>>

func _init():
	var node = XML.parse_file("res://datas/data.xml")
	for rootChildNode in node.root.children:
		if rootChildNode.name == 'inits':
			for initNode in rootChildNode.children:
				var datas = {}
				for dataNode in initNode.children:
					datas[dataNode.attributes.key] = dataNode.attributes.value
				inits[initNode.attributes.key] = datas
		elif rootChildNode.name == 'sounds':
			for soundNode in rootChildNode.children:
				sounds[soundNode.attributes.key] = soundNode.attributes.value
		elif rootChildNode.name == 'cards':
			for cardNode in rootChildNode.children:
				cards[cardNode.attributes.key] = Card.new(cardNode)
	
	node = XML.parse_file("res://datas/questions.xml")
	for questionsNode in node.root.children:
		var questionList = []
		for questionNode in questionsNode.children:
			var question = Question.new()
			question.loadNode(questionNode)
			questionList.push_back(question)
		questionList.shuffle()
		questions[questionsNode.attributes.city] = questionList

func getInit(key: String):
	return inits[key]

func getSound(key: String):
	return sounds[key]

func getCard(key: String) -> Card:
	return cards[key]

func getQuestionsFromCity(city: String):
	return questions[city]
