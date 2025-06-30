extends Control

var double_click: bool = false
var last_tree_item: TreeItem

func _ready():
	%VarietiesHSlider.max_value = Singleton.MAX_VARIETIES
	Singleton.varieties = Singleton.config.get_value("global", "varieties", 8)
	%VarietiesHSlider.value = Singleton.varieties
	%VarietiesLabel.text = str(Singleton.varieties)
	
	%ShakePicsCheckBox.button_pressed = Singleton.config.get_value("global", "shake_pics", true)
	%TrueRandomCheckBox.button_pressed = Singleton.config.get_value("global", "randomize_between_rounds", false)
	%RandomizeCheckBox.button_pressed = Singleton.config.get_value("global", "true_random", false)
	%RoundsHSlider.value = Singleton.config.get_value("global", "rounds", 3)
	_on_rounds_h_slider_value_changed(%RoundsHSlider.value)
	
	Singleton.pic_text_status = Singleton.config.get_value("global", "pic_text_status", 0)
	_change_option_button()
	
	
	var current_locale = TranslationServer.get_locale()
	for locale in TranslationServer.get_loaded_locales():
		print(locale)
		TranslationServer.set_locale(locale)
		%LanguageOptionButton.add_item(tr("tr_language"))
		var new_item_id = %LanguageOptionButton.get_item_count() - 1
		%LanguageOptionButton.set_item_metadata(new_item_id, locale)
		if current_locale ==  TranslationServer.get_locale():
			%LanguageOptionButton.select(new_item_id)
	TranslationServer.set_locale(current_locale)
	
	var tree :Tree = %Tree
	tree.hide_root = true
	tree.clear()
	_reload_from_config()
	var prev_treeitem :TreeItem = tree.create_item()
	prev_treeitem.set_meta("path", "")
	for path in Singleton.pic_folders:
		prev_treeitem = _create_tree_item(prev_treeitem, path)


func _reload_from_config() -> void:
	for pic in Singleton.pics:
		var shortpath = pic[1].trim_prefix(Singleton.DIRNAMEFOLDER + "/" + Singleton.DIRNAMEPICS + "/")
		#print("shortpath: " + shortpath)
		var activepic = Singleton.config.get_value("profile1", shortpath, false)
		pic[0] = activepic


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.double_click == true:
			double_click = true
		else:
			double_click = false


func _create_tree_item(last_item :TreeItem, path: String) -> TreeItem:
	var folderpath :String = path.trim_prefix(
			Singleton.DIRNAMEFOLDER + "/" + Singleton.DIRNAMEPICS + "/")
	var new_treeitem: TreeItem = null
	var font: Font = load("res://art/MulledWineSeason-Medium.otf")
	#print("folderpath:" + folderpath)
	#print("lastitem: " + last_item.get_meta("path"))
	#print("path: " + path )
	
	while true:
		if folderpath.begins_with(last_item.get_meta("path")):
			new_treeitem = %Tree.create_item(last_item)
			break
		last_item = last_item.get_parent()
	_setup_tree_item(new_treeitem, folderpath, font)
	return new_treeitem


func _setup_tree_item(item: TreeItem, folderpath: String, font: Font):
	var path: String = (Singleton.DIRNAMEFOLDER
			.path_join(Singleton.DIRNAMEPICS).path_join(folderpath))
	#var dir = DirAccess.open(path)
	item.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
	item.set_custom_minimum_height(40)
	item.set_icon_max_width(0, 100)
	item.set_editable(0, true)
	item.set_meta("path", folderpath)
	item.set_meta("fullpath", path)
	item.set_custom_font(0, font)
	item.set_custom_font_size(0, 20)
	tree_checkmark(item)
	item.set_text(0, folderpath.get_file())
	
	for pic in Singleton.pics:
		#print("pic[1]: " + pic[1])
		#print(path.get_base_dir())
		if pic[1].get_base_dir() == path:
			if pic[2] == null:
				var image = Image.load_from_file(pic[1])
				pic[2] = ImageTexture.create_from_image(image)
			item.set_icon(0, pic[2])
			break

func tree_checkmark (item: TreeItem):
	var true_items := 0
	var total_items := 0
	var results = _get_pic_counts(item.get_meta("fullpath"))
	true_items = results [0]
	total_items = results [1]
	
	if true_items < total_items:
		item.set_indeterminate(0, true)
	if total_items == true_items:
		item.set_indeterminate(0, false)
		item.set_checked(0, true)
	if true_items == 0:
		item.set_indeterminate(0, false)
		item.set_checked(0, false)
	#print(total_items)
	#print(true_items)
	
	_set_selected_pics()

func _set_selected_pics():
	var total_selected := 0
	for pic in Singleton.pics:
		if pic[0] == true:
			total_selected += 1
	%TotalLabel.text = str(total_selected)

func _get_pic_counts (string :String) -> Array:
	var total_items :=0
	var true_items := 0
	for pic in Singleton.pics:
		if pic[1].get_base_dir() == string:
			total_items += 1
			if pic[0] == true:
				true_items += 1
	return [true_items, total_items]

