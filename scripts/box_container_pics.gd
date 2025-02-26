extends VBoxContainer

#signal sendMissingScene

func delete_buttons() -> void:
	for button in get_tree().get_nodes_in_group("buttons"):
		button.queue_free()


func delete_pics() -> void:
	for pic in get_tree().get_nodes_in_group("pic"):
		pic.queue_free()


func populate(button_pictures: bool, lastnumber: int = -1) -> int:
	var sceneNr = []
	var missingVeg := -1
	
	print("Categories:")
	print(Singleton.category)
	var i := 0
	for pic in Singleton.pics:
		if pic[0] in Singleton.category:
			sceneNr.append(i)
		i += 1
		if sceneNr.size() >= Singleton.varieties:
			break
	print(sceneNr)
	#TODO ERROR
	
	delete_buttons()
	for nr in sceneNr:
		gen_button(nr, Singleton.pics[nr][2], Singleton.pics[nr][1])
	distribute_buttons()
	
	while Singleton.running:
		sceneNr.shuffle()
		if sceneNr[-1] == lastnumber && not Singleton.true_random:
			continue
		missingVeg = sceneNr.pop_back()
		break
	
	delete_pics()
	for nr in sceneNr:
		#var instance: Node = Singleton.SCENES[sceneNr.pop_back()][0].instantiate()
		# Invalid call. Nonexistent function 'init' in base 'CompressedTexture2D'.
		var texture :Texture = Singleton.pics[nr][1]
		print(texture)
		var instance :Node = Singleton.PICTURE.instantiate()
		instance.init(texture)
		instance.add_to_group("pic")
		%PicGen.add_child(instance)
	sort_buttons()
	distribute_pics()
	#sendMissingScene.emit(sceneNr.pop_back())
	return missingVeg


func gen_button(nr: int, text: String, texture: Texture) -> void:
	var button: Button = Singleton.BUTTON.instantiate()
	match Singleton.pic_button_status:
		0:
			button.text = text
		1:
			button.icon = texture
			button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		2:
			button.text = text
			button.icon = texture
			button.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
	%ButtonGen.add_child(button)
	button.connect("pressed", $"../../..".on_button_press.bind(button, nr))
	button.set_meta("nr", nr)


func distribute_pics() -> void:
	var rows := ceili(%PicGen.get_child_count() / 4.0)
	
	while %VBoxContainerPics.get_child_count() != 1:
		%VBoxContainerPics.get_child(0).free()
	
	var bigbox := create_box_container(not Singleton.side_buttons)
	%VBoxContainerPics.add_child(bigbox)
	%VBoxContainerPics.move_child(bigbox, 0)
	
	for i in range(0,rows):
		var box := create_box_container(Singleton.side_buttons)
		bigbox.add_child(box)
	
	var i := 0
	while %PicGen.get_child_count() != 0:
		var pic :Control = %PicGen.get_child(0)
		%PicGen.remove_child(pic)
		bigbox.get_child(i % rows).add_child(pic)
		i += 1
	$"../../..".exit_button_reset()


func create_box_container(vbox :bool) -> BoxContainer:
	var box : BoxContainer
	if vbox:
		box = VBoxContainer.new()
	else:
		box = HBoxContainer.new()
	box.size_flags_horizontal = SIZE_EXPAND_FILL
	box.size_flags_vertical = SIZE_EXPAND_FILL
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return box


func sort_buttons() -> void:
	#TODO Sort shit according to language
	pass


func distribute_buttons() -> void:
	var count := 0
	var maximum := %ButtonGen.get_child_count()
	
	for button in %ButtonGen.get_children():
		%ButtonGen.remove_child(button)
		var nr = button.get_meta("nr")
		var other_button = button.duplicate();
		other_button.connect("pressed", $"../../..".on_button_press.bind(other_button, nr))
		%VegieButtonGrid.add_child(button)
		if count < (maximum / 2.0):
			count += 1
			%VBoxContainerLeft.add_child(other_button)
		else:
			%VBoxContainerRight.add_child(other_button)
	$"../../..".exit_button_reset()


func shake() -> void:
	for pic in get_tree().get_nodes_in_group("pic"):
		pic.shake()
