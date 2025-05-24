extends Node

const PLAYER_START_POS: = Vector2i(288,936)
const CAM_START_POS: = Vector2i(960, 536)

var speed : float
var score: int
var screen_size: Vector2i
var game_running: bool
const START_SPEED: float = 10.0
const MAX_SPEED: int = 25

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
		speed = START_SPEED
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
	show_score()
	pass
