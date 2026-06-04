extends Node2D

@onready var camera: Camera2D = $camera
@onready var light: PointLight2D = $light
@onready var darkness: CanvasModulate = $darkness

@onready var void_spawn: Marker2D = $VoidSpawn

@onready var p1 = $Player/playerBody
@onready var p2 = $Player/playerBody2

func _ready() -> void:
	AudioManager.startMusicSystem()
	GameState.hasKey = false
	GameState.isDark = darkness.visible
	light.enabled = GameState.isDark

	# 📸 Garante que a luz fique na câmera logo no início (e como a câmera não move, a luz também não)
	light.global_position = camera.global_position

	await get_tree().create_timer(0.1).timeout
	preparar_fase_vertical()


func preparar_fase_vertical() -> void:
	print("--- A INICIAR PREPARAÇÃO DA FASE ---")
	
	if void_spawn == null:
		print("❌ ERRO: VoidSpawn não encontrado!")
		return
	else:
		print("✅ VoidSpawn encontrado em: ", void_spawn.global_position)
		
	if p1 == null:
		print("❌ ERRO: Charles não encontrado em $Player/playerBody!")
		return
		
	if p2 == null:
		print("❌ ERRO: Void não encontrado em $Player/playerBody2!")
		return

	print("✅ Jogadores encontrados! A iniciar teletransporte...")

	$Player.sync_positions = false

	# 2. MODO FANTASMA
	p1.add_collision_exception_with(p2)
	p2.add_collision_exception_with(p1)

	# 3. O TELETRANSPORTE
	p2.global_position = void_spawn.global_position
	p2.velocity = Vector2.ZERO
	print("✅ Void teletransportado para: ", p2.global_position)

	# 4. A LAVAGEM CEREBRAL DA GRAVIDADE
	p2.inverted = false 
	p2.up_direction = Vector2.UP 
	p2.baseGravity = abs(p2.baseGravity) 
	p2.baseJumpForce = -abs(p2.baseJumpForce) 
	
	if p2.animation != null:
		p2.animation.flip_v = false
		
	p2.rotation = 0
	p2.scale.y = 1
	
	for child in p2.get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D or child is Area2D:
			if child.position.y < 0: 
				child.position.y *= -1
				
	print("✅ Lavagem cerebral do Void concluída com sucesso!")
