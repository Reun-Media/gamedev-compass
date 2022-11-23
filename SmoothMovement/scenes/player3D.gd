extends KinematicBody

export var speed := 7.0
export var gravity := -20.0
export var jump_power := 15.0
export var h_accel := 35.0
export var v_accel := 35.0

var movement_vector := Vector3.ZERO

func _physics_process(delta) -> void:
	# Horizontal movement
	var horizontal_input := Vector3.ZERO
	horizontal_input.x = Input.get_axis("down", "up")
	horizontal_input.z = Input.get_axis("left", "right")
	horizontal_input = horizontal_input.limit_length(1.0)
	horizontal_input *= speed
	horizontal_input.y = movement_vector.y
	movement_vector = movement_vector.move_toward(horizontal_input, h_accel * delta)
	# Vertical movement
	movement_vector.y = move_toward(movement_vector.y, gravity, v_accel * delta)
	if Input.is_action_just_pressed("jump") and is_on_floor():
		movement_vector.y = jump_power
	# Move
	movement_vector = move_and_slide(movement_vector, Vector3.UP)
