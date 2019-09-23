extends Spatial

func _ready():
	coordinates.gridMap = get_node("GridMap")
	coordinates._newMap()
