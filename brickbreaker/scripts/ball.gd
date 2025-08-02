extends RigidBody2D

@export var initial_speed = 300  # Velocidade inicial em pixels por segundo
var direction = Vector2(0, -1)  # Começa indo para cima

func _ready():
	# Aplica impulso inicial ao iniciar
	apply_central_impulse(direction.normalized() * initial_speed)

func _physics_process(delta):
	# Verifica se a bola caiu abaixo da tela (perda de vida)
	if position.y > get_viewport_rect().size.y + 20:
		queue_free()  # Remove a bola
		# Emitir sinal para perda de vida (vamos conectar isso depois)
