extends CharacterBody3D

@export var speed := 5.0
@export var gravity := 9.8
@export var mouse_sensitivity := 0.002
@export var max_look_up := 80.0  # Maximum upward look angle in degrees
@export var max_look_down := 80.0  # Maximum downward look angle in degrees

@onready var head := $Head
@onready var camera := $Head/Camera3D

var rotation_x := 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		# Clamp the vertical rotation to prevent seeing through floor and character model
		var new_rotation_x = rotation_x - event.relative.y * mouse_sensitivity
		new_rotation_x = clamp(new_rotation_x,
			deg_to_rad(-max_look_down), deg_to_rad(max_look_up))

		# Additional check to prevent camera from going through floor
		if new_rotation_x < 0:  # Looking down
			var camera_global_pos = camera.global_position
			var look_direction = -camera.global_transform.basis.z
			var space_state = get_world_3d().direct_space_state
			var query = PhysicsRayQueryParameters3D.create(
				camera_global_pos,
				camera_global_pos + look_direction * 2.0
			)
			var result = space_state.intersect_ray(query)

			# If we would hit the floor too close, limit the rotation
			if result and result.position.distance_to(camera_global_pos) < 1.0:
				new_rotation_x = max(new_rotation_x, deg_to_rad(-60))  # Limit to -60 degrees

		rotation_x = new_rotation_x
		head.rotation.x = rotation_x

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction != Vector3.ZERO:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
