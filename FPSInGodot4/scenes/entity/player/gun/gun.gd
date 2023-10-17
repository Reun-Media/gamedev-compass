class_name Gun
extends Node3D

signal ammo_changed(value)

const RAY_MAX = 100.0
const AIM_DISTANCE = 5.0
const FIRE_ANIM_NAME = "fire"

enum WeaponType {PROJECTILE, RAYCAST}

@export var display_name: String
@export var gun_icon: Texture2D
@export var ammo := 0:
	set(value):
		ammo = value
		ammo_changed.emit(ammo)
@export var use_ammo := true
@export var weapon_type := WeaponType.PROJECTILE
@export var bullet_scene : PackedScene
@export var fire_rate := 0.2
@export var fire_delay := 0.0

@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var shoot_point: Marker3D = $ShootPoint

var rate_timer := Timer.new()

func _ready() -> void:
	rate_timer.one_shot = true
	add_child(rate_timer)
	visible = false

func fire() -> void:
	if !visible:
		return
	if !rate_timer.is_stopped():
		return
	if use_ammo and ammo <= 0:
		return
	ammo -= 1
	rate_timer.start(fire_rate)
	if animation.has_animation(FIRE_ANIM_NAME):
		if animation.is_playing() and animation.current_animation == FIRE_ANIM_NAME:
			animation.seek(0.0)
		animation.play(FIRE_ANIM_NAME)
	get_tree().create_timer(fire_delay).timeout.connect(create_bullet)

func create_bullet() -> void:
	var bullet := bullet_scene.instantiate() as Node3D
	get_parent().bullets.add_child(bullet)
	if weapon_type == WeaponType.PROJECTILE:
		var space = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(global_position, (-global_transform.basis.z * RAY_MAX) + global_position)
		var result = space.intersect_ray(query)
		var target_pos = (-global_transform.basis.z * RAY_MAX) + global_position
		if result:
			var distance = shoot_point.global_position.distance_to(result.position)
			if distance < AIM_DISTANCE:
				target_pos = (-global_transform.basis.z * AIM_DISTANCE) + global_position
			else:
				target_pos = result.position
		bullet.look_at_from_position(shoot_point.global_position, target_pos)
