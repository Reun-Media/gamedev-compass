extends Node3D

signal enemy_spawned(enemy)

const ENEMY_LIMIT = 50

@export var enabled := true
@export var enemy_to_spawn : PackedScene
@export var spawn_interval := 10.0
@export var spawn_speedup := 0.98
@export var spawn_speed_limit := 2.0

var player
var spawn_points : Array[Node]

func _ready() -> void:
	spawn_points = get_children()
	get_tree().create_timer(1.0).timeout.connect(spawn)

func spawn() -> void:
	if enabled and player and !get_tree().paused:
		if get_tree().get_nodes_in_group("Enemy").size() < 50:
			var enemy := enemy_to_spawn.instantiate() as Enemy
			enemy.player = player
			enemy.transform = find_furthest_marker().global_transform
			add_sibling(enemy)
			enemy_spawned.emit(enemy)
			spawn_interval *= spawn_speedup
			spawn_interval = max(spawn_interval, spawn_speed_limit)
	get_tree().create_timer(spawn_interval).timeout.connect(spawn)

func find_furthest_marker() -> Marker3D:
	var furthest_marker = spawn_points[0]
	var furthest_distance = 0
	for marker in spawn_points:
		var distance = marker.global_position.distance_to(player.global_position)
		if distance > furthest_distance:
			furthest_marker = marker
			furthest_distance = distance
	return furthest_marker
