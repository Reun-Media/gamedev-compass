extends "res://scenes/entity/player/bullet/bullet.gd"

func destroy() -> void:
	$MeshInstance3D.visible = false
	$OmniLight3D.visible = false
	$GPUParticles3D.emitting = false
	super.destroy()
