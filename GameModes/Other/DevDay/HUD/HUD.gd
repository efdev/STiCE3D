extends Control

func _process(_delta):
	$fpsCounter.text = String(Performance.get_monitor(Performance.TIME_FPS))

func _setSumPick(var val : int) -> void:
	$PickBox/SumPick.text = String(val)

func _setCurrentPickCount(var val : int) -> void:
	$PickBox/CurrentPickCount.text =String(val) + "/5"
