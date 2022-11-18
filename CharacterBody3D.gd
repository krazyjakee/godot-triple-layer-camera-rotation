extends CharacterBody3D

var pilot_mode = false
var mouse_rotation = Vector2.ZERO
var disable_input = false
const SENSITIVITY = 0.1
const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var head = get_node("Head")
@onready var outside_camera = get_tree().root.get_node("Node3D/SubViewportContainer/Space/CharacterBody3D")
@onready var distant_camera = get_tree().root.get_node("Node3D/SubViewportContainer/Skybox/CharacterBody3D")
@onready var gui = get_tree().root.get_node("Node3D/CanvasLayer")
@onready var hud = get_tree().root.get_node("Node3D/CanvasLayer2")
@onready var pilot_label: Label = hud.get_node("Label")

func _ready():
  Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
  
func _input(event):
  if !disable_input:
    if event is InputEventMouseMotion:
      mouse_rotation.y = event.relative.x * SENSITIVITY
      mouse_rotation.x = event.relative.y * SENSITIVITY
      
  if Input.is_action_just_pressed("escape"):
    disable_input = !disable_input
    gui.visible = !gui.visible
    var mouse_mode = Input.MOUSE_MODE_VISIBLE if gui.visible else Input.MOUSE_MODE_CAPTURED
    Input.set_mouse_mode(mouse_mode)
  else:
    if Input.is_action_just_pressed("drive"):
      disable_input = !disable_input
      pilot_mode = !pilot_mode
      outside_camera.pilot_active = !outside_camera.pilot_active
      pilot_label.text = "Pilot Mode: On" if pilot_mode else "Pilot Mode: Off"

func _physics_process(delta):
  # Add the gravity.
  if not is_on_floor():
    velocity.y -= gravity * delta
  
  if !pilot_mode:
    # Handle Jump.
    if Input.is_action_just_pressed("jump") and is_on_floor():
      velocity.y = JUMP_VELOCITY

    # Get the input direction and handle the movement/deceleration.
    # As good practice, you should replace UI actions with custom gameplay actions.
    var input_dir = Input.get_vector("left", "right", "up", "down")
    var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    if direction:
      velocity.x = direction.x * SPEED
      velocity.z = direction.z * SPEED
    else:
      velocity.x = move_toward(velocity.x, 0, SPEED)
      velocity.z = move_toward(velocity.z, 0, SPEED)
      
    rotate_cameras(delta)

  move_and_slide()

func rotate_cameras(delta: float):
  var look_angle = Vector2(-mouse_rotation.x * delta, -mouse_rotation.y * delta)
  
  # Handle look left and right
  rotate_object_local(Vector3(0, 1, 0), look_angle.y)
  
  # Handle look up and down
  head.rotate_object_local(Vector3(1, 0, 0), look_angle.x)
  
  # Handle other cameras
  outside_camera.rotate_object_local(Vector3(1, 0, 0), look_angle.x)
  outside_camera.rotate_object_local(Vector3(0, 1, 0), look_angle.y)
  distant_camera.rotate_object_local(Vector3(1, 0, 0), look_angle.x)
  distant_camera.rotate_object_local(Vector3(0, 1, 0), look_angle.y)
    
  mouse_rotation = Vector2.ZERO
