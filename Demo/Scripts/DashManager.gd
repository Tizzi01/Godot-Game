extends Node

var max_dashers := 1
var active_dashers := {}

func can_dash() -> bool:
	print("🧪 [can_dash] Starting dash eligibility check...")
	var current_count := active_dashers.size()
	print("📋 [can_dash] Current active dashers:", current_count)
	print("📋 [can_dash] Max allowed dashers:", max_dashers)
	var is_allowed := current_count < max_dashers
	print("🔍 [can_dash] Dash allowed?", is_allowed)
	return is_allowed

func register_dasher(mob3: Node) -> bool:
	print("🚀 [register_dasher] Attempting to register:", mob3.name)
	if not mob3:
		print("❗ [register_dasher] ERROR: Provided node is null!")
		return false

	if active_dashers.has(mob3.get_instance_id()):
		print("⚠️ [register_dasher] Already registered:", mob3.name)
		return false

	if can_dash():
		var id := mob3.get_instance_id()
		active_dashers[id] = mob3
		print("✅ [register_dasher] Dasher registered:", mob3.name, "| ID:", id)
		print("📈 [register_dasher] Total active dashers:", active_dashers.size())
		return true
	else:
		print("❌ [register_dasher] Dash denied for", mob3.name, "| Active:", active_dashers.size())
		return false

func release_dasher(mob3: Node) -> void:
	print("🔄 [release_dasher] Attempting to release:", mob3.name)
	if not mob3:
		print("❗ [release_dasher] ERROR: Provided node is null!")
		return

	var id := mob3.get_instance_id()
	if active_dashers.has(id):
		active_dashers.erase(id)
		print("🔓 [release_dasher] Dasher released:", mob3.name, "| ID:", id)
		print("📉 [release_dasher] Remaining dashers:", active_dashers.size())
	else:
		print("❌ [release_dasher] Dasher not found:", mob3.name, "| ID:", id)
