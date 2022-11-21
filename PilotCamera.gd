extends CharacterBody3D

@export var pilot_active = false
@export var mouse_axis = Vector2.ZERO
@export var roll_rotation = 0.0
@onready var viewport_container = get_tree().root.get_node("Node3D/SubViewportContainer")
@onready var outside_camera_3d: Camera3D = get_node("Camera3D")
@onready var distant_camera: CharacterBody3D = viewport_container.get_node("Skybox/CharacterBody3D")
@onready var distant_camera_3d: Camera3D = distant_camera.get_node("Camera3D")
@onready var gui = get_tree().root.get_node("Node3D/CanvasLayer")

const SPEED = 0.3
const ACCELERATION = 0.5
const ROLL_SPEED = 0.1
const SENSITIVITY = 0.05
const DECELERATION = 3.0
const TURN_SPEED = 0.1

var angular_velocity: Quaternion

func _input(event: InputEvent):
  if pilot_active:
    if event is InputEventMouseMotion:
      # Grab the mouse input
      mouse_axis.y = fmod(mouse_axis.y - clamp(event.relative.y * SENSITIVITY, -TURN_SPEED, TURN_SPEED), 360)
      mouse_axis.x = fmod(mouse_axis.x - clamp(event.relative.x * SENSITIVITY, -TURN_SPEED, TURN_SPEED), 360)

func _physics_process(delta):
  var direction = (transform.basis * Vector3(0, 0, 0)).normalized()
  if pilot_active and gui.visible == false:
    
    # Grab Q and E input for barrel roll
    if Input.is_action_pressed("pilot_roll_left"): roll_rotation = ROLL_SPEED
    if Input.is_action_pressed("pilot_roll_right"): roll_rotation = -ROLL_SPEED
    
    # The magic math to point us in the right direction
    var rotation_vec = Vector3(deg_to_rad(mouse_axis.y), deg_to_rad(mouse_axis.x), roll_rotation) * delta
    var relative_velocity = Quaternion(rotation_vec)
    angular_velocity = (angular_velocity * relative_velocity).slerp(Quaternion.IDENTITY, 0.15)
    var current_rotation = Quaternion(transform.basis)
    var final_rotation = current_rotation * angular_velocity
    transform.basis = Basis(final_rotation)
    transform = transform.orthonormalized()
    
    # Apply the same transform to the distant camera
    distant_camera.transform = transform
    
    # Decelerate
    mouse_axis.x = lerp(mouse_axis.x, 0.0, DECELERATION * delta)
    mouse_axis.y = lerp(mouse_axis.y, 0.0, DECELERATION * delta)
    roll_rotation = lerp(roll_rotation, 0.0, DECELERATION * delta)
    
    # Perform movement in 3D space
    var input_dir = Input.get_vector("left", "right", "up", "down")
    direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    
  velocity.x = lerp(velocity.x, direction.x * SPEED, ACCELERATION * delta)
  velocity.y = lerp(velocity.y, direction.y * SPEED, ACCELERATION * delta)
  velocity.z = lerp(velocity.z, direction.z * SPEED, ACCELERATION * delta)
  move_and_slide()
