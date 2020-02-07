extends Control

func _process(_delta):
	$fpsCounter.text = String(Performance.get_monitor(Performance.TIME_FPS))

func _setTouchedTiles(var tiles : int):
	$TileBox/actualTiles.text = "Actual: " + String(tiles)

func _setRecordTiles(var tiles : int):
	$TileBox/recordTiles.text = "Record: " + String(tiles)
	
func _setWorstTiles(var tiles : int):
	$TileBox/worstTiles.text = "Worst: " + String(tiles)
	
func _gameFinished():
	print("pff")
