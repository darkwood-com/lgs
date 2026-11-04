extends SceneTree

var scene
func _initialize(): call_deferred("run_flow")
func click_at(point: Vector2):
	var location = scene.to_global(point)
	for pressed in [true, false]:
		var event = InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.position = location
		event.pressed = pressed
		root.push_input(event)
		await process_frame
func run_flow():
	scene = load("res://scenes/root.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	await click_at(Vector2(65, 325))
	assert(scene.current_scene.student_menu_view.visible, "Menu button did not open menu")
	await click_at(Vector2(65, 230))
	assert(scene.current_scene.new_user_prompt_view.visible, "New adventure link did not open prompt")
	await click_at(Vector2(200, 180))
	for letter in "Tester":
		var event = InputEventKey.new()
		event.unicode = letter.unicode_at(0)
		event.pressed = true
		root.push_input(event)
		await process_frame
	assert(scene.current_scene.new_user_prompt_view.text_field.text == "Tester", "Name field input failed")
	await click_at(Vector2(370, 220))
	assert(scene.current_scene is IntroScene, "OK button did not start intro")
	scene.current_scene._on_action("Continue", null)
	scene.current_scene._on_action("Begin your quest", null)
	await process_frame
	assert(scene.current_scene is GameScene, "Intro did not reach game")
	await click_at(Vector2(324, 258))
	assert(scene.user.cardId == "4651", "East link did not navigate to shop")
	await click_at(Vector2(90, 320))
	assert(scene.current_scene.msgView.visible, "Inventory icon did not open message")
	await click_at(Vector2(100, 240))
	assert(not scene.current_scene.msgView.visible, "Message could not be dismissed")
	print("INPUT FLOW: mouse menu, links, typed name, OK, travel and inventory passed at 800x450")
	quit()
