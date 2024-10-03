class_name SlidingPlayerState extends PlayerMovementState

@export var SPEED: float = 12.0
@export var ACCELERATION: float = 0.1
@export var DECELERATION: float = 0.0025
@export var TILT_AMOUNT: float = 0.09
@export_range(1, 6, 0.1) var SLIDE_ANIM_SPEED: float = 4.0

@onready var CROUCH_SHAPECAST: ShapeCast3D = %ShapeCast3D
@onready var CAMERA_CONTROLLER: Node3D = %CameraController

func enter(previous_state) -> void:
	#set_tilt(PLAYER._current_rotation)
	PLAYER.velocity *= 1.2
	ANIMATION.get_animation("Sliding").track_set_key_value(4, 0, PLAYER.velocity.length())
	ANIMATION.speed_scale = 1.0
	ANIMATION.play("Sliding", -1.0, SLIDE_ANIM_SPEED)

func update(delta):
	PLAYER.update_gravity(delta)
	#PLAYER.update_input(SPEED, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()
	
	if Input.is_action_pressed("attack"):
		WEAPON._attack()
	
	if Input.is_action_just_released("crouch") and PLAYER.velocity.length() > 6:
		uncrouch()
		transition.emit("SprintingPlayerState")
		CAMERA_CONTROLLER.rotation = Vector3.ZERO
	
	if Input.is_action_just_pressed("jump") and PLAYER.is_on_floor():
		#ANIMATION.play("RESET", -1, 1)
		ANIMATION.play("Slide_to_jump", 0.5, 1.0)
		transition.emit("JumpingPlayerState")
		CAMERA_CONTROLLER.rotation = Vector3.ZERO

func set_tilt(player_rotation) -> void:
	var tilt = Vector3.ZERO
	tilt.z = clamp(TILT_AMOUNT * player_rotation, -0.1, 0.1)
	if tilt.z == 0.0:
		tilt.z = 0.07
	ANIMATION.get_animation("Sliding").track_set_key_value(3, 1, tilt)
	ANIMATION.get_animation("Sliding").track_set_key_value(3, 2, tilt)

func finish() -> void:
	transition.emit("CrouchingPlayerState")
	
func uncrouch(speed: int = 1.5) -> void:
	if CROUCH_SHAPECAST.is_colliding() == false and Input.is_action_pressed("crouch") == false:
		ANIMATION.play("Crouch", -1.0, -SPEED * speed, true)
		if ANIMATION.is_playing():
			await ANIMATION.animation_finished
	elif CROUCH_SHAPECAST.is_colliding() == true:
		await get_tree().create_timer(0.1).timeout
		uncrouch(speed)
