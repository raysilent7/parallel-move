extends CharacterBody2D

@onready var animation: AnimatedSprite2D = $playerAnim
@export var inverted: bool = false
@onready var playerCollision = $playerCollision
@onready var playerCollision2 = $playerCollision2

var baseGravity: int = 300
var baseJumpForce: int = -274
var canJump: bool = true
var isHoldingBox: bool = false
var isPullingBox: bool = false
var heldBox: Node2D = null

func _ready() -> void:
	startInvertedPlayer()

func _physics_process(_delta: float) -> void:
	applyGravity()
	jump()
	resolveAnimation()

func startInvertedPlayer() -> void:
	if inverted:
		animation.flip_h = inverted
		up_direction = Vector2.DOWN
		baseGravity *= -1
		baseJumpForce *= -1

func invertValues() -> void:
	if GameState.gravityInverted:
		animation.flip_v = true
		up_direction = Vector2.UP if inverted else Vector2.DOWN
		baseGravity *= -1
		baseJumpForce *= -1
	else:
		animation.flip_v = false
		up_direction = Vector2.DOWN if inverted else Vector2.UP
		baseGravity *= -1
		baseJumpForce *= -1

func tryToMove(speed) -> void:
	var estavaNoAr = not is_on_floor()
	
	velocity.x = speed
	move_and_slide()
	
	if estavaNoAr and is_on_floor():
		animation.play("landing")

func applyGravity() -> void:
	if not is_on_floor():
		velocity.y += baseGravity * 0.070
		if not GameState.gravityInverted:
			if inverted:
				velocity.y = max(velocity.y, baseGravity)
			else:
				velocity.y = min(velocity.y, baseGravity)
		else:
			if inverted:
				velocity.y = min(velocity.y, baseGravity)
			else:
				velocity.y = max(velocity.y, baseGravity)
	else:
		velocity.y = 0
		canJump = true

func jump() -> void:
	if Input.is_action_just_pressed("jump") and canJump:
		velocity.y = baseJumpForce
		canJump = false

func resolveAnimation() -> void:
	# Jujuba: Se a aterrissagem estiver rolando, trava as outras animações até ela terminar
	if animation.animation == "landing" and animation.is_playing():
		return

	# Jujuba: Se estiver no chão, segurando para baixo, e NÃO estiver segurando a caixa
	if Input.is_action_pressed("down") and is_on_floor() and not isHoldingBox:
		playerCollision.set_deferred("disabled", true)
		playerCollision2.set_deferred("disabled", false)
		
		# Jujuba: Checa se o boneco está parado agachado ou andando agachado
		if Input.get_axis("left", "right") == 0:
			animation.play("crouching")
		elif Input.get_axis("left", "right") > 0:
			animation.play("crouch walking")
			animation.flip_h = true if inverted else false
		elif Input.get_axis("left", "right") < 0:
			animation.play("crouch walking")
			animation.flip_h = false if inverted else true
			
	else:
		# Jujuba: Qualquer outra coisa que o boneco fizer, garante que a colisão normal volte a ficar ativada
		playerCollision.set_deferred("disabled", false)
		playerCollision2.set_deferred("disabled", true)
		
		# Jujuba: Só vira o boneco livremente se ele NÃO estiver segurando a caixa
		if not isHoldingBox:
			if Input.get_axis("left", "right") > 0:
				animation.flip_h = true if inverted else false
			elif Input.get_axis("left", "right") < 0:
				animation.flip_h = false if inverted else true
			
		# Jujuba: Escolhe a animação certa checando o pulo primeiro. 
		# Sem essa alteração, dava aquele bug do boneco não tocar a animação de pulo enquanto pulava em alguma direção.
		if not is_on_floor():
			animation.play("jumping")
			
		# Jujuba: --- LÓGICA DE ANIMAÇÃO DA CAIXA ---
		# Se ele estiver segurando a caixa, assume o controle das animações de braço
		elif isHoldingBox:
			if Input.get_axis("left", "right") == 0:
				animation.play("holding box") # Parado segurando a caixa
			elif isPullingBox:
				animation.play_backwards("moving box") # Toca de trás pra frente se for puxão!
			else:
				animation.play("moving box") # Toca normal se for empurrão
		
		elif Input.get_axis("left", "right") == 0:
			animation.play("idle")
		else:
			animation.play("walking")
