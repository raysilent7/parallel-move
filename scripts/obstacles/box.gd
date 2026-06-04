extends Node2D

@onready var boxBody: CharacterBody2D = $boxBody
@onready var boxArea: Area2D = $boxBody/boxArea

var playerInside: bool = false
var playerNode: CharacterBody2D = null
var baseGravity: int = 300
var pushSpeed: int = 40

func _ready() -> void:
	boxArea.body_entered.connect(onBodyEntered)
	boxArea.body_exited.connect(onBodyExited)

func _physics_process(_delta: float) -> void:
	if not boxBody.is_on_floor():
		boxBody.velocity.y += baseGravity * 0.070
	else:
		boxBody.velocity.y = 0

	# Jujuba: Adicionamos o "heldBox" in playerNode aqui como armadura de segurança extra!
	if playerNode and "heldBox" in playerNode and Input.is_action_pressed("interact"):
		
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
		var isFacingBox = (playerFacing == dirToBox)
		
		# Jujuba: 4. A TRAVA DE ALVO (TARGET LOCK)
		# Checa se o player tá livre pra agarrar essa caixa de frente, ou se ele JÁ estava agarrado nela antes
		var canGrabTheBox = (playerInside and isFacingBox and playerNode.heldBox == null)
		var isAlreadyHolding = (playerNode.heldBox == self)

		# Jujuba: O EMPURRÃO / PUXÃO
		# Se a trava de alvo permitiu, a gente assume o controle do Player!
		if canGrabTheBox or isAlreadyHolding:
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
		if playerNode and "heldBox" in playerNode:
			# Só limpa as variáveis se ELE for o dono dessa caixa específica
			if playerNode.heldBox == self:
				playerNode.heldBox = null
				playerNode.isHoldingBox = false
				playerNode.isPullingBox = false
				
			# Se ele não tá na área e não tá segurando nada, a caixa esquece completamente dele
			if not playerInside and playerNode.heldBox == null:
				playerNode = null
				
		boxBody.velocity.x = 0

	boxBody.move_and_slide()


func onBodyEntered(body: Node2D) -> void:
	# Jujuba: AQUI ESTÁ O SEGREDO! Agora a caixa só interage se for o Charles ou o Void.
	# O Wobble vai pisar nela e nada vai acontecer.
	if body.name == "playerBody" or body.name == "playerBody2":
		playerInside = true
		playerNode = body


func onBodyExited(body: Node2D) -> void:
	# Só processa a saída se quem estiver saindo for um dos irmãos.
	if body.name == "playerBody" or body.name == "playerBody2":
		playerInside = false
		if playerNode and "heldBox" in playerNode and playerNode.heldBox != self:
			playerNode = null


func movePlayerWithPlatform(moveSpeed: Vector2) -> void:
	boxBody.global_position += moveSpeed
	
	if playerInside and playerNode:
		playerNode.get_parent().movePlayerWithPlatform(moveSpeed)
