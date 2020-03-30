extends Control

func _process(_delta):
	$fpsCounter.text = String(Performance.get_monitor(Performance.TIME_FPS))
