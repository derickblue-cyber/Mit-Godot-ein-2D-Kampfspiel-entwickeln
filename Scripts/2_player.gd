extends CharacterBody2D

signal knockback_p2

#The player body
@onready var animated_sprite = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var animation_player: AnimationPlayer = $Hitbox/AnimationPlayer
@onready var hurtbox: Area2D = $Hurtbox
@onready var collision_shape_2d: CollisionShape2D = $Hurtbox/CollisionShape2D

# all constants
const NAME ='player_2'
const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# all variabels
var knockback_direction=1
var knockback
var direction = 1
var knockback_velocity_x = 0
var knockback_wait = 20
var is_ready_doge = true
var damage2 = 0
var jump_count = 0
var damage_taken = 1

#
func _on_player_1_knockback() -> void:
	var player_direction = get_parent().get_node('player').direction
	knockback_direction = player_direction
	knockback=true

func _physics_process(delta: float) -> void:
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	else: 
		jump_count=0

	# Movement controle
	if Input.is_action_just_pressed("Jump_p2") and jump_count<2:
		jump_count+=1
		velocity.y = JUMP_VELOCITY
		animated_sprite.play('jump')

	if Input.is_action_pressed('Walk_right_p2'):
		velocity.x = SPEED
		direction = 1
		animated_sprite.flip_h = false
		animated_sprite.play('run animation')
		
	elif Input.is_action_pressed('Walk_left_p2'):
		velocity.x = -SPEED
		direction = -1
		animated_sprite.flip_h = true
		animated_sprite.play('run animation')
		
	if	Input.is_action_just_released('Walk_right_p2'):
		velocity.x =0
		direction = 1
		animated_sprite.play('Idle')
		
	if	Input.is_action_just_released('Walk_left_p2'):
		velocity.x =0
		direction = -1
		animated_sprite.flip_h = true
		animated_sprite.play('Idle')
		
	
	if Input.is_action_just_pressed("doge_p2") and is_ready_doge: #remember to but in code that won't allow any outher Kind of movment
		is_ready_doge = false
		$Hitbox/AnimationPlayer.play("doge_p2")
		$cooldown_doge.start()
		
	# ATTACKS
	# Normal punch
	if animated_sprite.flip_h==true:
		hitbox.scale = Vector2(1,1)
		collision_shape_2d.scale = Vector2 (1,1)
	else:
		hitbox.scale = Vector2(-1,-1)
		collision_shape_2d.scale = Vector2 (-1,-1)
		 
	if Input.is_action_just_pressed('punch_p2'):
		#activate hit box for pl2
		$Hitbox/AnimationPlayer.play('punch_p2')
		
		
	# the actual knockback
	if knockback == true:
		velocity.y = -500
		direction = knockback_direction
		knockback_velocity_x=400*direction*damage_taken
		velocity.x= knockback_velocity_x
		knockback = false
		damage_taken+=0.2
		
	if knockback_velocity_x > 1 or knockback_velocity_x < -1:
		$Hitbox/AnimationPlayer.play("damage_p2")
		knockback_velocity_x=knockback_velocity_x*0.95
		velocity.x= knockback_velocity_x
	else:
		knockback_velocity_x=0
		
	for area in $Hitbox.get_overlapping_areas():
		if knockback_wait<= 0:
			damage2=damage2+1
			print("player_2 =", damage2)
			emit_signal("knockback_p2")
			knockback_wait = 10
	knockback_wait -= 1

	
	move_and_slide()

func _on_timer_timeout() -> void:
	is_ready_doge=true
