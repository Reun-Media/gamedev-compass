extends CharacterBody3D

const SPEED = 2.0
const JUMP_VELOCITY = 3.0
const LOOK_SENS  := 0.2

@onready var camera := $Camera3D
@onready var sub_viewport := $SubViewport
@onready var light_detection := $SubViewport/LightDetection
@onready var texture_rect := $TextureRect
@onready var color_rect := $ColorRect
@onready var light_level := $LightLevel

# Get the gravity from the project settings to be synced with RigidBody nodes
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var mouse_delta : Vector2

func _ready() -> void:
	# Capture mouse cursor for mouse look
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# Make SubViewport render lighting only
	sub_viewport.debug_draw = 2

func _physics_process(delta: float) -> void:	
	# Add gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	# Handle jumping
	if Input.is_action_just_pressed("jump"): # Removed is_on_floor check for testing
		velocity.y = JUMP_VELOCITY
	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()

func _process(delta: float) -> void:
	# Mouse look
	camera.rotate_x(-mouse_delta.y * LOOK_SENS * delta) # Rotate the camera around X axis using mouse delta
	camera.rotation.x = clamp(camera.rotation.x, -PI / 2, PI / 2) # Clamp camera X rotation between -90 and 90 degrees
	rotate_y(-mouse_delta.x * LOOK_SENS * delta) # Rotate the player around Y axis using mouse delta
	mouse_delta = Vector2.ZERO # Reset mouse delta so that only the last frame's relative motion is used
	
	# Light detection
	light_detection.global_position = global_position # Make light detection follow the player
	var texture = sub_viewport.get_texture() # Get the ViewportTexture from the SubViewport
	texture_rect.texture = texture # Display this texture on the TextureRect
	var color = get_average_color(texture) # Get the average color of the ViewportTexture
	color_rect.color = color # Display the average color on the ColorRect
	light_level.value = color.get_luminance() # Use the average color's brighness as the light level value
	light_level.tint_progress.a = color.get_luminance() # Also tint the progress texture with the above

func _input(event: InputEvent) -> void:
	# Record relative mouse motion in mouse_delta
	if event is InputEventMouseMotion:
		mouse_delta = event.relative

func get_average_color(texture: ViewportTexture) -> Color:
	var image = texture.get_image() # Get the Image of the input texture
	image.resize(1, 1, Image.INTERPOLATE_LANCZOS) # Resize the image to one pixel
	return image.get_pixel(0, 0) # Read the color of that pixel
