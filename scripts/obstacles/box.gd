extends Node2D

@onready var boxBody: CharacterBody2D = $boxBody
@onready var boxArea: Area2D = $boxBody/boxArea

@export var inverted: bool = false

var playerInside: bool = false
var playerNode: CharacterBody2D = null
var baseGravity: int = 300
var pushSpeed: int = 40
var is_falling_danger: bool = false

func _ready() -> void:
	boxArea.body_entered.connect(onBodyEntered)
	boxArea.body_exited.connect(onBodyExited)
	
	if inverted:
		boxBody.up_direction = Vector2.DOWN
		baseGravity *= -1
		
		for child in boxBody.get_children():
			if child is Sprite2D or child is AnimatedSprite2D:
				child.flip_v = true
				child.position.y *= -1
			elif child is CollisionShape2D or child is CollisionPolygon2D or child is Area2D:
				child.position.y *= -1
		
		for child in boxArea.get_children():
			if child is CollisionShape2D or child is CollisionPolygon2D:
				child.position.y *= -1

func _physics_process(_delta: float) -> void:
	if not boxBody.is_on_floor():
		boxBody.velocity.y += baseGravity * 0.070
		
		if abs(boxBody.velocity.y) > 50:
			is_falling_danger = true
	else:
		boxBody.velocity.y = 0
		is_falling_danger = false

	if playerNode and "heldBox" in playerNode and Input.is_action_pressed("interact"):
		var playerFacing = 0
		if playerNode.inverted:
			playerFacing = 1 if playerNode.animation.flip_h else -1
		else:
			playerFacing = -1 if playerNode.animation.flip_h else 1
			
		var dirToBox = sign(boxBody.global_position.x - playerNode.global_position.x)
		var isFacingBox = (playerFacing == dirToBox)
		var canGrabTheBox = (playerInside and isFacingBox and playerNode.heldBox == null)
		var isAlreadyHolding = (playerNode.heldBox == self)

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
				
			var parado_pelo_cenario = false
			if abs(playerNode.velocity.x) < 1.0:
				for i in playerNode.get_slide_collision_count():
					var colisao = playerNode.get_slide_collision(i)
					if colisao.get_collider() != boxBody:
						parado_pelo_cenario = true
						break
			
			if parado_pelo_cenario:
				boxBody.velocity.x = 0
			else:
				boxBody.velocity.x = pushDir * pushSpeed
		else:
			boxBody.velocity.x = 0
			
	else:
		if playerNode and "heldBox" in playerNode:
			if playerNode.heldBox == self:
				playerNode.heldBox = null
				playerNode.isHoldingBox = false
				playerNode.isPullingBox = false
				
			if not playerInside and playerNode.heldBox == null:
				playerNode = null
				
		boxBody.velocity.x = 0

	boxBody.move_and_slide()

	if is_falling_danger:
		for i in boxBody.get_slide_collision_count():
			var collision = boxBody.get_slide_collision(i)
			var collider = collision.get_collider()
			
			if collider != null:
				if collider.name == "playerBody" or collider.name == "playerBody2":
					var normal_y = collision.get_normal().y
					
					if baseGravity > 0:
						if normal_y < -0.5:
							var controller = collider.get_parent()
							if controller.has_method("death"):
								controller.death()
								
					elif baseGravity < 0:
						if normal_y > 0.5:
							var controller = collider.get_parent()
							if controller.has_method("death"):
								controller.death()
								
				else:
					if abs(collision.get_normal().y) > 0.5:
						is_falling_danger = false

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
