extends StaticBody3D

@export var angulo_abertura: float = -90.0 # Ângulo em graus para abrir
@export var tempo_animacao: float = 0.5  # Tempo que leva para abrir/fechar

@onready var som_abrindo = $SomPortaOpen
@onready var som_fechando = $SomPortaClose

var esta_aberta: bool = false
var porta_tween: Tween

func interagir():
	esta_aberta = not esta_aberta
	
	print("porta") # Seu print de teste pra garantir o clique
	
	if som_abrindo and esta_aberta == true:
		som_abrindo.play()
	else:
		som_fechando.play()
	
	var angulo_alvo = deg_to_rad(angulo_abertura) if esta_aberta else 0.0
	
	if porta_tween and porta_tween.is_running():
		porta_tween.kill()
		
	porta_tween = create_tween()
	
	# A MÁGICA ESTÁ AQUI: Mudamos de 'self' para 'get_parent()'
	# Agora o Tween gira o modelo 3D, e a colisão vai junto por ser filha!
	porta_tween.tween_property(get_parent(), "rotation:z", angulo_alvo, tempo_animacao) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN_OUT)
