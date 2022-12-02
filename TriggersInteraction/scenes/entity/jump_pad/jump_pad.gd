extends Area

export var power_vector : Vector3

func _ready():
	$Particles.process_material.direction = power_vector.limit_length(2.0)


func _on_body_entered(body):
	if body is Player:
		body.movement_vector = power_vector
		$AnimationPlayer.play("jump")
