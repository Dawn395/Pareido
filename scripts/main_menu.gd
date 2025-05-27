extends Control

var info_mode := false

func _ready() -> void:
	var root = get_tree().root
	Singleton.scene_current = root.get_child(-1)
	await get_tree().process_frame
	
	TranslationServer.set_locale(Singleton.config.get_value("global", "language", "de"))
	
	%InstructionsMarginContainer.visible = Singleton.starting_infobox
	if Singleton.config.get_value("global", "pic_text_status") != null:
		Singleton.pic_text_status = Singleton.config.get_value("global", "pic_text_status")
	_change_option_button()


func _on_exit_button_pressed() -> void:
	if info_mode:
		Singleton.create_tooltip(get_global_mouse_position(),
				"This button exits the game")
	else:
		#Save current options first?
		Singleton.exit_game()


func _on_start_button_pressed() -> void:
	if info_mode:
		Singleton.create_tooltip(get_global_mouse_position(),
				"This button starts the game")
	else:
		Singleton.goto_scene(Singleton.SIMPLE_CHOICE)


func _on_info_button_toggled() -> void:
	info_mode = not info_mode


func _on_donate_button_pressed() -> void:
	if info_mode:
		Singleton.create_tooltip(get_global_mouse_position(),
				"Donation_text")
	else:
		%DonateMarginContainer.visible = true


func _on_options_pressed() -> void:
	if info_mode:
		Singleton.create_tooltip(get_global_mouse_position(),
				"Option_text")
		Singleton.options_unlocked = true
	else:
		Singleton.pic_text_status += 1
		Singleton.pic_text_status %= 3
		Singleton.config.set_value("global", "pic_text_status", Singleton.pic_text_status)
		Singleton.config.save(Singleton.DIRNAMEFOLDER.path_join(Singleton.DIRNAMEINI))
		_change_option_button()


func _change_option_button() -> void:
	match Singleton.pic_text_status:
		0:
			%PictureOptionButton.text = "Text"
			%PictureOptionButton.icon = null
		1:
			%PictureOptionButton.text = ""
			var image = Image.load_from_file("res://art/pics/vehicles/car.png")
			var texture = ImageTexture.create_from_image(image)
			%PictureOptionButton.icon = texture
			%PictureOptionButton.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		2:
			%PictureOptionButton.text = "Bild und Text"
			var image = Image.load_from_file("res://art/pics/vehicles/car.png")
			var texture = ImageTexture.create_from_image(image)
			%PictureOptionButton.icon = texture
			%PictureOptionButton.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT


func _on_credits_button_pressed() -> void:
	if info_mode:
		Singleton.create_tooltip(get_global_mouse_position(),
				"Credits_text")
	else:
		%CreditMarginContainer.visible = true

func _on_credit_button_pressed() -> void:
	%CreditMarginContainer.visible = false

func _on_werk_raum_button_pressed() -> void:
	OS.shell_open("https://www.psz.co.at/berufliche-integration/werkraeume/werkraum-himberg/") 

func _on_donate_close_button_pressed() -> void:
	%DonateMarginContainer.visible = false

func _on_ko_fi_button_pressed() -> void:
	OS.shell_open("https://ko-fi.com/")

func _on_instructions_close_button_pressed() -> void:
	%InstructionsMarginContainer.visible = false
	Singleton.starting_infobox = false
	Singleton.config.set_value("global", "starting_infobox", false)
	Singleton.config.save(Singleton.DIRNAMEFOLDER.path_join(Singleton.DIRNAMEINI))

func _on_options_button_pressed() -> void:
	Singleton.goto_scene(Singleton.SCENE_OPTIONS)
