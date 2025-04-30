extends Button

var treeitem: TreeItem

var root

func init(texturepath: String, text: String, checked: bool, item: TreeItem, localroot) -> void:
	#print("texturepath: " + texturepath)
	var image = Image.load_from_file(texturepath)
	var texture = ImageTexture.create_from_image(image)
	treeitem = item
	root = localroot
	$".".icon = texture
	#%Sprite2D.texture = texture
	$".".set_meta("text", text)
	$".".set_meta("fullpath", texturepath)
	$".".set_meta("path",  texturepath.right(-1 * 
			(len(Singleton.DIRNAMEFOLDER) + 1 + len(Singleton.DIRNAMEPICS) + 1)))
	%ButtonText.text = text
	%CheckBox.button_pressed = checked
	self.set_block_signals(true)
	self.button_pressed = checked
	self.set_block_signals(false)
	_on_toggled(checked)

func _on_toggled(toggled_on: bool) -> void:
	%CheckBox.button_pressed = toggled_on
	for pic in Singleton.pics_new:
		print("fullpath: " + $".".get_meta("fullpath"))
		print("path: " + $".".get_meta("path"))
		if pic[1] == $".".get_meta("fullpath"):
			pic[0] = toggled_on
			Singleton.config.set_value("profile1", $".".get_meta("path"), toggled_on)
			break
	root.tree_checkmark(treeitem)
