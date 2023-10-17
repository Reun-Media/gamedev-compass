extends "res://scenes/entity/enemy/enemy.gd"

const SPEED = 5.0
const TURN_SPEED = 5.0
const ACCELERATION = 40.0
const TERMINAL_VELOCITY = 50.0
const STOP_DISTANCE = 4.0
const MOVE_TARGET_TIMER = 0.1
const WHEEL_SPIN_SPEED = 2.5
const KNOCKBACK_POWER := 0.2
const KNOCKBACK_DECAY := 5.0
const KNOCKBACK_LIMIT := 10.0
const MAX_AIM_ANGLE := deg_to_rad(20.0)

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var barrel: MeshInstance3D = $capsule_enemy/Barrel
@onready var barrel_point: Marker3D = $capsule_enemy/Barrel/Point
@onready var wheel: MeshInstance3D = $capsule_enemy/Wheel


var target_timer := Timer.new()
var knockback_vector := Vector3.ZERO

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	super._ready()
	target_timer.timeout.connect(set_move_target)
	add_child(target_timer)
	target_timer.start(MOVE_TARGET_TIMER)
	get_tree().create_timer(fire_rate).timeout.connect(fire)

func set_move_target() -> void:
	# Await to fix issues with navigation
	await get_tree().physics_frame
	if player:
		nav_agent.target_position = player.global_position

func _physics_process(delta: float) -> void:
	var direction : Vector3
	if nav_agent.is_navigation_finished():
		direction = Vector3.ZERO
	else:
		direction = nav_agent.get_next_path_position() - global_position
		direction = direction.normalized()
	# Determine look direction
	var look_target := Vector3(direction.x + global_position.x, global_position.y, direction.z + global_position.z)
	var current_look := -transform.basis.z + global_position
	if nav_agent.distance_to_target() > STOP_DISTANCE:
		look_at(current_look.lerp(look_target, TURN_SPEED * delta))
	elif player:
		var player_target := Vector3(player.global_position.x, global_position.y, player.global_position.z)
		look_at(current_look.lerp(player_target, TURN_SPEED * delta))
		# If close enough to player, stop movement
		direction = Vector3.ZERO
	direction *= SPEED
	direction.y = velocity.y
	velocity = velocity.move_toward(direction, ACCELERATION * delta)
	# Vertical movement
	if not is_on_floor():
		velocity.y -= gravity * delta
	velocity.y = max(velocity.y, -TERMINAL_VELOCITY)
	# Knockback and move
	velocity += knockback_vector
	move_and_slide()
	velocity -= knockback_vector
	knockback_vector = knockback_vector.move_toward(Vector3.ZERO, delta * KNOCKBACK_DECAY)
	# Aim barrel
	if player:
		aim_barrel()
	# Spin wheel
	wheel.rotate_x((transform.basis.transposed() * velocity).z * delta * WHEEL_SPIN_SPEED)

func aim_barrel() -> void:
	barrel.look_at(player.center_point.global_position)
	barrel.rotation.x = clamp(barrel.rotation.x, deg_to_rad(-25), deg_to_rad(25))
	barrel.rotation.y = 0
	barrel.rotation.z = 0

func hit(damage: float, point: Vector3) -> void:
	super.hit(damage, point)
	knockback_vector = point.direction_to(center_point.global_position)
	knockback_vector *= damage * KNOCKBACK_POWER
	knockback_vector *= Vector3(1, 0, 1)
	knockback_vector = knockback_vector.limit_length(KNOCKBACK_LIMIT)

func fire() -> void:
	if get_tree().paused:
		return
	if super.has_sight_of_player():
		var barrel_direction = -barrel.global_transform.basis.z
		var player_direction = barrel.global_position.direction_to(player.center_point.global_position)
		if barrel_direction.angle_to(player_direction) < MAX_AIM_ANGLE:
			var bullet = bullet_scene.instantiate() as Node3D
			bullet.global_transform = barrel_point.global_transform
			bullet.scale = Vector3.ONE
			add_sibling(bullet)
			get_tree().create_timer(fire_rate).timeout.connect(fire)
			return
	get_tree().create_timer(0.5).timeout.connect(fire)
