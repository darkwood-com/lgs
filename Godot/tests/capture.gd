extends SceneTree

var scene: RootScene
func _initialize(): call_deferred("capture")
func shot(label: String):
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("/tmp/lgs-tools/frames/" + label + ".png")
func capture():
	scene = load("res://scenes/root.tscn").instantiate()
	root.add_child(scene)
	await shot("01-menu-800x450")
	scene.current_scene._on_action("", scene.current_scene.student_view)
	await shot("02-menu-open-800x450")
	scene.current_scene._on_action("Start a new adventure.", scene.current_scene.student_menu_view)
	await shot("03-name-prompt-800x450")
	scene.current_scene.new_user_prompt_view.text_field.text = "Adventurer"
	scene.current_scene._on_action("OK", scene.current_scene.new_user_prompt_view)
	await shot("04-intro-800x450")
	scene.current_scene._on_action("Continue", null)
	await shot("05-instructions-800x450")
	scene.current_scene._on_action("Begin your quest", null)
	await shot("06-crossroads-800x450")
	scene.current_scene._on_action("", scene.current_scene.bagView)
	await shot("07-inventory-800x450")
	scene.current_scene._on_action("", scene.current_scene.msgView)
	scene.current_scene.goCard("17027")
	scene.current_scene._on_action("2 Talents", scene.current_scene.actionView)
	await shot("08-quiz-800x450")
	var question: Question = scene.current_scene.mode.chosenQuestion
	for answer in question.answers:
		if question.answers[answer]:
			scene.current_scene._on_action(answer, scene.current_scene.actionView)
			break
	await shot("09-quiz-feedback-800x450")
	scene.current_scene._on_action("", scene.current_scene.saveView)
	await shot("10-saved-800x450")
	var saved_user = User.new()
	assert(saved_user.load().success, "Save/load failed")
	assert(saved_user.name == "Adventurer", "Saved name mismatch")
	assert(saved_user.cardId == scene.user.cardId, "Saved location mismatch")
	assert(saved_user.askedQuestions.size() == 1, "Answered questions not saved")
	print("CAPTURE: scenes, menu flow, quiz answer, inventory and save/load passed")
	for card_id in ["4651", "5725", "8322", "19631", "26291", "3704", "7409", "5683"]:
		scene.current_scene.goCard(card_id)
		await shot("art-" + card_id + "-800x450")
	scene.set_current_scene("end")
	await shot("11-ending-800x450")
	quit()
