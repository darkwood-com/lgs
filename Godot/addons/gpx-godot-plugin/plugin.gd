@tool extends EditorPlugin
	
func _enter_tree():
	var cfg = ConfigFile.new()
	cfg.load("res://export_presets.cfg")

	var sdk_installed = false
	for key in cfg.get_sections():
		if cfg.has_section_key(key, "name"):
			if cfg.get_value(key, "name").begins_with("GamePix"):
				sdk_installed = true
				break

	if not(sdk_installed):
		# each preset have preset itself and options
		var new_section = "preset" + "." + str(len(cfg.get_sections()) / 2)
		var options = new_section + ".options"
		
		cfg.set_value(new_section, "name", "GamePix")
		cfg.set_value(new_section, "platform", "Web")
		cfg.set_value(new_section, "runnable", false)
		cfg.set_value(new_section, "custom_features", "")
		cfg.set_value(new_section, "export_filter", "all_resources")
		cfg.set_value(new_section, "include_filter", "")
		cfg.set_value(new_section, "exclude_filter", "")
		cfg.set_value(options, "html/custom_html_shell", "res://addons/gpx-godot-plugin/index.html")
		cfg.save("res://export_presets.cfg")
	
	add_autoload_singleton("GPX", "res://addons/gpx-godot-plugin/gpx.gd")

func _exit_tree():
	remove_autoload_singleton("GPX")
