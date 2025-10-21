extends CharacterBody2D

signal knockback

@onready var animated_sprite = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimatedSprite2D/Hitbox/AnimationPlayer
@onready var hitbox: Area2D = $AnimatedSprite2D/Hitbox
@onready var hurtbox: Area2D = $Hurtbox
@onready var collision_shape_2d: CollisionShape2D = $Hurtbox/CollisionShape2D


# all constants
const NAME ='player'
const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# all variabels
var direction = 1
var motion = Vector2()
var knockback_p2 #Knockback variable for player 2
var knockback_direction = 1
var knockback_wait = 1 #time for the Knockback
var is_ready_doge = true
var knockback_velocity_x = 0
var damage1=0
var damage_taken=1
var jump_count = 0

func _ready():
	$Hurtbox/CollisionShape2D.disabled = false

#I think this problem is here but I don't really know what it is yet
func _on__player_knockback_p_2() -> void:
	var player_direction = get_parent().get_node('2_Player').direction
	knockback_direction = player_direction
	knockback_p2=true


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		jump_count=0

	# Handle jump.
	if Input.is_action_just_pressed("ui_up") and jump_count<2:
		jump_count+=1
		velocity.y = JUMP_VELOCITY
		animated_sprite.play('jump')
		
	
	# Get the input direction and handle the movement/deceleration.
	# also conected to the animation
	if animated_sprite.flip_h==true:
		hitbox.scale = Vector2(-1,-1)
	else:
		hitbox.scale = Vector2(1,1)
	
	if Input.is_action_just_pressed('ui_accept'):
		#plays hit box animation
		$AnimatedSprite2D/Hitbox/AnimationPlayer.play('punch') 
		
	if Input.is_action_just_pressed("ui_down") and is_ready_doge: #remember to but in code that won't allow any outher Kind of movment
		is_ready_doge=false
		$AnimatedSprite2D/Hitbox/AnimationPlayer.play("doge")
		$cooldown_doge_p1.start()
	
	#walking and stoping
	if Input.is_action_pressed('ui_right'):
		velocity.x = SPEED
		animated_sprite.flip_h = false
		direction = 1
		animated_sprite.play('run animation')
		
	elif Input.is_action_pressed('ui_left'):
		velocity.x = -SPEED
		direction = -1
		animated_sprite.flip_h = true
		animated_sprite.play('run animation')
		
	if	Input.is_action_just_released('ui_left'):
		velocity.x =0
		direction = -1
		animated_sprite.flip_h = true
		animated_sprite.play('Idle')
		
	if	Input.is_action_just_released('ui_right'):
		velocity.x =0
		animated_sprite.flip_h = false
		direction = 1
		animated_sprite.play('Idle')
		
		# the actual knockback
	if knockback_p2 == true:
		direction = knockback_direction
		velocity.y = -500
		knockback_velocity_x=400*direction*damage_taken
		velocity.x= knockback_velocity_x
		knockback_p2 = false
		damage_taken+=0.2
		
	if knockback_velocity_x < -1 or knockback_velocity_x > 1:
		$AnimatedSprite2D/Hitbox/AnimationPlayer.play("damage_1")
		knockback_velocity_x = knockback_velocity_x*0.95
		velocity.x= knockback_velocity_x #add a timer that will make the Knockback last for a second and then stop
	else:
		knockback_velocity_x=0
		
	# when the punching hitbox overlaps with the hitbox of p2 send knockback signal 
	for area in $AnimatedSprite2D/Hitbox.get_overlapping_areas():
		if knockback_wait<= 0:
			damage1=damage1+1
			print("player_1 =", damage1)
			emit_signal("knockback")
			knockback_wait = 10
	knockback_wait -= 1

	move_and_slide()
	
func _on_cooldown_doge_p_1_timeout() -> void:
	is_ready_doge=true
