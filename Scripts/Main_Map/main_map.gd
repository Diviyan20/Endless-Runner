extends Node

const PLAYER_START_POS: = Vector2i(288,936)
const CAM_START_POS: = Vector2i(960, 536)

var spikes_scene = preload("res://Scenes/spikes.tscn")

var speed : float
var score: int
var screen_size: Vector2i
var game_running: bool
var spawn_on_ground: = true

const START_SPEED: float = 10.0
const MAX_SPEED: int = 25
const FLOOR_Y = 1015
const CEILING_Y =230

func _ready():
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

func _process(_delta):
	if game_running:
		show_score()
		$Player.position.x += speed
		$Camera2D.position.x += speed
		
		#update ground position
		if $Camera2D.position.x - $Ground.position.x > screen_size.x * 1.5:
			$Ground.position.x +=screen_size.x
			$Ceiling.position.x +=screen_size.x
	else:
		if Input.is_action_just_pressed("ui_accept"):
			game_running = true
			$HUD.get_node("Play").hide()
		pass

func show_score():
	$HUD.get_node("Score Label").text = "SCORE: " + str(score)
	pass


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

	add_child(spike)
