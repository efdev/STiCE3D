extends TextureButton

export(PackedScene) var sceneToShowOnPress = null
export(NodePath) var whereToAddTheScene = null
export(NodePath) var shouldInvisibleOnResume = null
var whereToAddTheSceneNode: Node
export(bool) var playButton = false

var sceneInstance

func _unhandled_key_input(event):
	if(event.is_action_pressed("ui_cancel")):
		if(shouldInvisibleOnResume != null):
			if(get_node(shouldInvisibleOnResume).visible == true):
				get_node(shouldInvisibleOnResume).visible = false
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				_clearOtherMenu()
				get_tree().paused = false
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				get_node(shouldInvisibleOnResume).visible = true
				get_tree().paused = true
				self.pause_mode = Node.PAUSE_MODE_PROCESS

func _ready():
	if(playButton):
		self.grab_focus()
	if(whereToAddTheScene != null):
		whereToAddTheSceneNode = get_node(whereToAddTheScene)
	else:
		printerr(self.name + ": whereToAddTheScene is not set")
		
	#instance the scene
	if(sceneToShowOnPress != null):
		sceneInstance = sceneToShowOnPress.instance()

#clears the other menu section befor the new UI scene is added 
func _clearOtherMenu():
	if(whereToAddTheSceneNode.get_child_count() > 0):
		get_node(whereToAddTheScene).remove_child(get_node(whereToAddTheScene).get_child(0))

func _on_playButton_pressed():
	if(whereToAddTheScene != null):
		_clearOtherMenu()
		if(sceneToShowOnPress != null):
			get_node(whereToAddTheScene).add_child(sceneToShowOnPress.instance())
			Settings._setNewRenderQuality()

func _on_optionsButton_pressed():
	if(whereToAddTheScene != null):
		_clearOtherMenu()
		get_node(whereToAddTheScene).add_child(sceneInstance)

func _on_exitButton_pressed():
	get_tree().paused = false
	get_tree().quit() #closes the game
	
func _setOtherMenuTo(newMenu):
	if(whereToAddTheScene != null):
		_clearOtherMenu()
		get_node(whereToAddTheScene).add_child(newMenu)


func _on_resumeButton_pressed():
	if(shouldInvisibleOnResume != null):
		get_tree().paused = false
		_clearOtherMenu()
		get_node(shouldInvisibleOnResume).visible = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
