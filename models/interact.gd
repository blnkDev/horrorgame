extends StaticBody3D

@export var angulo_abertura: float = 90.0 # Ângulo em graus para abrir
@export var tempo_animacao: float = 0.5  # Tempo que leva para abrir/fechar

var esta_aberta: bool = false
var porta_tween: Tween

func interagir():
	# Inverte o estado: se estava fechada (false), vira aberta (true) e vice-versa
	esta_aberta = not esta_aberta
	
	print("porta")
	
	# O Godot trabalha com Radianos para rotação 3D, então convertemos graus para radianos
	var angulo_alvo = deg_to_rad(angulo_abertura) if esta_aberta else 0.0
	
	# Se o jogador clicar na porta enquanto ela ainda está mexendo, cancela a animação atual
	if porta_tween and porta_tween.is_running():
		porta_tween.kill()
		
	# Cria a transição suave de rotação no eixo Y
	porta_tween = create_tween()
	porta_tween.tween_property(self, "rotation:y", angulo_alvo, tempo_animacao) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN_OUT)
