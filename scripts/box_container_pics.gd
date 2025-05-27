extends VBoxContainer

@onready var root = self.owner

func delete_buttons() -> void:
	for button in get_tree().get_nodes_in_group("buttons"):
		button.queue_free()

func delete_pics() -> void:
	for pic in get_tree().get_nodes_in_group("pic"):
		pic.queue_free()

func populate() -> void:
	var validPicArray = []
	
	print("Categories: " + str(Singleton.category))
	if Singleton.category == null:
		for pic in Singleton.pics:
			if pic[0]:
				validPicArray.push_back(pic)
	else:
		Singleton.varieties = 8
		for pic in Singleton.pics:
			var category :String = pic[1].trim_prefix(
					Singleton.DIRNAMEFOLDER + "/" + Singleton.DIRNAMEPICS + "/").get_base_dir()
			if Singleton.category == category:
				validPicArray.push_back(pic)
	
	validPicArray.shuffle()
	if Singleton.first_round or not Singleton.running:
		Singleton.picArray.clear()
		for i in range(Singleton.varieties):
			Singleton.picArray.push_back(validPicArray[i])
	
	delete_buttons()
	for pic in Singleton.picArray:
		gen_button(pic[1], pic[2], pic[3])
	sort_buttons()
	distribute_buttons()
	
	while Singleton.running:
		Singleton.picArray.shuffle()
		if Singleton.picArray[0][1] == Singleton.lastMissingPic && not Singleton.true_random:
			continue
		Singleton.missingPic = Singleton.picArray.front()[1]
		Singleton.lastMissingPic = Singleton.missingPic
		print("true_random: " + str(Singleton.true_random))
		print("missingpic: " + Singleton.missingPic)
		break
	
	delete_pics()
	var firstpic = true
	for pic in Singleton.picArray:
		if firstpic and Singleton.running:
			firstpic = false
		else:
			var instance :Node = Singleton.PICTURE.instantiate()
			instance.init(pic[2])
			instance.add_to_group("pic")
			instance.set_meta("name", pic[3])
			%PicGen.add_child(instance)
	if not Singleton.running:
		sort_pics()
	distribute_pics()


func gen_button(path: String, texture: Texture, text: String,) -> void:
	var button: Button = Singleton.BUTTON.instantiate()
	button.set_meta("path", path)
	button.set_meta("pic", texture)
	button.set_meta("text", text)
	match Singleton.pic_text_status:
		0:
			button.text = button.get_meta("text")
		1:
			button.icon = button.get_meta("pic")
			button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		2:
			button.text = button.get_meta("text")
			button.icon = button.get_meta("pic")
			button.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
	%ButtonGen.add_child(button)
	button.connect("pressed", root.on_button_press.bind(button, path))
	#print("buttonpath: " + path)


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


func distribute_pics() -> void:
	var pics := %PicGen.get_child_count()
	var rows := 1
	if pics > 1:
		rows = 2
	if pics > 8:
		rows = 3
	while %VBoxContainerPics.get_child_count() != 1:
		%VBoxContainerPics.get_child(0).free()
	var bigbox := create_box_container(not Singleton.side_buttons)
	%VBoxContainerPics.add_child(bigbox)
	%VBoxContainerPics.move_child(bigbox, 0)
	for i in range(0,rows):
		var box := create_box_container(Singleton.side_buttons)
		bigbox.add_child(box)
	var i := 0
	if rows == 2:
		while %PicGen.get_child_count() != 0:
			var pic :Control = %PicGen.get_child(0)
			%PicGen.remove_child(pic)
			bigbox.get_child(i / ((pics + 1) / 2)).add_child(pic)
			i += 1
	if rows == 3:
		while %PicGen.get_child_count() != 0:
			var pic :Control = %PicGen.get_child(0)
			%PicGen.remove_child(pic)
			bigbox.get_child(i / ((pics + 2) / 3)).add_child(pic)
			i += 1
	root.exit_button_reset()


func distribute_buttons() -> void:
	var count := 0
	var maximum := %ButtonGen.get_child_count()
	
	for button in %ButtonGen.get_children():
		%ButtonGen.remove_child(button)
		var path = button.get_meta("path")
		#print("otherpath: " + path)
		var other_button = button.duplicate();
		other_button.connect("pressed", root.on_button_press.bind(other_button, path))
		%VegieButtonGrid.add_child(button)
		if count < (maximum / 2.0):
			count += 1
			%VBoxContainerLeft.add_child(other_button)
		else:
			%VBoxContainerRight.add_child(other_button)
	root.exit_button_reset()

func sort_buttons() -> void:
	var sorted := false
	while not sorted:
		sorted = true
		for i in range(%ButtonGen.get_child_count() - 1):
			if tr(%ButtonGen.get_child(i).text) > tr(%ButtonGen.get_child(i + 1).text):
				%ButtonGen.move_child(%ButtonGen.get_child(i + 1), i)
				sorted = false

func sort_pics() -> void:
	var sorted := false
	while not sorted:
		sorted = true
		var test :Sprite2D
		for i in range(%PicGen.get_child_count() - 1):
			if tr(%PicGen.get_child(i).get_meta("name")) > tr(%PicGen.get_child(i + 1).get_meta("name")):
				%PicGen.move_child(%PicGen.get_child(i + 1), i)
				sorted = false

func shake() -> void:
	if Singleton.shake:
		for pic in get_tree().get_nodes_in_group("pic"):
			pic.shake()
