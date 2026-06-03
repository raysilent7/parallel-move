extends Node2D

@onready var p1 = $playerBody
@onready var p2 = $playerBody2

var baseSpeed: int = 100

# Jujuba: Variáveis de memória para saber a posição do frame passado
var last_p1_x: float = 0.0
var last_p2_x: float = 0.0

func _ready() -> void:
	GameState.lastCheckpointP1 = p1.global_position
	GameState.lastCheckpointP2 = p2.global_position
	
	# Jujuba: Salva a posição inicial para não dar puxão no primeiro segundo de jogo
	last_p1_x = p1.global_position.x
	last_p2_x = p2.global_position.x

func _physics_process(_delta) -> void:
	# --- CORREÇÃO DE PLATAFORMA ASSÍMETRICA ---
	# Jujuba: Se apenas UM dos players foi movido pela caixa (que está na plataforma),
	# arrasta o outro irmão junto no eixo X antes de calcular o resto da física!
	if p1.global_position.x != last_p1_x and p2.global_position.x == last_p2_x:
		p2.global_position.x += (p1.global_position.x - last_p1_x)
	elif p2.global_position.x != last_p2_x and p1.global_position.x == last_p1_x:
		p1.global_position.x += (p2.global_position.x - last_p2_x)
	# ------------------------------------------

	# Jujuba: Se os dois chegarem muito perto, o p2 consome o p1
	if p1.global_position.distance_to(p2.global_position) < 35:
		p1.animation.play("consumed")
		p2.animation.play("consuming")
		p1.set_physics_process(false)
		p2.set_physics_process(false)
		set_physics_process(false)
		return

	var inputDir = Input.get_axis("left", "right")
	var xSpeed = inputDir * baseSpeed

	# Jujuba: Se segurar para baixo, o boneco anda agachado, mas com metade da velocidade
	if Input.is_action_pressed("down"):
		xSpeed = inputDir * (baseSpeed / 2)

	# --- LÓGICA NOVA DA CAIXA ENTRA AQUI ---
	# Jujuba: Se QUALQUER UM dos dois players segurar a caixa, amarra a velocidade dos dois!
	if p1.isHoldingBox or p2.isHoldingBox:
		xSpeed = inputDir * 40 # Esse número precisa ser igual ao pushSpeed da Caixa!
	# ---------------------------------------

	# Jujuba: Se não apertar nada, manda parar. Senão, manda andar com a velocidade atual
	if inputDir == 0:
		p1.tryToMove(0)
		p2.tryToMove(0)
	else:
		p1.tryToMove(xSpeed)
		p2.tryToMove(xSpeed)

	# Jujuba: Sincroniza a posição X dos dois players para andarem perfeitamente alinhados
	if p1.global_position.x > p2.global_position.x or p1.global_position.x < p2.global_position.x:
		p1.global_position.x = p2.global_position.x
		p1.tryToMove(0)
		if p1.global_position.x > p2.global_position.x or p1.global_position.x < p2.global_position.x:
			p2.global_position.x = p1.global_position.x

	# Jujuba: Guarda a posição atual no final do frame para usarmos de referência na "trava magnética"
	last_p1_x = p1.global_position.x
	last_p2_x = p2.global_position.x


# Jujuba: Agora o player pode "morrer"
func death() -> void:
	p1.animation.play("death")
	p2.animation.play("void death")
	p1.set_physics_process(false)
	p2.set_physics_process(false)
	set_physics_process(false)

# Jujuba: Retorna os dois irmãos para a posição salva no checkpoint
func movePlayerToCheckPoint() -> void:
	p1.global_position = GameState.lastCheckpointP1
	p2.global_position = GameState.lastCheckpointP2

# Jujuba: Aplica a inversão de gravidade para os dois ao mesmo tempo
func invertGravity() -> void:
	p1.invertValues()
	p2.invertValues()

# Jujuba: Função chamada pela plataforma móvel ("ônibus")
# Como a plataforma interage com o corpo físico mas pega o pai dele (o Controller),
# ela fala direto com esse script. Aqui a gente garante que a carona leve os dois juntos!
func movePlayerWithPlatform(speed) -> void:
	p1.global_position += speed
	p2.global_position += speed
