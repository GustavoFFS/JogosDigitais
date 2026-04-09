extends GdUnitTestSuite

## Testes do GameManager
## Verifica fluxo de fases, vidas e estados do jogo.

var gm: Node

func before_test() -> void:
	# Cria uma instância limpa do GameManager para cada teste
	gm = load("res://Scripts/game_manager.gd").new()
	add_child(gm)

func after_test() -> void:
	gm.queue_free()

# --------------------------------------------------------
# Estado inicial
# --------------------------------------------------------

func test_estado_inicial_e_menu() -> void:
	assert_that(gm.current_state).is_equal(gm.GameState.MENU)

func test_inicio_com_3_vidas() -> void:
	gm.start_game()
	assert_that(gm.lives).is_equal(3)

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
	gm.current_level_index = 4   # posiciona na ultima fase
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
# Vidas
# --------------------------------------------------------

func test_perder_vida_diminui_contador() -> void:
	gm.start_game()
	gm.lose_life()
	assert_that(gm.lives).is_equal(2)

func test_perder_todas_as_vidas_retorna_false() -> void:
	gm.start_game()
	gm.lose_life()
	gm.lose_life()
	var ainda_vivo := gm.lose_life()
	assert_that(ainda_vivo).is_false()

func test_reset_restaura_estado_inicial() -> void:
	gm.start_game()
	gm.next_level()
	gm.lose_life()
	gm.reset_game()
	assert_that(gm.current_level_index).is_equal(0)
	assert_that(gm.lives).is_equal(3)
	assert_that(gm.current_state).is_equal(gm.GameState.MENU)
