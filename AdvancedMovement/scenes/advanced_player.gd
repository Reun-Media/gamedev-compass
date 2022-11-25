extends KinematicBody

export var speed := 7.0
export var running_speed := 15.0
export var gravity := -20.0
export var jump_power := 15.0
export var h_accel := 35.0
export var v_accel := 35.0
export var max_jumps := 2
export var jump_delay := 0.2
export var water_multiplier := 0.5

var movement_vector := Vector3.ZERO
var jump_amount := max_jumps
var jump_timer := Timer.new()
var in_water := false

func _ready():
	add_child(jump_timer)
	jump_timer.one_shot = true
	jump_timer.connect("timeout", self, "jump_timer_timeout")

func _physics_process(delta) -> void:
	var modifier := 1.0
	if in_water:
		modifier *= water_multiplier
	# Horizontal movement
	var horizontal_input := Vector3.ZERO
	horizontal_input.x = Input.get_axis("down", "up")
	horizontal_input.z = Input.get_axis("left", "right")
	horizontal_input = horizontal_input.limit_length(1.0)
	horizontal_input *= running_speed if Input.is_action_pressed("run") else speed
	horizontal_input.y = movement_vector.y
	movement_vector = movement_vector.move_toward(horizontal_input, h_accel * delta)
	# Vertical movement
	movement_vector.y = move_toward(movement_vector.y, gravity, v_accel * delta)
	if is_on_floor():
		jump_amount = max_jumps
		jump_timer.stop()
	elif jump_timer.is_stopped() and jump_amount == max_jumps:
		jump_timer.start(jump_delay)
	if Input.is_action_just_pressed("jump") and jump_amount > 0:
		movement_vector.y = jump_power
		jump_amount -= 1
		jump_timer.stop()
	# Move
	movement_vector = move_and_slide(movement_vector * modifier, Vector3.UP)
	movement_vector /= modifier

func jump_timer_timeout():
	jump_amount -= 1
