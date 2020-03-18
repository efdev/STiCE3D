extends Node

export(NodePath) var gameViewportContainerPath: NodePath
export(NodePath) var gameViewportPath: NodePath
export(NodePath) var userInterfacePath: NodePath
export(NodePath) var mainMenuPath: NodePath

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true
	self.pause_mode = Node.PAUSE_MODE_PROCESS
	
	Settings.viewportContainer = get_node(gameViewportContainerPath)
	Settings.viewportGame = get_node(gameViewportPath)
	Settings.userInterface = get_node(userInterfacePath)
	Settings.mainMenu = get_node(mainMenuPath)
	Settings._setNewRenderQuality()

