extends Control

func _on_vegie_button_pressed() -> void:
	Singleton.category = "/vegies"
	_on_scene_change()


func _on_office_button_pressed() -> void:
	Singleton.category = "/office"
	_on_scene_change()


func _on_vehicle_button_pressed() -> void:
	Singleton.category = "/vehicles"
	_on_scene_change()


func _on_animal_button_pressed() -> void:
	Singleton.category = "/animals"
	_on_scene_change()


func _on_scene_change() -> void:
	Singleton.running = false
	Singleton.cur_rounds = 1
	Singleton.goto_scene(Singleton.SCENE_PLAYING)


func _on_exit_button_pressed() -> void:
	Singleton.goto_scene(Singleton.SCENE_MENU)
