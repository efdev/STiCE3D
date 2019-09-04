extends Spatial
var gridCells = []	#helper for multiplayer
var gridMap  = null
var spawnCoordinates = []	#coordinate whera a pickable can spawn
var pickable	#the pickable 
var counter = 1
var tempCell	#helper for new map generation, "saves" the spot on which the player is.



func _ready():
	randomize()	#set a random seed

func _add_pickable(var picki):
		pickable = picki	#sets the pickable
		if pickable.visible == false:
			pickable.visible = true
	
func _move_pickable():
	if not playerAttributes.MultiPlayer:
		#new map generation is singleplayer only at this momement
		if playerAttributes.count == 5*counter:
			counter +=1	#every multiple of 5 the map is new generated 
			_newMap()
		elif  not spawnCoordinates.empty():
			spawnCoordinates.shuffle()
			tempCell = gridMap.world_to_map(spawnCoordinates.front())
			pickable.set_translation(spawnCoordinates.front()+ Vector3(0,-3,0))
		

	elif playerAttributes.MultiPlayer && get_tree().get_network_unique_id() == 1:
		#only the host can move the pickable and publish the new position to clients
		spawnCoordinates.shuffle()
		if  not spawnCoordinates.empty():
			pickable.set_translation(spawnCoordinates.front()+ Vector3(0,-3,0))
			for id in playerAttributes.player2IDs:
				#send every client the new position
				rpc_id(id, "move_pick_c", var2str(spawnCoordinates.front()+ Vector3(0,-3,0)))
	
	elif playerAttributes.MultiPlayer:
		#if a client is first, send the host to move the pickable
		rpc_id(1, "move_pick")

func _newMap():
	gridMap.clear() #clear all cells
	gridMap.set_cell_item(tempCell.x,tempCell.y-1,tempCell.z, 0, 0)	#set the spot where the player stands new
	spawnCoordinates.clear()	#remove all spawn coordinates
	randomize()
	var x = 0
	var z = 0
	while x <= 20:
		while z <= 20:
			if x == tempCell.x && z ==tempCell.z:
				#if the loop is at the point where the player stands ignore this position
				pass
			elif randi()%4 != 1:	#random chance for a empty field/pillar
				var height = randi()%5+1	#pillar height
				spawnCoordinates.push_back(gridMap.map_to_world(x, height, z))	#add top of the pillar to possible spawn coordinates
				for y in height:
					gridMap.set_cell_item(x,y,z, 0, 0) #build the pillar

			z += 1
		z = 0
		x += 1
		
	_move_pickable()	#move pickable to a new spawn coordinate

remote func move_pick():
	#the function which is called from clients
	_move_pickable()
	
remote func move_pick_c(var pos):
	#the function which the host calls at every client to set the new pickable position
	pickable.set_translation(str2var(pos))