extends CharacterBody2D

@export var gravity: float = 700.0
@export var walk_speed: float = 200.0
@export var sprint_speed: float = 320.0
@export var jump_speed: float = -360.0
@export var dodge_speed: float = 500.0
@export var dodge_duration: float = 0.18
@export var dodge_cooldown: float = 0.35
@export var dodge_double_tap_window: float = 0.5  # under this interval == dodge

var jumps_used: int = 0  # keeping info about jumping
var facing_right: bool = true
var is_crouching: bool = false
var is_sprinting: bool = false

# Dodge mechanism
var is_dodging: bool = false
var dodge_direction: float = 1.0
var dodge_time_left: float = 0.0
var dodge_cooldown_left: float = 0.0
var last_shift_tap_time: float = -100.0
var dodge_requested: bool = false

var _movement_locked := false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	animated_sprite.play("idle")


# for shift uses
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_SHIFT:
		var now := Time.get_ticks_msec() / 1000.0
		if now - last_shift_tap_time <= dodge_double_tap_window:
			dodge_requested = true
		last_shift_tap_time = now


func _physics_process(delta: float) -> void:
	if _movement_locked:
		velocity = Vector2.ZERO
		is_dodging = false
		dodge_requested = false
		move_and_slide()
		animated_sprite.play("idle")
		return

	if dodge_cooldown_left > 0.0:
		dodge_cooldown_left -= delta

	if is_on_floor():
		jumps_used = 0

	var input_dir := Input.get_axis("ui_left", "ui_right")
	if input_dir != 0.0:
		facing_right = input_dir > 0.0
		animated_sprite.flip_h = not facing_right

	is_crouching = is_on_floor() and Input.is_action_pressed("ui_down")
	is_sprinting = (
		Input.is_physical_key_pressed(KEY_SHIFT) and not is_crouching and abs(input_dir) > 0.0
	)

	if dodge_requested and _can_start_dodge():
		_start_dodge(input_dir)
	dodge_requested = false

	if is_dodging:
		dodge_time_left -= delta
		velocity.x = dodge_direction * dodge_speed
		velocity.y = 0.0
		if dodge_time_left <= 0.0:
			is_dodging = false
	else:
		velocity.y += gravity * delta

		if Input.is_action_just_pressed("ui_up") and jumps_used < 2:
			velocity.y = jump_speed
			jumps_used += 1

		if is_crouching:
			velocity.x = 0.0
		else:
			var target_speed := sprint_speed if is_sprinting else walk_speed
			velocity.x = input_dir * target_speed

	move_and_slide()
	_update_animation()


func _can_start_dodge() -> bool:
	return not is_dodging and dodge_cooldown_left <= 0.0


func _start_dodge(input_dir: float) -> void:
	is_dodging = true
	dodge_time_left = dodge_duration
	dodge_cooldown_left = dodge_cooldown
	if input_dir != 0.0:
		dodge_direction = input_dir
	else:
		dodge_direction = 1.0 if facing_right else -1.0
	animated_sprite.flip_h = dodge_direction < 0.0


func set_movement_locked(value: bool):
	_movement_locked = value
	if _movement_locked:
		velocity = Vector2.ZERO
		is_dodging = false
		dodge_requested = false


func _update_animation() -> void:
	if is_dodging:
		animated_sprite.play("slide")
		return

	if is_crouching:
		animated_sprite.play("duck")
		return

	if not is_on_floor():
		animated_sprite.play("jump" if velocity.y < 0.0 else "fall")
		return

	if abs(velocity.x) > 6.0:
		animated_sprite.play("walk", 2.0 if is_sprinting else 1.2)
		return

	animated_sprite.play("idle")
