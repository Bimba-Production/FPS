class_name JumpingPlayerState extends PlayerMovementState

@export var SPEED: float = 10.0
@export var ACCELERATION: float = 0.1
@export var DECELERATION: float = 0.55
@export var JUMP_VELOCITY: float = 7.0
@export_range(0.5, 1.0, 0.01) var INPUT_MULTIPLIER: float = 0.85

func enter(previous_state) -> void:
	PLAYER.velocity.y += JUMP_VELOCITY
	if ANIMATION.is_playing() and (ANIMATION.current_animation == "Crouch" or ANIMATION.current_animation == "JumpStart" or ANIMATION.current_animation == "Slide_to_jump"):
		await ANIMATION.animation_finished
		ANIMATION.play("JumpStart")
	else:
		ANIMATION.play("JumpStart")

func update(delta: float) -> void:
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED * INPUT_MULTIPLIER, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()
	
	if Input.is_action_just_released("jump"):
		if PLAYER.velocity.y > 0:
			PLAYER.velocity.y = PLAYER.velocity.y / 2
	
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
