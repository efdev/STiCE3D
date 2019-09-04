extends Spatial

func _ready():
	randomize()
	var x = 0
	var z = 0
	while x <= 20:
		while z <= 20:
			if randi()%4 != 1:
				var height = randi()%5+1
				coordinates.spawnCoordinates.push_back($GridMap.map_to_world(x, height, z))
				for y in height:
					$GridMap.set_cell_item(x,y,z, 0, 0)
			
			z += 1
		z = 0
		x += 1
	
	coordinates.gridMap = get_node("GridMap")
	coordinates.gridCells = $GridMap.get_used_cells()
	coordinates._move_pickable()