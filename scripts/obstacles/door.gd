extends Node2D

@onready var doorArea: Area2D = $doorBody/doorArea
@onready var doorCollision: CollisionShape2D = $doorBody/bodyCollision
@onready var doorAnim: AnimatedSprite2D = $doorBody/doorAnim
@export var hasDoorLock: bool = false

var playerInside: bool = false
var isOpen: bool = false
var isTransitioning: bool = false 

func _ready() -> void:
	doorArea.body_entered.connect(onBodyEntered)
	doorArea.body_exited.connect(onBodyExited)

func _process(_delta: float) -> void:
	if hasDoorLock:
		openWithKey()
	else:
		openByPressureButton()
	
	if isOpen and doorAnim.animation.begins_with("opening"):
		doorAnim.play("opened")

	if not GameState.buttonPressed and isOpen and not isTransitioning:
		isTransitioning = true
		isOpen = false
		doorCollision.disabled = false
		doorAnim.play("closing")
		await doorAnim.animation_finished
		doorAnim.play("closed")
		isTransitioning = false

func onBodyEntered(body: Node2D) -> void:
	if body is CharacterBody2D:
		playerInside = true

func onBodyExited(body: Node2D) -> void:
	if body is CharacterBody2D:
		playerInside = false

func openWithKey() -> void:
	if Input.is_action_just_pressed("interact") and playerInside and GameState.hasKey and not isTransitioning:
		isTransitioning = true
		GameState.hasKey = false
		doorAnim.play("opening")
		await doorAnim.animation_finished
		doorCollision.disabled = true
		isOpen = true
		isTransitioning = false

func openByPressureButton() -> void:
	if GameState.buttonPressed and not isOpen and not isTransitioning:
		isTransitioning = true
		doorAnim.play("opening")
		await doorAnim.animation_finished
		doorCollision.disabled = true
		isOpen = true
		isTransitioning = false
