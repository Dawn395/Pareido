extends Control

#TODO fix bottom button overlap
#TODO automate adding languages to project?
#TODO Darkmode?

#TODO V1 done


func _ready():
	await get_tree().process_frame
	
	%VBoxContainerPics.delete_buttons()
	%VBoxContainerPics.populate(Singleton.varieties)
	exit_button_reset()
	
	for pic in Singleton.pics:
		print(pic)


func exit_button_reset() -> void:
	await get_tree().process_frame
	if %VBoxContainerRight.visible:
		%ExitButton.global_position.x = 1120 - %VBoxContainerRight.size.x - %ExitButton.size.x
	else:
		%ExitButton.global_position.x = 1072 # TODO Check if still correct


#TODO: depreciated?
func _on_layout_button_pressed() -> void:
	%VBoxContainerLeft.visible = not %VBoxContainerLeft.visible
	%VBoxContainerRight.visible = not %VBoxContainerRight.visible
	%VegieButtonGrid.visible = not %VegieButtonGrid.visible
	Singleton.side_buttons = not Singleton.side_buttons
	exit_button_reset()


func _on_start_button_pressed() -> void:
	_switch_buttons()
	%StartButton.visible = false
	%LayoutButton.visible = false
	%StartContainer.visible = false
	#%RoundsSpinBox.editable = false
	#%RoundsHSlider.editable = false
	#%VarietiesSpinBox.editable = false
	#%VarietiesHSlider.editable = false
	Singleton.running = not Singleton.running
	%VBoxContainerPics.delete_pics()
	Singleton.missingVeg = %VBoxContainerPics.populate(Singleton.varieties)
	%VBoxContainerPics.shake()
	%GuessTimer.stop()
	%GuessTimer.paused = false
	%GuessTimer.start()
#	missingVeg = missingScene


func on_button_press(pressedButton: Button, number: int) -> void:
	if Singleton.running:
		if Singleton.missingVeg == number:
			%CorrectTimer.start()
			pressedButton.add_theme_color_override("icon_normal_color", Color(0, 1, 0))
			pressedButton.add_theme_color_override("font_color", Color(0, 1, 0))
			pressedButton.add_theme_color_override("font_focus_color", Color(0, 1, 0))
			pressedButton.add_theme_color_override("font_disabled_color", Color(0, 1, 0))
		else:
			%DisabledTimer.start()
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
	if Singleton.cur_rounds == %RoundsSpinBox.value:
		Singleton.cur_rounds = 1
		%GuessTimer.paused = true
		%StartContainer.visible = true
		%TimeLabel.visible = true
		%StartButton.visible = true
		%TimeLabel.text = "%.2f" % (%GuessTimer.wait_time - %GuessTimer.time_left - %RoundsSpinBox.value * %CorrectTimer.wait_time)
		Singleton.running = not Singleton.running
	else:
		%VBoxContainerPics.delete_pics()
		Singleton.missingVeg =  %VBoxContainerPics.populate(Singleton.missingVeg)
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


#func _on_flag_button_pressed() -> void:
	#cur_language_nr += 1
	#if cur_language_nr >= LANGUAGES.size():
		#cur_language_nr = 0;
	#TranslationServer.set_locale(LANGUAGES[cur_language_nr])
	#%FlagButton.icon = load("res://translations/%s" % tr("key_picture_path"))
	#print(tr("key_picture_path"))


##region OptionChanges
#func _on_rounds_spin_box_value_changed(value: float) -> void:
	#if not alreadychanged:
		#%RoundsHSlider.value = value
	#alreadychanged = not alreadychanged
	#max_rounds = value
#
#
#func _on_rounds_h_slider_value_changed(value: float) -> void:
	#if not alreadychanged:
		#%RoundsSpinBox.value = value
	#alreadychanged = not alreadychanged
	#max_rounds = value
#
#
#func _on_varieties_spin_box_value_changed(value: float) -> void:
	#if not alreadychanged:
		#%VarietiesHSlider.value = value
	#alreadychanged = not alreadychanged
	#varieties = value
	#%VBoxContainerPics.delete_buttons()
	#%VBoxContainerPics.delete_pics()
	#%VBoxContainerPics.populate(varieties)
#
#
#func _on_varieties_h_slider_value_changed(value: float) -> void:
	#if not alreadychanged:
		#%VarietiesSpinBox.value = value
	#alreadychanged = not alreadychanged
	#varieties = value
	#%VBoxContainerPics.delete_buttons()
	#%VBoxContainerPics.delete_pics()
	#%VBoxContainerPics.populate(varieties)
##endregion
#
##func _on_vegie_pic_send_missing_scene(missingScene) -> void:
#
#func _on_symbols_button_pressed() -> void:
	#button_pictures = !button_pictures
	#%VBoxContainerPics.populate(varieties)
	#
