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
var isHoldingKeyAnim: bool = false
var wasOnFloor: bool = true

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
	resolveAudio()

func tryGoUp(speed) -> void:
	if isHoldingKeyAnim: return
	velocity.y = speed
	move_and_slide()
	checkLandingPhysics()

func shoot():
	if Input.is_action_just_pressed("shoot") and canShoot:
		animation.play("attack throwing")
		AudioManager.playThrow()
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
	checkLandingPhysics()

func checkLandingPhysics() -> void:
	if is_on_floor() and not wasOnFloor:
		animation.play("landing")
		AudioManager.playLanding()
	wasOnFloor = is_on_floor()

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
		AudioManager.playJumping()

func resolveAnimation() -> void:
	if (animation.animation == "landing" and animation.is_playing()) or \
	   (animation.animation == "attack throwing" and animation.is_playing()) or \
	   (animation.animation == "holding key" and animation.is_playing()):
		return

	if Input.is_action_pressed("down") and is_on_floor() and not isHoldingBox:
		playerCollision.set_deferred("disabled", true)
		playerCollision2.set_deferred("disabled", false)
		
		if Input.get_axis("left", "right") == 0:
			animation.play("crouching")
		elif Input.get_axis("left", "right") > 0:
			animation.play("crouch walking")
			animation.flip_h = true if inverted else false
			facingDirection = "right"
		elif Input.get_axis("left", "right") < 0:
			animation.play("crouch walking")
			animation.flip_h = false if inverted else true
			facingDirection = "left"
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
			
		elif isHoldingBox:
			if Input.get_axis("left", "right") == 0:
				animation.play("holding box") 
			elif isPullingBox:
				animation.play_backwards("moving box") 
			else:
				animation.play("moving box") 
		
		elif Input.get_axis("left", "right") == 0:
			animation.play("idle")
		else:
			animation.play("walking")

func resolveAudio():
	if animation.animation.begins_with("walking") or animation.animation.begins_with("crouch"):
		AudioManager.playWalking()
	if animation.animation.begins_with("moving box"):
		AudioManager.playDragginBox()
