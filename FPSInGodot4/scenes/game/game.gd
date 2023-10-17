extends Node3D

signal score_changed(value)

const GAME_OVER_TIME = 10.0

@onready var player: Player = $Player
@onready var hud: Control = $HUD
@onready var enemy_spawner: Node3D = $Enemy/EnemySpawner
@onready var game_over_screen: Control = $GameOver
@onready var game_over_text: Label = $GameOver/Text
@onready var bg: ColorRect = $GameOver/BG

var score : int:
	set(value):
		score = value
		score_changed.emit(score)

func _ready() -> void:
	player.guns.gun_changed.connect(hud.update_gun)
	player.health_changed.connect(hud.update_health)
	player.death.connect(game_over)
	score_changed.connect(hud.update_score)
	enemy_spawner.player = player
	enemy_spawner.enemy_spawned.connect(enemy_spawned)
	game_over_screen.visible = false

func enemy_spawned(enemy: Enemy) -> void:
	enemy.destroyed.connect(func(value): score += value)

func game_over() -> void:
	game_over_screen.visible = true
	hud.visible = false
	game_over_text.text += str(score)
	var tween = get_tree().create_tween()
	tween.tween_property(bg, "color:a", 1.0, GAME_OVER_TIME)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	get_tree().paused = true
	await get_tree().create_timer(GAME_OVER_TIME).timeout
	get_tree().paused = false
	get_tree().reload_current_scene()
