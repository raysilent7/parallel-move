extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var particles: GPUParticles2D = $GPUParticles2D
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

@export var min_speed: float = 1.0     
@export var max_speed: float = 2.5     
@export var min_duration: float = 1.5  
@export var max_duration: float = 4.0  
@export var weight_inertia: float = 4.0 

var target_speed: float = 0.0
var current_speed: float = 0.0
var action_timer: float = 0.0

func _ready() -> void:
	choose_next_action()

func _process(delta: float) -> void:
	if sprite == null: return
	
	current_speed = lerp(current_speed, target_speed, weight_inertia * delta)
	sprite.rotation += current_speed * delta
	
	action_timer -= delta
	if action_timer <= 0:
		choose_next_action()

func choose_next_action() -> void:
	var random_choice = randi() % 3
	
	match random_choice:
		0:
			target_speed = 0.0
			if particles:
				particles.emitting = false
			if audio_player:
				audio_player.stop()
			
		1, 2:
			if random_choice == 1:
				target_speed = -randf_range(min_speed, max_speed)
			else:
				target_speed = randf_range(min_speed, max_speed)
			
			if particles:
				particles.emitting = true

			if audio_player and not audio_player.playing:
				audio_player.play()
			
	action_timer = randf_range(min_duration, max_duration)
