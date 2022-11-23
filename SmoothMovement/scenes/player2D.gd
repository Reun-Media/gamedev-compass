extends KinematicBody2D

export var speed := 1000.0
export var gravity := 2000.0
export var jump_power := 2000.0
export var h_accel:= 5000.0
export var v_accel := 5000.0

var movement_vector := Vector2.ZERO

func _physics_process(delta) -> void:
	# Horizontal movement
	var horizontal_input = Input.get_axis("left", "right")
	horizontal_input *= speed
	movement_vector.x = move_toward(movement_vector.x, horizontal_input, h_accel * delta)
	# Vertical movement
	movement_vector.y = move_toward(movement_vector.y, gravity, v_accel * delta)
	if Input.is_action_just_pressed("jump") and is_on_floor():
		movement_vector.y = -jump_power
	# Move
	movement_vector = move_and_slide(movement_vector, Vector2.UP)
