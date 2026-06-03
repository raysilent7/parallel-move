extends Node2D

# Jujuba: Puxando as referências dos nós físicos lá da árvore do Godot
@onready var boxBody: CharacterBody2D = $boxBody
@onready var boxArea: Area2D = $boxBody/boxArea

# Jujuba: Variáveis para o jogo saber se o player está perto e "quem" é ele
var playerInside: bool = false
var playerNode: CharacterBody2D = null

# Jujuba: Configurações de peso da caixa e a velocidade que ela se move ao ser empurrada
var baseGravity: int = 300
var pushSpeed: int = 40 

func _ready() -> void:
	# Jujuba: Assim que o jogo liga, conectamos os alarmes da área de detecção.
	# Eles vão gritar "Entrou!" ou "Saiu!" sempre que algo encostar na caixa.
	boxArea.body_entered.connect(onBodyEntered)
	boxArea.body_exited.connect(onBodyExited)

func _physics_process(_delta: float) -> void:
	# Jujuba: GRAVIDADE DA CAIXA
	# Se a caixa não estiver pisando no chão, empurra ela pra baixo pra ela cair pesada.
	if not boxBody.is_on_floor():
		boxBody.velocity.y += baseGravity * 0.070
	else:
		boxBody.velocity.y = 0

	# Jujuba: INÍCIO DA INTERAÇÃO
	# Só entra aqui se existir um player por perto E ele estiver segurando o botão de interagir
	if playerNode and Input.is_action_pressed("interact"):
		
		# Jujuba: 1. PARA ONDE O PLAYER OLHA?
		# Faz a matemática (levando em conta a gravidade invertida) pra descobrir o lado exato que o boneco olha
		var playerFacing = 0
		if playerNode.inverted:
			playerFacing = 1 if playerNode.animation.flip_h else -1
		else:
			playerFacing = -1 if playerNode.animation.flip_h else 1
			
		# Jujuba: 2. ONDE A CAIXA ESTÁ?
		# Compara a posição do boneco com a caixa. Retorna +1 (Direita) ou -1 (Esquerda)
		var dirToBox = sign(boxBody.global_position.x - playerNode.global_position.x)
		
		# Jujuba: 3. O ENCARAR
		# Só dá "True" se o boneco estiver olhando diretamente pra mesma direção onde a caixa está
		var olhandoPraMim = (playerFacing == dirToBox)
		
		# Jujuba: 4. A TRAVA DE ALVO (TARGET LOCK)
		# Checa se o player tá livre pra agarrar essa caixa de frente, ou se ele JÁ estava agarrado nela antes
		var podeIniciarGarra = (playerInside and olhandoPraMim and playerNode.heldBox == null)
		var jaEstaSegurandoMim = (playerNode.heldBox == self)

		# Jujuba: O EMPURRÃO / PUXÃO
		# Se a trava de alvo permitiu, a gente assume o controle do Player!
		if podeIniciarGarra or jaEstaSegurandoMim:
			# Avisa pro código do player que a caixa oficial dele agora é esta
			playerNode.heldBox = self
			playerNode.isHoldingBox = true
			
			# Vê pra qual lado o jogador tá querendo andar no teclado/controle
			var pushDir = Input.get_axis("left", "right")
			
			# Se o lado que ele quer andar for diferente do lado que a caixa tá, ele está PUXANDO
			if pushDir != 0 and pushDir != dirToBox:
				playerNode.isPullingBox = true
			else:
				playerNode.isPullingBox = false
				
			# Força o boneco a ficar olhando pra caixa enquanto segura ela
			if dirToBox > 0:
				playerNode.animation.flip_h = true if playerNode.inverted else false
			elif dirToBox < 0:
				playerNode.animation.flip_h = false if playerNode.inverted else true
				
			# Finalmente, manda a caixa andar!
			boxBody.velocity.x = pushDir * pushSpeed
		else:
			# Jujuba: Se o player tá agarrando a caixa vizinha, esta aqui fica congelada no lugar
			boxBody.velocity.x = 0
			
	else:
		# Jujuba: SOLTOU O BOTÃO OU FOI EMBORA
		# Limpa a memória do player pra ele soltar a caixa e parar de fazer força
		if playerNode:
			# Só limpa as variáveis se ELE for o dono dessa caixa específica
			if playerNode.heldBox == self:
				playerNode.heldBox = null
				playerNode.isHoldingBox = false
				playerNode.isPullingBox = false
				
			# Se ele não tá na área e não tá segurando nada, a caixa esquece completamente dele
			if not playerInside and playerNode.heldBox == null:
				playerNode = null
				
		# Zera a velocidade pra caixa parar de deslizar
		boxBody.velocity.x = 0

	# Jujuba: Manda o motor físico do Godot aplicar todas essas velocidades de vez!
	boxBody.move_and_slide()


# Jujuba: ALARMES DE ENTRADA E SAÍDA DA ÁREA VERMELHA
func onBodyEntered(body: Node2D) -> void:
	# Se alguém encostou, e esse alguém é o personagem, salva ele na memória!
	if body is CharacterBody2D and body.name != "boxBody":
		playerInside = true
		playerNode = body

func onBodyExited(body: Node2D) -> void:
	# Se o personagem saiu, avisa que ele não tá mais dentro
	if body is CharacterBody2D and body.name != "boxBody":
		playerInside = false
		# Se ele saiu andando (sem segurar a caixa), limpa ele da memória pra não dar erro
		if playerNode and playerNode.heldBox != self:
			playerNode = null


# --- LÓGICA DA PLATAFORMA MÓVEL ---
# Jujuba: O SISTEMA DE CARONA (ÔNIBUS)
# A plataforma chama essa função. A caixa obedece e anda junto com ela.
func movePlayerWithPlatform(moveSpeed: Vector2) -> void:
	boxBody.global_position += moveSpeed
	
	# Jujuba: Se o player estiver pisando em cima da caixa enquanto a plataforma anda,
	# a caixa passa a carona adiante e carrega o corpo dele nas costas!
	if playerInside and playerNode:
		playerNode.global_position += moveSpeed
