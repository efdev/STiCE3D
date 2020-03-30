extends KinematicBody

#movement variables
var maxSpeed: int = 6
var jumpSpeed: int = 10
var accelerationAir = 3
var acceleration: float = 10
var accelerationDef: int = 10
var deacceleration: int = 20
var gravity: int = -35

var velocity: Vector3 = Vector3()
var direction: Vector3 = Vector3()

var moveable : bool = true

##jump variables
enum jumpState{
	onGround, jumpLeft, jumpRight, jumpBack, jumpForward, jumpOnTop, cornerJumpLeft, cornerJumpRight
}

var currentState: int = jumpState.onGround
var onEdge: bool = false

func _physics_process(delta):
	if moveable:
		_movementInput()
		_processMovement(delta)
	_defineJumpState()
	_defineOnEdge()


func _deactivateMovement(var boo : bool) -> void:
		moveable = boo
		velocity = Vector3(0,0,0)

func _movementInput() -> void:

	var lookDirection: Transform = self.global_transform
	var movementVector: Vector2 = Vector2()
	direction = Vector3()

	if Input.is_action_pressed("moveForward") and (not (currentState == jumpState.cornerJumpLeft or currentState == jumpState.cornerJumpRight)):
		movementVector.y -= 1
	if Input.is_action_pressed("moveBackward"):
		movementVector.y += 1
	if Input.is_action_pressed("moveLeft"):
		movementVector.x -= 1
	if Input.is_action_pressed("moveRight"):
		movementVector.x += 1

	match currentState:
		jumpState.cornerJumpLeft:
			direction = Vector3(0,0,0)
			movementVector.x += 1
			movementVector.y -= 0.3
		jumpState.cornerJumpRight:
			direction = Vector3(0,0,0)
			movementVector.x -= 1
			movementVector.y -=0.3
		jumpState.jumpBack:
			direction = Vector3(0,0,0)
			movementVector.y += 0.8
		jumpState.jumpForward:
			direction = Vector3(0,0,0)
			movementVector.y -= 0.8
		jumpState.jumpOnTop:
			direction = Vector3(0,0,0)
			movementVector.y -= 0.5
		jumpState.jumpLeft:
			direction = Vector3(0,0,0)
			movementVector.x += 0.8
			#movementVector.y -= 1
		jumpState.jumpRight:
			direction = Vector3(0,0,0)
			movementVector.x -= 0.8
			#movementVector.y -= 1

	movementVector = movementVector.normalized()
	direction += lookDirection.basis.z.normalized() * movementVector.y
	direction += lookDirection.basis.x.normalized() * movementVector.x
	
func _frontCollides() -> bool:
	if $Rays/RayFront.is_colliding() or $Rays/RayFront2.is_colliding() or $Rays/RayFront3.is_colliding():
		return true
	else:
		return false

func _defineJumpState() -> void:
	if is_on_floor():
		currentState = jumpState.onGround
		acceleration = accelerationDef
		if Input.is_action_just_pressed("jump"):
			acceleration = accelerationAir
			velocity.y = jumpSpeed * 0.8
	elif onEdge and Input.is_action_just_pressed("jump"):
		velocity.y = jumpSpeed
		currentState = jumpState.jumpOnTop
	else:
		if Input.is_action_just_pressed("jump"):
			if ($Rays/RayLeft.is_colliding() and _frontCollides()) and (currentState != jumpState.cornerJumpLeft and currentState != jumpState.jumpLeft):
				velocity.y = jumpSpeed
				currentState = jumpState.cornerJumpLeft
			elif ($Rays/RayRight.is_colliding() and _frontCollides()) and (currentState != jumpState.cornerJumpRight and currentState != jumpState.jumpRight):
				velocity.y = jumpSpeed
				currentState = jumpState.cornerJumpRight
			elif $Rays/RayLeft.is_colliding() and (currentState != jumpState.jumpLeft and currentState != jumpState.cornerJumpLeft):
				velocity.y = jumpSpeed
				currentState = jumpState.jumpLeft
			elif $Rays/RayRight.is_colliding() and (currentState != jumpState.jumpRight and currentState != jumpState.cornerJumpRight):
				velocity.y = jumpSpeed
				currentState = jumpState.jumpRight
			else:
				if $Rays/RayFront.is_colliding() and currentState != jumpState.jumpBack:
					velocity.y = jumpSpeed
					currentState = jumpState.jumpBack
				if $Rays/RayBack.is_colliding() and currentState != jumpState.jumpForward:
					velocity.y = jumpSpeed
					currentState = jumpState.jumpForward

func _defineOnEdge() -> void:
	if not $Rays/RayHead.is_colliding() and ($Rays/RayFoot.is_colliding() or $Rays/RayFront.is_colliding()):
		onEdge = true
	else:
		onEdge = false

func _processMovement(delta) -> void:
	direction.y = 0
	direction = direction.normalized()

	velocity.y += delta * gravity
	velocity.y = clamp(velocity.y, -100, 100)

	var hvel: Vector3 = velocity
	hvel.y = 0

	var target: Vector3 = direction
	target *= maxSpeed

	var accel: float
	if direction.dot(hvel) > 0:
		accel = acceleration
	else:
		accel = deacceleration

	hvel = hvel.linear_interpolate(target, accel*delta)
	velocity.x = hvel.x 
	velocity.z = hvel.z 
	velocity = move_and_slide(velocity, Vector3(0,1,0), 0.05, 4, deg2rad(45))

	
func _resetPlayer(var resetPoint:Vector3) -> void:
	direction = Vector3(0,0,0)
	velocity = Vector3(0,0,0)
	translation = (resetPoint)
	
func _setEnvironment(var newEnv : Resource) -> void:
	$RotationHelper/Camera.environment = newEnv
	


