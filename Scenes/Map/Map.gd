extends Spatial

func _ready():
	coordinates.gridMap = get_node("GridMap")
	coordinates._newMap()
	
#func _newMap():
#	randomize()
#	var x = 0
#	var z = 0
#	while x <= 20:
#		while z <= 20:
#			if randi()%4 != 1:
#				var height = randi()%5+1
#				coordinates.spawnCoordinates.push_back($GridMap.map_to_world(x, height, z))
#				for y in height:
#					$GridMap.set_cell_item(x,y,z, 0, 0)
#
#			z += 1
#		z = 0
#		x += 1
#

#
#func _newMap():
#	$GridMap.clear() #clear all cells
#	if coordinates.tempCell != null:
#		$GridMap.set_cell_item(coordinates.tempCell.x,coordinates.tempCell.y-1,coordinates.tempCell.z, 0, 0)	#set the spot where the player stands new
#	coordinates.spawnCoordinates.clear()	#remove all spawn coordinates
#	randomize()
#	var x = 0
#	var z = 0
#	while x <= 20:
#		while z <= 20:
#			if x == tempCell.x && z ==tempCell.z:
#				#if the loop is at the point where the player stands ignore this position
#				pass
#			elif randi()%4 != 1:	#random chance for a empty field/pillar
#				var height = randi()%5+1	#pillar height
#				spawnCoordinates.push_back(gridMap.map_to_world(x, height, z))	#add top of the pillar to possible spawn coordinates
#				for y in height:
#					gridMap.set_cell_item(x,y,z, 0, 0) #build the pillar
#
#			z += 1
#		z = 0
#		x += 1
#
#	coordinates.gridCells = $GridMap.get_used_cells()
#	coordinates._move_pickable()	#move pickable to a new spawn coordinate