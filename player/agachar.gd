extends Node

@export var velocidade_agachado: float = 1.8
@export var tempo_tween: float = 0.2

@onready var player = get_parent() # Referência ao Player
@onready var head = player.get_node("head")
@onready var collision_shape = player.get_node("CollisionShape3D")

@onready var sfx1 = $sfx1

var is_crouching: bool = false
var altura_head_normal: float
var altura_shape_normal: float
var posicao_shape_normal_y: float
var crouch_tween: Tween

func _ready():
	# Inicializa os valores baseados no estado inicial do Player
	altura_head_normal = head.position.y
	posicao_shape_normal_y = collision_shape.position.y
	
	if collision_shape.shape:
		collision_shape.shape = collision_shape.shape.duplicate()
		altura_shape_normal = collision_shape.shape.height

func _process(_delta):
	# O componente escuta o input
	if Input.is_action_just_pressed("agachar"):
		toggle_crouch(true)
		sfx1.play()
	elif Input.is_action_just_released("agachar"):
		toggle_crouch(false)

func toggle_crouch(agachar: bool):
	is_crouching = agachar
	
	# Avisa o player que a velocidade deve mudar
	player.atualizar_velocidade_externa(agachar)
	
	var alvo_head_y = altura_head_normal - 0.7 if agachar else altura_head_normal
	var alvo_shape_height = altura_shape_normal * 0.5 if agachar else altura_shape_normal
	
	var diferenca_altura = altura_shape_normal - alvo_shape_height
	var alvo_shape_y = posicao_shape_normal_y - (diferenca_altura * 0.5) if agachar else posicao_shape_normal_y
	
	if crouch_tween and crouch_tween.is_running():
		crouch_tween.kill()
		
	crouch_tween = create_tween().set_parallel(true)
	crouch_tween.tween_property(head, "position:y", alvo_head_y, tempo_tween)
	crouch_tween.tween_property(collision_shape.shape, "height", alvo_shape_height, tempo_tween)
	crouch_tween.tween_property(collision_shape, "position:y", alvo_shape_y, tempo_tween)
