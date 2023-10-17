# First-Person Shooter in Godot 4.0

<p align="center">
  <a href="https://www.youtube.com/watch?v=h8BmeRRGWxI">
    <img alt="YouTube video thumbnail" src="http://img.youtube.com/vi/h8BmeRRGWxI/0.jpg"><br>
    Watch on YouTube
  </a>
</p>

This tutorial covers the structure of a simple first-person shooter game in Godot 4.0. This video isn't a step-by-step tutorial, but rather a showcase of a complete project.
Note that the project has not been updated for Godot 4.1+.

# Game Features
- A full player controller with movement, jumping, stair-climbing and weapon switching.
- Controller support.
- Melee, projectile and raycast weapons.
- One enemy unit with pathfinding AI.
- Weapon and health pickups.
- A simple symmetrical arena-style level.
- PBR assets for weapons, level surfaces and enemies.

Published on 2023-10-17.

# Relevant files
[player.gd](./scenes/entity/player/player.gd)  
[player_guns.gd](./scenes/entity/player/player_guns.gd)  
[gun.gd](./scenes/entity/player/gun/gun.gd)  
[enemy.gd](./scenes/entity/enemy/enemy.gd)  
[capsule_enemy.gd](./scenes/entity/enemy/capsule/capsule_enemy.gd)  
[enemy_bullet.gd](./scenes/entity/enemy/bullet/enemy_bullet.gd)  
[game.gd](./scenes/game/game.gd)  
[enemy_spawner.gd](./scenes/entity/enemy_spawner/enemy_spawner.gd)  
[pickup_spawner.gd](./scenes/entity/pickup_spawner/pickup_spawner.gd)  
[pickup.gd](./scenes/entity/pickup/pickup.gd)  
[hud.gd](./scenes/game/hud/hud.gd)  

# License and Assets
This project is licensed CC BY 4.0 https://creativecommons.org/licenses/by/4.0/
All assets are custom made for this project with the following exception:
Heebo Medium font from Google Fonts: https://fonts.google.com/specimen/Heebo
