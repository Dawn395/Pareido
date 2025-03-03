extends Node

const DIRNAMEPICS = "pictures"
const DIRNAMEFONT = "font"
const DIRNAMEFOLDER = "user://pareido_data"


func create_dir(executeable_path: String) -> void:
	#if DirAccess.dir_exists_absolute(DIRNAMEFOLDER):
		#return
	var dir_user = DirAccess.open("user://")
	var dir_exe = DirAccess.open("user://")
	dir_user.make_dir(DIRNAMEFOLDER)
	print_debug("create_dir_sym_link:")
	print_debug(dir_exe.create_link(DIRNAMEFOLDER, executeable_path.path_join("pareido_data")))
	dir_user.make_dir(DIRNAMEFOLDER.path_join(DIRNAMEPICS))
	copy_pics("res://art/pics/", DIRNAMEFOLDER.path_join(DIRNAMEPICS))
	dir_user.make_dir(DIRNAMEFOLDER.path_join(DIRNAMEFONT))
	dir_user.copy("res://art/font/add_your_own_font.txt",
			DIRNAMEFOLDER.path_join(DIRNAMEFONT).path_join("add_your_own_font.txt"))


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
			#if not (file.to_lower().ends_with(".txt") or file.to_lower().ends_with(".import")):
				#Image.load_from_file(path.path_join(file))
			print(indent + "FILE %s" % file);


func load_resources(path: String) -> void:
	var dir = DirAccess.open(path)
	print_debug("load_resources")

	load_pics(path, path)
	if dir.dir_exists(DIRNAMEFOLDER.path_join(DIRNAMEFONT)):
		load_font(DIRNAMEFOLDER.path_join(DIRNAMEFONT))


func load_pics(basepath: String, path: String) -> void:
	print("   ")
	print("path: " + path)
	print("basepath: " + basepath)
	print("   ")
	var dir = DirAccess.open(path)
	if dir:
		print("dir opened successful")
		for directory in dir.get_directories():
			load_pics(basepath, path.path_join(directory))
		for file in dir.get_files():
			print("file found:" + file)
			if not (file.to_lower().ends_with(".txt")
					or file.to_lower().ends_with(".import")):
				print_debug(basepath)
				var image = Image.load_from_file(path.path_join(file))
				var texture = ImageTexture.create_from_image(image)
				Singleton.pics.push_back([path.trim_prefix(basepath), texture, "tr_" + file.get_basename()])
				print("new Push:")
				print(texture)
				print(path.trim_prefix(basepath))
				print(path.path_join(file))
				print("tr_" + file.get_basename())


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
		var pos: int =  item.find(DIRNAMEPICS)
		var str: String = item.substr(pos + DIRNAMEPICS.length() + 1)
		dict.get_or_add(str.get_base_dir(), item)
	return dict
