extends Area2D

var speed: float = 300.0
var startingPoint: Vector2 = Vector2(1.1, 1.1)
var directionMultiplier: float = 1.0

func _ready() -> void:
	print("aconteci")
	startingPoint = global_position
	
	# Conecta automaticamente o sinal de colisão com corpos físicos por código
	body_entered.connect(_on_body_entered)
	
	# Perguntamos para onde o player olha APENAS uma vez ao nascer!
	var playerNode = get_tree().current_scene.player
	if playerNode and playerNode.has_method("getPlayerFacingDirection"):
		var projectileDirection: String = playerNode.getPlayerFacingDirection()
		
		if projectileDirection == "right":
			directionMultiplier = 1.0
		else:
			directionMultiplier = -1.0
			
			# Jujuba: --- A MUDANÇA VISUAL ESTÁ AQUI ---
			# Se o tiro for para a esquerda, varre os nós dele, acha o sprite e vira de lado!
			for child in get_children():
				if child is Sprite2D or child is AnimatedSprite2D:
					child.flip_h = true

func _process(delta: float) -> void:
	global_position.x += speed * directionMultiplier * delta

	if global_position.distance_to(startingPoint) > 1000.0:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	# Proteção para não estourar na cara do Charles ou do Void
	if body.name == "playerBody" or body.name == "playerBody2":
		return
		
	# Se acertar o Wobble, causa dano e deleta ele se o HP zerar
	if body.is_in_group("wobbles"):
		if "hp" in body:
			body.hp -= 1
			print("Inimigo atingido! HP do Wobble: ", body.hp)
			
			if body.hp <= 0:
				print("Wobble eliminado!")
				body.queue_free()
				
	# Some ao bater em qualquer parede, caixa ou inimigo
	queue_free()
