extends Control

var ingame :bool = false

export(NodePath) var gameModeParentPath
export(NodePath) var viewportGamePath
export(NodePath) var viewportContainerPath
export(NodePath) var gameModeUIPath
var gameModeParent : Node
var viewportGame : Viewport
var viewportContainer : ViewportContainer
var gameModeUI : Control

var loader
var wait_frames
var time_max = 10

var pathGame : String
var pathHud : String

var err : int

var renderQuality : float = 1
var resWidth : int
var resHeight : int
var notDefaultRes : bool = false

func _ready():
	gameModeParent = get_node(gameModeParentPath)
	viewportGame = get_node(viewportGamePath)
	viewportContainer = get_node(viewportContainerPath)
	gameModeUI = get_node(gameModeUIPath)
	err = $PlayerMenu.connect("continuePressed", self, "_closePlayerMenu")
	err = $PlayerMenu.connect("optionsPressed", self, "_getInOptions")
	err = $PlayerMenu.connect("quitPressed", self, "_quitToMenu")
	err = $MainMenu.connect("optionsPressed", self, "_getInOptions")
	err = $MainMenu.connect("playPressed", self, "_startGame")
	err = $MainMenu.connect("nextPressed", self, "_nextGameMode")
	err = $MainMenu.connect("previousPressed", self, "_previousGameMode")
	err = $OptionsMenu.connect("backPressed", self, "_getOutOptions")
	err = $OptionsMenu.connect("badQualitySet", self, "_setBadQuality")
	err = $"/root".connect("size_changed", self, "_resizeGameview")
	err = $OptionsMenu.connect("fullscreen", self, "_setFullscreen")
	err = $OptionsMenu.connect("vsync", self, "_vsync")
	err = $OptionsMenu.connect("updateMouseSens", self, "_setMouseSens")
	err = $OptionsMenu.connect("setMaxFps", self, "_setMaxFps")
	err = $OptionsMenu.connect("setNewMaxFps", self, "_resetMaxFps")
	err = $MainMenu/HBoxContainer/TabContainer/MinTiles.connect("item_selected", self, "_setLevel")
	err = $MainMenu/HBoxContainer/TabContainer/Other.connect("item_selected", self, "_setLevel")
	err = $OptionsMenu.connect("updateResolution", self, "_setResolution")
	err = $MainMenu/HBoxContainer/TabContainer.connect("tab_selected", self, "_selectGameMode")
	
	if err:
		printerr("connect menu signals error")
	#_initialMenuSetup()
	$OptionsMenu._loadSettings()
	_setBackground()
	_fillMinTilesLevelList()
	_fillOtherList()
	
func _selectGameMode(id):
	Config.selectedLevel = 0
	Config.selectedGameMode = id

func _fillMinTilesLevelList():
	var i : int = 0
	while i < Config.minTilesLevel.size():
		$MainMenu._addMinTilesItem(Config.minTilesLevelName[i], Config.minTilesPreviews[i])
		i += 1
	
	$MainMenu._selectItem(0)
	
func _fillOtherList():
	var i : int = 0
	while i < Config.otherLevel.size():
		$MainMenu._addOtherItem(Config.otherLevelName[i], Config.otherLevelPreviews[i])
		i += 1

func _setBackground() -> void:
	$Background.set_size(OS.get_real_window_size())
	$Background.set_anchors_and_margins_preset(Control.PRESET_CENTER, Control.PRESET_MODE_KEEP_SIZE)

###--- Menu Navigation ---###
func _on_OptionsMenu_backPressed() -> void:
	_getOutOptions()

func _unhandled_key_input(event):
	if event.is_action_pressed("ui_cancel"):
		if ingame:
			if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
				$"..".move_child($"../Menus", 2)
				_openPlayerMenu()
			else:
				_closePlayerMenu()

func _openPlayerMenu() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$PlayerMenu.visible = true
	get_tree().paused = true
	$Background.visible = true
	self.pause_mode = Node.PAUSE_MODE_PROCESS

func _closePlayerMenu() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false
	$PlayerMenu.visible = false
	$OptionsMenu.visible = false
	$Background.visible = false

func _getOutOptions() -> void:
	if ingame:
		$OptionsMenu.visible = false
		$PlayerMenu.visible = true

	else: 
		$MainMenu.visible = true
		$OptionsMenu.visible = false

func _getInOptions() -> void:
	if ingame:
		$PlayerMenu.visible = false
		$OptionsMenu.visible = true
	else:
		$MainMenu.visible = false
		$OptionsMenu.visible = true

