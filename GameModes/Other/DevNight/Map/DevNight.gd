extends Spatial

var spawnCoordinates : Array
var mapCells : Array
var collectedCounter : int = 0
var collectedSum : int = 0
var HUD : Array 

func _ready():
	HUD = get_tree().get_nodes_in_group("HUD")
	randomize()
	_buildSpawnPosition()
	_spawnCollectable()
	_spawnPlayer()
	_buildMap()
	_setInitialRespawn()
		
	var val : int = Config._loadSomethingFromConfig("DevNight", "SumCollected")
	if val != null:
		collectedSum = val
		_setSumPick(val)
		
func _buildMap() -> void:
	if not mapCells.empty():
		for i in mapCells:
			$GameMap.set_cell_item(i.x,i.y,i.z, -1,0)
		mapCells.clear()
		spawnCoordinates.clear()
	var x = 1
	var z = 1
	while x <= 30:
		while z <= 30:
			if randi()%4 != 1:	#random chance for a empty field/pillar
				var height = randi()%5+1	#pillar height
				spawnCoordinates.push_back($GameMap.map_to_world(x,height,z))
				$GameMap.set_cell_item(x,height-1,z, 1, 0)
				mapCells.push_back(Vector3(x,height-1, z))
				for y in height-1:
					$GameMap.set_cell_item(x,y,z, 0, 0) #build the pillar
					mapCells.push_back(Vector3(x,y,z))
			z += 1
		z = 0
		x += 1
	spawnCoordinates.shuffle()
	_setGameObjects()

func _setGameObjects() -> void:
	$Collectable.translation = spawnCoordinates.pop_front() + Vector3(0,0.1,0)
	
func _collectableCollected(var body : Spatial) -> void:
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
	var playerScene = preload("res://Scenes/Player/Player.tscn")
	var player : Spatial = playerScene.instance()
	player._setEnvironment(preload("res://GameModes/Other/DevNight/Map/gameEnv.tres"))
	player.add_child(preload("res://GameModes/Other/DevNight/Map/OmniLight.tscn").instance())
	player.translation = Vector3(1,20,1)
	player.rotation = Vector3(player.rotation.x, 180, player.rotation.z )
	self.add_child(player)


func _spawnCollectable() -> void:
	var collectableScene = preload("res://GameModes/Other/DevNight/Map/Collectable.tscn")
	var collectable = collectableScene.instance()
	self.add_child(collectable)
	
	var err : int = $Collectable/PickableArea.connect("body_entered", self, "_collectableCollected")
	if err != OK:
		print("Signal not connected")

func _setInitialRespawn() -> void:
	$ResetGround._setSafePoint($GameMap.map_to_world(1,9,1) - Vector3(0,3,0))
	
func _buildSpawnPosition() -> void:
	$GameMap.set_cell_item(0,6,0,0,0)
	$GameMap.set_cell_item(0,6,1,0,0)
	$GameMap.set_cell_item(1,6,0,0,0)
	$GameMap.set_cell_item(1,6,1,0,0)
	
func _setSumPick(var val : int) -> void:
	if not HUD.empty():
		Config._saveSomethingInConfig("DevNight", "SumCollected", val)
		HUD[0]._setSumPick(val)

func _setCurrentPickCount(var val : int) -> void:
	if not HUD.empty():
		HUD[0]._setCurrentPickCount(val)
	

	
	


