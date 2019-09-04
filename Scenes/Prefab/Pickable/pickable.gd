extends Area
func _ready():
	coordinates._add_pickable(self)	#call the add_pickable function in the coordinates script node

func _physics_process(delta):
	rotation(delta)	#calls the rotation function on physics_process

func rotation(delta):
	rotate_y(2*delta)	#rotate the pickalbe on the y-axis on delta

func _on_Area_body_entered(body):
	body._on_pickbable_body_entered()	#calls the pickUp function on player
	coordinates._move_pickable()	#move the pickable to a new random position

