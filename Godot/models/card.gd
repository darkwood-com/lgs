class_name Card extends Object

var imagePath: String #image path to the card
var messages: Dictionary #Dictionary<String => String>
var surfaces: Dictionary #Dictionary<String => Value<Rect>>
var actions: Dictionary #NSDictionary<String => Action>
var coords: Vector2i #hero coordinate in map

func _init(node: XMLNode):
	imagePath = node.attributes.imagePath
	coords = Vector2i(int(node.attributes.mapX), int(node.attributes.mapY))
	for childNode in node.children:
		if childNode.name == 'messages':
			for messageNode in childNode.children:
				messages[messageNode.attributes.key] = messageNode.attributes.value.replace("\\n", "\n")
		elif childNode.name == 'surfaces':
			for surfaceNode in childNode.children:
				if not surfaces.has(surfaceNode.attributes.action):
					surfaces[surfaceNode.attributes.action] = []
				surfaces[surfaceNode.attributes.action].append(Rect2i(
					int(surfaceNode.attributes.x),
					int(surfaceNode.attributes.y),
					int(surfaceNode.attributes.width),
					int(surfaceNode.attributes.height),
				))
		elif childNode.name == 'actions':
			for actionNode in childNode.children:
				actions[actionNode.attributes.key] = Action.new(actionNode.attributes.type, actionNode.attributes.value)
