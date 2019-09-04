extends StaticBody

var this 
# Called when the node enters the scene tree for the first time.
func _ready():
	pass# Replace with function body.

func _process(delta):
	rotation(delta)

func rotation(delta):
	rotate_y(2*delta)
	
