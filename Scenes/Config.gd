extends Node

var mouseSens : float = 0.05

var config : ConfigFile
const path = "user://config.ini"

var gameModePaths : Array = []
var gameModePreviews : Array = []

var selectedLevel : int = 0
var selectedGameMode : int = 0

var minTilesPreviews : Array
var minTilesLevel : Array
var minTilesLevelName : Array

var otherLevelPreviews : Array
var otherLevel : Array
var otherLevelName : Array
var otherHud : Array

var defaultHUD : PackedScene

func _getGameModeName():
	match selectedGameMode:
		0:
			return minTilesLevelName[selectedLevel]
		1: 
			return otherLevelName[selectedLevel]

func _ready():
	defaultHUD = preload("res://LevelDefaults/DefaultHUD/DefHud.tscn")
	config = ConfigFile.new()
	var err : int = config.load(path)
	if err == ERR_FILE_NOT_FOUND:
		_saveConfig()
	
	var modFolder : Directory = Directory.new()
	if not modFolder.dir_exists("user://Mods"):
		modFolder.make_dir("user://Mods")
	_loadMinTiles()
	_loadMinTilesPreviews()
	_loadOtherLevel()
	_loadOtherPreviews()
	print(minTilesLevel)
	print(minTilesLevelName)
	print(minTilesPreviews)
	print(otherHud)
	print(otherLevel)
	print(otherLevelName)
	print(otherLevelPreviews)
	#_loadGameModeScenes()
	#_loadMods()
	#_loadPreviews()
func _getHud():
	match selectedGameMode:
		0:
			return defaultHUD.instance()
		1: 
			return otherHud[selectedLevel].instance()
func _getScene():
	match selectedGameMode:
		0:
			return minTilesLevel[selectedLevel].instance()
		1:
			return otherLevel[selectedLevel].instance()

func _loadPreviews() -> void:
	#var checkFile : File = File.new()
	var checkDir : Directory = Directory.new()
	#checkDir.open("res://GameModes/GameModeName")
	checkDir.list_dir_begin(true, true)
	var dirName : String = checkDir.get_next()
	while dirName != "":
		dirName = checkDir.get_next()
	var checkFile : File = File.new()
	for x in Config.gameModePaths : 
		var preview : Texture = load( "res://GameModes/" + x + "/" + x + ".png")
		print(load( "res://GameModes/" + x + "/" + x + ".png"))
		if preview != null:
			gameModePreviews.push_back(preview)
		else:
			var defaultPreview : Texture = preload("res://Textures/new_noisetexture.tres")
			gameModePreviews.push_back(defaultPreview)
			
func _loadMinTiles() -> void:
	var minTilesDir : Directory = Directory.new()
	minTilesDir.open("res://GameModes/MinTiles")
	minTilesDir.list_dir_begin(true, false)
	var levelName : String = minTilesDir.get_next()
	while levelName != "":
		var scene : Resource = load("res://GameModes/MinTiles/" + levelName + "/" + levelName + ".tscn")
		minTilesLevel.push_back(scene)
		minTilesLevelName.push_back(levelName)
		levelName = minTilesDir.get_next()

func _loadOtherLevel() -> void:
	var otherDir : Directory = Directory.new()
	otherDir.open("res://GameModes/Other")
	otherDir.list_dir_begin(true, false)
	var levelName : String = otherDir.get_next()
	while levelName != "":
		var scene : Resource = load("res://GameModes/Other/" + levelName + "/" + levelName + ".tscn")
		var hud : Resource = load("res://GameModes/Other/" + levelName + "/HUD/" + levelName + ".tscn")
		if hud != null:
			otherHud.push_back(hud)
		else: 
			otherHud.push_back(defaultHUD)
		otherLevel.push_back(scene)
		otherLevelName.push_back(levelName)
		levelName = otherDir.get_next()

func _loadOtherPreviews() -> void:
	var otherDir : Directory = Directory.new()
	otherDir.open("res://GameModes/Other")
	otherDir.list_dir_begin(true, false)
	var levelName : String = otherDir.get_next()
	while levelName != "":
		var preview : Texture = load("res://GameModes/Other/" + levelName + "/" + levelName + ".png")
		if preview != null:
			otherLevelPreviews.push_back(preview)
		else:
			var defaultPreview : Texture = preload("res://Textures/new_noisetexture.tres")
			otherLevelPreviews.push_back(defaultPreview)
		levelName = otherDir.get_next()

func _loadMinTilesPreviews() -> void:
	var minTilesDir : Directory = Directory.new()
	minTilesDir.open("res://GameModes/MinTiles")
	minTilesDir.list_dir_begin(true, false)
	var levelName : String = minTilesDir.get_next()
	while levelName != "":
		var preview : Texture = load("res://GameModes/MinTiles/" + levelName + "/" + levelName + ".png")
		if preview != null:
			minTilesPreviews.push_back(preview)
		else:
			var defaultPreview : Texture = preload("res://Textures/new_noisetexture.tres")
			minTilesPreviews.push_back(defaultPreview)
		levelName = minTilesDir.get_next()
			
func _loadGameModeScenes() -> void:
	var gameModeDir : Directory = Directory.new()
	gameModeDir.open("res://GameModes")
	gameModeDir.list_dir_begin(true, false)
	var gameModeName : String = gameModeDir.get_next()
	while gameModeName != "":
		gameModePaths.push_back(gameModeName)
		gameModeName = gameModeDir.get_next()
		
func _loadMods() -> void:
	var modFolder : Directory = Directory.new()
	modFolder.open("user://Mods")
	modFolder.list_dir_begin(true, true)
	var modToLoad : String = modFolder.get_next()
	while modToLoad!= "":
		print(ProjectSettings.load_resource_pack("user://Mods/" + modToLoad, true))
		gameModePaths.push_back(modToLoad.rstrip(".pck"))
		modToLoad = modFolder.get_next()

func _saveSomethingInConfig(var section : String, var keyName : String ,var val) -> void:
	config.set_value(section, keyName, val)
		
func _loadSomethingFromConfig(var section : String, var keyName : String):
	return config.get_value(section, keyName, null)
		
func _saveConfig() -> void:
	config.save(path)
