extends Node


var threadArray := []
var starttime
const threadcount := 8

var starting_infobox := true
var running := false
var side_buttons := true # depreciated?
var alreadychanged := false

var config: ConfigFile

var info_mode := false # if the Cursor is in info_mode
var options_unlocked := false # if options are clickable
var first_round := true
var missingPic = null
var lastMissingPic = null
var pic_text_status :int = 0	# 0 = only text
								# 1 = only picture
								# 2 = picture & text
var button_pictures :bool = false

var current_tooltip
var cur_language_nr : int
var LANGUAGES

var picArray := []
# contains the currently running Set

var pics := []
# 0 ... selected (bool)
# 1 ... texturepath (String)
# 2 ... texture (Texture)
# 3 ... translation (String)

var pic_folders := [] # path

var category = null
var true_random := false
var randomize_between_rounds := false
var shake := false
var wrong_guesses := 0
var cur_rounds := 1 #the current round
var rounds := 3 #the selected round setting
var varieties := 8 #the selected maximum varieties setting
const MAX_VARIETIES := 12 #hardcoded maximum varietes
const MAX_ROUNDS := 10 #hardcoded maximum rounds

const BUTTON := preload("res://scenes/button.tscn")
const OPTION_PICTURE_BUTTON := preload("res://scenes/option_picture_button.tscn")
const TOOLTIP := preload("res://scenes/tooltip.tscn")
const PICTURE := preload("res://scenes/picture.tscn")

const DIRNAMEPICS = "pictures"
const DIRNAMEFONT = "font"
const DIRNAMEINI = "config.ini"
const DIRNAMEFOLDER = "user://pareido_data"

var font_override: FontFile

var scene_current = null
const SCENE_MENU = "res://scenes/menu.tscn"
const SCENE_PLAYING = "res://scenes/game.tscn"
const SIMPLE_CHOICE := "res://scenes/simple_choice.tscn"
const SCENE_OPTIONS = "res://scenes/options.tscn"

const TARGET :int = 160 # Target size for all sprites
const POS_VAR :int = 25 # random position variance of sprites
const MAX_ROTATION :float = deg_to_rad(45) # max degree that sprites are rotated
var flip_pics := false
var directory

func _ready() -> void:
	await get_tree().process_frame
	randomize()
	starttime = Time.get_unix_time_from_system()
	for i in range(threadcount):
		threadArray.append(Thread.new())
	var directory_script = load("res://scripts/directorys.gd")
	
	directory = directory_script.new()
	
	LANGUAGES = TranslationServer.get_loaded_locales()
	TranslationServer.set_locale("de")
	
	cur_language_nr = TranslationServer.get_loaded_locales().find(TranslationServer.get_locale())
	
	var executeable_path :String = OS.get_executable_path().get_base_dir()
	print_debug(executeable_path)
	directory.create_dir(executeable_path)
	starttime = Time.get_unix_time_from_system()
	print("Loading started: " + str(starttime))
	load_resources()
	print("Loading finished: " + str(Time.get_unix_time_from_system() - starttime))

func load_resources():
	pic_folders.clear()
	pics.clear()
	directory.load_resources("user://pareido_data/pictures")
	var count = Singleton.pics.size()
	for i in range(threadcount):
		threadArray[i].start(load_multithread_pics.bind(
				count * i / threadcount, (count * (i + 1) / threadcount) - 1))

func load_multithread_pics(start:int , finish:int) -> void:
	for i in range(start, finish + 1):
		load_pic(i)
	print("Thread finished: " + str(Time.get_unix_time_from_system() - starttime))
	

func load_pic(i :int) -> Texture:
	if Singleton.pics[i][2] != null:
		return Singleton.pics[i][2]
	elif Singleton.pics[i][1] != null:
		var image = Image.load_from_file(Singleton.pics[i][1])
		var texture = ImageTexture.create_from_image(image)
		Singleton.pics[i][2] = texture
		return texture
	else:
		return null

func create_tooltip(mouse_pos : Vector2, text :String) -> void:
	if current_tooltip:
		current_tooltip.free()
	current_tooltip = TOOLTIP.instantiate()
	current_tooltip.init(mouse_pos, text)
	get_tree().get_root().add_child(current_tooltip)


func exit_game() -> void:
	#TODO write settings to config?
	get_tree().quit()


func goto_scene(future_scene) -> void:
	# This function will usually be called from a signal callback,
	# or some other function in the current scene.
	# Deleting the current scene at this point is
	# a bad idea, because it may still be executing code.
	# This will result in a crash or unexpected behavior.

	# The solution is to defer the load to a later time, when
	# we can be sure that no code from the current scene is running:
	_deferred_goto_scene.call_deferred(future_scene)


func _deferred_goto_scene(future_scene) -> void:
	# It is now safe to remove the current scene.
	scene_current.free()
	# Load the new scene.
	var s = ResourceLoader.load(future_scene)
	# Instance the new scene.
	scene_current = s.instantiate()
	# Add it to the active scene, as child of root.
	get_tree().root.add_child(scene_current)
	# Optionally, to make it compatible with the SceneTree.change_scene_to_file() API.
	# get_tree().scene_current = scene_current
