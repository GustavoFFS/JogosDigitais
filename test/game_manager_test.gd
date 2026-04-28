extends GdUnitTestSuite

## Testes do GameManager
## Verifica fluxo de fases, contador de mortes e estados do jogo.

var gm: Node

func before_test() -> void:
	gm = load("res://Scripts/game_manager.gd").new()
	add_child(gm)

func after_test() -> void:
	gm.queue_free()

# --------------------------------------------------------
# Estado inicial
# --------------------------------------------------------

func test_estado_inicial_e_menu() -> void:
	assert_that(gm.current_state).is_equal(gm.GameState.MENU)

func test_inicio_com_zero_mortes() -> void:
	gm.start_game()
	assert_that(gm.deaths).is_equal(0)

func test_inicia_na_fase_1() -> void:
	gm.start_game()
	assert_that(gm.current_level_index).is_equal(0)

# --------------------------------------------------------
# Fases
# --------------------------------------------------------

func test_total_de_5_fases() -> void:
	assert_that(gm.get_level_count()).is_equal(5)

func test_proximo_nivel_avanca_indice() -> void:
	gm.start_game()
	var avancou := gm.next_level()
	assert_that(avancou).is_true()
	assert_that(gm.current_level_index).is_equal(1)

func test_ultima_fase_retorna_false() -> void:
	gm.start_game()
	gm.current_level_index = 4
	var avancou := gm.next_level()
	assert_that(avancou).is_false()

func test_jogo_completo_apos_ultima_fase() -> void:
	gm.start_game()
	gm.current_level_index = 4
	gm.next_level()
	assert_that(gm.current_state).is_equal(gm.GameState.GAME_COMPLETE)

func test_dados_da_fase_1_existem() -> void:
	gm.start_game()
	var level := gm.get_current_level()
	assert_that(level).is_not_null()
	assert_that(level.has("name")).is_true()
	assert_that(level.has("modifiers")).is_true()
	assert_that(level.has("platforms")).is_true()

# --------------------------------------------------------
# Mortes (sem game over — apenas contador)
# --------------------------------------------------------

func test_registrar_morte_incrementa_contador() -> void:
	gm.start_game()
	gm.register_death()
	assert_that(gm.deaths).is_equal(1)

func test_morrer_varias_vezes_nao_termina_o_jogo() -> void:
	gm.start_game()
	for i in 10:
		gm.register_death()
	assert_that(gm.deaths).is_equal(10)
	assert_that(gm.current_state).is_equal(gm.GameState.PLAYING)

func test_reset_restaura_estado_inicial() -> void:
	gm.start_game()
	gm.next_level()
	gm.register_death()
	gm.reset_game()
	assert_that(gm.current_level_index).is_equal(0)
	assert_that(gm.deaths).is_equal(0)
	assert_that(gm.current_state).is_equal(gm.GameState.MENU)
