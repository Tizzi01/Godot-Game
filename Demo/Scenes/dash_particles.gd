extends CPUParticles2D

var fade_tween: Tween = null
var original_emission := 50  # Match your particle amount

func fade_out():
	if fade_tween:
		fade_tween.kill()

	if process_material and process_material is ParticleProcessMaterial:
		fade_tween = create_tween()
		fade_tween.tween_property(process_material, "emission_rate", 0.0, 0.5)
		fade_tween.set_trans(Tween.TRANS_LINEAR)
		fade_tween.set_ease(Tween.EASE_OUT)
		fade_tween.tween_callback(Callable(self, "_stop_emitting"))

func _stop_emitting():
	emitting = false
	if process_material and process_material is ParticleProcessMaterial:
		process_material.emission_rate = original_emission
	fade_tween = null
