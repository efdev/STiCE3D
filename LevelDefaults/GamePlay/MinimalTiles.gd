extends Spatial

var coloredTiles : Array

var touchedTiles : int = 0
var record : int = 0
var worst : int = 0

var HUD : Array

func _ready():
	$ResetGround._setSafePoint(Vector3(0,3,0))
	HUD = get_tree().get_nodes_in_group("HUD")
	_spawnAreas()
	_spawnPlayer()
	_loadGame()

func _switchItem(var array : Array):
	var index : int = array.front().to_int()
	$ModifiableTiles.set_cell_item(coloredTiles[index].x, coloredTiles[index].y, coloredTiles[index].z, 1, 0)
	touchedTiles += 1
	HUD.front()._setTouchedTiles(touchedTiles)

func _spawnAreas():
	coloredTiles = $ModifiableTiles.get_used_cells()
	
	var i = 0
	for tile in coloredTiles:
		var area : Spatial = load("res://LevelDefaults/SwitchArea/Area.tscn").instance()
		area.translation = ($ModifiableTiles.map_to_world(tile.x, tile.y, tile.z) + Vector3(0,1.01,0))
		area.connect("area", self, "_switchItem")
		area.add_to_group(String(i))
		$Areas.add_child(area)
		i += 1

func _spawnPlayer():
	var playerScene = load("res://Scenes/Player/Player.tscn")
	var player : Spatial = playerScene.instance()
	player.translation = Vector3(0,3,0)
	#player.rotation = Vector3(player.rotation.x, 180, player.rotation.z )
	self.add_child(player)
	
func _levelFinished(body):
	if touchedTiles < record or record == 0:
		Config._saveSomethingInConfig(Config._getGameModeName(), "Record", touchedTiles)
	if touchedTiles > worst:
		Config._saveSomethingInConfig(Config._getGameModeName(), "Worst", touchedTiles)
	HUD.front()._gameFinished()
	
func _loadGame():
	var val : int = Config._loadSomethingFromConfig(Config._getGameModeName(), "Record")
	if val != null:
		record = val
		HUD.front()._setRecordTiles(record)
	var val2 : int = Config._loadSomethingFromConfig(Config._getGameModeName(), "Worst")
	if val2 != null:
		worst = val2
		HUD.front()._setWorstTiles(worst)
	
	
