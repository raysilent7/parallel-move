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
		
	if inputDir == 0:
		p1.tryToMove(0)
		p2.tryToMove(0)
	else:
		p1.tryToMove(xSpeed)
		p2.tryToMove(xSpeed)
	
	if p1.canGoUp and p2.canGoUp and Input.is_action_just_pressed("up"):
		p1.tryGoUp(ySpeed)
		p2.tryGoUp(ySpeed*-1)
		
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
