class_name Player
extends CharacterBody3D

signal health_changed(value)
signal death

const MAX_HEALTH = 100.0
const SPEED = 6.0
const JUMP_VELOCITY = 5.0
const MOUSE_LOOK_SENS  = 0.002
const STICK_LOOK_SENS = 1500.0
const ACCELERATION = 40.0
const TERMINAL_VELOCITY = 50.0
const PICKUP_ANIM = "pickup"
const HIT_ANIM = "hit"

@onready var camera := $FirstPersonCamera
@onready var guns: Node3D = $FirstPersonCamera/SubViewportContainer/SubViewport/GunCamera/Guns
@onready var gun_camera: Camera3D = $FirstPersonCamera/SubViewportContainer/SubViewport/GunCamera
@onready var center_point: Marker3D = $CenterPoint
@onready var animation: AnimationPlayer = $AnimationPlayer
var using_controller := false

@export var health := MAX_HEALTH:
	set(value):
		# Overlay based on if health is being increased or reduced
		if health > value:
			overlay(HIT_ANIM)
		else:
			overlay(PICKUP_ANIM)
		health = clamp(value, 0, MAX_HEALTH)
		health_changed.emit(health)
		# When health runs out, the player emits a death signal
		if health <= 0:
			death.emit()

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var look_delta : Vector2
var camera_initial_offset : Vector3
var current_gun := 0

func _ready() -> void:
	# Setup for mouse look
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	# Horizontal movement
	var input_vector := Input.get_vector("left", "right", "forward", "back")
	var direction := (transform.basis * Vector3(input_vector.x, 0, input_vector.y)).limit_length()
	direction *= SPEED
	direction.y = velocity.y
	velocity = velocity.move_toward(direction, ACCELERATION * delta)
	# Vertical movement
	if not is_on_floor():
		velocity.y -= gravity * delta
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	velocity.y = max(velocity.y, -TERMINAL_VELOCITY)
	move_and_slide()

func _process(delta: float) -> void:
	# Controller look input
	if using_controller:
		look_delta.x = Input.get_axis("look_left", "look_right")
		look_delta.y = Input.get_axis("look_up", "look_down")
		look_delta = look_delta.limit_length() * STICK_LOOK_SENS * delta
	# Rotations for mouse look
	camera.rotate_x(-look_delta.y * MOUSE_LOOK_SENS)
	camera.rotation.x = clamp(camera.rotation.x, -PI / 2, PI / 2)
	rotate_y(-look_delta.x * MOUSE_LOOK_SENS)
	# Reset the mouse motion delta after rotations
	look_delta = Vector2.ZERO
	# Make the gun camera transform match the normal camera
	gun_camera.global_transform = camera.global_transform

func _input(event: InputEvent) -> void:
	# Record mouse motion delta to a variable
	# Also check if the player is using a mouse or a controller
	if event is InputEventMouseMotion:
		using_controller = false
		look_delta = event.relative
	if event is InputEventJoypadMotion:
		using_controller = true

# Visual overlays for damage and pickups
func overlay(anim_name: String = "RESET") -> void:
	animation.play(anim_name)
	animation.seek(0.0)
