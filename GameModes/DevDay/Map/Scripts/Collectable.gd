extends Spatial

func _ready():
	pass
	#$PickableArea.emit_signal("body_entered", null)

func _process(delta):
	$ColBody.rotate(Vector3(0,1,0), 2*delta)
