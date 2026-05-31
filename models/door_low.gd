extends StaticBody3D

@export_category("Configurações da Porta")
@export var angulo_abertura: float = 110.0  # Em graus. Se abrir pro lado errado, mude para -90.0
@export var tempo_animacao: float = 0.6    # Tempo para abrir/fechar

@onready var som_abrindo = $FrigdeOpening
@onready var som_fechando = $FrigdeClosing

var esta_aberta: bool = false
var rotacao_inicial_y: float
var tween: Tween

func _ready():
	# Salva o ângulo exato em que a porta começou (fechada)
	rotacao_inicial_y = rotation.y

# ESSA É A FUNÇÃO QUE O SEU SCRIPT DE INTERAÇÃO DO PLAYER VAI CHAMAR!
func interagir():
	# Se a porta já estiver se movendo, cancela o tween atual para não dar bug
	if tween and tween.is_running():
		tween.kill()
	
	# Cria a animação via código de forma ultra suave
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	
	if not esta_aberta:
		# Calcula o ângulo final somando os graus convertidos para Radianos (padrão do Godot 3D)
		var alvo_rotacao = rotacao_inicial_y + deg_to_rad(angulo_abertura)
		tween.tween_property(self, "rotation:y", alvo_rotacao, tempo_animacao)
		esta_aberta = true
		som_abrindo.play()
	else:
		# Volta para a rotação original de fechada
		tween.tween_property(self, "rotation:y", rotacao_inicial_y, tempo_animacao)
		esta_aberta = false
		som_fechando.play()
