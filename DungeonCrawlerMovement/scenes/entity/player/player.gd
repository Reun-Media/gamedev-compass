extends Spatial

const TRAVEL_TIME := 0.3

onready var front_ray := $FrontRay
onready var back_ray := $BackRay
onready var animation := $Animation

var tween

func _physics_process(delta):
	if tween is SceneTreeTween:
		if tween.is_running():
			return
	if Input.is_action_pressed("forward") and not front_ray.is_colliding():
		tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "transform", transform.translated(Vector3.FORWARD * 2), TRAVEL_TIME)
		animation.play("headbob")
	if Input.is_action_pressed("back") and not back_ray.is_colliding():
		tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "transform", transform.translated(Vector3.BACK * 2), TRAVEL_TIME)
		animation.play("headbob")
	if Input.is_action_pressed("left"):
		tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "transform:basis", transform.basis.rotated(Vector3.UP, PI / 2), TRAVEL_TIME)
	if Input.is_action_pressed("right"):
		tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "transform:basis", transform.basis.rotated(Vector3.UP, -PI / 2), TRAVEL_TIME)
