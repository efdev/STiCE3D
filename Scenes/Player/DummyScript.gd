extends KinematicBody
#moves the dummy character on the server according to client
slave func puppet_pos(p_pos):
	translation = p_pos

func _on_pickbable_body_entered():
	pass

func _on_JumpPad_body_exited():
	pass
	
func _resetPlayer(): 
	pass
