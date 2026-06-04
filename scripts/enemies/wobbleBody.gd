extends CharacterBody2D

# Jujuba: Configurações de física e status
@export var walk_speed: float = 40.0
@export var chase_speed: float = 120.0
@export var jump_velocity: float = -250.0
@export var hp: int = 1

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Jujuba: Controle de estados (Cérebro do Wobble)
var is_chasing: bool = false
var player_target = null
var current_direction: int = 1 # 1 para direita, -1 para esquerda

@onready var anim = $wobbleAnim
@onready var wander_timer = $WanderTimer

func _ready() -> void:
	# Jujuba: Coloca o Wobble num grupo para o Spawner conseguir contar quantos existem na tela!
	add_to_group("wobbles")
	
	# Jujuba: Configura o timer de ficar andando à toa e já dá o play
	wander_timer.timeout.connect(_on_wander_timer_timeout)
	wander_timer.start(randf_range(1.5, 3.5))

func _physics_process(delta: float) -> void:
	# Jujuba: Aplica a gravidade padrão do Godot
	if not is_on_floor():
		velocity.y += gravity * delta

	if is_chasing and player_target:
		# --- LÓGICA DE CAÇA ---
		var dir_to_player = sign(player_target.global_position.x - global_position.x)
		if dir_to_player != 0:
			current_direction = dir_to_player
		
		velocity.x = current_direction * chase_speed
		
		# Jujuba: Se ele estiver no chão e bater numa parede, ou aleatoriamente, ele pula pra cima do player!
		if is_on_floor() and (is_on_wall() or randi() % 100 < 3):
			velocity.y = jump_velocity
			
	else:
		# --- LÓGICA DE ANDAR DE BOBEIRA ---
		velocity.x = current_direction * walk_speed
		
		# Jujuba: Pula aleatoriamente de vez em quando se estiver no chão
		if is_on_floor() and randi() % 100 < 1:
			velocity.y = jump_velocity

	# Jujuba: Vira a animação para o lado certo dependendo de pra onde está andando
	if velocity.x != 0:
		anim.flip_h = velocity.x < 0

	move_and_slide()

# Jujuba: Quando o timer apitar, ele escolhe uma direção nova ou decide parar
func _on_wander_timer_timeout() -> void:
	if not is_chasing:
		current_direction = [-1, 0, 1].pick_random()
	# Reinicia o timer com um tempo aleatório
	wander_timer.start(randf_range(1.0, 3.0))


# --- LÓGICA DE VISÃO (DETECTION AREA) ---

func _on_detection_area_body_entered(body: Node2D) -> void:
	# Checa se quem entrou no raio de visão é um dos irmãos (Charles ou o Void)
	if body.name == "playerBody" or body.name == "playerBody2": 
		is_chasing = true
		player_target = body

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == player_target:
		is_chasing = false
		player_target = null
		current_direction = [-1, 1].pick_random() # Volta a andar à toa


# --- LÓGICA DE CAUSAR DANO (DAMAGE AREA) ---

func _on_damage_area_body_entered(body: Node2D) -> void:
	# Checa se quem encostou foi um dos irmãos
	if body.name == "playerBody" or body.name == "playerBody2":
		
		# Pega o nó pai do player (que é o seu Controller!)
		var controller = body.get_parent()
		
		# Chama a função death() que já está pronta lá no Controller
		if controller.has_method("death"):
			controller.death()
