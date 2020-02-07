extends Area

signal area

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#connect("body_entered", self, "_on_Area_body_entered")


func _on_Area_body_entered(body):
	emit_signal("area", get_groups())
	$CollisionShape.disabled = true