func _on_tree_item_edited() -> void:
	%TopHelpRichTextLabel.visible = false
	%CenterHelpRichTextLabel.visible = false
	%TopHelpLabel.visible = false
	%CenterHelpLabel.visible = false
	%BottomHelpLabel.visible = false
	var item :TreeItem = %Tree.get_edited()
	if double_click:
		var true_items := 0
		var total_items := 0
		var results = _get_pic_counts(item.get_meta("fullpath"))
		true_items = results [0]
		total_items = results [1]
		if true_items < total_items:
			for pic in Singleton.pics:
				#print("pic[1]: " + pic[1].get_base_dir())
				#print("fullpath: " + item.get_meta("fullpath"))
				if pic[1].get_base_dir() == item.get_meta("fullpath"):
					pic[0] = true
		if total_items == true_items:
			for pic in Singleton.pics:
				if pic[1].get_base_dir() == item.get_meta("fullpath"):
					pic[0] = false
	if double_click or item != last_tree_item:
		_populate_Pic_Grid_Container(item.get_meta("fullpath"), item)
	tree_checkmark(item)
	_labels_ok()
	last_tree_item = item 


func _populate_Pic_Grid_Container(path: String, treeitem: TreeItem) -> void:
	for item in %PicGridContainer.get_children():
		item.queue_free()
	var theme = load("res://option_button_theme.tres")
	for pic in Singleton.pics:
		if pic[1].get_base_dir() == path:
			#print("worked!" + pic[1])
			var button: Button = Singleton.OPTION_PICTURE_BUTTON.instantiate()
			%PicGridContainer.add_child(button)
			button.theme = theme
			button.focus_mode = Control.FOCUS_NONE
			if pic[2] == null:
				var image = Image.load_from_file(pic[1])
				pic[2] = ImageTexture.create_from_image(image)
			button.init(pic[1], pic[2], pic[3], pic[0], treeitem, self)


func _on_picture_type_button_pressed() -> void:
	Singleton.pic_text_status += 1
	Singleton.pic_text_status %= 3
	Singleton.config.set_value("global", "pic_text_status", Singleton.pic_text_status)
	_change_option_button()

func _change_option_button() -> void:
	match Singleton.pic_text_status:
		0:
			%PictureTypeButton.text = "tr_text"
			%PictureTypeButton.icon = null
		1:
			%PictureTypeButton.text = ""
			var image = Image.load_from_file("res://art/pics/vehicles/car.png")
			var texture = ImageTexture.create_from_image(image)
			%PictureTypeButton.icon = texture
			%PictureTypeButton.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		2:
			%PictureTypeButton.text = "tr_pic_and_text"
			var image = Image.load_from_file("res://art/pics/vehicles/car.png")
			var texture = ImageTexture.create_from_image(image)
			%PictureTypeButton.icon = texture
			%PictureTypeButton.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT


func _labels_ok() -> bool:
	if int(%VarietiesLabel.text) > int(%TotalLabel.text):
		%VarietiesLabel.add_theme_color_override("font_color", Color(1, 0, 0))
		%SlashLabel.add_theme_color_override("font_color", Color(1, 0, 0))
		%TotalLabel.add_theme_color_override("font_color", Color(1, 0, 0))
		return false
	else:
		%VarietiesLabel.add_theme_color_override("font_color", Color(0, 0, 0))
		%SlashLabel.add_theme_color_override("font_color", Color(0, 0, 0))
		%TotalLabel.add_theme_color_override("font_color", Color(0, 0, 0))
		return true


func _on_exit_button_pressed() -> void:
	Singleton.config.load(Singleton.DIRNAMEFOLDER.path_join(Singleton.DIRNAMEINI))
	Singleton.goto_scene(Singleton.SCENE_MENU)

func _on_language_button_pressed() -> void:
	pass # Replace with function body.

func _on_options_button_pressed() -> void:
	%OptionsPanel.visible = not %OptionsPanel.visible

func _on_accept_button_pressed() -> void:
	Singleton.config.save(Singleton.DIRNAMEFOLDER.path_join(Singleton.DIRNAMEINI))
	Singleton.goto_scene(Singleton.SCENE_MENU)

func _on_play_button_pressed() -> void:
	if _labels_ok():
		Singleton.config.save(Singleton.DIRNAMEFOLDER.path_join(Singleton.DIRNAMEINI))
		Singleton.category = null
		Singleton.goto_scene(Singleton.SCENE_PLAYING)

func _on_varieties_h_slider_value_changed(value: float) -> void:
	Singleton.config.set_value("global", "varieties", int(value))
	Singleton.varieties = int(value)
	%VarietiesLabel.text = str(Singleton.varieties)
	_labels_ok()

func _on_randomize_check_box_toggled(toggled_on: bool) -> void:
	Singleton.config.set_value("global", "randomize_between_rounds", toggled_on)

func _on_true_random_check_box_toggled(toggled_on: bool) -> void:
	Singleton.config.set_value("global", "true_random", toggled_on)

func _on_rounds_h_slider_value_changed(value: float) -> void:
	Singleton.config.set_value("global", "rounds", int(value))
	%RoundsLabel.text = "  " + str(int(value)) + "  "

func _on_language_option_button_item_selected(index: int) -> void:
	TranslationServer.set_locale(%LanguageOptionButton.get_item_metadata(index))
	Singleton.config.set_value("global", "language", %LanguageOptionButton.get_item_metadata(index))
	%TopHelpRichTextLabel.translate()
	%CenterHelpRichTextLabel.translate()
	$VBoxContainer/Panel/BottomHelpRichTextLabel.translate()

func _on_reset_popup_button_pressed() -> void:
	Singleton.config.set_value("global", "starting_infobox", true)

func _on_shake_check_box_toggled(toggled_on: bool) -> void:
	Singleton.config.set_value("global", "shake_pics", toggled_on)

func _on_center_help_rich_text_label_meta_clicked(meta: Variant) -> void:
	OS.shell_open("https://github.com/Dawn395/Pareido")
