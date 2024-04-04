extends Node

@export var pipe_scene : PackedScene

var game_running : bool
var game_over : bool
var scroll
var score
const SCROLL_SPEED : int = 4
var screen_size : Vector2i
var ground_height : int
var obstacle : Array
const PIPE_DELAY : int = 350
const PIPE_RANGE : int = 150

func _ready():
	screen_size = get_window().size
	ground_height = $ground.get_node("Sprite2D").texture.get_height()
	new_game()
	
func new_game():
	game_running = false
	game_over = false
	score = 0
	scroll = 0
	get_tree().call_group("obstacles", "queue_free")
	obstacle.clear()
	generate_pipes()
	$plane.reset()	
	$GameOver.hide()
	
func _input(event):
	if game_over == false:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				if game_running == false :
					start_game()
				else:
					if $plane.flying:
						$plane.flap()
						check_top()
				
func start_game():
	game_running = true
	$plane.flying = true
	$plane.flap()
	$pipeTimer.start()
	
func _process(delta):
	if game_running:
		scroll += SCROLL_SPEED
		if scroll >= screen_size.x :
			scroll = 0
		$ground.position.x = -scroll
		for pipe in obstacle:
			pipe.position.x -= SCROLL_SPEED

func _on_pipe_timer_timeout():
	generate_pipes()
	
func generate_pipes():
	var pipe = pipe_scene.instantiate()
	pipe.position.x = screen_size.x + PIPE_DELAY
	pipe.position.y = (screen_size.y - ground_height) / 2 + randi_range(-PIPE_RANGE, PIPE_RANGE)
	pipe.hit.connect(plan_hit)
	pipe.scored.connect(scored)
	add_child(pipe)
	obstacle.append(pipe)
	if obstacle.size() > 4 :
		#obstacle[0].get_node("up").t
		#obstacle.pop_front()
		obstacle.remove_at(0)

func scored():
	score += 1
	$scoreLabel.text = "Score : " + str(score)

func check_top():
	if $plane.position.y < 0:
		$plane.falling = true
		stop_game()
		
func stop_game():
	$GameOver.show()
	$pipeTimer.stop()
	$plane.flying = false
	game_running = false
	game_over = true
	
func plan_hit() :
	$plane.falling = true
	stop_game()


func _on_ground_hit():
	$plane.falling = false
	stop_game()


func _on_game_over_restart():
	new_game()
