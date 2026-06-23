extends Node2D

const CELL_SIZE = 22
const GRID_SIZE = 22

var snake_body = []
var direction = Vector2.RIGHT
var next_direction = Vector2.RIGHT
var food_position = Vector2.ZERO
var game_over = false
var score = 0
var tick_time = 0.10

var timer: Timer

func _ready() -> void:
	start_game()

func start_game() -> void:
	snake_body = [Vector2(5, 10), Vector2(4, 10), Vector2(3, 10)]
	direction = Vector2.RIGHT
	next_direction = Vector2.RIGHT
	game_over = false
	score = 0
	tick_time = 0.15
	spawn_food()

	if timer:
		timer.queue_free()
	timer = Timer.new()
	timer.wait_time = tick_time
	timer.timeout.connect(_on_tick)
	add_child(timer)
	timer.start()

	queue_redraw()

func _on_tick() -> void:
	if game_over:
		return
	direction = next_direction
	move_snake()
	queue_redraw()

func move_snake() -> void:
	var new_head = snake_body[0] + direction

	if new_head.x < 0 or new_head.x >= GRID_SIZE or new_head.y < 0 or new_head.y >= GRID_SIZE:
		game_over = true
		print("Perdiste: chocaste con el límite. Puntaje: ", score)
		return

	if new_head in snake_body:
		game_over = true
		print("Perdiste: chocaste contigo mismo. Puntaje: ", score)
		return

	snake_body.insert(0, new_head)

	if new_head == food_position:
		score += 1
		spawn_food()
		tick_time = max(0.06, tick_time - 0.005)
		timer.wait_time = tick_time
	else:
		snake_body.pop_back()

func spawn_food() -> void:
	var new_pos = Vector2(randi() % GRID_SIZE, randi() % GRID_SIZE)
	while new_pos in snake_body:
		new_pos = Vector2(randi() % GRID_SIZE, randi() % GRID_SIZE)
	food_position = new_pos

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		print("Tecla detectada: ", event.keycode) # Para comprobar que sí detecta input

		if game_over and event.keycode == KEY_SPACE:
			start_game()
			return

		if event.keycode == KEY_UP and direction != Vector2.DOWN:
			next_direction = Vector2.UP
		elif event.keycode == KEY_DOWN and direction != Vector2.UP:
			next_direction = Vector2.DOWN
		elif event.keycode == KEY_LEFT and direction != Vector2.RIGHT:
			next_direction = Vector2.LEFT
		elif event.keycode == KEY_RIGHT and direction != Vector2.LEFT:
			next_direction = Vector2.RIGHT

func _draw() -> void:
	var field_size = Vector2(GRID_SIZE * CELL_SIZE, GRID_SIZE * CELL_SIZE)

	# Fondo negro tipo consola retro
	draw_rect(Rect2(Vector2.ZERO, field_size), Color(0.02, 0.02, 0.02), true)

	# Cuadrícula sutil (efecto pantalla CRT)
	for x in range(GRID_SIZE):
		draw_line(Vector2(x * CELL_SIZE, 0), Vector2(x * CELL_SIZE, field_size.y), Color(0, 0.2, 0, 0.4), 1.0)
	for y in range(GRID_SIZE):
		draw_line(Vector2(0, y * CELL_SIZE), Vector2(field_size.x, y * CELL_SIZE), Color(0, 0.2, 0, 0.4), 1.0)

	# Borde verde fosforescente
	draw_rect(Rect2(Vector2.ZERO, field_size), Color(0, 1, 0.3), false, 4.0)

	# Cuerpo de la serpiente - verde fosforescente clásico
	for i in range(snake_body.size()):
		var color = Color(0.7, 1, 0.3) if i == 0 else Color(0, 0.85, 0.2) # cabeza más clara
		# Pequeño margen entre celdas para efecto "pixel" separado
		draw_rect(Rect2(snake_body[i] * CELL_SIZE + Vector2(1, 1), Vector2(CELL_SIZE - 2, CELL_SIZE - 2)), color)

	# Fruta - rojo/naranja brillante estilo arcade
	draw_rect(Rect2(food_position * CELL_SIZE + Vector2(2, 2), Vector2(CELL_SIZE - 4, CELL_SIZE - 4)), Color(1, 0.3, 0))

	# Puntaje estilo arcade (verde fosforescente)
	draw_string(ThemeDB.fallback_font, Vector2(10, field_size.y + 28), "SCORE: " + str(score).pad_zeros(4), HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color(0, 1, 0.3))

	if game_over:
		# Fondo semi-transparente sobre el campo para resaltar el mensaje
		draw_rect(Rect2(Vector2.ZERO, field_size), Color(0, 0, 0, 0.7), true)
		draw_string(ThemeDB.fallback_font, Vector2(field_size.x / 2 - 110, field_size.y / 2 - 10), "GAME OVER", HORIZONTAL_ALIGNMENT_LEFT, -1, 36, Color(1, 0.2, 0.2))
		draw_string(ThemeDB.fallback_font, Vector2(field_size.x / 2 - 130, field_size.y / 2 + 25), "PRESS SPACE TO RESTART", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(0, 1, 0.3))
