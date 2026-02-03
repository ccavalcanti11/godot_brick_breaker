# Adjustable Game Parameters

This document lists all configurable parameters in the Brick Breaker game. These parameters can be adjusted in the Godot editor to fine-tune gameplay feel, difficulty, and visual effects.

---

## Table of Contents
- [Player / Paddle Parameters](#player--paddle-parameters)
- [Ball Parameters](#ball-parameters)
- [Brick Parameters](#brick-parameters)
- [Game Manager Parameters](#game-manager-parameters)
- [Camera & Effects Parameters](#camera--effects-parameters)

---

## Player / Paddle Parameters
**Script:** `scripts/player.gd`  
**Node:** Player (CharacterBody2D)

### Movement Settings

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `max_speed` | float | 400.0 | Maximum horizontal movement speed of the paddle |
| `acceleration` | float | 2000.0 | How quickly the paddle speeds up when input is pressed |
| `deceleration` | float | 1800.0 | How quickly the paddle slows down when input is released |
| `friction` | float | 800.0 | Additional slowdown applied when there's no input for natural feel |

### Visual Feel Settings

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `tilt_amount` | float | 15.0 | Maximum tilt angle (in degrees) when the paddle is moving |
| `tilt_speed` | float | 8.0 | How quickly the paddle rotates to the target tilt angle |
| `float_amplitude` | float | 3.0 | Height of the subtle floating/hovering motion in pixels |
| `float_frequency` | float | 2.0 | Speed of the floating sine wave animation |

### Weapon Hit Settings

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `weapon_forward_offset` | float | 20.0 | Distance above the player where the weapon hitbox is positioned |
| `weapon_width` | float | 20.0 | Width of the weapon swing hitbox |
| `weapon_thickness` | float | 8.0 | Thickness (height) of the weapon hitbox |
| `hit_duration` | float | 0.2 | How long (in seconds) the weapon hitbox stays active after activation |
| `hit_cooldown` | float | 0.5 | Cooldown time (in seconds) before the weapon can be used again |
| `weapon_hit_boost` | float | 1.5 | Velocity multiplier applied to the ball when hit by the weapon |

### Impact Feel Settings

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `hitstop_duration` | float | 0.08 | Duration of the freeze-frame effect on weapon impact (seconds) |
| `impact_scale_amount` | float | 1.15 | Scale multiplier for the paddle when weapon hits (1.0 = no change) |
| `impact_scale_duration` | float | 0.12 | Duration of the impact scale animation (seconds) |
| `shake_intensity` | float | 8.0 | Camera shake intensity when weapon hits the ball (in pixels) |

**Tips:**
- Increase `weapon_hit_boost` for more aggressive gameplay
- Increase `hitstop_duration` for a heavier, more deliberate impact feel
- Increase `shake_intensity` for more dramatic visual feedback
- Adjust `max_speed` to control difficulty (faster = harder to control)

---

## Ball Parameters
**Script:** `scripts/ball.gd`  
**Node:** Ball (RigidBody2D)

### Speed Settings

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `speed` | int | 400 | Initial speed of the ball in pixels per second |
| `min_vertical_speed` | int | 100 | Minimum vertical velocity to prevent purely horizontal bouncing |
| `speed_increment` | int | 30 | Amount speed increases each interval |
| `max_speed` | int | 800 | Maximum speed the ball can reach |
| `speed_increase_interval` | float | 5.0 | Time (in seconds) between automatic speed increases |

### Impact Feel Settings

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `impact_scale_amount` | float | 1.25 | Scale multiplier when hit by weapon (creates squash/stretch effect) |
| `impact_scale_duration` | float | 0.15 | Duration of the impact scale animation (seconds) |

**Tips:**
- Lower `speed` and `max_speed` for easier gameplay
- Increase `speed_increase_interval` to reduce difficulty scaling
- Adjust `min_vertical_speed` if the ball gets stuck bouncing horizontally
- Higher `impact_scale_amount` makes weapon hits more visually satisfying

---

## Brick Parameters
**Script:** `scripts/brick.gd`  
**Node:** Brick (StaticBody2D)

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `health` | int | 1 | Number of hits required to destroy the brick |

**Tips:**
- Set `health` to higher values for tougher bricks
- Different brick types can have different health values
- Purple bricks may have different default values

---

## Game Manager Parameters
**Script:** `scripts/game_manager.gd`  
**Autoload:** Global singleton

### Initial Values

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `current_score` | int | 0 | Starting score value |
| `current_lives` | int | 5 | Number of lives the player starts with |
| `current_level` | int | 1 | Starting level number |

**Tips:**
- Adjust `current_lives` to change game difficulty
- These are initial values; modify them in the script for different starting conditions

---

## Camera & Effects Parameters
**Script:** `scripts/game.gd`  
**Node:** Game scene

### Camera Shake Settings

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `shake_intensity` | float | 0.0 (runtime) | Current shake intensity (controlled by weapon hits) |
| `shake_decay` | float | 5.0 | How quickly the camera shake effect fades out |

**Notes:**
- Camera shake is triggered by weapon hits through signals
- The shake intensity is passed from the player script via the `weapon_hit` signal
- Adjust `shake_decay` in the code if you want longer/shorter shake effects

---

## Physics Material Settings
**Location:** Ball script `_ready()` function

The ball uses a custom physics material for perfect bouncing:

```gdscript
var physics_mat = PhysicsMaterial.new()
physics_mat.bounce = 1.0  # Perfect bounce (no energy loss)
physics_mat.friction = 0.0  # No friction
```

**Tips:**
- `bounce = 1.0` creates classic brick breaker physics
- Lower bounce values (0.8-0.95) create more realistic but potentially frustrating gameplay
- Non-zero friction values can add unpredictable movement

---

## Recommended Parameter Sets

### Easy Mode
```
Player:
  max_speed: 350.0
  
Ball:
  speed: 350
  max_speed: 650
  speed_increase_interval: 7.0

Game Manager:
  current_lives: 7
```

### Hard Mode
```
Player:
  max_speed: 450.0
  weapon_hit_boost: 1.3
  
Ball:
  speed: 450
  max_speed: 900
  speed_increase_interval: 3.0

Game Manager:
  current_lives: 3
```

### Impact Feel - Subtle
```
Player:
  hitstop_duration: 0.05
  impact_scale_amount: 1.08
  shake_intensity: 4.0
  
Ball:
  impact_scale_amount: 1.15
```

### Impact Feel - Extreme
```
Player:
  hitstop_duration: 0.12
  impact_scale_amount: 1.25
  shake_intensity: 15.0
  
Ball:
  impact_scale_amount: 1.4
```

---

## How to Adjust Parameters

1. **In Godot Editor:**
   - Select the node (e.g., Player, Ball)
   - Look in the Inspector panel
   - Find the exported parameters under the script properties
   - Adjust values and test in real-time

2. **In Code:**
   - Open the respective `.gd` script file
   - Find the `@export` variable declarations
   - Modify the default values
   - Save and reload the scene

3. **At Runtime (Advanced):**
   - Access parameters via code: `$Player.max_speed = 500.0`
   - Useful for difficulty scaling or power-ups

---

## Testing Tips

- **Movement Feel:** Adjust `max_speed`, `acceleration`, and `deceleration` together for cohesive feel
- **Visual Polish:** Fine-tune `tilt_amount`, `float_amplitude`, and scale amounts for satisfying animations
- **Impact Weight:** Balance `hitstop_duration`, `shake_intensity`, and scale effects for desired punch
- **Difficulty Curve:** Test the relationship between ball `speed_increase_interval` and player `max_speed`
- **Weapon Feel:** Experiment with `weapon_hit_boost` vs. `hitstop_duration` for different combat styles

---

**Last Updated:** February 3, 2026  
**Game Version:** MVP - Brick Breaker with Weapon Mechanic
