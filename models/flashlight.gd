extends Node3D

@export_category("Configuração do Lag")
@export var intensidade_sway: float = 0.02  # O quanto ela afasta quando mexe o mouse rápido
@export var limite_maximo: float = 0.02    # Limite para a lanterna não sair voando da tela
@export var velocidade_retorno: float = 7.0  # Velocidade com que ela volta pro centro

var rotacao_original: Vector3

func _ready():
	# Respeita 100% a posição e rotação que você deixou no Editor!
	top_level = false 
	rotacao_original = rotation

func _input(event):
	# Captura o movimento puro do mouse para gerar o "atraso"
	if event is InputEventMouseMotion:
		# Quando move o mouse pra direita, a lanterna rotaciona levemente pro lado oposto
		rotation.y -= clamp(event.relative.x * intensidade_sway * 0.1, -limite_maximo, limite_maximo)
		rotation.x -= clamp(event.relative.y * intensidade_sway * 0.1, -limite_maximo, limite_maximo)

func _process(delta):
	# Traz a lanterna de volta para o centro do seu olhar de forma ultra suave
	rotation.x = lerp(rotation.x, rotacao_original.x, velocidade_retorno * delta)
	rotation.y = lerp(rotation.y, rotacao_original.y, velocidade_retorno * delta)
	rotation.z = lerp(rotation.z, rotacao_original.z, velocidade_retorno * delta)
