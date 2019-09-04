extends Area

func _ready():
	pass

func _on_JumpPad_body_exited(body):
	body._on_JumpPad_body_exited() # calls the jumpPad function in player
