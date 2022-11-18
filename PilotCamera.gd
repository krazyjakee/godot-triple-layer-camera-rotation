extends CharacterBody3D

@export var pilot_active = false
@export var mouse_axis = Vector2.ZERO
@export var roll_rotation = 0.0
@onready var viewport_container = get_tree().root.get_node("Node3D/SubViewportContainer")
@onready var distant_camera: CharacterBody3D = viewport_container.get_node("Skybox/CharacterBody3D")
@onready var gui = get_tree().root.get_node("Node3D/CanvasLayer")

const SPEED = 0.3
const ACCELERATION = 0.5
const SENSITIVITY = 0.01
const MOUSE_PULL_CAP = 0.01
const DECELERATION = 3.0

func _input(event: InputEvent):
  if pilot_active:
    if event is InputEventMouseMotion:
      mouse_axis.y += clamp(event.relative.x * SENSITIVITY, -MOUSE_PULL_CAP, MOUSE_PULL_CAP)
      mouse_axis.x += clamp(event.relative.y * SENSITIVITY, -MOUSE_PULL_CAP, MOUSE_PULL_CAP)

func _process(delta):
  if pilot_active and gui.visible == false:    
    if Input.is_action_pressed("pilot_roll_left"): roll_rotation = ACCELERATION
    if Input.is_action_pressed("pilot_roll_right"): roll_rotation = -ACCELERATION
    
    rotate_object_local(Vector3(1, 0, 0), -mouse_axis.x * delta)
    rotate_object_local(Vector3(0, 1, 0), -mouse_axis.y * delta)
    rotate_object_local(Vector3(0, 0, 1), roll_rotation * delta)
    distant_camera.rotate_object_local(Vector3(1, 0, 0), -mouse_axis.x * delta)
    distant_camera.rotate_object_local(Vector3(0, 1, 0), -mouse_axis.y * delta)
    distant_camera.rotate_object_local(Vector3(0, 0, 1), roll_rotation * delta)
    
    mouse_axis.x = lerp(mouse_axis.x, 0.0, DECELERATION * delta)
    mouse_axis.y = lerp(mouse_axis.y, 0.0, DECELERATION * delta)
    roll_rotation = lerp(roll_rotation, 0.0, DECELERATION * delta)
    
    var input_dir = Input.get_vector("left", "right", "up", "down")
    var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    velocity.x = lerp(velocity.x, direction.x * SPEED, ACCELERATION * delta)
    velocity.y = lerp(velocity.y, direction.y * SPEED, ACCELERATION * delta)
    velocity.z = lerp(velocity.z, direction.z * SPEED, ACCELERATION * delta)
    move_and_slide()
