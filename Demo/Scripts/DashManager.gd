extends Node

var max_dashers := 3
var active_dashers := {}

func can_dash(mob3: Node) -> bool:
	if not mob3:
		print("❗ [can_dash] ERROR: Provided node is null!")
		return false

	var id := mob3.get_instance_id()
	if active_dashers.has(id):
		print("🔁 [can_dash] Already registered — continuing dash cycle:", mob3.name)
		return true 

	var current_count := active_dashers.size()
	var is_allowed := current_count < max_dashers
	print("🧪 [can_dash] Dash allowed?", is_allowed, "| Active:", current_count, "/", max_dashers)
	return is_allowed

func register_dasher(mob3: Node) -> bool:
	if not mob3:
		print("❗ [register_dasher] ERROR: Provided node is null!")
		return false

	var id := mob3.get_instance_id()
	if active_dashers.has(id):
		print("🔁 [register_dasher] Already registered:", mob3.name)
		return true

	if can_dash(mob3):
		active_dashers[id] = mob3
		print("✅ [register_dasher] Dasher registered:", mob3.name, "| ID:", id)
		return true
	else:
		print("❌ [register_dasher] Dash denied for", mob3.name)
		return false

func release_dasher(mob3: Node) -> void:
	if not mob3:
		print("❗ [release_dasher] ERROR: Provided node is null!")
		return

	var id := mob3.get_instance_id()
	if active_dashers.has(id):
		active_dashers.erase(id)
		print("🔓 [release_dasher] Dasher released:", mob3.name, "| ID:", id)

		# Optional: assign a new dasher
		var mobs := get_tree().get_nodes_in_group("Mob3")
		mobs.shuffle()
		for mob in mobs:
			if not active_dashers.has(mob.get_instance_id()):
				if mob.has_method("try_become_dasher"):
					print("🎯 [release_dasher] Assigning new dasher:", mob.name)
					mob.try_become_dasher()
					break
	else:
		print("❌ [release_dasher] Dasher not found:", mob3.name, "| ID:", id)
