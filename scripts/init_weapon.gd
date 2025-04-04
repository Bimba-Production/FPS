@tool

class_name WeaponController extends Node3D

signal weapon_fired

@export var WEAPON_TYPE: Weapon:
	set(val):
		WEAPON_TYPE = val
		if Engine.is_editor_hint():
			load_weapon()
@export var sway_noise: NoiseTexture2D
@export var sway_speed: float = 1.2
@export var reset: bool = false:
	set(val):
		reset = val
		if Engine.is_editor_hint():
			load_weapon()

@onready var weapon_mesh = %WeaponMesh
@onready var weapon_shadow = %WeaponShadow

var mouse_movement: Vector2
var random_sway_x
var random_sway_y
var random_sway_amount: float
var time: float = 0.0
var idle_sway_adjustment
var idle_sway_rotation_strength
var weapon_bob_amount: Vector2 = Vector2(0, 0)

var shoot_time: float = 0.07
var can_shoot: bool = true

var raycast_test = preload("res://scenes/raycast_test.tscn")

func _ready() -> void:
	load_weapon()

func _input(event) -> void:
	if event.is_action_pressed("weapon1"):
		WEAPON_TYPE = load("res://meshes/weapons/crowbar/crowbar.tres")
		load_weapon()
	if event.is_action_pressed("weapon2"):
		WEAPON_TYPE = load("res://meshes/weapons/gun_rifle/scifi_rifle.tres")
		load_weapon()
	if event is InputEventMouseMotion:
		mouse_movement = event.relative

func load_weapon() -> void:
	weapon_mesh.mesh = WEAPON_TYPE.mesh
	position = WEAPON_TYPE.position
	rotation_degrees = WEAPON_TYPE.rotation
	scale = WEAPON_TYPE.scale
	weapon_shadow.visible = WEAPON_TYPE.shadow
	idle_sway_adjustment = WEAPON_TYPE.idle_sway_adjustment
	idle_sway_rotation_strength = WEAPON_TYPE.idle_sway_rotation_strength
	random_sway_amount = WEAPON_TYPE.random_sway_amount

func sway_weapon(delta: float, isIdle: bool) -> void:
	mouse_movement = mouse_movement.clamp(WEAPON_TYPE.sway_min, WEAPON_TYPE.sway_max)
	
	if isIdle:
		var sway_random: float = get_sway_noise()
		var sway_random_adjusted: float = sway_random * idle_sway_adjustment
	
		time += delta * (sway_speed + sway_random)
		random_sway_x = sin(time * 1.5 + sway_random_adjusted) / random_sway_amount
		random_sway_y = sin(time - sway_random_adjusted) / random_sway_amount
	
		position.x = lerp(position.x, WEAPON_TYPE.position.x - (mouse_movement.x * WEAPON_TYPE.sway_amount_position + random_sway_x) * delta, WEAPON_TYPE.sway_speed_position)
		position.y = lerp(position.y, WEAPON_TYPE.position.y - (mouse_movement.y * WEAPON_TYPE.sway_amount_position + random_sway_y) * delta, WEAPON_TYPE.sway_speed_position)
		rotation_degrees.x = lerp(rotation_degrees.x, WEAPON_TYPE.rotation.x - (mouse_movement.y * WEAPON_TYPE.sway_amount_rotation + (random_sway_x * idle_sway_rotation_strength)) * delta, WEAPON_TYPE.sway_speed_rotation)
		rotation_degrees.y = lerp(rotation_degrees.y, WEAPON_TYPE.rotation.y + (mouse_movement.x * WEAPON_TYPE.sway_amount_rotation + (random_sway_y * idle_sway_rotation_strength)) * delta, WEAPON_TYPE.sway_speed_rotation)
	else:
		position.x = lerp(position.x, WEAPON_TYPE.position.x - (mouse_movement.x * WEAPON_TYPE.sway_amount_position + weapon_bob_amount.x) * delta, WEAPON_TYPE.sway_speed_position)
		position.y = lerp(position.y, WEAPON_TYPE.position.y - (mouse_movement.y * WEAPON_TYPE.sway_amount_position + weapon_bob_amount.y) * delta, WEAPON_TYPE.sway_speed_position)
		rotation_degrees.x = lerp(rotation_degrees.x, WEAPON_TYPE.rotation.x - (mouse_movement.y * WEAPON_TYPE.sway_amount_rotation) * delta, WEAPON_TYPE.sway_speed_rotation)
		rotation_degrees.y = lerp(rotation_degrees.y, WEAPON_TYPE.rotation.y + (mouse_movement.x * WEAPON_TYPE.sway_amount_rotation) * delta, WEAPON_TYPE.sway_speed_rotation)

func _weapon_bob(delta: float, speed: float, h_amount: float, v_amount: float) -> void:
	time += delta
	
	weapon_bob_amount.x = sin(time * speed) * h_amount
	weapon_bob_amount.y = abs(cos(time * speed) * v_amount)

func get_sway_noise() -> float:
	var player_position: Vector3 = Vector3(0, 0, 0)
	
	if not Engine.is_editor_hint():
		player_position = Global.player.global_position
	
	var noise_location: float = sway_noise.noise.get_noise_2d(player_position.x, player_position.y)
	return noise_location
	
func _attack() -> void:
	if !can_shoot:
		return
	
	can_shoot = false
	_reser_attack()
	
	weapon_fired.emit()
	var camera = Global.player.CAMERA_CONTROLLER
	var space_state = camera.get_world_3d().direct_space_state
	var screen_center = get_viewport().size / 2
	var origin = camera.project_ray_origin(screen_center)
	var end = origin + camera.project_ray_normal(screen_center) * 1000
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_bodies = true
	var result = space_state.intersect_ray(query)
	if result:
		_bullet_hole(result.get("position"), result.get("normal"))
		
func _reser_attack() -> void:
	await get_tree().create_timer(shoot_time).timeout
	can_shoot = true

func _bullet_hole(position: Vector3, normal: Vector3) -> void:
	var instance = raycast_test.instantiate()
	get_tree().root.add_child(instance)
	instance.global_position = position
	instance.look_at(instance.global_transform.origin + normal, Vector3.UP)
	if normal != Vector3.UP and normal != Vector3.DOWN:
		instance.rotate_object_local(Vector3(1, 0, 0), 90)
	await get_tree().create_timer(2).timeout
	var fade = get_tree().create_tween()
	fade.tween_property(instance, "modulate:a", 0, 1.5)
	await get_tree().create_timer(1.5).timeout
	instance.queue_free()









