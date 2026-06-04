extends Node2D

@onready var boxBody: CharacterBody2D = $boxBody
@onready var boxArea: Area2D = $boxBody/boxArea

# Jujuba: Nova variável para ativar o modo de cabeça para baixo no Inspetor!
@export var inverted: bool = false

var playerInside: bool = false
var playerNode: CharacterBody2D = null
var baseGravity: int = 300
var pushSpeed: int = 40

func _ready() -> void:
	boxArea.body_entered.connect(onBodyEntered)
	boxArea.body_exited.connect(onBodyExited)
	
	if inverted:
		boxBody.up_direction = Vector2.DOWN
		baseGravity *= -1
		
		# Jujuba: Varre os filhos do boxBody para inverter o visual e espelhar as colisões
		for child in boxBody.get_children():
			if child is Sprite2D or child is AnimatedSprite2D:
				child.flip_v = true
				child.position.y *= -1 # Inverte o offset do próprio sprite se houver
			elif child is CollisionShape2D or child is CollisionPolygon2D or child is Area2D:
				child.position.y *= -1 # Força a colisão/área a pular para o teto!
		
		# Jujuba: Correção extra para o formato de colisão que fica guardado dentro da Area2D
		for child in boxArea.get_children():
			if child is CollisionShape2D or child is CollisionPolygon2D:
				child.position.y *= -1

func _physics_process(_delta: float) -> void:
	if not boxBody.is_on_floor():
		boxBody.velocity.y += baseGravity * 0.070
	else:
		boxBody.velocity.y = 0

	# Jujuba: Adicionamos o "heldBox" in playerNode aqui como armadura de segurança extra!
	if playerNode and "heldBox" in playerNode and Input.is_action_pressed("interact"):
		
		# Jujuba: 1. PARA ONDE O PLAYER OLHA?
		var playerFacing = 0
		if playerNode.inverted:
			playerFacing = 1 if playerNode.animation.flip_h else -1
		else:
			playerFacing = -1 if playerNode.animation.flip_h else 1
			
		# Jujuba: 2. ONDE A CAIXA ESTÁ?
		var dirToBox = sign(boxBody.global_position.x - playerNode.global_position.x)
		
		# Jujuba: 3. O ENCARAR
		var isFacingBox = (playerFacing == dirToBox)
		
		# Jujuba: 4. A TRAVA DE ALVO (TARGET LOCK)
		var canGrabTheBox = (playerInside and isFacingBox and playerNode.heldBox == null)
		var isAlreadyHolding = (playerNode.heldBox == self)

		# Jujuba: O EMPURRÃO / PUXÃO
		if canGrabTheBox or isAlreadyHolding:
			playerNode.heldBox = self
			playerNode.isHoldingBox = true
			
			var pushDir = Input.get_axis("left", "right")
			
			if pushDir != 0 and pushDir != dirToBox:
				playerNode.isPullingBox = true
			else:
				playerNode.isPullingBox = false
				
			if dirToBox > 0:
				playerNode.animation.flip_h = true if playerNode.inverted else false
			elif dirToBox < 0:
				playerNode.animation.flip_h = false if playerNode.inverted else true
				
			# 🛠️ JUJUBA: --- NOVA COLOAÇÃO DE SEGURANÇA ANTILOCK ---
			# Vamos descobrir SE o jogador foi parado por um obstáculo real do cenário (TileMap, paredes, etc)
			var parado_pelo_cenario = false
			if abs(playerNode.velocity.x) < 1.0:
				for i in playerNode.get_slide_collision_count():
					var colisao = playerNode.get_slide_collision(i)
					# Se o que parou o jogador NÃO foi esta caixa, então foi um teto/parede!
					if colisao.get_collider() != boxBody:
						parado_pelo_cenario = true
						break
			
			# Se ele bateu com a cabeça ou numa parede real, a caixa trava.
			# Se ele só parou porque encostou na caixa, deixamos a caixa andar livremente!
			if parado_pelo_cenario:
				boxBody.velocity.x = 0
			else:
				boxBody.velocity.x = pushDir * pushSpeed
		else:
			boxBody.velocity.x = 0
			
	else:
		# Jujuba: SOLTOU O BOTÃO OU FOI EMBORA
		if playerNode and "heldBox" in playerNode:
			if playerNode.heldBox == self:
				playerNode.heldBox = null
				playerNode.isHoldingBox = false
				playerNode.isPullingBox = false
				
			if not playerInside and playerNode.heldBox == null:
				playerNode = null
				
		boxBody.velocity.x = 0

	boxBody.move_and_slide()


func onBodyEntered(body: Node2D) -> void:
	if body.name == "playerBody" or body.name == "playerBody2":
		playerInside = true
		playerNode = body


func onBodyExited(body: Node2D) -> void:
	if body.name == "playerBody" or body.name == "playerBody2":
		playerInside = false
		if playerNode and "heldBox" in playerNode and playerNode.heldBox != self:
			playerNode = null


func movePlayerWithPlatform(moveSpeed: Vector2) -> void:
	boxBody.global_position += moveSpeed
	
	if playerInside and playerNode:
		playerNode.get_parent().movePlayerWithPlatform(moveSpeed)
