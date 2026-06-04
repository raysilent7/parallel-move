extends CharacterBody2D

@onready var animation: AnimatedSprite2D = $playerAnim
@export var inverted: bool = false
@onready var playerCollision = $playerCollision
@onready var playerCollision2 = $playerCollision2
var projectileScene: PackedScene = preload("res://objects/player/projectile.tscn")

var baseGravity: int = 300
var baseJumpForce: int = -320
var canJump: bool = true
var isHoldingBox: bool = false
var isPullingBox: bool = false
var heldBox: Node2D = null
var facingDirection: String
var canShoot: bool = true
var canGoUp: bool = false

# Jujuba: Nova variável para trancar o Charles no modo "Zelda" ao pegar a chave
var isHoldingKeyAnim: bool = false

# 🎵 JUJUBA: Referências de todos os nós de efeitos sonoros
@onready var snd_shoot: AudioStreamPlayer2D = $Sounds/Shoot
@onready var snd_jump: AudioStreamPlayer2D = $Sounds/Jump
@onready var snd_land: AudioStreamPlayer2D = $Sounds/Land
@onready var snd_walk: AudioStreamPlayer2D = $Sounds/Walk
@onready var snd_crouch: AudioStreamPlayer2D = $Sounds/CrouchWalk
@onready var snd_box: AudioStreamPlayer2D = $Sounds/MoveBox
@onready var snd_death: AudioStreamPlayer2D = $Sounds/Death

# Rastreador físico para detectar aterrissagem legítima
var was_on_floor: bool = true

func _ready() -> void:
	startInvertedPlayer()

func _process(_delta: float) -> void:
	if not isHoldingKeyAnim:
		shoot()

func _physics_process(_delta: float) -> void:
	if isHoldingKeyAnim:
		velocity = Vector2.ZERO
		return

	applyGravity()
	jump()
	resolveAnimation()

func tryGoUp(speed) -> void:
	if isHoldingKeyAnim: return
	velocity.y = speed
	move_and_slide()
	check_landing_physics()

func shoot():
	if Input.is_action_just_pressed("shoot") and canShoot:
		animation.play("attack throwing")
		if snd_shoot: snd_shoot.play() # 🎵 Som: Atirar
		await animation.animation_finished
		var projectile = projectileScene.instantiate()
		projectile.global_position = global_position
		get_tree().current_scene.add_child(projectile)
		startFireCooldown()

func startFireCooldown():
	canShoot = false
	await get_tree().create_timer(0.5).timeout
	canShoot = true

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
	if isHoldingKeyAnim:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	velocity.x = speed
	move_and_slide()
	check_landing_physics()

# 🧠 JUJUBA: Nova função centralizada que gerencia o impacto no chão corretamente
func check_landing_physics() -> void:
	if is_on_floor() and not was_on_floor:
		animation.play("landing")
		if snd_land: snd_land.play() # 🎵 Som: Aterrissar
	was_on_floor = is_on_floor()

func applyGravity() -> void:
	if not is_on_floor():
		velocity.y += baseGravity * 0.070
		if not GameState.gravityInverted:
			if inverted: velocity.y = max(velocity.y, baseGravity)
			else: velocity.y = min(velocity.y, baseGravity)
		else:
			if inverted: velocity.y = min(velocity.y, baseGravity)
			else: velocity.y = max(velocity.y, baseGravity)
	else:
		velocity.y = 0
		canJump = true

func jump() -> void:
	if Input.is_action_just_pressed("jump") and canJump:
		velocity.y = baseJumpForce
		canJump = false
		if snd_jump: snd_jump.play() # 🎵 Som: Pular

# 🧠 JUJUBA: Função de suporte para ligar o áudio contínuo certo e desligar os outros
func manage_loop_sound(active_sound: AudioStreamPlayer2D) -> void:
	var loops = [snd_walk, snd_crouch, snd_box]
	for snd in loops:
		if snd and snd != active_sound:
			snd.stop()
	if active_sound and not active_sound.playing:
		active_sound.play()

# 🧠 JUJUBA: Função pública para o seu Controller disparar a morte do Charles com áudio
func play_death_sound() -> void:
	manage_loop_sound(null) # Para qualquer som de passos ativo
	if snd_death: snd_death.play() # 🎵 Som: Morrer

func resolveAnimation() -> void:
	# Se travas de animação de ação estiverem rolando, corta sons de passos e sai
	if (animation.animation == "landing" and animation.is_playing()) or \
	   (animation.animation == "attack throwing" and animation.is_playing()) or \
	   (animation.animation == "holding key" and animation.is_playing()):
		manage_loop_sound(null)
		return

	# Se estiver no chão, segurando para baixo, e NÃO estiver segurando a caixa
	if Input.is_action_pressed("down") and is_on_floor() and not isHoldingBox:
		playerCollision.set_deferred("disabled", true)
		playerCollision2.set_deferred("disabled", false)
		
		if Input.get_axis("left", "right") == 0:
			animation.play("crouching")
			manage_loop_sound(null) # 🎵 Som: Parado agachado (Silêncio)
		elif Input.get_axis("left", "right") > 0:
			animation.play("crouch walking")
			animation.flip_h = true if inverted else false
			facingDirection = "right"
			manage_loop_sound(snd_crouch) # 🎵 Som: Passos Agachado
		elif Input.get_axis("left", "right") < 0:
			animation.play("crouch walking")
			animation.flip_h = false if inverted else true
			facingDirection = "left"
			manage_loop_sound(snd_crouch) # 🎵 Som: Passos Agachado
			
	else:
		playerCollision.set_deferred("disabled", false)
		playerCollision2.set_deferred("disabled", true)
		
		if not isHoldingBox:
			if Input.get_axis("left", "right") > 0:
				animation.flip_h = true if inverted else false
				facingDirection = "right"
			elif Input.get_axis("left", "right") < 0:
				animation.flip_h = false if inverted else true
				facingDirection = "left"

		if not is_on_floor():
			animation.play("jumping")
			manage_loop_sound(null) # 🎵 Som: No ar não há passos
			
		elif isHoldingBox:
			if Input.get_axis("left", "right") == 0:
				animation.play("holding box") 
				manage_loop_sound(null) # 🎵 Som: Segurando caixa parado
			elif isPullingBox:
				animation.play_backwards("moving box") 
				manage_loop_sound(snd_box) # 🎵 Som: Carregar caixa andando
			else:
				animation.play("moving box") 
				manage_loop_sound(snd_box) # 🎵 Som: Carregar caixa andando
		
		elif Input.get_axis("left", "right") == 0:
			animation.play("idle")
			manage_loop_sound(null) # 🎵 Som: Idle
		else:
			animation.play("walking")
			manage_loop_sound(snd_walk) # 🎵 Som: Andar normal
