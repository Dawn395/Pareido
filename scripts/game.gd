extends Control

func _ready():
	await get_tree().process_frame
	
	%StartContainer.visible = false
	if Singleton.category == null:
		Singleton.varieties = Singleton.config.get_value("global", "varieties", 8)
	else:
		Singleton.varieties = 8
	Singleton.true_random = Singleton.config.get_value("global", "true_random", false)
	Singleton.randomize_between_rounds = Singleton.config.get_value("global", "randomize_between_rounds", false)
	Singleton.rounds = Singleton.config.get_value("global", "rounds", 3)
	Singleton.pic_text_status = Singleton.config.get_value("global", "pic_text_status", 0)
	Singleton.shake = Singleton.config.get_value("global", "shake_pics", true)
	Singleton.cur_rounds = 1
	Singleton.wrong_guesses = 0
	Singleton.running = false
	%VBoxContainerPics.delete_buttons()
	%VBoxContainerPics.populate()
	exit_button_reset()

func exit_button_reset() -> void:
	await get_tree().process_frame
	if %VBoxContainerRight.visible:
		%ExitButton.global_position.x = 1120 - %VBoxContainerRight.size.x - %ExitButton.size.x
	else:
		%ExitButton.global_position.x = 1070


func _on_layout_button_pressed() -> void:
	%VBoxContainerLeft.visible = not %VBoxContainerLeft.visible
	%VBoxContainerRight.visible = not %VBoxContainerRight.visible
	%VegieButtonGrid.visible = not %VegieButtonGrid.visible
	Singleton.side_buttons = not Singleton.side_buttons
	exit_button_reset()


func _on_start_button_pressed() -> void:
	Singleton.first_round = true
	_switch_buttons()
	Singleton.wrong_guesses = 0
	%StartButton.visible = false
	%LayoutButton.visible = false
	%StartContainer.visible = false
	Singleton.first_round = true
	Singleton.running = not Singleton.running
	%VBoxContainerPics.delete_pics()
	%VBoxContainerPics.populate()
	%VBoxContainerPics.shake()
	%GuessTimer.stop()
	%GuessTimer.paused = false
	%GuessTimer.start()


func on_button_press(pressedButton: Button, path: String) -> void:
	if Singleton.running:
		Singleton.first_round = false
		if Singleton.missingPic == path:
			%CorrectTimer.start()
			pressedButton.add_theme_color_override("icon_normal_color", Color(0, 1, 0))
			pressedButton.add_theme_color_override("font_color", Color(0, 1, 0))
			pressedButton.add_theme_color_override("font_focus_color", Color(0, 1, 0))
			pressedButton.add_theme_color_override("font_disabled_color", Color(0, 1, 0))
		else:
			%DisabledTimer.start()
			Singleton.wrong_guesses += 1
			pressedButton.add_theme_color_override("font_color", Color(1, 0, 0))
			pressedButton.add_theme_color_override("font_focus_color", Color(1, 0, 0))
			pressedButton.add_theme_color_override("font_disabled_color", Color(1, 0, 0))
			pressedButton.icon = pressedButton.get_meta("pic")
			pressedButton.text = pressedButton.get_meta("text")
		_switch_buttons()
		exit_button_reset()


func _on_disabledtimer_timeout() -> void:
	_switch_buttons()


func _on_correct_timer_timeout() -> void:
	if Singleton.cur_rounds == Singleton.rounds:
		Singleton.cur_rounds = 1
		%GuessTimer.paused = true
		%StartContainer.visible = true
		%TimeLabel.visible = true
		%StartButton.visible = true
		%TimeLabel.text = "%.2f" % (%GuessTimer.wait_time - %GuessTimer.time_left - Singleton.rounds * %CorrectTimer.wait_time)
		%GuessesLabel.text = str(Singleton.wrong_guesses) + " "
		Singleton.running = not Singleton.running
	else:
		%VBoxContainerPics.delete_pics()
		%VBoxContainerPics.populate()
		%VBoxContainerPics.shake()
		Singleton.cur_rounds += 1
	for button :Button in get_tree().get_nodes_in_group("buttons"):
		button.remove_theme_color_override("icon_normal_color")
		button.remove_theme_color_override("font_color")
		button.remove_theme_color_override("font_focus_color")
		button.remove_theme_color_override("font_disabled_color")
	exit_button_reset()


func _switch_buttons():
	for button in get_tree().get_nodes_in_group("buttons"):
		button.disabled = !button.disabled


func _on_exit_button_pressed() -> void:
	Singleton.goto_scene(Singleton.SCENE_MENU)
	Singleton.first_round = true
	Singleton.category = null
