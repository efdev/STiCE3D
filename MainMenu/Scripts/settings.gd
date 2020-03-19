extends Node

var configFile : ConfigFile
var saveGames : ConfigFile
const path = "user://config.ini"
const saveGamesPath = "user://saveGame.ini"

func _saveInSettings(var section : String, var keyName : String ,var val) -> int:
	configFile.set_value(section, keyName, val)
	return _saveSettings()

func _loadFromSettings(var section : String, var keyName : String):
	return configFile.get_value(section, keyName, null)

func _saveSettings() -> int:
	var err = configFile.save(path)
	return err

func _ready():
	configFile = ConfigFile.new()
	var err : int = configFile.load(path)
	if err == ERR_FILE_NOT_FOUND:
		err = _saveSettings()
	
	saveGames = ConfigFile.new()
	err = saveGames.load(saveGamesPath)
	if err == ERR_FILE_NOT_FOUND:
		err = saveGames.save(saveGamesPath)

	var modFolder : Directory = Directory.new()
	if not modFolder.dir_exists("user://Mods"):
		err = modFolder.make_dir("user://Mods")

var mouseSens : float = 0.05
var renderQuality: float = 1
var automaticRes: bool = true
var resWidth: int
var resHeight: int
var viewportGame = null
var viewportContainer = null
var userInterface = null
var mainMenu = null
var ui = null
		
func _setNewRenderQuality():
	if !automaticRes:
		get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT, SceneTree.STRETCH_ASPECT_IGNORE, Vector2(resWidth, resHeight), 1)
		if(viewportGame != null):
			viewportGame.size = Vector2(resWidth, resHeight) * renderQuality
		if(viewportContainer != null):
			viewportContainer.rect_size = Vector2(resWidth,resHeight)
	else:
		get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_DISABLED, SceneTree.STRETCH_ASPECT_IGNORE, OS.get_real_window_size(), 1)
		if(viewportContainer != null):
			viewportContainer.rect_size = OS.get_real_window_size()
		if(viewportGame != null):
			viewportGame.size = OS.get_real_window_size() * renderQuality

