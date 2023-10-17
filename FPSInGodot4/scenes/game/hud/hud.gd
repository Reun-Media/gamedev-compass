extends Control

var current_gun: Gun

func update_gun_info(ammo: int) -> void:
	if current_gun:
		$GunInfo/Name.text = current_gun.display_name
		if current_gun.gun_icon:
			$GunInfo/Icon.texture = current_gun.gun_icon
		else:
			$GunInfo/Icon.texture = null
	$GunInfo/AmmoBox/Ammo.text = str(ammo)

func update_gun(value: Gun) -> void:
	if current_gun and current_gun.ammo_changed.is_connected(update_gun_info):
		current_gun.ammo_changed.disconnect(update_gun_info)
	current_gun = value
	$GunInfo/AmmoBox.visible = current_gun.use_ammo
	current_gun.ammo_changed.connect(update_gun_info)
	update_gun_info(current_gun.ammo)

func update_health(value: float) -> void:
	$Health/HealthBar.value = value

func update_score(value: int) -> void:
	$Score/Amount.text = str(value)
