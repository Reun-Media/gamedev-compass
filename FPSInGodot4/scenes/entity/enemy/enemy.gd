class_name Enemy
extends CharacterBody3D

signal destroyed(score)

@export var score_value := 1
@export var hit_effect : PackedScene
@export var dead_enemy : PackedScene
@export var bullet_scene : PackedScene
@export var death_effect: PackedScene
@export var fire_rate := 1.0
@export var health := 100.0:
	set(value):
		health = value
		if health <= 0:
			destroy()
@onready var center_point: Marker3D = $CenterPoint
var player : Player

func _ready() -> void:
	add_to_group("Enemy")

func hit(damage: float, point: Vector3) -> void:
	health -= damage
	var effect = hit_effect.instantiate() as Node3D
	# The effect particles are more numerous based on bullet damage
	effect.strength = damage
	add_sibling(effect)
	effect.global_position = point
	# Turn the effect to face the center of the enemy
	effect.look_at(effect.global_position + (point - center_point.global_position))

func destroy() -> void:
	destroyed.emit(score_value)
	var effect = death_effect.instantiate()
	if dead_enemy:
		var dead = dead_enemy.instantiate() as RigidBody3D
		add_sibling(dead)
		# Add a bit of believeable motion to the dead enemy
		dead.apply_impulse(-velocity)
		dead.apply_impulse(Vector3(randf(), 0, randf()))
		dead.global_transform = global_transform
		dead.add_child(effect)
	else:
		add_sibling(effect)
	effect.global_transform = center_point.global_transform
	queue_free()

func has_sight_of_player() -> bool:
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(center_point.global_position, player.center_point.global_position)
	query.exclude = [self.get_rid()]
	var result = space_state.intersect_ray(query)
	if result and result.collider == player:
		return true
	else:
		return false
