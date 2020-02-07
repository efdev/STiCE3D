extends Camera

var cam :Camera
var rotationHelper: Spatial
var player: KinematicBody
export var playerPath: NodePath

#should later in settings singleton

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	cam = $"."
	rotationHelper = $"../"
	player = get_node(playerPath)
	
func _input(event) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotationHelper.rotate_x(deg2rad(event.relative.y * Config.mouseSens * -1))
		if player:
			player.rotate_y(deg2rad((event.relative.x * Config.mouseSens * -1)))
		var cameraRotation :Vector3 = rotationHelper.rotation_degrees
		cameraRotation.x = clamp(cameraRotation.x, -70, 70)
		rotationHelper.rotation_degrees = cameraRotation
#	if Input.is_action_just_pressed("ui_cancel"):
#		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
#			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
#		else:
#			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
	
	
