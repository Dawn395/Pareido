extends Control

var selected_pic_count: int = 0
var right_click: bool = false

func _ready():
	%VarietiesHSlider.max_value = Singleton.MAX_VARIETIES
	%VarietiesHSlider.value = Singleton.varieties
	%VarietiesLabel.text = str(Singleton.varieties) + " / " + str(selected_pic_count) + " "
	
	var tree :Tree = %Tree
	tree.hide_root = true
	var prev_treeitem :TreeItem = tree.create_item()
	prev_treeitem.set_meta("path", "")
	for path in Singleton.pic_folders:
		prev_treeitem = _create_tree_item(prev_treeitem, path)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			right_click = true
		else:
			right_click = false


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
	item.set_icon_max_width(0, 40)
	item.set_editable(0, true)
	item.set_meta("path", folderpath)
	item.set_text(0, folderpath.get_file())
	for file in dir.get_files():
		if not (file.to_lower().ends_with(".txt")
				or file.to_lower().ends_with(".import")):
			var image = Image.load_from_file(path.path_join(file))
			var texture = ImageTexture.create_from_image(image)
			if texture != null:
				item.set_icon(0, texture)
				break;


func _on_tree_item_edited() -> void:
	var item :TreeItem = %Tree.get_edited()
	
	print("Itemchecked:")
	print(item.is_checked(0))
	print("Rightclick:")
	print(right_click)
	#if right_click && item.is_checked(0):
		#item.set_checked(0, false)
	#elif right_click:
		#item.set_checked(0, true)
	print(item)
	print(item.get_meta("path"))
	
	print()


func _populate_Pic_Grid_Container(short_path: String) -> void:
	for pic in Singleton.pics_new:
		pic
	pass

func _on_exit_button_pressed() -> void:
	Singleton.config.load(Singleton.DIRNAMEFOLDER.path_join(Singleton.DIRNAMEINI))
	Singleton.goto_scene(Singleton.SCENE_MENU)


func _on_flag_button_pressed() -> void:
	pass # Replace with function body.


func _on_options_button_pressed() -> void:
	pass # Replace with function body.


func _on_accept_button_pressed() -> void:
	Singleton.config.save(Singleton.DIRNAMEFOLDER.path_join(Singleton.DIRNAMEINI))
	Singleton.goto_scene(Singleton.SCENE_MENU)


func _on_varieties_h_slider_value_changed(value: float) -> void:
	Singleton.config.set_value("global", "varieties", int(value))
	Singleton.varieties = int(value)
	%VarietiesLabel.text = str(Singleton.varieties) + " / " + str(selected_pic_count) + " "


func _on_tree_button_clicked(item: TreeItem, column: int, id: int, mouse_button_index: int) -> void:
	print(TreeItem)
	print(column)
	print(id)
	print(mouse_button_index)
	print()
