extends Spatial

var spawnCoordinates : Array
var mapCells : Array
var collectedCounter : int = 0
var collectedSum : int = 0
export(PackedScene) var playerScene = null

func _ready():
	randomize()
	_buildSpawnPosition()
	_setInitialRespawn()
	_spawnPlayer()
	
	_spawnCollectable()
	_buildMap()

	var val  = Settings.saveGames.get_value("DevNew", "SumCollected", 0)
	if val != 0:
		collectedSum = val
		_setSumPick(val)

func _getHeight(var val):
	if(val < -0.1):
		return 0
	elif(val < 0):
		return 1
	elif(val < 0.15):
		return 2
	elif(val < 0.3):
		return 4
	elif(val < 0.45):
		return 6
	elif(val < 0.6):
		return 7
	else:
		return 8
	

func _buildMapPart(var fromX, var fromZ, var toX, var toZ):
	var noise = OpenSimplexNoise.new()

	noise.seed = randi()
	noise.lacunarity = 2
	noise.octaves = 3
	noise.period = 1
	noise.persistence = 5
	var curX = fromX
	var curZ = fromZ

	while(curX <= toX):
		while(curZ <= toZ):
			var pillarHeight = _getHeight(noise.get_noise_2d(curX, curZ))
			if(pillarHeight == 0):
				pass #empty cell
			else:
				spawnCoordinates.push_back($GameMap.map_to_world(curX,pillarHeight+1,curZ))
				$GameMap.set_cell_item(curX,pillarHeight,curZ, 0, 0)
				var changeColor = preload("res://GameModes/DevNew/ChangeColor/ColorField.tscn").instance()
				changeColor._setCellPosition(Vector3(curX, pillarHeight, curZ))
				changeColor.translation = $GameMap.map_to_world(curX, pillarHeight, curZ) + Vector3(0,1.01,0)
				changeColor.connect("changeColor", self, "changeColor")
				$GameMap.add_child(changeColor)
				for y in pillarHeight:
					$GameMap.set_cell_item(curX,y,curZ, 0, 0) #build the pillar
			
			curZ += 1
		curZ = fromZ
		curX += 1
				
func changeColor(var position):
	print(position)
	$GameMap.set_cell_item(position.x, position.y, position.z, 1, 0)
	pass
	
func _buildMap() -> void:
	$GameMap.clear()
	_buildSpawnPosition()
#	if not mapCells.empty():
#		for i in mapCells:
#			$GameMap.set_cell_item(i.x,i.y,i.z, -1,0)
#		mapCells.clear()
	spawnCoordinates.clear()
	for i in $GameMap.get_child_count():
		$GameMap.get_child(i).queue_free()
	_buildMapPart(0, 0, 16,16)
	spawnCoordinates.shuffle()
	_setGameObjects()

func _setGameObjects() -> void:
	$Collectable.translation = spawnCoordinates.pop_front() + Vector3(0,0.1,0)
	
func _collectableCollected(var _body : Spatial) -> void:
	collectedCounter += 1
	collectedSum += 1
	if(collectedCounter >= 5):
		collectedCounter = 0
		_setInitialRespawn()
		$Player._resetPlayer($ResetGround/SafePoint.translation)
		$Player.rotation = Vector3($Player.rotation.x, 180, $Player.rotation.z )
		_buildMap()
		_setSumPick(collectedSum)
		_setCurrentPickCount(collectedCounter)
		return
	$ResetGround._setSafePoint($Collectable.translation)
	_setGameObjects()
	_setSumPick(collectedSum)
	_setCurrentPickCount(collectedCounter)
	
func _spawnPlayer() -> void:

	var player : Spatial = playerScene.instance()
	player.translation = $ResetGround/SafePoint.translation#Vector3(1,20,1)
	player.rotation = Vector3(player.rotation.x, 180, player.rotation.z )
	self.add_child(player)


func _spawnCollectable() -> void:
	var collectableScene = preload("res://GameModes/DevNew/Map/Scenes/Collectable.tscn")
	var collectable = collectableScene.instance()
	self.add_child(collectable)
	
	var err : int = $Collectable/PickableArea.connect("body_entered", self, "_collectableCollected")
	if err != OK:
		print("Signal not connected")

func _setInitialRespawn() -> void:
	$ResetGround._setSafePoint($GameMap.map_to_world(-1,11,-1) + Vector3(0,3,0))
	
func _buildSpawnPosition() -> void:
	$GameMap.set_cell_item(-1,11,-1,1,0)
	$GameMap.set_cell_item(-1,11,-2,1,0)
	$GameMap.set_cell_item(-2,11,-1,1,0)
	$GameMap.set_cell_item(-2,11,-2,1,0)

func _setSumPick(var val : int) -> void:
	Settings.saveGames.set_value("DevNew", "SumCollected", val)
	var temp = Settings.saveGames.save(Settings.saveGamesPath)
	Settings.ui._setSumPick(val)

func _setCurrentPickCount(var val : int) -> void:
	Settings.ui._setCurrentPickCount(val)
	

	
	


