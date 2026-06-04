extends Node2D

@onready var particles: GPUParticles2D = $GPUParticles2D
@export var min_idle_time: float = 3.0  
@export var max_idle_time: float = 7.0  
@export var min_leak_time: float = 2.0  
@export var max_leak_time: float = 5.0  

var state_timer: float = 0.0
var is_leaking: bool = false

func _ready() -> void:
	choose_next_state()

func _process(delta: float) -> void:
	state_timer -= delta
	if state_timer <= 0:
		choose_next_state()

func choose_next_state() -> void:
	is_leaking = not is_leaking
	if particles:
		particles.emitting = is_leaking 
	if is_leaking:
		state_timer = randf_range(min_leak_time, max_leak_time)
	else:
		state_timer = randf_range(min_idle_time, max_idle_time)
