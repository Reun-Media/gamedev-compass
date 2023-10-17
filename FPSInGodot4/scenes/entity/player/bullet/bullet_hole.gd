extends Decal

const FADE_TIME = 5.0

func _ready() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0, FADE_TIME)
	get_tree().create_timer(FADE_TIME).timeout.connect(queue_free)
	
