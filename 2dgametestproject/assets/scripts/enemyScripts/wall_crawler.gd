extends CharacterBody2D

@export var speed := 50.0
@export var ray_length := 16.0

var surface_normal := Vector2.UP
var surface_change_timer := 0.0
const SURFACE_CHANGE_COOLDOWN := 1.0  # seconds (tweak if needed)


func _ready() -> void:
	update_rays()
	$rayDown.enabled = true
	$rayForward.enabled = true

func _physics_process(delta: float) -> void:
	surface_change_timer -= delta

	var tangent = Vector2(-surface_normal.y, surface_normal.x).normalized()
	velocity = tangent * speed

	if surface_change_timer <= 0.0:
		if $rayDown.is_colliding():
			var hit_normal = $rayDown.get_collision_normal().normalized()
			if is_valid_surface_transition(hit_normal):
				surface_normal = hit_normal
				update_rays()
				snap_to_surface()
				surface_change_timer = SURFACE_CHANGE_COOLDOWN
		elif $rayCornerPeek.is_colliding():
			var peek_normal = $rayCornerPeek.get_collision_normal().normalized()
			if is_valid_surface_transition(peek_normal):
				surface_normal = peek_normal
				update_rays()
				snap_to_surface()
				surface_change_timer = SURFACE_CHANGE_COOLDOWN
		elif $rayForward.is_colliding():
			var hit_normal = $rayForward.get_collision_normal().normalized()
			if is_valid_surface_transition(hit_normal):
				surface_normal = hit_normal
				update_rays()
				snap_to_surface()
				surface_change_timer = SURFACE_CHANGE_COOLDOWN
		
	if not $rayDown.is_colliding() and not $rayForward.is_colliding() and not $rayCornerPeek.is_colliding():
		velocity += Vector2.DOWN * 30 * delta  # gravity-ish fall
		
	move_and_slide()
	rotation = velocity.angle()

func snap_to_surface():
	# Nudge the enemy slightly toward the surface so it's not stuck in geometry
	global_position += surface_normal * 2


func is_valid_surface_transition(new_normal: Vector2) -> bool:
	# Don’t allow a 180 flip
	if new_normal.is_equal_approx(-surface_normal):
		return false
	# Only allow if it’s at least 45° different
	var dot = surface_normal.dot(new_normal)
	return dot < 0.7  # dot of 0.7 ≈ ~45°

func update_rays():
	$rayDown.target_position = surface_normal * 16

	var tangent = Vector2(-surface_normal.y, surface_normal.x).normalized()
	$rayForward.target_position = tangent * 16

	var diagonal = (surface_normal + tangent).normalized()
	$rayCornerPeek.target_position = diagonal * 16

	print("Updated Rays - SurfaceNormal:", surface_normal, " Tangent:", tangent, " Diagonal:", diagonal)



#func _draw():
	#draw_line(Vector2.ZERO, $rayDown.target_position, Color.RED, 2)
	#draw_line(Vector2.ZERO, $rayForward.target_position, Color.GREEN, 2)
	#draw_line(Vector2.ZERO, surface_normal * 24, Color.BLUE, 2)  # Shows the surface normal


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("takeDamage"):
		body.takeDamage(10)
