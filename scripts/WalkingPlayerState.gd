class_name WalkingPlayerState extends PlayerMovementState

@export var SPEED: float = 5.0
@export var ACCELERATION: float = 0.1
@export var DECELERATION: float = 0.25
@export var TOP_ANIM_SPEED: float = 1.8
@export var WEAPON_BOB_SPEED: float = 5.0
@export var WEAPON_BOB_H: float = 2.0
@export var WEAPON_BOB_V: float = 0.5

func enter(previous_state) -> void:
	if ANIMATION.is_playing() and ANIMATION.current_animation == "JumpStart":
		await ANIMATION.animation_finished
		ANIMATION.play("Walking", -1.0, 1.0)
	else:
		ANIMATION.play("Walking", -1.0, 1.0)

func exit() -> void:
	ANIMATION.speed_scale = 1.0

func update(delta: float):
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()
	
	WEAPON._weapon_bob(delta, WEAPON_BOB_SPEED, WEAPON_BOB_H, WEAPON_BOB_V)
	WEAPON.sway_weapon(delta, false)
	
	set_animation_speed(PLAYER.velocity.length())
	
	if Input.is_action_pressed("attack"):
		WEAPON._attack()
	
	if Input.is_action_pressed("sprint") and PLAYER.is_on_floor():
		transition.emit("SprintingPlayerState")
	
	#if Input.is_action_just_pressed("crouch") and PLAYER.is_on_floor():
		#transition.emit("CrouchingPlayerState")
	
	if Input.is_action_pressed("crouch") and PLAYER.is_on_floor():
		transition.emit("CrouchingPlayerState")
	
	if PLAYER.velocity.length() == 0.0:
		transition.emit("IdlePlayerState")
	
	if Input.is_action_just_pressed("jump") and PLAYER.is_on_floor():
		transition.emit("JumpingPlayerState")
	
	if PLAYER.velocity.y < -3.0 and !PLAYER.is_on_floor():
		transition.emit("FallindPlayerState")

func set_animation_speed(spd) -> void:
	var alpha = remap(spd, 0.0, SPEED, 0.0, 1.0)
	ANIMATION.speed_scale = lerp(0.0, TOP_ANIM_SPEED, alpha)
	
