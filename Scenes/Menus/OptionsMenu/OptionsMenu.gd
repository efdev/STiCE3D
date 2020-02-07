extends Control

signal backPressed
signal badQualitySet
signal vsync
signal fullscreen
signal setNewMaxFps
signal setMaxFps
signal updateMouseSens
signal updateResolution

var err : int

func _ready():
	err = $hbox/Back.connect("button_down", self, "_backButtonPressed")
	err = $hbox/OptionName/vsync/VSYNC.connect("toggled", self, "_VSYNC")
	err = $hbox/OptionName/MaxFps/vbox/MaxFps_trig.connect("toggled", self, "_forceFPS")
	err = $hbox/OptionName/MaxFps/vbox/MaxFps.connect("text_entered", self, "_forceFPSUpdate")
	err = $hbox/OptionName/MouseSens/MouseSens.connect("text_changed", self, "_updateMouseSens")
	err = $hbox/OptionName/Fullscreen/Fullscreen.connect("toggled", self, "_setFullscreen")
	err = $hbox/OptionName/RenderQuality/Quality.connect("value_changed", self, "_setRenderQuality")
	err = $hbox/OptionName/Resolution/ResolutionChoice.connect("item_selected", self, "_setResolution")
	
func _setResolution(var id : int):
	emit_signal("updateResolution", id)
	
func _loadSettings() -> void:
	var val = Config._loadSomethingFromConfig("Settings", "RenderQuality")
	if val != null:
		$hbox/OptionName/RenderQuality/Quality.value = val
		_setRenderQuality(val)
		
	val = Config._loadSomethingFromConfig("Settings", "maxFps")
	if val != null:
		$hbox/OptionName/MaxFps/vbox/MaxFps.text = String(val)
		_forceFPSUpdate(String(val))
	
	val = Config._loadSomethingFromConfig("Settings", "maxFpsOn")
	if val != null:
		$hbox/OptionName/MaxFps/vbox/MaxFps_trig.pressed = val
		$hbox/OptionName/MaxFps/vbox/MaxFps.editable = val
		_forceFPS(val)
	
	val = Config._loadSomethingFromConfig("Settings", "vsync")
	if val != null:
		$hbox/OptionName/vsync/VSYNC.pressed = val
		_VSYNC(val)
	
	val = Config._loadSomethingFromConfig("Settings", "fullscreen")
	if val != null:
		$hbox/OptionName/Fullscreen/Fullscreen.pressed = val
		_setFullscreen(val)
	
	val = Config._loadSomethingFromConfig("Settings", "mouseSensitivity")
	if val != null:
		$hbox/OptionName/MouseSens/MouseSens.text = String(val)
		_updateMouseSens(String(val))

	val = Config._loadSomethingFromConfig("Settings", "Resolution")
	if val != null:
		$hbox/OptionName/Resolution/ResolutionChoice.select(val)
		_setResolution(val)
		
func _maxFpsEditable(var val :bool) -> void:
	$hbox/OptionName/MaxFps/vbox/MaxFps.editable = val
	
func _setRenderQuality(var setQuality: float) -> void:
	emit_signal("badQualitySet", setQuality)
	
func _setFullscreen(var fullscreen : bool) -> void:
	emit_signal("fullscreen", fullscreen)

func _backButtonPressed() -> void:
	emit_signal("backPressed")
	
func _VSYNC(var vsync : bool) -> void:
	emit_signal("vsync", vsync)
	
func _forceFPSUpdate(var newMaxFps : String) -> void:
	var fps : int = newMaxFps.to_int()
	if fps < 30:
		return
	else:
		emit_signal("setNewMaxFps", fps)
	
func _forceFPS(var force : bool) -> void:
	emit_signal("setMaxFps", force)

func _updateMouseSens(var mouseSens : String) -> void:
	emit_signal("updateMouseSens", mouseSens.to_float())

