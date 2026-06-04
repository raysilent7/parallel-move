extends Node2D

@onready var p1 = $playerBody
@onready var p2 = $playerBody2

var baseSpeed: int = 100

func _ready() -> void:
	GameState.lastCheckpointP1 = p1.global_position
	GameState.lastCheckpointP2 = p2.global_position

func _physics_process(_delta) -> void:
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
		
	if p1.isHoldingBox or p2.isHoldingBox:
		xSpeed = inputDir * 40 # Esse número precisa ser igual ao pushSpeed da Caixa!
		
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

func death() -> void:
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
