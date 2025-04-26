extends Node3D

const TREE = preload("res://models/tree/tree.tscn")

var speed = 2.0
var lateral = 0.0
var side = 1.0

var tree_limit = -5.0
var tree_step = 1.0

var score = 0.0

func _ready() -> void:
	for i in range(100):
		add_next_tree_if_needed()
	%SendItButton.grab_focus()
	get_tree().paused = true

func _physics_process(delta: float) -> void:
	var collision = %Character.move_and_collide(Vector3(lateral, 0.0, -speed) * delta)
	%Camera.rotation_degrees.y = lateral * -7.0
	if collision:
		get_tree().paused = true;
		#var distance = %Character.global_position.z * -1
		#%ScoreLabel.text = "Distance: %0.1f Gnarly Units" % [distance]
		%GameOver.show()
		%RetryButton.grab_focus()
	
	var distance = %Character.global_position.z * -1
	%ScoreLabel.text = "Score: %0.1f Gnarly Units" % [score]
	
	lateral = lerp(lateral, speed * side * 1.3, 0.035)
	
	if Input.is_action_just_pressed("toggle"):
		side *= -1
		speed *= 0.8
	
	for ground in %Grounds.get_children():
		if ground.global_position.z > %Character.global_position.z + 12.5:
			ground.global_position += Vector3(0, 0, -45)
	
	speed += delta * 1.2
	
	add_next_tree_if_needed()
	
	score += speed * speed * speed * delta


func _on_retry_button_pressed() -> void:
	get_tree().reload_current_scene()


func _on_send_it_button_pressed() -> void:
	get_tree().paused = false;
	%StartScreen.hide()

func add_next_tree_if_needed():
	if tree_limit > %Character.global_position.z - 45:
		var tree = TREE.instantiate()
		tree.global_position = Vector3(randf() * 20.0 - 10.0, 0, tree_limit)
		%Forest.add_child(tree)
		tree_limit -= tree_step
		tree_step *= 0.99
		if tree_step < 0.2:
			tree_step = 0.2
	for tree in %Forest.get_children():
		if tree.global_position.z > %Character.global_position.z + 1:
			tree.queue_free()
