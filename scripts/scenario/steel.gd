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
	print("⚙️💨🎵 [STEEL] Sistema unificado com ÁUDIO inicializado!")
	
	if sprite == null: print("❌ [ERRO] Não encontrei o nó 'Sprite2D'.")
	if particles == null: print("❌ [ERRO] Não encontrei o nó 'GPUParticles2D'.")
	if audio_player == null: print("❌ [ERRO] Não encontrei o nó 'AudioStreamPlayer2D'.")
		
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
			# ESTADO: Parado (Fecha a válvula, cessa a fumaça e PARA o som!)
			target_speed = 0.0
			if particles:
				particles.emitting = false
			if audio_player:
				audio_player.stop() # Parou o vazamento, corta o som na hora!
			print("⏸️ [VÁLVULA] Parada. Fumaça e ÁUDIO desativados.")
			
		1, 2:
			# ESTADO 1 ou 2: Girar (Ativa a fumaça e TOCA o som!)
			if random_choice == 1:
				target_speed = -randf_range(min_speed, max_speed)
				print("⬅️ [VÁLVULA] Girando Esquerda. Fumaça ATIVADA!")
			else:
				target_speed = randf_range(min_speed, max_speed)
				print("➡️ [VÁLVULA] Girando Direita. Fumaça ATIVADA!")
			
			if particles:
				particles.emitting = true
				
			# 🎵 JUJUBA: SÓ DA PLAY SE O SOM JÁ NÃO ESTIVER TOCANDO!
			# Isso evita que o som dê um corte seco e recomece do zero se a válvula apenas mudar de lado
			if audio_player and not audio_player.playing:
				audio_player.play()
				print("🔊 [ÁUDIO] Som de vazamento iniciado!")
			
	action_timer = randf_range(min_duration, max_duration)
