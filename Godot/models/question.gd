class_name Question extends Object

var points: int #points given for this question
var ask: String #asking question
var answers: Dictionary #Dictionary<String => Number(BOOL)>

func loadNode(node: XMLNode):
	points = int(node.attributes.points)
	ask = node.attributes.ask.replace("\\n", "\n")
	for answerNode in node.children:
		if answerNode.attributes.has('valid') and answerNode.attributes.valid == 'true':
			answers[answerNode.attributes.value] = true
		else:
			answers[answerNode.attributes.value] = false
