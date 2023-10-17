extends Node3D

@export var damage := 10.0
@export var speed : float
@export var life_span := 10.0

func _ready() -> void:
	get_tree().create_timer(life_span).timeout.connect(queue_free)

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		body.health -= damage
	queue_free()

func _physics_process(delta: float) -> void:
	translate(Vector3.FORWARD * speed * delta)
