extends Node3D
var strength := 1.0

func _ready() -> void:
	$GPUParticles3D.amount *= strength
