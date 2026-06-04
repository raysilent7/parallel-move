extends Area2D

func _ready() -> void:
	body_entered.connect(onBodyEntered)

func onBodyEntered(body: Node2D) -> void:
	print("aconteci 1")
	
	# Jujuba: Garante que estamos falando com um dos corpos do player
	if body is CharacterBody2D and (body.name == "playerBody" or body.name == "playerBody2"):
		var controller = body.get_parent()
		
		# Jujuba: Calcula exatamente quantos pixels o player vai viajar no eixo X
		var offset_x = 0.0
		if self.name == "right":
			offset_x = -40.0 - body.global_position.x
		elif self.name == "left":
			offset_x = 1152.0 - body.global_position.x
		
		# Jujuba: SE o player estiver segurando a caixa, teleporta o corpo da caixa junto!
		if "heldBox" in body and body.heldBox != null:
			var caixa = body.heldBox
			if "boxBody" in caixa:
				# Move a caixa pela mesma distância relativa que o player vai viajar
				caixa.boxBody.global_position.x += offset_x
		
		# Jujuba: Agora ativa o teletransporte que o seu amigo programou no Controller
		if self.name == "right":
			print("aconteci 2")
			controller.moveTo(Vector2(-40.0, body.global_position.y), Vector2(-40.0, body.global_position.y+64.0))
		elif self.name == "left":
			print("aconteci 3")
			controller.moveTo(Vector2(1152.0, body.global_position.y), Vector2(1152.0, body.global_position.y+64.0))
