extends Area2D

var playerInside: bool = false
# Jujuba: Guardamos o nó do player que entrou para saber exatamente quem pegou a chave!
var playerNode: CharacterBody2D = null

func _ready() -> void:
	body_entered.connect(onBodyEntered)
	body_exited.connect(onBodyExited)

func _process(_delta: float) -> void:
	# Jujuba: Checa se o botão foi apertado e se temos um player válido na área
	if Input.is_action_just_pressed("interact") and playerInside and playerNode:
		GameState.hasKey = true
		
		# Jujuba: Manda o irmão que interagiu com a chave travar na animação estilo Zelda!
		if playerNode.has_method("startHoldingKeyAnimation"):
			playerNode.startHoldingKeyAnimation()
		
		# Desaparece com o objeto do mapa com segurança
		get_parent().call_deferred("queue_free")

func onBodyEntered(body: Node2D) -> void:
	# Jujuba: Só aceita a entrada se for o Charles (playerBody) ou o Void (playerBody2)
	if body.name == "playerBody" or body.name == "playerBody2":
		playerInside = true
		playerNode = body

func onBodyExited(body: Node2D) -> void:
	# Jujuba: Se o player que estava dentro resolver sair sem pegar a chave, limpamos a memória
	if body == playerNode:
		playerInside = false
		playerNode = null
