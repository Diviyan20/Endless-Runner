extends Node

const PLAYER_START_POS: = Vector2i(288,936)
const CAM_START_POS: = Vector2i(960, 536)

var spikes_scene = preload("res://Scenes/spikes.tscn")

var speed : float
var score: int
var health: float = 5.0
var screen_size: Vector2i
var game_running: bool
var spawn_on_ground: = true
var shake_timer = 0.0
var shake_strength = 4.0
var shake_duration = 0.2
var cam_original_pos = Vector2.ZERO

const START_SPEED: float = 10.0
const MAX_SPEED: float = 15.0
const FLOOR_Y = 1015
const CEILING_Y =230
const SCORE_MODIFIER: int = 50

func _ready():
	cam_original_pos = $Camera2D.position
	screen_size = get_window().size
	new_game()
	pass
	
func new_game():
	#reset all variables
	score = 0
	show_score()
	game_running = false
	$Player.position = PLAYER_START_POS
	$Player.velocity = Vector2i(0,0)
	$Camera2D.position = CAM_START_POS
	$HUD.get_node("Play").show()
	pass

func _process(delta):
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
			$Ground.position.x +=screen_size.x
			$Ceiling.position.x +=screen_size.x
	
	if Input.is_action_just_pressed("ui_accept"):
		game_running = true
		$HUD.get_node("Play").hide()
		pass

func show_score():
	$HUD.get_node("Score Label").text = "SCORE: " + str(score / SCORE_MODIFIER)
	pass

func start_shake():
	shake_timer = shake_duration



func _on_spawn_timer_timeout() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var spike = spikes_scene.instantiate()
	var spike_sprite = spike.get_node("Sprite2D")
	var sprite_height = spike_sprite.texture.get_size().y
	
	# Randomize horizontal offset slightly
	var spawn_x = $Camera2D.position.x + screen_size.x + rng.randf_range(0.0, 100.0)

	# Randomize ceiling vs ground with 50-50 chance, but allow more nuance if desired
	var is_ceiling = rng.randi_range(0, 1) == 1

	if is_ceiling:
		spike.position = Vector2(spawn_x, CEILING_Y + sprite_height / 2)
		spike_sprite.flip_v = true
	else:
		spike.position = Vector2(spawn_x, FLOOR_Y - sprite_height / 2)
		spike_sprite.flip_v = false
	
	spike.body_entered.connect(_on_spike_body_entered)
	add_child(spike)

func _on_spike_body_entered(body):
	if body.name=="Player":
		$Player.get_node("Hit_Flash").play("hit_flash")
		health -= 1.0
		if health <= 0.0:
			game_over()

func game_over():
	$Player.get_node("AnimatedSprite2D").show()
	get_tree().paused = true
	game_running = false
	$Player.queue_free()
