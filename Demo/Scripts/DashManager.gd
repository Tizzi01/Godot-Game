extends Node

var max_dashers := 1
var active_dashers: Array = []

func can_dash() -> bool:
	print("🧠 DashManager: Initiating dash eligibility check...")
	var current_count := active_dashers.size()
	print("📊 DashManager: Current active dashers:", current_count, " | Max allowed:", max_dashers)
	var result := current_count < max_dashers
	if result:
		print("✅ DashManager: Dash is permitted. Room for more dashers!")
	else:
		print("🚫 DashManager: Dash denied. Too many dashers already!")
	return result

func register_dasher(mob3: Node) -> bool:
	print("📥 DashManager: Attempting to register dasher:", mob3.name)
	if can_dash():
		print("🛠️ DashManager: Adding", mob3.name, "to active dashers list...")
		active_dashers.push_back(mob3)
		print("🎉 DashManager: Success! Dasher", mob3.name, "is now active.")
		print("📈 DashManager: Total active dashers now:", active_dashers.size())
		return true
	else:
		print("😢 DashManager: Could not register", mob3.name, "— dash limit reached.")
		print("📉 DashManager: Active dashers count remains at:", active_dashers.size())
		return false

func release_dasher(mob3: Node) -> void:
	print("📤 DashManager: Request received to release dasher:", mob3.name)
	if active_dashers.has(mob3):
		print("🔍 DashManager: Found", mob3.name, "in active dashers. Proceeding with removal...")
		active_dashers.erase(mob3)
		print("✅ DashManager: Dasher", mob3.name, "successfully released.")
		print("📊 DashManager: Remaining active dashers:", active_dashers.size())
	else:
		print("❓ DashManager: Dasher", mob3.name, "not found in active list. Nothing to release.")
