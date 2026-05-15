extends Area2D
class_name GravityZone

## Zona que inverte a gravidade do personagem ao entrar.

@export var gravity_scale: float = -1.0  # negativo = invertido

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body is CharacterBase:
		body.gravity_mult = gravity_scale

func _on_body_exited(body: Node) -> void:
	if body is CharacterBase:
		body.gravity_mult = 1.0  # restaura ao sair
