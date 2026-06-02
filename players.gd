extends CharacterBody3D

const RAY_LENGTH = 20.0

@onready var _camera = $SpringArm3D/Camera3D2 as Camera3D
@onready var _floor = $"../Floor" as Node3D
@onready var _head = $Character/Rig/Skeleton3D/Mage_Head as MeshInstance3D
@onready var _headBNone = $Character/Rig/Skeleton3D/head as BoneAttachment3D
@onready var _animation = $Character/AnimationPlayer as AnimationPlayer
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

func _ready() -> void:
	#_head.visible = false
	_animation.get_animation("Idle").loop_mode = Animation.LOOP_LINEAR
	_animation.play("Idle")
	navigation_agent.path_desired_distance = 0.0
	navigation_agent.target_desired_distance = 0.2
	
	
var movement_speed: float = 2.0
func _physics_process(delta: float) -> void:
	#var input_dir := Input.get_vector("move_left", "move_righ", "move_front", "move_back")
	
	
	_cast()
	if !navigation_agent.is_navigation_finished():
		var current_agent_position: Vector3 = global_position
		var next_path_position: Vector3 = navigation_agent.get_next_path_position()
		velocity = current_agent_position.direction_to(next_path_position) * movement_speed
		#print(global_position)
	else : 
		velocity = Vector3.ZERO
			
	move_and_slide()

func _cast() -> void:
	if (Input.is_action_just_released("move")) :
		var mouse = get_viewport().get_mouse_position()
		var from = _camera.project_ray_origin(mouse)
		var to = from + _camera.project_ray_normal(mouse) * RAY_LENGTH
		var query = PhysicsRayQueryParameters3D.create(from,to)
		var result = get_world_3d().direct_space_state.intersect_ray(query)
		if !result.is_empty() :
			print(result)
			if (result["collider"] as StaticBody3D).collision_layer & 256 : # layer 9 
				navigation_agent.set_target_position(result["position"])
				print(global_position)
				print(result["position"])
	
	
#func _unhandled_input(event: InputEvent) -> void:
	#print(event)
const tilt_limit = deg_to_rad(50)
const mouse_sensitivity = 0.01

var _previous_mouse_position : Vector2

func _unhandled_input(event: InputEvent) -> void:
	
	if event is InputEventMouseButton and Input.is_action_just_pressed("move_camera"):
		_previous_mouse_position = (event as InputEventMouseButton).position
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event is InputEventMouseButton and Input.is_action_just_released("move_camera") :
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		Input.warp_mouse(_previous_mouse_position)
	elif event is InputEventMouseMotion and Input.is_action_pressed("move_camera"):
		_camera.rotation.x -= event.relative.y * mouse_sensitivity
		_camera.rotation.x = clampf(_camera.rotation.x, -tilt_limit, tilt_limit)
		_camera.rotation.y += -event.relative.x * mouse_sensitivity
		#_headBNone.rotation.x = -_camera.rotation.x 
		#_headBNone.rotation.y = _camera.rotation.y 
		#_headBNone.rotation.x += event.relative.y * mouse_sensitivity
		#_headBNone.rotation.y += -event.relative.x * mouse_sensitivity
