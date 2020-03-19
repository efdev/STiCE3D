extends Control

const pathGameModes = "user://gameModes.ini"
var gameModeFile : ConfigFile
export(NodePath) var previewLabel = null
export(NodePath) var gameModeDescription = null
export(NodePath) var previewPicture = null

var currentGameMode = 0
var gameModes
var gameModeCount

func _setPreview(var gameMode):
	if(gameMode != null):
		if(previewLabel != null):
			get_node(previewLabel).text = gameMode
		if(gameModeDescription != null):
			get_node(gameModeDescription).text = gameModeFile.get_value(gameMode, "Description", "No description is given")
		if(previewPicture != null):
			var path = gameModeFile.get_value(gameMode, "previewPath", "nope")
			if(ResourceLoader.exists(path)):
				var picture = load(path)
				get_node(previewPicture).set_texture(picture)
			else: 
				get_node(previewPicture).set_texture(null)

func _ready():
	gameModeFile = ConfigFile.new()
	var err : int = gameModeFile.load(pathGameModes)
	if err == ERR_FILE_NOT_FOUND:
		err = gameModeFile.save(pathGameModes)
	gameModeFile.set_value("DevDay", "Path", "res://GameModes/DevDay/")
	gameModeFile.set_value("DevDay", "Description", "This is a simple generated map for testing purpose."+
													"The UI only counts the collected points and every" +
													"five collected points the map is new generated.")
	gameModeFile.set_value("DevDay", "previewPath", "res://GameModes/DevDay/DevDay.png")
	gameModeFile.set_value("DevDay", "uiPath", "res://GameModes/DevDay/HUD/Scenes/DevDay.tscn")
	gameModeFile.set_value("DevDay", "gamePath", "res://GameModes/DevDay/DevDay.tscn")
	gameModeFile.set_value("DevDay", "anotherMenu", false)
	
	gameModeFile.set_value("DevNight", "Path", "res://GameModes/DevNight/")
	gameModeFile.set_value("DevNight", "Description", "This is a simple generated map for testing purpose."+
													"The UI only counts the collected points and every" +
													"five collected points the map is new generated.")
	gameModeFile.set_value("DevNight", "previewPath", "res://GameModes/DevNight/DevNight.png")
	gameModeFile.set_value("DevNight", "uiPath", "res://GameModes/DevNight/HUD/Scenes/DevNight.tscn")
	gameModeFile.set_value("DevNight", "gamePath", "res://GameModes/DevNight/DevNight.tscn")
	gameModeFile.set_value("DevNight", "anotherMenu", false)

	gameModes = gameModeFile.get_sections()
	gameModeCount = gameModes.size()
	print(gameModeCount)
	_setPreview(gameModes[currentGameMode])



func _on_arrowLeft_pressed():
	if(currentGameMode == 0):
		currentGameMode = gameModeCount-1
	else:
		currentGameMode -= 1
	_setPreview(gameModes[currentGameMode])


func _on_arrowRight_pressed():
	if(currentGameMode == (gameModeCount-1)):
		currentGameMode = 0
	else:
		currentGameMode += 1
	_setPreview(gameModes[currentGameMode])

func _on_selectButton_pressed():
	if(gameModeFile.get_value(gameModes[currentGameMode], "anotherMenu", false) == true):
		pass
		#mache anderen kram
	else:
		var path = gameModeFile.get_value(gameModes[currentGameMode], "gamePath", null)
		var pathUI = gameModeFile.get_value(gameModes[currentGameMode], "uiPath", null)
		if(path != null and pathUI != null):
			if(ResourceLoader.exists(path)):
				if(Settings.viewportGame.get_child_count() > 0):
					Settings.viewportGame.remove_child(Settings.viewportGame.get_child(0))
				if(Settings.userInterface.get_child_count() >0):
					Settings.userInterface.remove_child(Settings.userInterface.get_child(0))
					
				Settings.userInterface.add_child(load(pathUI).instance())
				Settings.ui = Settings.userInterface.get_child(0)
	
				Settings.viewportGame.add_child(load(path).instance())

				Settings.mainMenu._on_resumeButton_pressed()
			

		
		
		
	
