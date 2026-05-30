extends CharacterBody3D

# --- CONFIGURAÇÕES DE MOVIMENTO ---
const VELOCIDADE_NORMAL = 3
const VELOCIDADE_ZOOM = 1
const JUMP_VELOCITY = 0

var velocidade_atual = VELOCIDADE_NORMAL

# --- REFERÊNCIAS ---
@onready var camera = $head/Camera3D
@onready var luz_lanterna = $head/Camera3D/flashlight/SpotLight3D
@onready var sfx_lanterna = $AudioStreamPlayer
@onready var sfx_passos = $SfxPassos
@onready var sfx_zoonIn = $ZoomIn

# --- CONFIGURAÇÕES DO ZOOM ---
var fov_normal: float = 75.0
var fov_zoom: float = 40.0
var tempo_zoom: float = 0.3
var zoom_tween: Tween

# --- CONFIGURAÇÕES DE HEAD BOBBING ---
const BOB_FREQUENCIA = 4.0 # Velocidade do balanço
const BOB_AMPLITUDE = 0.08 # Força/tamanho do balanço
var tempo_bob = 0.0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("left", "right", "foward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * velocidade_atual
		velocity.z = direction.z * velocidade_atual
	else:
		velocity.x = move_toward(velocity.x, 0, velocidade_atual)
		velocity.z = move_toward(velocity.z, 0, velocidade_atual)

	move_and_slide()
	
	gerenciar_sons_de_passos()
	aplicar_headbob(delta) # Chamamos o head bobbing aqui todo frame
	
func _process(delta):
	# --- SISTEMA DE LANTERNA ---
	if Input.is_action_just_pressed("lanterna"):
		luz_lanterna.visible = not luz_lanterna.visible
		sfx_lanterna.play()
		
	# --- SISTEMA DE ZOOM E VELOCIDADE ---
	if Input.is_action_just_pressed("zoom"):
		aplicar_zoom(fov_zoom)
		velocidade_atual = VELOCIDADE_ZOOM
		sfx_zoonIn.play()
		
	elif Input.is_action_just_released("zoom"):
		aplicar_zoom(fov_normal)
		velocidade_atual = VELOCIDADE_NORMAL
		
func gerenciar_sons_de_passos():
	var no_chao = is_on_floor()
	var se_movendo = Vector3(velocity.x, 0, velocity.z).length() > 0.1
	
	if no_chao and se_movendo:
		if not sfx_passos.playing:
			sfx_passos.volume_db = 0 # Restaura o volume original
			sfx_passos.play()
	else:
		# Só faz o fade out se o som estiver tocando
		if sfx_passos.playing:
			var tween = create_tween()
			# Abaixa o volume para -80db (silêncio total) em 0.1s
			tween.tween_property(sfx_passos, "volume_db", -80.0, 0.1)
			# Quando terminar, para o som e reseta o volume para quando for tocar de novo
			tween.tween_callback(func(): 
				sfx_passos.stop()
				sfx_passos.volume_db = 0
			)

# --- FUNÇÃO DE TRANSIÇÃO DO ZOOM ---
func aplicar_zoom(fov_alvo: float):
	if zoom_tween and zoom_tween.is_running():
		zoom_tween.kill()
		
	zoom_tween = create_tween()
	
	zoom_tween.tween_property(camera, "fov", fov_alvo, tempo_zoom) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN_OUT)

# --- FUNÇÃO DE HEAD BOBBING ---
# --- FUNÇÃO DE HEAD BOBBING ATUALIZADA ---
func aplicar_headbob(delta: float):
	var no_chao = is_on_floor()
	var se_movendo = Vector3(velocity.x, 0, velocity.z).length() > 0.1
	var bob_alvo = Vector3.ZERO
	
	if no_chao and se_movendo:
		tempo_bob += delta * velocity.length()
		
		# Calcula para onde a câmera deve ir
		bob_alvo.y = sin(tempo_bob * BOB_FREQUENCIA) * BOB_AMPLITUDE
		bob_alvo.x = cos(tempo_bob * BOB_FREQUENCIA / 2.0) * BOB_AMPLITUDE
	else:
		# Quando parar, reseta o tempo para a onda começar do zero no próximo passo
		tempo_bob = 0.0 
		
	# A mágica tá aqui: a câmera SEMPRE persegue o bob_alvo suavemente
	camera.transform.origin = camera.transform.origin.lerp(bob_alvo, delta * 10.0)
	
	# Adicione isso no seu script principal do Player
func atualizar_velocidade_externa(agachado: bool):
	if agachado:
		velocidade_atual = 1 # VELOCIDADE_AGACHADO
	elif Input.is_action_pressed("zoom"):
		velocidade_atual = 1 # VELOCIDADE_ZOOM
	else:
		velocidade_atual = 3.0 # VELOCIDADE_NORMAL
