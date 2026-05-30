extends Node

@onready var ray = $"../head/Camera3D/InteracaoRay"
@onready var mirinha = $"../HUD/CenterContainer/Anchor/Mirinha"

# --- CONFIGURAÇÃO VISUAL POLIDA ---
# Color(R, G, B, Alpha) -> O quarto número é a opacidade (vai de 0.0 a 1.0)
# 0.35 significa 35% de opacidade quando o player está só andando
const COR_NORMAL = Color(1.0, 1.0, 1.0, 0.35) 
const COR_INTERATIVA = Color(1.0, 1.0, 1.0, 0.60)  # Verde levemente azulado e mais opaco (85%)

# Tempo da transição (0.15 segundos dá um feedback responsivo e macio)
const TEMPO_TRANSICAO: float = 0.15 

var mirinha_tween: Tween
var estava_interativo: bool = false # Guarda o estado do frame anterior

func _ready():
	# Inicializa a mirinha com o visual discreto e transparente
	if mirinha:
		mirinha.modulate = COR_NORMAL
		mirinha.scale = Vector2(0.8, 0.8)

func _process(_delta):
	var pode_interagir: bool = false
	
	if ray and ray.is_colliding():
		var objeto_olhado = ray.get_collider()
		if objeto_olhado and objeto_olhado.has_method("interagir"):
			pode_interagir = true
			
			if Input.is_action_just_pressed("interagir"):
				objeto_olhado.interagir()
				
	# GATILHO INTELIGENTE: Só roda a animação se o estado MUDOU de um frame pro outro
	if pode_interagir != estava_interativo:
		estava_interativo = pode_interagir
		executar_animacao_mirinha(pode_interagir)

func executar_animacao_mirinha(interativo: bool):
	if not mirinha:
		return
		
	# Se já tinha uma animação rolando (o player mirou e tirou a mira rápido), cancela ela
	if mirinha_tween and mirinha_tween.is_running():
		mirinha_tween.kill()
		
	# Cria o Tween e ativa o modo paralelo para animar escala e cor JUNTAS
	mirinha_tween = create_tween().set_parallel(true)
	
	# Define os alvos com base no estado atual
	var cor_alvo = COR_INTERATIVA if interativo else COR_NORMAL
	var escala_alvo = Vector2(1.2, 1.2) if interativo else Vector2(1.0, 1.0)
	
	# Animação da Opacidade/Cor (Transição SINE)
	mirinha_tween.tween_property(mirinha, "modulate", cor_alvo, TEMPO_TRANSICAO)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
		
	# Animação do Tamanho (Transição SINE)
	mirinha_tween.tween_property(mirinha, "scale", escala_alvo, TEMPO_TRANSICAO)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
