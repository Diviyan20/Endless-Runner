extends Node

const PLAYER_START_POS := Vector2i(288, 936)
const CAM_START_POS := Vector2i(960, 536)

var spikes_scene = preload("res://Scenes/spikes.tscn")
var spider_robot_scene = preload("res://Scenes/spider_robot.tscn")

var speed: float
var score: int
var high_score: int
var health: float = 5.0
var screen_size: Vector2i
var game_running: bool
var shake_timer = 0.0
var shake_strength = 4.0
var shake_duration = 0.2
var cam_original_pos = Vector2.ZERO

const START_SPEED: float = 10.0
const MAX_SPEED: float = 20.0
const FLOOR_Y = 1015
const CEILING_Y = 230
const SCORE_MODIFIER: int = 50

func _ready():
	cam_original_pos = $Camera2D.position
	screen_size = get_window().size
	new_game()

func new_game():
	score = 0
	show_score()
	check_high_score()
	$Player.position = PLAYER_START_POS
	$Player.velocity = Vector2i(0, 0)
	$Camera2D.position = CAM_START_POS

func _process(delta):
	game_running = true
	score += speed

	if game_running:
		speed = START_SPEED + score / 5000
		if speed > MAX_SPEED:
			speed = MAX_SPEED
		show_score()
		$Player.position.x += speed
		$Camera2D.position.x += speed

	if shake_timer > 0:
		shake_timer -= delta
		$Camera2D.offset = Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
	else:
		$Camera2D.offset = Vector2.ZERO

	if $Camera2D.position.x - $Ground.position.x > screen_size.x * 1.5:
		$Ground.position.x += screen_size.x
		$Ceiling.position.x += screen_size.x

func show_score():
	$HUD.get_node("Score Label").text = "SCORE: " + str(score / SCORE_MODIFIER)

func check_high_score():
	if score > high_score:
		high_score = score
	$HUD.get_node("High Score Label").text = "HIGH SCORE: " + str(score / SCORE_MODIFIER)

func start_shake():
	shake_timer = shake_duration

func _on_spawn_timer_timeout():
	var rng := RandomNumberGenerator.new()
	rng.randomize()

	var obstacle_type := rng.randi_range(0, 1)
	var obstacle
	var sprite_height = 0.0
	var spawn_x = $Camera2D.position.x + screen_size.x + rng.randf_range(0.0, 100.0)

	if obstacle_type == 0:
		# Spike Obstacle
		obstacle = spikes_scene.instantiate()
		if obstacle.has_node("Sprite2D"):
			var sprite: Sprite2D = obstacle.get_node("Sprite2D")
			sprite_height = sprite.texture.get_size().y

			var is_ceiling = rng.randi_range(0, 1) == 1
			if is_ceiling:
				obstacle.position = Vector2(spawn_x, CEILING_Y + sprite_height / 2)
				sprite.flip_v = true
			else:
				obstacle.position = Vector2(spawn_x, FLOOR_Y - sprite_height / 2)
				sprite.flip_v = false
		else:
			print("❌ Sprite2D not found in spikes.tscn")

	else:
		# Spider Robot Obstacle (now using Sprite2D)
		obstacle = spider_robot_scene.instantiate()
		if obstacle.has_node("Sprite2D"):
			var sprite: Sprite2D = obstacle.get_node("Sprite2D")
			if sprite.texture:
				sprite_height = sprite.texture.get_size().y
				# If centered is true, the pivot is in the middle
				if sprite.centered:
					obstacle.position = Vector2(spawn_x, FLOOR_Y - sprite_height / 7)
				else:
					obstacle.position = Vector2(spawn_x, FLOOR_Y - sprite_height)
			else:
				obstacle.position = Vector2(spawn_x, FLOOR_Y)  # fallback
		else:
			print("❌ Sprite2D not found in spider_robot.tscn")

	# Connect collision and add to scene
	obstacle.body_entered.connect(_on_spike_body_entered)
	add_child(obstacle)


func _on_spike_body_entered(body):
	if body.name == "Player":
		$Player.get_node("Hit_Flash").play("hit_flash")
		health -= 1.0
		if health <= 0.0:
			game_over()

func game_over():
	check_high_score()
	$Player.get_node("AnimatedSprite2D").show()
	get_tree().paused = true
	game_running = false
	get_tree().change_scene_to_file("res://Scenes/game_over.tscn")
