extends Area

signal changeColor
var cellPosition = Vector3(0,0,0)
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#connect("body_entered", self, "_on_Area_body_entered")

func _setCellPosition(var val):
	cellPosition = val

func _on_ColorField_body_entered(_body):
	emit_signal("changeColor", cellPosition)
	$CollisionShape.disabled = true
