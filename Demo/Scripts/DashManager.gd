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
	print_active_dashers()

func release_dasher(mob3: Node) -> void:
	if mob3 in active_dashers:
		active_dashers.erase(mob3)
		print("🔓 DashManager: Released dasher:", mob3.name, "→ Remaining:", active_dashers.size())
		assign_dash_to_random_mob3() 
		print_active_dashers()
		
func assign_dash_to_random_mob3():
	var candidates = get_tree().get_nodes_in_group("Mob3").filter(func(m):
		return not active_dashers.has(m)
	)

	print("🎯 DashManager: Found", candidates.size(), "eligible Mob3s")

	if candidates.size() > 0:
		var chosen = candidates[randi() % candidates.size()]
		active_dashers.append(chosen)
		chosen.dash_permission_granted = true
		print("⚡ DashManager: Reassigned dash to", chosen.name)

	if candidates.size() > 0:
		var chosen = candidates[randi() % candidates.size()]
		active_dashers.append(chosen)
		chosen.dash_permission_granted = true
		print("🎯 DashManager: Reassigned dash to", chosen.name)

	if candidates.size() > 0:
		var chosen = candidates[randi() % candidates.size()]
		active_dashers.append(chosen)
		chosen.dash_permission_granted = true
		print("🎯 DashManager: Reassigned dash to", chosen.name)
		
func print_active_dashers():
	print("👑 Current Dashers:", active_dashers.map(func(m): return m.name))
