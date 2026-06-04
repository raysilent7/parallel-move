extends Node2D

@export var point_a: Node2D 
@export var point_b: Node2D 
@export var move_speed: float = 100.0 

@export var box_scene: PackedScene 
@export var min_hold_time: float = 2.0 
@export var max_hold_time: float = 5.0 
@export var spawn_delay: float = 2.0 

@export var spawn_inverted: bool = false

@export var cor_da_garra: Color = Color.WHITE 

@onready var arm_1 = $"arm 1"
@onready var arm_2 = $"arm 2"
@onready var box_spawn = $BoxSpawn
@onready var volante = $spin

var current_target: Vector2
var current_box: Node2D = null

var arm1_open_angle = deg_to_rad(30)
var arm1_closed_angle = 0.0
var arm2_open_angle = deg_to_rad(-30)
var arm2_closed_angle = 0.0

func _ready() -> void:
	arm_1.modulate = cor_da_garra
	arm_2.modulate = cor_da_garra
	if volante != null:
		volante.modulate = cor_da_garra

	open_arms(0.1)

	if point_a and point_b:
		global_position = point_a.global_position
		current_target = point_b.global_position

	start_box_cycle()

func _physics_process(delta: float) -> void:
	if point_a == null or point_b == null: return

	global_position = global_position.move_toward(current_target, move_speed * delta)

	if global_position.distance_to(current_target) < 1.0:
		if current_target == point_a.global_position:
			current_target = point_b.global_position
		else:
			current_target = point_a.global_position

func start_box_cycle() -> void:
	while true:
		await get_tree().create_timer(spawn_delay).timeout
		
		spawn_box()
		close_arms()
		
		var hold_time = randf_range(min_hold_time, max_hold_time)
		await get_tree().create_timer(hold_time).timeout
		
		drop_box()
		open_arms()

func spawn_box() -> void:
	if box_scene == null: return
		
	current_box = box_scene.instantiate()
	
	if spawn_inverted:
		current_box.inverted = true
	
	box_spawn.add_child(current_box)
	current_box.position = Vector2.ZERO 
	
	current_box.rotation = 0
	current_box.scale = Vector2(1, 1)
	
	current_box.set_physics_process(false)
	var inner_body = current_box.get_node_or_null("boxBody")
	if inner_body:
		inner_body.velocity = Vector2.ZERO

func drop_box() -> void:
	if current_box != null:
		current_box.reparent(get_parent())
		
		current_box.rotation = 0
		current_box.scale = Vector2(1, 1)
		
		var inner_body = current_box.get_node_or_null("boxBody")
		if inner_body:
			inner_body.velocity = Vector2.ZERO
		
		current_box.set_physics_process(true)
			
		current_box = null

func open_arms(duration: float = 0.3) -> void:
	var tween = create_tween().set_parallel(true).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(arm_1, "rotation", arm1_open_angle, duration)
	tween.tween_property(arm_2, "rotation", arm2_open_angle, duration)

func close_arms(duration: float = 0.2) -> void:
	var tween = create_tween().set_parallel(true).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(arm_1, "rotation", arm1_closed_angle, duration)
	tween.tween_property(arm_2, "rotation", arm2_closed_angle, duration)
