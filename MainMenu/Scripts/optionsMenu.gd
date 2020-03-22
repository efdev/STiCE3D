extends Control

export(NodePath) var fullscreenPath = null
export(NodePath) var vSyncPath = null
export(NodePath) var fpsLimitPath = null
export(NodePath) var mouseSensPath = null
export(NodePath) var renderQualityPath = null
export(NodePath) var resolutionPath = null
export(NodePath) var fovPath = null

func _loadFullscreen():
	if(fullscreenPath != null):
		get_node(fullscreenPath).pressed =  Settings.configFile.get_value("Settings", "Fullscreen", false)

func _loadVSync():
	if(vSyncPath != null):
		get_node(vSyncPath).pressed = Settings.configFile.get_value("Settings", "vSync", true)

func _loadFpsLimit():
	if(fpsLimitPath != null):
		var ret = Settings.configFile.get_value("Settings", "FPSLimit", "0")
		get_node(fpsLimitPath).text = ret
		get_node(fpsLimitPath).emit_signal("text_entered", ret)

func _loadMouseSens():			
	if(mouseSensPath != null):
		var ret = Settings.configFile.get_value("Settings", "MouseSensitivity", 0.05)
		get_node(mouseSensPath).value = ret
		Settings.mouseSens = ret

func _loadRenderQuality():
	if(renderQualityPath != null):
		var ret = Settings.configFile.get_value("Settings", "RenderQuality", 1)
		get_node(renderQualityPath).value = ret
		Settings.renderQuality = ret
		Settings._setNewRenderQuality()

func _loadResolution():
	if(resolutionPath != null):
		var ret = Settings.configFile.get_value("Settings", "Resolution", 3)
		_on_resolutionOptionButton_item_selected(ret)
		get_node(resolutionPath).selected = ret
		
func _loadFov():
	if(fovPath != null):
		var ret = Settings.configFile.get_value("Settings", "FOV", "75")
		Settings.FOV = ret
		get_node(fovPath).text = String(ret)



func _reloadSettings():
	_loadFullscreen()
	_loadVSync()
	_loadFpsLimit()
	_loadMouseSens()
	_loadRenderQuality()
	_loadResolution()
	_loadFov()

func _notification(what):
	match what:
		NOTIFICATION_INSTANCED:
			_reloadSettings()
	
export(NodePath) var popupPath = null
export(NodePath) var errorMessagePath = null

func _popupError(message: String):
	if(errorMessagePath != null):
		get_node(errorMessagePath).text = message
	if(popupPath != null):
		get_node(popupPath).popup()

func _on_vSyncCheckBox_toggled(button_pressed):
	OS.vsync_enabled = button_pressed
	if(Settings._saveInSettings("Settings", "vSync", button_pressed) != OK):
		_popupError("Error on saving Settings")

func _on_renderQualitySlider_value_changed(value):
	Settings.renderQuality = value
	Settings._setNewRenderQuality()
	if(Settings._saveInSettings("Settings", "Render Quality", value) != OK):
		_popupError("Error on saving Settings")

func _on_resolutionOptionButton_item_selected(id):
	Settings.automaticRes = false
	match id:
		3:
			Settings.automaticRes = true
		0:
			Settings.resWidth = 2560
			Settings.resHeight = 1440
		1:
			Settings.resWidth = 1920
			Settings.resHeight = 1200
		
		2: 
			Settings.resWidth = 1920
			Settings.resHeight = 1080
#		4:
#			resWidth = 1680
#			resHeight = 1050
#		5:
#			resWidth = 1600
#			resHeight = 900
#		6: 
#			resWidth = 1440
#			resHeight = 900
#		7:
#			resWidth = 1360
#			resHeight = 768
#		8:
#			resWidth = 1280
#			resHeight = 1024
#		9:
#			resWidth = 1280
#			resHeight = 800
#		10:
#			resWidth = 1280
#			resHeight = 720
#		11: 
#			resWidth = 1024
#			resHeight = 768
#		12:
#			resWidth = 800
#			resHeight = 600 
	Settings._setNewRenderQuality()
	if(Settings._saveInSettings("Settings", "Resolution", id) != OK):
		_popupError("Error on saving Settings")

func _on_mouseSensSlider_value_changed(value):
	Settings.mouseSens = value
	if(Settings._saveInSettings("Settings", "Mouse Sensitivity", value) != OK):
		_popupError("Error on saving Settings")

func _on_fullscreenCheckBox_toggled(button_pressed):
	OS.window_fullscreen = button_pressed
	if(Settings._saveInSettings("Settings", "Fullscreen", button_pressed) != OK):
		_popupError("Error on saving Settings")
	Settings._setNewRenderQuality()

func _on_fovInput_text_entered(value):
	var temp = value.to_int()
	if(temp > 140):
		temp = 140
	elif(temp < 50):
		temp = 50
	
	if(Settings._saveInSettings("Settings", "FOV", temp) != OK):
		_popupError("Error on saving Settings")
	Settings.FOV = temp
	if(Settings.currentCamera != null):
		Settings.currentCamera.fov = temp


func _on_fpsLimitInput_text_entered(value):
	Engine.target_fps = value.to_int()
	if(Settings._saveInSettings("Settings", "FPS Limit", value) != OK):
		_popupError("Error on saving Settings")
