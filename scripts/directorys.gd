extends Node


func create_dir(executeable_path: String) -> void:
	#if DirAccess.dir_exists_absolute(DIRNAMEFOLDER):
		#return
	var dir= DirAccess.open("user://")
	dir.make_dir(Singleton.DIRNAMEFOLDER)
	dir.create_link(Singleton.DIRNAMEFOLDER, executeable_path.path_join("pareido_data"))
	dir.make_dir(Singleton.DIRNAMEFOLDER.path_join(Singleton.DIRNAMEPICS))
	copy_pics("res://art/pics/", Singleton.DIRNAMEFOLDER.path_join(Singleton.DIRNAMEPICS))
	#Singleton.pic_folders = read_pic_dirs()
	
	dir.make_dir(Singleton.DIRNAMEFOLDER.path_join(Singleton.DIRNAMEFONT))
	dir.copy("res://art/font/add_your_own_font.txt",
			Singleton.DIRNAMEFOLDER.path_join(Singleton.DIRNAMEFONT).path_join("add_your_own_font.txt"))


func copy_pics(src: String, dst: String) -> void:
	var dir = DirAccess.open(src)
	if dir:
		for directory in dir.get_directories():
			DirAccess.open(dst).make_dir(directory)
			copy_pics(src.path_join(directory), dst.path_join(directory))
		for file in dir.get_files():
			if not file.ends_with(".import"):
				dir.copy(src.path_join(file),dst.path_join(file))


func log_files(basepath: String, path: String, indent: String) -> void:
	var dir = DirAccess.open(path)
	if dir:
		for directory in dir.get_directories():
			print(indent + "DIR %s" % directory);
			log_files(basepath, path.path_join(directory), indent + "- ")
		for file in dir.get_files():
			print(indent + "FILE %s" % file);


func load_resources(path: String) -> void:
	var dir = DirAccess.open(path)
	print_debug("load_resources")
	
	load_config(Singleton.DIRNAMEFOLDER.path_join(Singleton.DIRNAMEINI))
	load_pics(path, path)
	if dir.dir_exists(Singleton.DIRNAMEFOLDER.path_join(Singleton.DIRNAMEFONT)):
		load_font(Singleton.DIRNAMEFOLDER.path_join(Singleton.DIRNAMEFONT))

func load_config(path: String) -> void:
	Singleton.config = ConfigFile.new()
	if Singleton.config.load(path) != OK:
		Singleton.config = ConfigFile.new()
		Singleton.config.set_value("global","starting_infobox", true)
	Singleton.starting_infobox = Singleton.config.get_value("global","starting_infobox")
	Singleton.config.save(path)


func load_pics(basepath: String, path: String) -> void:
	var dir = DirAccess.open(path)
	if dir:
		for directory :String in dir.get_directories():
			Singleton.pic_folders.push_back(path.path_join(directory))
			load_pics(basepath, path.path_join(directory))
		for file in dir.get_files():
			if not (file.to_lower().ends_with(".txt")
					or file.to_lower().ends_with(".import")):
				#var image = Image.load_from_file(path.path_join(file))
				#var texture = ImageTexture.create_from_image(image)
				var texture = null
				var filename = "tr_" + file.get_basename()
				
				if tr(filename) == filename:
					filename = file.get_basename()
				#print("path:" + path.trim_prefix(basepath).right(-1).path_join(file))
				var activepic = Singleton.config.get_value("profile1",path.trim_prefix(basepath).right(-1).path_join(file), false)
				Singleton.pics.push_back([activepic, path.path_join(file), texture, filename])
				#print(path.path_join(file))


func load_font(path: String) -> void:
	var dir = DirAccess.open(path)
	var font_file = FontFile.new()
	for file in dir.get_files():
		if (
			file.to_lower().ends_with(".ttf")
			or file.to_lower().ends_with(".otf")
			or file.to_lower().ends_with(".woff")
			or file.to_lower().ends_with(".woff2")
			or file.to_lower().ends_with(".pfb")
			or file.to_lower().ends_with(".pfm")
		):
			if font_file.load_dynamic_font(path.path_join(file)) == OK:
				break;
		elif (file.to_lower().ends_with(".fnt") or file.ends_with(".font")):
			if font_file.load_bitmap_font(path.path_join(file)) == OK:
				break;
	if not font_file.data.is_empty():
		var theme: Theme = load("res://theme.tres")
		theme.set_font("font", "Button", font_file)
		theme.set_font("font", "Label", font_file)
		theme.set_font("font", "LineEdit", font_file)


func read_pic_dirs() -> Dictionary:
	var dict: Dictionary
	for item: String in Singleton.pics:
		var pos: int =  item.find(Singleton.DIRNAMEPICS)
		var str: String = item.substr(pos + Singleton.DIRNAMEPICS.length() + 1)
		dict.get_or_add(str.get_base_dir(), item)
	return dict
