extends Node3D

@export var pickup_list : Array[PackedScene]
@export var spawn_delay := 25.0

var pickup_points : Array[Node]
var pickup_index := 0

func _ready() -> void:
	pickup_points = get_children()
	get_tree().create_timer(spawn_delay).timeout.connect(spawn_pickup)

func spawn_pickup() -> void:
	if get_tree().paused:
		return
	# Choose pickup and increment wrapping index
	var pickup = pickup_list[pickup_index].instantiate() as Pickup
	pickup_index = wrapi(pickup_index + 1, 0, pickup_list.size() - 1)
	add_sibling(pickup)
	pickup.global_position = pickup_points.pick_random().global_position
	get_tree().create_timer(spawn_delay).timeout.connect(spawn_pickup)
