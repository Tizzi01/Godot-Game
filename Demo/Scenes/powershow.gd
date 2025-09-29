extends Area2D

signal black_hole_spawned  # 📢 Signal for camera shake

@onready var anim = $AnimationPlayer
@onready var animation_player_2: AnimationPlayer = $Sprite2D2/AnimationPlayer2
@onready var pull_zone = $PullZone
@onready var idle: AudioStreamPlayer2D = $Idle
@onready var ka: AudioStreamPlayer = $ka
@onready var pf: AudioStreamPlayer = $PF
@onready var timer_10s: Timer = $J
@onready var cooldown_timer: Timer = $CooldownTimer
@onready var cooldown_bar: ProgressBar = get_node("/root/Game/CanvasLayer3/BHCD")

var is_on_cooldown := false
var min_audio_distance: float = 0.0
var max_audio_distance: float = 888.0

var affected_mobs: Array = []
var affected_player: CharacterBody2D = null

func _ready():
	idle.play()
	animation_player_2.play("Black")
