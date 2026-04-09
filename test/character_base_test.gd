extends GdUnitTestSuite

## Testes do CharacterBase
## Verifica modificadores de movimento, estado ativo/inativo e ciclo vida/morte.

var character: CharacterBase

func before_test() -> void:
	character = auto_free(load("res://Scripts/character_base.gd").new())
	add_child(character)

# --------------------------------------------------------
# Valores padrão
# --------------------------------------------------------

func test_speed_padrao_sem_modificadores() -> void:
	assert_float(character.get_speed()).is_equal(character.base_speed)

func test_jump_padrao_sem_modificadores() -> void:
	assert_float(character.get_jump()).is_equal(character.base_jump_velocity)

func test_começa_inativo() -> void:
	assert_that(character.is_active).is_false()

func test_começa_vivo() -> void:
	assert_that(character.is_dead).is_false()

# --------------------------------------------------------
# Modificadores de movimento
# --------------------------------------------------------

func test_apply_modifiers_velocidade() -> void:
	character.apply_modifiers({ "speed_mult": 1.5, "jump_mult": 1.0,
		"gravity_mult": 1.0, "friction": 1.0, "air_control": 1.0 })
	assert_float(character.get_speed()).is_equal(character.base_speed * 1.5)

func test_apply_modifiers_pulo() -> void:
	character.apply_modifiers({ "speed_mult": 1.0, "jump_mult": 2.0,
		"gravity_mult": 1.0, "friction": 1.0, "air_control": 1.0 })
	assert_float(character.get_jump()).is_equal(character.base_jump_velocity * 2.0)

func test_apply_modifiers_friccao_baixa() -> void:
	character.apply_modifiers({ "speed_mult": 1.0, "jump_mult": 1.0,
		"gravity_mult": 1.0, "friction": 0.08, "air_control": 1.0 })
	assert_float(character.friction).is_equal(0.08)

func test_reset_restaura_multiplicadores() -> void:
	character.apply_modifiers({ "speed_mult": 2.0, "jump_mult": 3.0,
		"gravity_mult": 2.0, "friction": 0.1, "air_control": 0.5 })
	character.reset_modifiers()
	assert_float(character.speed_mult).is_equal(1.0)
	assert_float(character.jump_mult).is_equal(1.0)
	assert_float(character.gravity_mult).is_equal(1.0)
	assert_float(character.friction).is_equal(1.0)
	assert_float(character.air_control).is_equal(1.0)

# --------------------------------------------------------
# Estado ativo
# --------------------------------------------------------

func test_set_active_true() -> void:
	character.set_active(true)
	assert_that(character.is_active).is_true()

func test_set_active_false() -> void:
	character.set_active(true)
	character.set_active(false)
	assert_that(character.is_active).is_false()

# --------------------------------------------------------
# Morte e reviver
# --------------------------------------------------------

func test_die_marca_como_morto() -> void:
	character.die()
	assert_that(character.is_dead).is_true()

func test_die_zera_velocidade() -> void:
	character.velocity = Vector2(200, -100)
	character.die()
	assert_that(character.velocity).is_equal(Vector2.ZERO)

func test_revive_restaura_vivo() -> void:
	character.die()
	character.revive()
	assert_that(character.is_dead).is_false()

func test_revive_zera_velocidade() -> void:
	character.velocity = Vector2(100, 50)
	character.die()
	character.revive()
	assert_that(character.velocity).is_equal(Vector2.ZERO)
