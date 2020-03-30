extends Area

export(NodePath) var SafePoint

func _on_Area_body_entered(body):
	body._resetPlayer($SafePoint.translation)

func _setSafePoint(var coordinates: Vector3):
	$SafePoint.translation = coordinates
