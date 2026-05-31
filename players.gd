extends CharacterBody3D

const RAY_LENGTH = 20.0

@onready var _camera = $"../Camera3D" as Camera3D

func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_righ", "move_front", "move_back")
	
	_cast()
	
	move_and_slide()

func _cast() -> void:
	var mouse = get_viewport().get_mouse_position()
	var from = _camera.project_ray_origin(mouse)
	var to = from + _camera.project_ray_normal(mouse) * RAY_LENGTH
	var query = PhysicsRayQueryParameters3D.create(from,to)
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	if !result.is_empty() :
		
		if result["collider"] != self :
			self.position = result["position"]
			print(result["position"])
	
	
#func _unhandled_input(event: InputEvent) -> void:
	#print(event)
