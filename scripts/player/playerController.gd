extends Node2D

@onready var p1 = $playerBody
@onready var p2 = $playerBody2

var baseSpeed: int = 100
var upSpeed: int = 50

func _ready() -> void:
	GameState.lastCheckpointP1 = p1.global_position
	GameState.lastCheckpointP2 = p2.global_position

func _physics_process(_delta) -> void:
	var inputDir = Input.get_axis("left", "right")
	var inputUp = Input.get_axis("up", "down")
	var xSpeed = inputDir * baseSpeed
	var ySpeed = inputUp * upSpeed

	# Jujuba: Se segurar para baixo, o boneco anda agachado, mas com metade da velocidade
	if Input.is_action_pressed("down"):
		xSpeed = inputDir * (baseSpeed / 2)
		
	if p1.isHoldingBox or p2.isHoldingBox:
		xSpeed = inputDir * 40 # Esse número precisa ser igual ao pushSpeed da Caixa!
		
	# 🕵️‍♀️ JUJUBA: Guardamos a posição X exata dos players ANTES deles se moverem.
	# Como eles começam o frame alinhados, a posição de um serve para os dois.
	var old_x = p1.global_position.x

	if inputDir == 0:
		p1.tryToMove(0)
		p2.tryToMove(0)
	else:
		p1.tryToMove(xSpeed)
		p2.tryToMove(xSpeed)
	
	if p1.canGoUp and p2.canGoUp and Input.is_action_just_pressed("up"):
		p1.tryGoUp(ySpeed)
		p2.tryGoUp(ySpeed*-1)
		
	# 🛠️ NOVA SINCRONIZAÇÃO SEGURA (Anti-Clipping / Anti-Super Salto):
	# Calculamos quantos pixels cada irmão conseguiu caminhar de verdade neste frame
	var dist_p1 = abs(p1.global_position.x - old_x)
	var dist_p2 = abs(p2.global_position.x - old_x)

	if dist_p1 < dist_p2:
		# O Charles (p1) colidiu com algo (caixa/parede) e andou menos! 
		# O Void (p2) recua e se alinha perfeitamente ao X seguro do Charles.
		p2.global_position.x = p1.global_position.x
	elif dist_p2 < dist_p1:
		# O Void (p2) colidiu com algo no mundo dele e andou menos! 
		# O Charles (p1) recua e se alinha perfeitamente ao X seguro do Void.
		p1.global_position.x = p2.global_position.x

func death() -> void:
	# Jujuba: ARMADURA DE INVENCIBILIDADE
	# Se o Charles estiver segurando a chave, o jogo ignora a morte!
	if p1.isHoldingKeyAnim:
		return

	# 🎵 JUJUBA: Para os passos e toca o áudio de morte do Charles!
	if p1.has_method("play_death_sound"):
		p1.play_death_sound()

	p1.animation.play("death")
	p2.animation.play("void death")
	p1.set_physics_process(false)
	p2.set_physics_process(false)
	set_physics_process(false)

func movePlayerToCheckPoint() -> void:
	p1.global_position = GameState.lastCheckpointP1
	p2.global_position = GameState.lastCheckpointP2

func invertGravity() -> void:
	p1.invertValues()
	p2.invertValues()

func movePlayerWithPlatform(speed) -> void:
	p1.global_position += speed
	p2.global_position += speed

func getPlayerFacingDirection() -> String:
	return p1.facingDirection

func moveTo(destiny: Vector2, destiny2: Vector2) -> void:
	p1.global_position = destiny
	p2.global_position = destiny2

func activateUpButton() -> void:
	p1.canGoUp = true
	p1.baseGravity = 0
	p2.canGoUp = true
	p2.baseGravity = 0

func deactivateUpButton() -> void:
	p1.canGoUp = false
	p1.baseGravity = 274
	p2.canGoUp = false
	p2.baseGravity = -274
