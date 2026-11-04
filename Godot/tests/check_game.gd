extends SceneTree

var failures = 0
func check(condition: bool, message: String):
	if not condition:
		failures += 1
		push_error(message)

func _initialize():
	call_deferred("run_checks")

func run_checks():
	var scene = load("res://scenes/root.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	for dimensions in [Vector2i(800, 450), Vector2i(1280, 720), Vector2i(450, 800), Vector2i(320, 568)]:
		root.size = dimensions
		scene.size_changed()
		var corner = scene.position + scene.scale * Vector2(512, 342)
		check(scene.position.x >= -0.01 and scene.position.y >= -0.01, "Negative viewport offset")
		check(corner.x <= dimensions.x + 0.01 and corner.y <= dimensions.y + 0.01, "Scene cropped at " + str(dimensions))
		check(is_equal_approx(scene.scale.x, scene.scale.y), "Scene stretched")
	for name in ["intro", "game", "end", "main"]:
		scene.user.cardId = "4101"
		scene.set_current_scene(name)
		await process_frame
		check(scene.current_scene != null, "Missing scene " + name)
	var card_count = 0
	for card_id in scene.data.cards:
		scene.user = User.new()
		scene.user.cardId = card_id
		scene.set_current_scene("game")
		await process_frame
		check(scene.current_scene.cameraView.texture != null, "Missing art for " + card_id)
		for view in scene.current_scene.boxViews.values():
			check(view.content != null, "Missing text panel for " + card_id)
		card_count += 1
	var action_count = 0
	for card_id in scene.data.cards:
		for equipped in [false, true]:
			scene.user = User.new()
			scene.user.cardId = card_id
			if equipped:
				for item in scene.user.objects: scene.user.objects[item] = true
				for city in scene.user.points: scene.user.points[city] = 25
			scene.set_current_scene("game")
			await process_frame
			var available_actions = scene.current_scene.actions.keys()
			for action_key in available_actions:
				scene.user = User.new()
				scene.user.cardId = card_id
				if equipped:
					for item in scene.user.objects: scene.user.objects[item] = true
					for city in scene.user.points: scene.user.points[city] = 25
				scene.set_current_scene("game")
				await process_frame
				scene.current_scene._on_action(action_key, scene.current_scene.actionView)
				await process_frame
				action_count += 1
	print("ACTION CHECK: ", action_count, " interactions across empty and equipped inventories")
	var question_count = 0
	for city in scene.data.questions:
		for question in scene.data.questions[city]:
			var correct = []
			for answer in question.answers:
				if question.answers[answer]: correct.append(answer)
			check(correct.size() == 1, "Question must have exactly one correct answer: " + question.ask)
			if correct.size() == 1:
				var user = User.new()
				var result = user.answer(correct[0], question, "1", city)
				check(result.isValid and user.points[city] == question.points, "Quiz scoring failed")
				check(user.didAnswer(question), "Answered question tracking failed")
			question_count += 1
	var gamepix = root.get_node_or_null("GPX")
	if gamepix != null:
		gamepix._pause([])
		check(paused and AudioServer.is_bus_mute(0), "Host pause must also mute audio")
		gamepix._sound_off([])
		gamepix._resume([])
		check(not paused and AudioServer.is_bus_mute(0), "Resume must preserve sound-off state")
		gamepix._sound_on([])
		check(not AudioServer.is_bus_mute(0), "Sound-on must restore audio")
	print("CHECKED: 4 viewport sizes, 4 scenes, ", card_count, " locations, ", question_count, " questions; failures=", failures)
	scene.queue_free()
	await process_frame
	quit(1 if failures else 0)