####----Set Options ---###

func _setResolution(var id : int):
	notDefaultRes = true
	match id:
		0:
			notDefaultRes = false
		1:
			resWidth = 2560
			resHeight = 1440
		2:
			resWidth = 1920
			resHeight = 1200
		
		3: 
			resWidth = 1920
			resHeight = 1080
		4:
			resWidth = 1680
			resHeight = 1050
		5:
			resWidth = 1600
			resHeight = 900
		6: 
			resWidth = 1440
			resHeight = 900
		7:
			resWidth = 1360
			resHeight = 768
		8:
			resWidth = 1280
			resHeight = 1024
		9:
			resWidth = 1280
			resHeight = 800
		10:
			resWidth = 1280
			resHeight = 720
		11: 
			resWidth = 1024
			resHeight = 768
		12:
			resWidth = 800
			resHeight = 600 
	Config._saveSomethingInConfig("Settings", "Resolution", id)
	_resizeGameview()

func _setBadQuality(var newVal : float) -> void:
	renderQuality = newVal
	Config._saveSomethingInConfig("Settings", "RenderQuality", newVal)
	_resizeGameview()
	
func _resizeGameview() -> void:
	if notDefaultRes:
		get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT, SceneTree.STRETCH_ASPECT_IGNORE, Vector2(resWidth, resHeight), 1)
		viewportGame.size = Vector2(resWidth, resHeight) * renderQuality
		viewportContainer.rect_size = Vector2(resWidth,resHeight)
	else:
		get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_DISABLED, SceneTree.STRETCH_ASPECT_IGNORE, OS.get_real_window_size(), 1)
		viewportGame.size = OS.get_real_window_size() * renderQuality
		viewportContainer.rect_size = OS.get_real_window_size()
	_setBackground()

func _vsync(var vsync : bool) -> void:
	OS.vsync_enabled = vsync
	Config._saveSomethingInConfig("Settings", "vsync", vsync)
	
func _setFullscreen(var val : bool) -> void:
	OS.window_fullscreen = val
	Config._saveSomethingInConfig("Settings", "fullscreen", val)

func _setMouseSens(var val : float) -> void:
	Config.mouseSens = val
	Config._saveSomethingInConfig("Settings", "mouseSensitivity", val)

func _setMaxFps(var val : bool) -> void:
	$OptionsMenu._maxFpsEditable(val)
	Config._saveSomethingInConfig("Settings", "maxFpsOn", val)
	if val:
		var newVal : int = Config._loadSomethingFromConfig("Settings", "maxFps")
		if newVal != null:
			_resetMaxFps(newVal)
		else:
			_resetMaxFps(60)
	else: 
		_resetMaxFps(0)
	
func _resetMaxFps(var val : int) -> void:
	Engine.target_fps = val
	Config._saveSomethingInConfig("Settings", "maxFps", val)

func _quitToMenu() -> void:
	gameModeParent.get_child(0).free()
	gameModeUI.get_child(0).free()
	$MainMenu.visible = true
	$PlayerMenu.visible = false
	ingame = false
	get_tree().paused = false
	Config._saveConfig()
	
func _startGame() -> void: 
	gameModeUI.add_child(Config._getHud())
	gameModeParent.add_child(Config._getScene())
	
	_resizeGameview()
	$"..".move_child($"../Menus", 1)
	
	ingame = true
	$MainMenu.visible = false
	$OptionsMenu.visible = false
	$Background.visible = false

#func _loadScene():
#	loader = ResourceLoader.load_interactive(pathGame)
#	set_process(true)
#	$LoadingScreen.visible = true
#	wait_frames = 1
#
#func _process(time):
#	if loader == null:
#		set_process(false)
#		return
#	if wait_frames > 0:
#		wait_frames -= 1
#		return
#
#	var t = OS.get_ticks_msec()
#	while OS.get_ticks_msec() < t + time_max:
#		var err = loader.poll()
#
#		if err == ERR_FILE_EOF:
#			var resource = loader.get_resource()
#			loader = null
#			gameModeParent.add_child(resource.instance())
#			$LoadingScreen.visible = false
#			break
#		elif err == OK:
#			_updateProgress()
#
#func _updateProgress():
#	print(loader.get_stage_count())
#	var progress = float(loader.get_stage()) / loader.get_stage_count()
#	print(progress)
#	$LoadingScreen/ProgressBar.percent_visible = progress * 100
	

func _setLevel(var index : int):
	Config.selectedLevel = index
