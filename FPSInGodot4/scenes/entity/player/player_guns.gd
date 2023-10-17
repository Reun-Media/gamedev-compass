extends Node3D

signal gun_changed(value: Gun)

@onready var bullets: Node3D = $"../Bullets"

var current_gun: Gun

func _ready() -> void:
	current_gun = get_child(0)
	equip_gun.call_deferred(0)

func _process(_delta: float) -> void:
	# Fire input is in process to enable repeat firing when holding the button
	if Input.is_action_pressed("fire"):
		current_gun.fire()

func _unhandled_input(event: InputEvent) -> void:
	# Weapon cycling
	if event.is_action_pressed("weapon_next"):
		equip_gun(current_gun.get_index() + 1)
	elif event.is_action_pressed("weapon_previous"):
		equip_gun(current_gun.get_index() - 1)

func equip_gun(index: int) -> void:
	for node in get_children():
		node.visible = false
	# Wrap the value to repeat the order and avoid invalid indexes
	current_gun = get_child(wrapi(index, 0, get_child_count()))
	current_gun.visible = true
	gun_changed.emit(current_gun)
