extends Area2D

@export var player_obj: String = "Player"

var _victory_shown := false


func _show_victory_and_transition():
	var player = get_tree().current_scene.find_child(player_obj, true, false)
	if player:
		if player.has_method("set_movement_locked"):
			player.set_movement_locked(true)

	var tomori_sprite: AnimatedSprite2D = get_parent().get_node_or_null("AnimatedSprite2D")
	if tomori_sprite:
		tomori_sprite.play("winning")

	var ui_layer := CanvasLayer.new()
	ui_layer.layer = 100

	var label := Label.new()
	label.text = "You saved Tomori!"
	label.add_theme_font_size_override("font_size", 48)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	label.anchor_right = 1.0
	label.position += Vector2(-25, 20)
	label.modulate = Color(0.2, 1.0, 0.3)

	ui_layer.add_child(label)
	get_tree().current_scene.add_child(ui_layer)


func _on_body_entered(body: CharacterBody2D) -> void:
	if body.name == player_obj and not _victory_shown:
		_victory_shown = true
		_show_victory_and_transition()
