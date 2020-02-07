extends Area

func _on_Area_body_entered(body):
	body._resetPlayer($SafePoint.translation)

func _setSafePoint(var coordinates: Vector3) -> void:
	$SafePoint.translation = coordinates
