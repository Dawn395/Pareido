extends Control

var selected_pic_count: int = 0
#var last_treeitem_selected: TreeItem = null
var double_click: bool = false

func _ready():
	
	%VarietiesHSlider.max_value = Singleton.MAX_VARIETIES
	%VarietiesHSlider.value = Singleton.varieties
	%VarietiesLabel.text = str(Singleton.varieties)
	
	%ScrollContainer.get_v_scroll_bar().custom_minimum_size.x = 50
	
	var tree :Tree = %Tree
	tree.hide_root = true
	tree.clear()
	Singleton.load_resources()
	var prev_treeitem :TreeItem = tree.create_item()
	prev_treeitem.set_meta("path", "")
	for path in Singleton.pic_folders:
		prev_treeitem = _create_tree_item(prev_treeitem, path)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.double_click == true:
			double_click = true
		else:
			double_click = false


func _create_tree_item(last_item :TreeItem, path: String) -> TreeItem:
	var folderpath :String = path.trim_prefix(Singleton.DIRNAMEFOLDER
			.path_join(Singleton.DIRNAMEPICS)).right(-1)
	var new_treeitem: TreeItem = null
	#print("folderpath:" + folderpath)
	#print("lastitem: " + last_item.get_meta("path"))
	#print("path: " + path )
	
	while true:
		if folderpath.begins_with(last_item.get_meta("path")):
			new_treeitem = %Tree.create_item(last_item)
			break
		last_item = last_item.get_parent()
	_setup_tree_item(new_treeitem, folderpath)
	return new_treeitem


func _setup_tree_item(item: TreeItem, folderpath: String):
	var path: String = (Singleton.DIRNAMEFOLDER
			.path_join(Singleton.DIRNAMEPICS).path_join(folderpath))
	var dir = DirAccess.open(path)
	item.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
	item.set_custom_minimum_height(40)
	item.set_icon_max_width(0, 40)
	item.set_editable(0, true)
	item.set_meta("path", folderpath)
	item.set_meta("fullpath", path)
	tree_checkmark(item)

	item.set_text(0, folderpath.get_file())
	for file in dir.get_files():
		if not (file.to_lower().ends_with(".txt")
				or file.to_lower().ends_with(".import")):
			var image = Image.load_from_file(path.path_join(file))
			var texture = ImageTexture.create_from_image(image)
			if texture != null:
				item.set_icon(0, texture)
				break;


func tree_checkmark (item: TreeItem):
	var true_items := 0
	var total_items :=0
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
	print(total_items)
	print(true_items)
	
	_set_selected_pics()

func _set_selected_pics():
	var total_selected := 0
	for pic in Singleton.pics_new:
		if pic[0] == true:
			total_selected += 1
	%TotalLabel.text = str(total_selected)

func _get_pic_counts (string :String) -> Array:
	var total_items :=0
	var true_items := 0
	for pic in Singleton.pics_new:
		if pic[1].get_base_dir() == string:
			total_items += 1
			if pic[0] == true:
				true_items += 1
	return [true_items, total_items]

func _on_tree_item_edited() -> void:
	var item :TreeItem = %Tree.get_edited()
	
	if double_click:
		var true_items := 0
		var total_items :=0
		var results = _get_pic_counts(item.get_meta("fullpath"))
		true_items = results [0]
		total_items = results [1]
		if true_items < total_items:
			for pic in Singleton.pics_new:
				print("pic[1]: " + pic[1].get_base_dir())
				print("fullpath: " + item.get_meta("fullpath"))
				if pic[1].get_base_dir() == item.get_meta("fullpath"):
					pic[0] = true
		if total_items == true_items:
			for pic in Singleton.pics_new:
				if pic[1].get_base_dir() == item.get_meta("fullpath"):
					pic[0] = false
	_populate_Pic_Grid_Container(item.get_meta("fullpath"), item)
	tree_checkmark(item)

func _populate_Pic_Grid_Container(path: String, treeitem: TreeItem) -> void:
	for item in %PicGridContainer.get_children():
		item.queue_free()
	
	for pic in Singleton.pics_new:
		if pic[1].get_base_dir() == path:
			#print("worked!" + pic[1])
			var button: Button = Singleton.OPTION_PICTURE_BUTTON.instantiate()
			%PicGridContainer.add_child(button)
			button.init(pic[1], pic[2], pic[0], treeitem, self)


func _on_exit_button_pressed() -> void:
	Singleton.config.load(Singleton.DIRNAMEFOLDER.path_join(Singleton.DIRNAMEINI))
	Singleton.goto_scene(Singleton.SCENE_MENU)


func _on_language_button_pressed() -> void:
	pass # Replace with function body.


func _on_options_button_pressed() -> void:
	pass # Replace with function body.


func _on_accept_button_pressed() -> void:
	Singleton.config.save(Singleton.DIRNAMEFOLDER.path_join(Singleton.DIRNAMEINI))
	Singleton.goto_scene(Singleton.SCENE_MENU)


func _on_play_button_pressed() -> void:
	Singleton.config.save(Singleton.DIRNAMEFOLDER.path_join(Singleton.DIRNAMEINI))


func _on_varieties_h_slider_value_changed(value: float) -> void:
	Singleton.config.set_value("global", "varieties", int(value))
	Singleton.varieties = int(value)
	%VarietiesLabel.text = str(Singleton.varieties)
