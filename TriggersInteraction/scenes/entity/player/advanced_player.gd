class_name Player
extends KinematicBody

export var speed := 7.0
export var run_speed := 10.0
export var gravity := -20.0
export var jump_power := 15.0
export var h_accel := 35.0
export var v_accel := 35.0
export var jump_delay := 0.5
export var max_jumps := 2
export var water_multiplier := 0.5

var horizontal_input := Vector3.ZERO
var movement_vector := Vector3.ZERO
var movement_multiplier := 1.0
var jump_amount := max_jumps
var jump_timer := Timer.new()
var in_water := false
var interactables : Array
var closest_interactable

func _ready():
	add_child(jump_timer)
	jump_timer.one_shot = true
# warning-ignore:return_value_discarded
	jump_timer.connect("timeout", self, "jump_timer_timeout")

func _physics_process(delta) -> void:
	# Modifier
	var modifier := 1.0
	if in_water:
		modifier *= water_multiplier
	# Horizontal movement
	horizontal_input = Vector3.ZERO
	horizontal_input.x = Input.get_axis("down", "up")
	horizontal_input.z = Input.get_axis("left", "right")
	horizontal_input = horizontal_input.limit_length(1.0)
	# Running
	horizontal_input *= speed if !Input.is_action_pressed("run") else run_speed
	horizontal_input.y = movement_vector.y
	movement_vector = movement_vector.move_toward(horizontal_input, h_accel * delta)
	# Vertical movement
	movement_vector.y = move_toward(movement_vector.y, gravity, v_accel * delta)
	if is_on_floor():
		jump_amount = max_jumps
		jump_timer.stop()
	elif jump_timer.is_stopped() and jump_amount == max_jumps:
		# If not on floor, timer not running and haven't jumped yet, start timer
		jump_timer.start(jump_delay)
	if Input.is_action_just_pressed("jump") and jump_amount > 0:
		# Once you jump, timer is not needed
		jump_timer.stop()
		movement_vector.y = jump_power
		jump_amount -= 1
	# Move
	movement_vector = move_and_slide(movement_vector * modifier, Vector3.UP)
	movement_vector /= modifier
	# Interaction
	closest_interactable = find_closest_interactable()
	if Input.is_action_just_pressed("interact") and closest_interactable != null:
		closest_interactable.interact()

func find_closest_interactable():
	if interactables.size() < 1:
		return null
	elif interactables.size() > 1:
		var distance = INF
		var closest = interactables[0]
		for n in interactables:
			var new_distance = n.global_translation.distance_to(global_translation)
			if new_distance < distance:
				distance = new_distance
				closest = n
		return closest
	else:
		return interactables[0]

func jump_timer_timeout():
	jump_amount -= 1
