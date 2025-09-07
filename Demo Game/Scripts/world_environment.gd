# Attach this to your WorldEnvironment node (once in your scene)
extends WorldEnvironment

func _ready():
	var env = Environment.new()
	self.environment = env

	env.glow_enabled = true
	env.glow_strength = 1.2
	env.glow_hdr_threshold = 1.0  # Only very bright objects glow
	env.glow_intensity = 1.0
