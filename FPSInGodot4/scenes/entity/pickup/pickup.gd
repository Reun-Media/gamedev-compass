class_name Pickup
extends Area3D

const TIMEOUT_ANIM_NAME = "timeout"

enum PickupType {GUN, HEALTH}

@export var pickup_type : PickupType
@export var gun_scene : PackedScene
@export var health_add_amount : float
@export var timeout_time := 20.0

@onready var timeout_animation: AnimationPlayer = $TimeoutAnimation

func _ready() -> void:
	var timeout_anim_time := timeout_animation.get_animation(TIMEOUT_ANIM_NAME).length
	get_tree().create_timer(timeout_time - timeout_anim_time).timeout.connect(on_timeout)

func on_pickup(body: Node3D) -> void:
	match pickup_type:
		PickupType.GUN:
			if body is Player:
				var gun = gun_scene.instantiate()
				if body.guns.has_node(str(gun.name)):
					body.guns.get_node(str(gun.name)).ammo += gun.ammo
					gun.queue_free()
				body.guns.add_child(gun)
				body.overlay(body.PICKUP_ANIM)
		PickupType.HEALTH:
			if body is Player:
				body.health += health_add_amount
	queue_free()

func on_timeout() -> void:
	timeout_animation.play(TIMEOUT_ANIM_NAME)
	timeout_animation.animation_finished.connect(func(anim_name): if anim_name == TIMEOUT_ANIM_NAME: queue_free())
