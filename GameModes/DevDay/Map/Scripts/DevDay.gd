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
		
const HIGH_HIGH = 4 # HIGH_MAX = 10, because Num%4 -> 0, 1, 2, 3 -> HIGH_MIN + 3 = HIGH_MAX  
const HIGH_LOW = 7 

const MID_HIGH = 4
const MID_LOW = 4

const LOW_HIGH = 4
const LOW_LOW = 1

func _getMaxHeight(var val):
	match val:
		1:
			return HIGH_HIGH
		2:
			return MID_HIGH
		3:
			return LOW_HIGH

func _getMinHeight(var val):
	match val:
		1:
			return HIGH_LOW
		2:
			return MID_LOW
		3:
			return LOW_LOW

func _buildMapPart(var fromX, var fromZ, var toX, var toZ):
	var curX = fromX
	var curZ = fromZ
	
	var chanceForEmptyCell = randi()%6+4
	var temp = randi()%3+1
	var minHeight = _getMinHeight(temp)
	var maxHeight = _getMaxHeight(temp) #high mid low
	
	print("%d maxHeight: %d minHeight: %d" % [temp, maxHeight, minHeight])
	
	#build this part of the map
	while(curX <= toX):
		while(curZ <= toZ):
			temp = randi()%chanceForEmptyCell
			print(temp)
			if(temp == 0):
				pass #empty cell
			else:
				var pillarHeight = randi()%maxHeight
				if(pillarHeight == 0):
					pillarHeight = minHeight
				else:
					pillarHeight += minHeight
				spawnCoordinates.push_back($GameMap.map_to_world(curX,pillarHeight+1,curZ))
				#mapCells.push_back(Vector3(curX, pillarHeight, curZ))
				$GameMap.set_cell_item(curX,pillarHeight,curZ, 1, 0)
				for y in pillarHeight:
					$GameMap.set_cell_item(curX,y,curZ, 0, 0) #build the pillar
					#mapCells.push_back(Vector3(curX,y,curZ))
			
			curZ += 1
		curZ = fromZ
		curX += 1
				
		
func _buildMap() -> void:
	$GameMap.clear()
	_buildSpawnPosition()
#	if not mapCells.empty():
#		for i in mapCells:
#			$GameMap.set_cell_item(i.x,i.y,i.z, -1,0)
#		mapCells.clear()
	spawnCoordinates.clear()
	_buildMapPart(0, 0, 10,10)
	_buildMapPart(0, 11, 10,21)
	_buildMapPart(11, 0, 21,10)
	_buildMapPart(11, 11, 21,21)
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
	$GameMap.set_cell_item(-1,11,-1,0,0)
	$GameMap.set_cell_item(-1,11,-2,0,0)
	$GameMap.set_cell_item(-2,11,-1,0,0)
	$GameMap.set_cell_item(-2,11,-2,0,0)
	
func _setSumPick(var val : int) -> void:
	Settings.saveGames.set_value("DevNew", "SumCollected", val)
	Settings.saveGames.save(Settings.saveGamesPath)
	Settings.ui._setSumPick(val)

func _setCurrentPickCount(var val : int) -> void:
	Settings.ui._setCurrentPickCount(val)
	

	
	


