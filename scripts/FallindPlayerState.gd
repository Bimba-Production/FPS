class_name FallindPlayerState extends PlayerMovementState

@export var SPEED: float = 5.0
@export var ACCELERATION: float = 0.1
@export var DECELERATION: float = 0.55

func enter(previous_state) -> void:
	ANIMATION.pause()

func update(delta: float) -> void:
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()
	
	if PLAYER.is_on_floor() and PLAYER.velocity.length() == 0:
		ANIMATION.play("JumpStart")
		transition.emit("IdlePlayerState")
	
	if Input.is_action_pressed("sprint") and PLAYER.is_on_floor():
		transition.emit("SprintingPlayerState")
	elif PLAYER.velocity.length() > 0.0 and PLAYER.is_on_floor():
		ANIMATION.play("JumpStart")
		transition.emit("WalkingPlayerState")
		
	if Input.is_action_just_pressed("jump") and PLAYER.is_on_floor():
		ANIMATION.play("JumpStart")
		transition.emit("JumpingPlayerState")
