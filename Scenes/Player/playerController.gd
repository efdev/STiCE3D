extends KinematicBody

var DEBUG = false

#variables movement
export var MAX_SPEED_DEF = 30	#move speed on ground
export var MAX_SPEED_AIR = 20	#move speed on air
var MAX_SPEED = MAX_SPEED_DEF	#max speed of the player
export var JUMP_SPEED = 30	#jump height
export var ACCEL = 5	#how fast the player reaches maximal speed
export var DEACCEL= 20	#how fast the player slows down
export var GRAVITY = -80	#how much energy forces the player to the ground
var ACCEL_DEF = 5

var vel = Vector3()

#helpers for jump movement
var playerHeight = Vector3()	#distance between ground and player
var jumpState = "onGround"	#state to determine what to do in air on ground and so on
var onEdge = false	#helper to move the player on top on an obstacle
var floorHeight = Vector3()	#height of the last touched floor (to calculate the distance between player and ground)

var dir = Vector3()	#direction where to move the player

const MAX_SLOPE_ANGLE = 40	#on which angle the player does stay save

var camera	
var rotation_helper	#helper for camera rotation

#------------------------

func _ready():
	if DEBUG:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera = $Rotation_Helper/Camera
	translation = (playerAttributes.StartPoint)
	rotation_helper = $Rotation_Helper

func _physics_process(delta):
		$"/root/Counter/FPS".text = String(Performance.get_monitor(Performance.TIME_FPS))
		process_input()
		process_movement(delta)
		_on_edge()

func _on_edge():
	if not $RayFrontHead.is_colliding() and $RayFrontFoot.is_colliding():
		onEdge = true
	else:
		onEdge = false
		
func process_input():
	#---WALKING---#
			dir = Vector3()
			var cam_xform = camera.get_global_transform()
		
			var input_movement_vector = Vector2()
			
			if Input.is_action_pressed("move_forward"):
					input_movement_vector.y += 1
			if Input.is_action_pressed("move_backward"):
					input_movement_vector.y -= 1
			if Input.is_action_pressed("move_left"):
					input_movement_vector.x -= 1
			if Input.is_action_pressed("move_right"):
					input_movement_vector.x += 1
			#--------------#
			
			#---JUMP MOVEMENT---#
			#---do the different jump movements---#
			if jumpState == "jumpBackward":
				dir = Vector3(0, 0, 0)
				input_movement_vector.y -= 1
		
			if jumpState == "jumpForward":
				dir = Vector3(0, 0, 0)
				input_movement_vector.y += 1
			
			if jumpState == "jumpOnTop":
				dir = Vector3(0, 0, 0)
				input_movement_vector.y += 0.01
		
			if jumpState == "jumpRight":
				MAX_SPEED = MAX_SPEED_AIR
				dir = Vector3(0, 0, 0)
				input_movement_vector.y += 0.5
				input_movement_vector.x += 1
		
			if jumpState == "jumpLeft":
				MAX_SPEED = MAX_SPEED_AIR
				dir = Vector3(0, 0, 0)
				input_movement_vector.y += 0.5
				input_movement_vector.x -= 1
			#------------#
			#---set the jump movement based on player position in world---#
			if is_on_floor():
				#if player is on a floor
				floorHeight = get_global_transform().origin	#set the floor height 
				MAX_SPEED = MAX_SPEED_DEF	#set max player movement speed to default speed
				jumpState = "onGround"	#set the jumpState to "onGround" -> is not jumping right now
				onEdge = false	#if player is on floor the player is not on a edge
				if Input.is_action_just_pressed("jump"):
					vel.y = JUMP_SPEED	#push the player in the air
					MAX_SPEED = MAX_SPEED_AIR	#set maximum speed to speed in the air
					
			#playerHeight = get_global_transform().origin - floorHeight	#calculate player height base on the latest floor position
			if onEdge and (Input.is_action_just_pressed("jump")):
				#move player on top of an obstacle
				vel.y = JUMP_SPEED
				jumpState = "jumpOnTop"
			
			elif not is_on_floor():
			#elif playerHeight[1] > 4 or playerHeight[1] < 0:
				#if the player has a certain height
				if Input.is_action_just_pressed("jump"):
					if $RayLeft.is_colliding()and jumpState != "jumpRight":
						vel.y = JUMP_SPEED
						ACCEL = ACCEL_DEF*2
						jumpState = "jumpRight"
		
					if $RayRight.is_colliding()and jumpState != "jumpLeft":
						vel.y = JUMP_SPEED
						ACCEL = ACCEL_DEF*2
						jumpState = "jumpLeft"
					
					if not $RayRight.is_colliding() and not $RayLeft.is_colliding():	
						if $RayFront.is_colliding() and jumpState != "jumpBackward":
							vel.y = JUMP_SPEED
							ACCEL = ACCEL_DEF*2
							jumpState = "jumpBackward"
		
						if $RayBack.is_colliding()and jumpState != "jumpForward":
							vel.y = JUMP_SPEED
							ACCEL = ACCEL_DEF*2
							jumpState = "jumpForward"
			#--------------#
			
			input_movement_vector = input_movement_vector.normalized()
		
			dir += -cam_xform.basis.z.normalized() * input_movement_vector.y
			dir += cam_xform.basis.x.normalized() * input_movement_vector.x

func process_movement(delta):
    dir.y = 0
    dir = dir.normalized()

    vel.y += delta * GRAVITY

    var hvel = vel
    hvel.y = 0

    var target = dir
    target *= MAX_SPEED

    var accel
    if dir.dot(hvel) > 0:
        accel = ACCEL
    else:
        accel = DEACCEL

    hvel = hvel.linear_interpolate(target, accel * delta)
    vel.x = hvel.x
    vel.z = hvel.z
    vel = move_and_slide(vel, Vector3(0, 1, 0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))
    if playerAttributes.MultiPlayer:
   	 rpc_unreliable("puppet_pos",get_translation())

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(deg2rad(event.relative.y * playerAttributes.mouseSensitivity * -1))
		self.rotate_y(deg2rad(event.relative.x * playerAttributes.mouseSensitivity * -1))
		#max rotation
		var camera_rot = rotation_helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -70, 70)
		rotation_helper.rotation_degrees = camera_rot

func _on_pickbable_body_entered():
	playerAttributes.count += 1
	$"/root/Counter/Display".text = String(playerAttributes.count)

func _on_JumpPad_body_exited():
	if not is_on_floor():
		vel.y = JUMP_SPEED*3
		MAX_SPEED = MAX_SPEED_AIR
	
func _resetPlayer(): 
	playerAttributes.respawns += 1
	translation = (playerAttributes.safePoint)
