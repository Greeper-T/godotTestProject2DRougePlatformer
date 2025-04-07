extends CharacterBody2D


@export var speed = 3
@export var jumpPower = 10
@export var dashSpeed = 20
@export var dashTime = 0.2
@export var dashCooldown = 1.0

@onready var boss_texure: AnimatedSprite2D = $bossTexure
@onready var muzzle: Node2D = $bossTexure/muzzle


var speedMultiplier = 30
var jumpMultiplier = -30
var direction = 0
var jumpsLeft = 1
var sprintSpeed = speed + 3
var lastDirection = 1

var isDashing = false
var canDash = true
var dashTimer = 0.0
var dashCooldownTimer = 0.0

var currentMode = 0
var enemiesInRange = []
var hp = null
var maxHp = null
var init = false

func _input(event: InputEvent) -> void:
	#handles jumping events such as double jump and wall jumps
	if event.is_action_pressed("jump") and !Input.is_action_pressed("moveDown"):
		if is_on_floor():
			velocity.y = jumpPower * jumpMultiplier
		elif jumpsLeft >= 1:
			velocity.y = jumpPower * jumpMultiplier
			jumpsLeft -= 1
	
	#deals with healing
	if event.is_action_pressed("heal"):
		PlayerData.addHp(100)
		
	if event.is_action_pressed("dash") and canDash:
		startDash()
	
	#deal with attacking
	if event.is_action_pressed("fireBullet"):
		changeState(PlayerData.PlayerState.MELEE_ATTACK)

func _process(delta):
	hp = PlayerData.hp
	maxHp = PlayerData.maxHp

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		
		velocity += get_gravity() * delta
		if Input.is_action_pressed("moveDown") and velocity.y > 0:
			velocity.y += 40000 * delta
		if velocity.y < 0 and PlayerData.currentState != PlayerData.PlayerState.MELEE_ATTACK:
			changeState(PlayerData.PlayerState.JUMPING)
		elif PlayerData.currentState != PlayerData.PlayerState.MELEE_ATTACK:
			changeState(PlayerData.PlayerState.FALLING)
	else:
		jumpsLeft = 1

	# Handle move down one way.
	if Input.is_action_pressed("moveDown") and Input.is_action_pressed("jump"):
		set_collision_mask_value(10,false)
	else:
		set_collision_mask_value(10,true)
	
	if Input.is_action_pressed("sprint"):
		PlayerData.speed = sprintSpeed
		if PlayerData.currentState != PlayerData.PlayerState.MELEE_ATTACK:
			changeState(PlayerData.PlayerState.SPRINTING)
	else:
		PlayerData.speed = sprintSpeed/1.5
	if isDashing:
		dashTimer -= delta
		if dashTimer <= 0:
			endDash()
	else:

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
		direction = Input.get_axis("moveLeft", "moveRight")
		if direction != 0:
			velocity.x = direction * PlayerData.speed * speedMultiplier
			if is_on_floor() and PlayerData.currentState != PlayerData.PlayerState.MELEE_ATTACK:
				changeState(PlayerData.PlayerState.MOVING)
			if direction != sign(lastDirection):
				boss_texure.scale.x *= -1
				lastDirection = direction
		else:
			velocity.x = move_toward(velocity.x, 0, speedMultiplier * PlayerData.speed)
			if is_on_floor() and PlayerData.currentState != PlayerData.PlayerState.MELEE_ATTACK:
				changeState(PlayerData.PlayerState.IDLE)
	
	if not canDash:
		dashCooldownTimer -= delta
		if dashCooldownTimer <= 0:
			canDash = true
	move_and_slide()
	
	

func changeState(newState):
	PlayerData.currentState = newState
	playerAnimations()

func startDash():
	isDashing = true
	canDash = false
	dashTimer = dashTime
	dashCooldownTimer = dashCooldown
	velocity.x = lastDirection * dashSpeed * speedMultiplier
	
func endDash():
	isDashing = false
	velocity.x = 0
	
func _ready() -> void:
	sprintSpeed = PlayerData.speed * 1.5
	if init:
		maxHp = maxHp
		hp = hp
	else:
		maxHp = 100
		hp = 50
		init = true
	GameManager.hudUpdate()



func _on_hurtbox_body_entered(body: Node2D) -> void:
	var damage: float = 0
	if body.has_method("getDamage"):
		print("take damage")
		damage = body.damage
	if not isDashing:
		PlayerData.takeDamage(damage/2)
		checkIfDead()

func takeDamage(damages: float):
	print("damage taken")
	if not isDashing:
		PlayerData.takeDamage(damages/2)
		checkIfDead()

func checkIfDead():
	if PlayerData.hp <= 0:
		changeState(PlayerData.PlayerState.DEATH)

func playerAnimations():
	if PlayerData.currentState == PlayerData.PlayerState.IDLE:
		boss_texure.play("idle")
	elif  PlayerData.currentState == PlayerData.PlayerState.MOVING:
		boss_texure.play("idle")
	elif PlayerData.currentState == PlayerData.PlayerState.JUMPING:
		boss_texure.play("idle")
	elif PlayerData.currentState == PlayerData.PlayerState.FALLING:
		boss_texure.play("idle")
	elif PlayerData.currentState == PlayerData.PlayerState.MELEE_ATTACK:
		boss_texure.play("meleeAttack")
	elif PlayerData.currentState == PlayerData.PlayerState.DEATH:
		boss_texure.play("death")
		await boss_texure.animation_finished
		PlayerData.die()

func _on_enemy_in_melee_body_entered(body: Node2D) -> void:
	if body not in enemiesInRange and body is CharacterBody2D:
		enemiesInRange.append(body)


func _on_enemy_in_melee_body_exited(body: Node2D) -> void:
	if body in enemiesInRange:
		enemiesInRange.erase(body)


func _on_boss_texure_animation_finished() -> void:
	if PlayerData.currentState == PlayerData.PlayerState.MELEE_ATTACK:
		for enemy in enemiesInRange:
			enemy.takeDamage(PlayerData.damage)
		PlayerData.currentState = PlayerData.PlayerState.IDLE
