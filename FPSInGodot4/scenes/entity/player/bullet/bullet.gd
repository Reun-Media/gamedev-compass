extends Node3D

@export var damage := 20.0
@export var speed : float
@export var destroy_delay : float
@export var timeout_delay := 10.0
@export var bullet_hole : PackedScene
@export var bullet_hole_rot_start := -180.0
@export var bullet_hole_rot_end := 180.0
@export var area : Area3D
@export var raycast : RayCast3D
@export var piercing := false

func _ready() -> void:
	# If area and raycast are not manually set, try to find them
	if !area:
		var find = find_children("*", "Area3D", false)
		if !find.is_empty():
			area = find[0]
	if !raycast:
		var find = find_children("*", "RayCast3D", false)
		if !find.is_empty():
			raycast = find[0]
	get_tree().create_timer(timeout_delay).timeout.connect(queue_free)
	if area:
		area.body_entered.connect(hit)

func hit(body: PhysicsBody3D = null) -> void:
	# Disable the bullet once it hits something
	if area:
		area.set_deferred("monitoring", false)
	set_physics_process(false)
	# Set the body to be the raycast collider to reuse the logic
	if raycast and raycast.is_colliding():
		body = raycast.get_collider()
	create_bullet_hole(body)
	# Collision layer value 3 is the Enemy layer
	if body.get_collision_layer_value(3):
		# The hit functions are provided a position for secondary effects
		if raycast and raycast.is_colliding():
			body.hit(damage, raycast.get_collision_point())
		else:
			body.hit(damage, global_position)
		# Piercing bullets are duplicated
		if piercing:
			var new = duplicate()
			new.raycast.add_exception(body)
			await get_tree().physics_frame
			add_sibling(new)
	destroy()

func create_bullet_hole(body: PhysicsBody3D) -> void:
	var hole := bullet_hole.instantiate() as Decal
	# Add bullet holes on enemies as children
	if body.get_collision_layer_value(3):
		body.add_child(hole)
	else:
		add_sibling(hole)
		hole.top_level = true
	# Set the position to either the bullet or the raycast collision point
	hole.global_position = global_position
	if raycast and raycast.is_colliding():
		hole.global_position = raycast.get_collision_point()
	# Rotate the bullet hole randomly
	hole.rotate_object_local(Vector3.UP, deg_to_rad(randf_range(bullet_hole_rot_start, bullet_hole_rot_end)))

func _physics_process(delta: float) -> void:
	# Bullet movement
	translate(Vector3.FORWARD * speed * delta)
	# Trigger raycast collision
	if raycast and raycast.is_colliding():
		hit()

func destroy() -> void:
	get_tree().create_timer(destroy_delay).timeout.connect(queue_free)
