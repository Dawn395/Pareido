extends Node

var starting_infobox := true
var running := false
var side_buttons := true # depreciated?
var alreadychanged := false

var config: ConfigFile

var info_mode := false # if the Cursor is in info_mode
var options_unlocked := false # if options are clickable
var missingVeg := -1
var pic_button_status :int = 0	# 0 = only text
								# 1 = only picture
								# 2 = picture & text


var current_tooltip
var cur_language_nr : int
var LANGUAGES

var pics := [] #  category, path, translation

var pics_new := [] # selected, path, translation
var pic_folders := [] # path

#var tree :Tree = null

var category = null
var true_random := false
var cur_rounds := 1 #the current round
var max_rounds := 3 #the selected maximum round setting
var varieties := 8 #the selected maximum varieties setting
const MAX_VARIETIES := 12 #hardcoded maximum varietes
const MAX_ROUNDS := 10 #hardcoded maximum rounds

const BUTTON := preload("res://scenes/button.tscn")
const TOOLTIP := preload("res://scenes/tooltip.tscn")
const PICTURE := preload("res://scenes/picture.tscn")

const DIRNAMEPICS = "pictures"
const DIRNAMEFONT = "font"
const DIRNAMEINI = "config.ini"
const DIRNAMEFOLDER = "user://pareido_data"

#const SCENES := [
		#[preload("res://scenes/vegies/basil.tscn"), "tr_basil",],
		#[preload("res://scenes/vegies/broccoli.tscn"), "tr_broccoli",],
		#[preload("res://scenes/vegies/carrot.tscn"), "tr_carrot",],
		#[preload("res://scenes/vegies/chanterelle.tscn"), "tr_chanterelle",],
		#[preload("res://scenes/vegies/eggplant.tscn"), "tr_eggplant",],
		#[preload("res://scenes/vegies/garlic.tscn"), "tr_garlic",],
		#[preload("res://scenes/vegies/leek.tscn"), "tr_leek",],
		#[preload("res://scenes/vegies/paprika.tscn"), "tr_paprika",],
		#[preload("res://scenes/vegies/potato.tscn"), "tr_potato",],
		#[preload("res://scenes/vegies/pumpkin.tscn"), "tr_pumpkin",],
		#[preload("res://scenes/vegies/salad.tscn"), "tr_salad",],
		#[preload("res://scenes/vegies/scallion.tscn"), "tr_scallion",],
		#[preload("res://scenes/vegies/tomato.tscn"), "tr_tomato",],
		#[preload("res://scenes/vegies/zucchini.tscn"), "tr_zucchini",],
		#]

var font_override: FontFile

var scene_current = null
const SCENE_MENU = "res://scenes/menu.tscn"
const SCENE_PLAYING = "res://scenes/playing.tscn"
const SIMPLE_CHOICE := "res://scenes/simple_choice.tscn"
const SCENE_OPTIONS = "res://scenes/options.tscn"

const TARGET :int = 200 # Target size for all sprites
const POS_VAR :int = 50 # random position variance of sprites
const MAX_ROTATION :float = deg_to_rad(45) # max degree that sprites are rotated
var flip_pics := false

func _ready() -> void:
	randomize()
	await get_tree().process_frame
	var directory_script = load("res://scripts/directorys.gd")
	
	var directory = directory_script.new()
	
	LANGUAGES = TranslationServer.get_loaded_locales()
	#if OS.get_locale_language() in LANGUAGES:
		#TranslationServer.set_locale(OS.get_locale_language())
	#elif OS.get_locale() in LANGUAGES:
		#TranslationServer.set_locale(OS.get_locale())
	#else:
	TranslationServer.set_locale("de")
	
	cur_language_nr = TranslationServer.get_loaded_locales().find(TranslationServer.get_locale())
	#%FlagButton.icon = load("res://translations/%s" % tr("tr_picture_path"))
	
	var executeable_path :String = OS.get_executable_path().get_base_dir()
	print_debug(executeable_path)
	#match OS.get_name():
		#"Windows", "macOS", "Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD", "Android", "iOS",  :
	directory.create_dir(executeable_path)
	directory.load_resources("user://pareido_data/pictures")
	#"Android", "iOS", "Web":
		#directory.load_resources("res://art/pics/")


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
