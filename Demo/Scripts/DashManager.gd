extends Node

var max_dashers := 3
var active_dashers: Array = []

func can_dash() -> bool:
	print("🔍 DashManager: Checking if dash is allowed. Active:", active_dashers.size())
	return active_dashers.size() < max_dashers

func register_dasher(mob3: Node) -> bool:
	if can_dash():
		active_dashers.append(mob3)
		print("✅ DashManager: Registered dasher:", mob3.name, "→ Total:", active_dashers.size())
		return true
	print("❌ DashManager: DENIED dash for", mob3.name, "→ Total:", active_dashers.size())
	return false

func release_dasher(mob3: Node) -> void:
	if mob3 in active_dashers:
		active_dashers.erase(mob3)
		print("🔓 DashManager: Released dasher:", mob3.name, "→ Remaining:", active_dashers.size()) 
