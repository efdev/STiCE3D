extends Control

var path
const SERVER_PORT = 5000
# Called when the node enters the scene tree for the first time.
func _ready():
	$MouseSens.set_text(String(playerAttributes.mouseSensitivity))
	
	get_tree().connect("network_peer_connected",self,"_player_connected")
	get_tree().connect("network_peer_disconnected",self,"_player_disconnected")
	get_tree().connect("connected_to_server",self,"_connected_ok")
	get_tree().connect("connection_failed",self,"_connected_fail")
	get_tree().connect("server_disconnected",self,"_server_disconnected")
	
func _on_Button_pressed():
	##this is from before the map is generated through a gridMap ##
	path = $Path.get_text()
	var fileCheck = File.new()	#opens a new file
	if fileCheck.file_exists(path):
		var sceneToLoad = load(path) #loads the scene
		var scene = sceneToLoad.instance() #instances the loaded content
		get_tree().get_root().add_child(scene)

	else:	#if this file not exists popup the error message
		$Error.popup()	#popup the error popup

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	procInput()
	
func procInput():
		if Input.is_action_just_pressed("ui_cancel") && visible == true:	#if this assgined key is pressed and the menu is visible
			if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:	#if the mouse is visible
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)	#capture the mouse(and make the mouse invisble)
				visible = false	#make the menu invisble
				playerAttributes.mouseSensitivity = $MouseSens.get_text().to_float()
				get_viewport().set_size(Vector2($width.get_text().to_int(), $height.get_text().to_int())) #set veiwport resolution but im still confused from viewports and this resolution stuff

		elif Input.is_action_just_pressed("ui_cancel") && visible == false:		#if key is pressed and menu not visible 
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)	#make the mouse visible
			visible = true	#and the menu visible

func _on_Button_close_pressed():
	get_tree().quit() #close the game

remote func register_player():
	playerAttributes.player2IDs.push_back(get_tree().get_rpc_sender_id()) 	#add network id
	print(playerAttributes.player2IDs)
	for i in get_node("/root/Game/Players").get_children():
		i.free()
		
	var selfPeerID = get_tree().get_network_unique_id()
	var my_player = preload("res://Scenes/Player/Player.tscn").instance()
	my_player.set_name(str(selfPeerID))
	my_player.set_network_master(selfPeerID) # The player belongs to this peer; it has the authority.
	get_node("/root/Game/Players").add_child(my_player)

	for ids in playerAttributes.player2IDs:
		var Player2 = load("res://Scenes/Player/Player2.tscn").instance() #instance a dummy because im to stupid to setup the normal player controller right
		Player2.set_name(str(ids))	#set the name to the unique network id
		Player2.set_network_master(ids)	#set the mast of this dummy to the right client
		get_node("/root/Game/Players").add_child(Player2)
	
	if not get_tree().is_network_server():
		rpc_id(1, "ready_to_start", get_tree().get_network_unique_id())

var readyIDs = []

remote func ready_to_start(var id):
	#send every player the host map and rebuild it there
	assert(get_tree().is_network_server())

	if not id in readyIDs:
		readyIDs.append(id)

	if readyIDs.size() == playerAttributes.player2IDs.size():
		for id in readyIDs:
			rpc_id(id, "rebuild_map", var2str(coordinates.gridMap.get_used_cells()))
			coordinates._move_pickable()
		
remote func rebuild_map(var gridMap):
	var usedCells = str2var(gridMap)
	print(gridMap)
	coordinates._rebuildMap(usedCells)

func _player_connected(id):
	rpc_id(id, "register_player")


func _player_disconnected(id):
	get_node("/root/Game/Players/"+str(id)).free()

# callback from SceneTree, only for clients (not server)
func _connected_ok():
	# will not use this one
	pass
	
# callback from SceneTree, only for clients (not server)	
func _connected_fail():
	print("connect failed")

func _server_disconnected():
	for player in playerAttributes.player2IDs:
		get_node("/root/Game/Players/"+str(player)).free()
	print("server disconnected")


func _on_Connect_pressed():
	print("connecting")
	var SERVER_IP = $IP.get_text()
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(SERVER_IP, SERVER_PORT)
	get_tree().set_network_peer(peer)
	playerAttributes.MultiPlayer = true


func _on_Host_pressed():
	print("Host pressed")
	var host = NetworkedMultiplayerENet.new()
	host.create_server(SERVER_PORT, 3)
	get_tree().set_network_peer(host)
	playerAttributes.MultiPlayer = true