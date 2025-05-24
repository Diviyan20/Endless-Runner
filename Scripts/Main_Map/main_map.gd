extends Node

const PLAYER_START_POS: = Vector2i(288,936)
const CAM_START_POS: = Vector2i(960, 536)

var spikes_scene = preload("res://Scenes/spikes.tscn")

var speed : float
var score: int
var screen_size: Vector2i
var game_running: bool
var spawn_on_ground: = true
var shake_timer = 0.0
var shake_strength = 4.0
var shake_duration = 0.2
var cam_original_pos = Vector2.ZERO

const START_SPEED: float = 10.0
const MAX_SPEED: int = 25
const FLOOR_Y = 1015
const CEILING_Y =230

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
	if game_running:
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
	$HUD.get_node("Score Label").text = "SCORE: " + str(score)
	pass

func start_shake():
	shake_timer = shake_duration

func _on_score_timer_timeout() -> void:
	score += 1
	
	speed = min(START_SPEED + int(score / 10) * 5, MAX_SPEED)
	show_score()
	pass


func _on_spawn_timer_timeout() -> void:
	var spike = spikes_scene.instantiate()
	var spike_sprite = spike.get_node("Sprite2D")
	var sprite_height = spike_sprite.texture.get_size().y
	var spawn_x = $Camera2D.position.x + screen_size.x

	if randi() % 2 == 0:
		# Ground
		spike.position = Vector2(spawn_x, FLOOR_Y - sprite_height / 2)
	else:
		# Ceiling
		spike.position = Vector2(spawn_x, CEILING_Y + sprite_height / 2)
		spike_sprite.flip_v = true
	
	spike.body_entered.connect(_on_spike_body_entered)
	add_child(spike)

func _on_spike_body_entered(body):
	if body.name=="Player":
		game_over()

func game_over():
	$Player.get_node("AnimatedSprite2D").show()
	get_tree().paused = true
	game_running = false
