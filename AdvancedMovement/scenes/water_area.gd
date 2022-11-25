extends Area

func _body_entered(body):
	if body.get("in_water") != null:
		body.in_water = true


func _body_exited(body):
	if body.get("in_water") != null:
		body.in_water = false
