extends Node2D # 🛠️ JUJUBA: Mudado para Node2D porque o script está no nó pai!

# Pega automaticamente a referência do nó de partículas que está logo abaixo dele
@onready var particles: GPUParticles2D = $GPUParticles2D

# ⚙️ CONFIGURAÇÕES AJUSTÁVEIS NO INSPETOR (Painel da Direita)
@export var min_idle_time: float = 3.0  
@export var max_idle_time: float = 7.0  
@export var min_leak_time: float = 2.0  
@export var max_leak_time: float = 5.0  

var state_timer: float = 0.0
var is_leaking: bool = false

func _ready() -> void:
	print("💨 [FUMAÇA] Sistema de vazamento aleatório iniciado!")
	
	# Verificação de segurança para garantir que o nó filho tem o nome correto
	if particles == null:
		print("❌ [FUMAÇA ERRO] Não encontrei o nó filho com o nome 'GPUParticles2D'!")
		
	choose_next_state()

func _process(delta: float) -> void:
	state_timer -= delta
	if state_timer <= 0:
		choose_next_state()

func choose_next_state() -> void:
	is_leaking = not is_leaking
	
	# 🛠️ JUJUBA: Agora controlamos o 'emitting' apontando para as partículas filhas!
	if particles:
		particles.emitting = is_leaking 
	
	if is_leaking:
		state_timer = randf_range(min_leak_time, max_leak_time)
		print("🔥 [FUMAÇA] Canos quentes! Vazamento ATIVADO por: ", state_timer, "s.")
	else:
		state_timer = randf_range(min_idle_time, max_idle_time)
		print("⏸️ [FUMAÇA] Pressão normalizada. Próximo estouro em: ", state_timer, "s.")
