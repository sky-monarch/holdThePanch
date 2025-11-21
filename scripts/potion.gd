extends Area2D

@export var heal_amount: int = 20

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	anim_sprite.play("Idle")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		collect_potion(body)

func collect_potion(player):
	set_deferred("monitoring", false)
	if player.has_method("heal"):
		player.heal(heal_amount)
	play_collect_animation()

func play_collect_animation():
	anim_sprite.stop()
	var tween = create_tween()
	tween.parallel().tween_property(anim_sprite, "scale", Vector2(1.5, 1.5), 0.3)
	tween.parallel().tween_property(anim_sprite, "modulate:a", 0.0, 0.3)
	tween.tween_callback(queue_free)
