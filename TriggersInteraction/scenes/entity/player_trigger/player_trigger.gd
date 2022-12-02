extends Area

export(NodePath) var node_path
export(String) var enter_method
export(String) var exit_method

func _on_body_entered(body):
	if body is Player:
		if node_path:
			if get_node_or_null(node_path) != null:
				if get_node(node_path).has_method(enter_method):
					get_node(node_path).call(enter_method)
				else:
					printerr("Trigger node missing method")
			else:
				printerr("Trigger couldn't get node")
		else:
			printerr("Trigger node path empty")


func _on_body_exited(body):
	if body is Player:
		if node_path:
			if get_node_or_null(node_path) != null:
				if get_node(node_path).has_method(exit_method):
					get_node(node_path).call(exit_method)
				else:
					printerr("Trigger node missing method")
			else:
				printerr("Trigger couldn't get node")
		else:
			printerr("Trigger node path empty")
