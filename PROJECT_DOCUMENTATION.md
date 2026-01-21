# Godot Brick Breaker - Project Documentation

## Project Overview
This is a classic brick breaker game (Breakout-style) built in Godot Engine. The player controls a robot character to bounce a ball and destroy bricks across multiple levels. The game includes features like lives system, scoring, level progression, pause functionality, and a special player skill attack.

---

## Project Structure

```
brickbreaker/
├── assets/
│   ├── sounds/          # Sound effects (brick breaks, BGM)
│   └── sprites/         # Game sprites (ball, bricks, player, robot animations)
├── scenes/              # Godot scene files (.tscn)
│   ├── levels/          # Individual level scenes
│   └── [UI and gameplay scenes]
└── scripts/             # GDScript files (.gd)
```

---

## Core Systems

### 1. GameManager (Singleton/Autoload)
**File:** [scripts/game_manager.gd](brickbreaker/scripts/game_manager.gd)

**Purpose:** Central game state manager that persists across scenes.

**Key Responsibilities:**
- Tracks player score, lives, and current level
- Manages game state persistence
- Handles scene transitions
- Emits signals for UI updates

**Properties:**
- `current_score`: Player's score (starts at 0)
- `current_lives`: Player's remaining lives (starts at 3)
- `current_level`: Current level number (starts at 1)

**Signals:**
- `score_updated(new_score)`: Emitted when score changes
- `lives_updated(new_lives)`: Emitted when lives change

**Key Methods:**
- `reset_game()`: Resets score, lives, and level to initial values
- `lose_life()`: Decrements lives and returns to main menu if game over
- `add_score(amount)`: Adds points to score
- `load_level(level_num)`: Loads a specific level by changing to Game scene

---

### 2. Ball Physics and Movement
**File:** [scripts/ball.gd](brickbreaker/scripts/ball.gd)

**Type:** RigidBody2D

**Purpose:** Handles ball physics, collision detection, and dynamic difficulty.

**Features:**
- **Progressive Speed System**: Ball speed increases every 5 seconds (configurable)
  - Starts at 400 speed
  - Increases by 30 per interval
  - Max speed caps at 800
  
- **Smart Player Collision**:
  - Factors in player momentum (50% of player velocity affects ball)
  - Angular control based on hit position (hitting edges changes trajectory more)
  - Uses player's width to calculate hit offset
  
- **Brick Collision Detection**:
  - Detects collisions with "Brick", "PurpleBrick", or any object with "destroyed" signal
  - Calls `hit()` method on bricks
  
- **Horizontal Lock Prevention**:
  - Ensures minimum vertical velocity (100 units) to prevent purely horizontal bouncing
  - Maintains ball direction while enforcing minimum speed

**Exports:**
- `speed`: Current ball speed (400)
- `min_vertical_speed`: Minimum Y velocity (100)
- `speed_increment`: Speed increase per tick (30)
- `max_speed`: Maximum speed cap (800)
- `speed_increase_interval`: Time between speed increases (5.0s)

**Key Methods:**
- `launch(dir)`: Launches the ball in specified direction with current speed
- `increase_speed(delta)`: Gradually increases speed over time

---

### 3. Player Control
**File:** [scripts/player.gd](brickbreaker/scripts/player.gd)

**Type:** CharacterBody2D

**Purpose:** Player-controlled robot character with horizontal movement and special skill attack.

**Movement System:**
- Keyboard-based left/right movement (400 speed)
- Uses Godot's `move_and_slide()` for smooth physics

**Special Skill Attack:**
A horizontal hitbox appears above the player character for a short duration when activated.

**Skill Parameters:**
- `skill_forward_offset`: Distance above player (25.0)
- `skill_thickness`: Hitbox height (6.0)
- `skill_duration`: How long skill is active (0.18s)
- `skill_cooldown`: Time before next use (0.65s)

**Skill System:**
- Activated with "player_skill" input action
- Creates a capsule-shaped hitbox spanning player width
- Positioned above player, rotated 90 degrees to be horizontal
- Triggers attack animation on AnimatedSprite2D
- Respects cooldown and active windows

**Key Methods:**
- `get_width()`: Returns player width for ball collision calculations
- `setup_skill_hitbox()`: Configures the skill attack hitbox geometry
- `try_activate_skill()`: Handles skill activation with cooldown check

---

### 4. Brick System
**File:** [scripts/brick.gd](brickbreaker/scripts/brick.gd)

**Type:** StaticBody2D

**Purpose:** Destructible bricks that can take multiple hits.

**Features:**
- Health-based destruction (configurable via export)
- Emits "destroyed" signal when health reaches 0
- Self-destructs with `queue_free()`

**Exports:**
- `health`: Number of hits to destroy (default: 1)

**Signals:**
- `destroyed`: Emitted when brick is destroyed

**Key Methods:**
- `hit()`: Reduces health by 1, emits signal and removes brick if health ≤ 0

**Note:** There appear to be multiple brick types (Brick, PurpleBrick) likely with different health values or behaviors.

---

### 5. Death Zone
**File:** [scripts/death_zone.gd](brickbreaker/scripts/death_zone.gd)

**Type:** Area2D

**Purpose:** Detects when ball falls below the player character.

**Features:**
- Detects bodies entering the zone
- Checks if body is in "ball" group
- Emits signal and destroys the ball

**Signals:**
- `ball_lost`: Emitted when a ball enters the death zone

**Key Methods:**
- `_on_body_entered(body)`: Handles ball detection and destruction

---

### 6. Game Scene Controller
**File:** [scripts/game.gd](brickbreaker/scripts/game.gd)

**Type:** Node2D

**Purpose:** Main gameplay scene that orchestrates all game elements.

**Key Components:**
- Player reference
- Ball container (holds ball instances)
- Level container (holds loaded level scenes)
- UI overlay

**Game Loop:**
1. **Initialization** (`_ready`):
   - Loads current level from GameManager
   - Creates initial ball
   - Connects GameManager signals to UI
   - Updates UI with current stats

2. **Ball on Player State**:
   - Ball sticks to player position (60 units above)
   - Launches when "launch_ball" action pressed
   - Launches upward initially

3. **Level Loading** (`load_level`):
   - Clears previous level
   - Loads level scene from `res://scenes/levels/Level{N}.tscn`
   - Finds "Bricks" node and connects all brick signals
   - Connects DeathZone signal for ball loss detection

4. **Pause System**:
   - Activates with "pause" input action
   - Pauses game tree
   - Instantiates pause menu overlay

**Signal Handlers:**
- `_on_brick_destroyed()`: Awards 100 points, updates UI, counts remaining bricks
- `_on_ball_lost()`: Triggers life loss, resets ball if lives remain

**Key Methods:**
- `connect_bricks(bricks)`: Recursively finds and connects all brick destroyed signals
- `count_remaining_bricks()`: Counts bricks in level (returns count - 1)
- `reset_ball()`: Destroys old ball, creates new one, returns to player

**Note:** Level completion logic is present but commented out (lines checking for 0 remaining bricks).

---

### 7. UI System
**File:** [scripts/ui.gd](brickbreaker/scripts/ui.gd)

**Type:** CanvasLayer

**Purpose:** In-game heads-up display (HUD).

**Elements:**
- `ScoreLabel`: Displays current score
- `LivesLabel`: Displays remaining lives

**Key Methods:**
- `update_score(score)`: Updates score display (format: "Score: X")
- `update_lives(lives)`: Updates lives display (format: "Lives: X")

---

### 8. Main Menu
**File:** [scripts/main_menu.gd](brickbreaker/scripts/main_menu.gd)

**Type:** Control

**Purpose:** Entry point for the game with navigation options.

**Buttons:**
- **Start**: Resets game state and loads Level 1
- **Level Select**: Opens level selection screen
- **Quit**: Exits the game

**Key Methods:**
- `_on_start_button_pressed()`: Starts new game
- `_on_level_select_button_pressed()`: Opens level select
- `_on_quit_button_pressed()`: Quits application

---

### 9. Level Select Menu
**File:** [scripts/level_select.gd](brickbreaker/scripts/level_select.gd)

**Type:** Control

**Purpose:** Allows players to choose specific levels.

**Features:**
- GridContainer of level buttons
- Dynamically connects buttons based on their text (extracts level number)
- Resets game state when level is selected

**Key Methods:**
- `_on_level_button_pressed(level_number)`: Loads selected level
- `_on_back_button_pressed()`: Returns to main menu

---

### 10. Pause Menu
**File:** [scripts/pause_menu.gd](brickbreaker/scripts/pause_menu.gd)

**Type:** ColorRect (overlay)

**Purpose:** In-game pause screen.

**Buttons:**
- **Resume**: Unpauses game and removes menu
- **Main Menu**: Returns to main menu (keeps game paused)

**Key Methods:**
- `_on_resume_button_pressed()`: Continues game
- `_on_main_menu_button_pressed()`: Returns to main menu

---

## Game Flow

### Start Flow
```
Main Menu → Start Button → GameManager.reset_game() → GameManager.load_level(1) → Game Scene
```

### Gameplay Loop
```
1. Ball spawns on player
2. Player moves character (left/right)
3. Player launches ball (spacebar/action)
4. Ball bounces off walls, player, and bricks
5. Bricks destroyed → +100 points
6. Ball falls → -1 life → reset ball
7. All bricks destroyed → next level (currently disabled)
8. Lives = 0 → Main Menu
```

### Pause Flow
```
Game → Pause Action → Game.paused = true → Pause Menu spawns → Resume/Quit
```

---

## Key Features Implemented

### ✅ Core Mechanics
- Physics-based ball movement with collision detection
- Player control with momentum transfer to ball
- Angular ball control based on player hit position
- Health-based brick destruction
- Lives system (3 lives)
- Score tracking (+100 per brick)

### ✅ Progression
- Multiple levels (Level 1 exists, system supports more)
- Dynamic ball speed increase (progressive difficulty)
- Level loading system

### ✅ UI/UX
- Main menu with start, level select, quit
- In-game HUD (score, lives)
- Pause menu with resume and quit
- Level selection screen

### ✅ Advanced Features
- Player special skill attack (timed hitbox above player)
- Ball horizontal lock prevention (minimum vertical speed)
- Persistent game state via GameManager singleton

---

## Input Actions Required

Your project.godot should define these input actions:
- `move_left`: Move player left
- `move_right`: Move player right
- `launch_ball`: Launch ball from player
- `pause`: Pause the game
- `player_skill`: Activate player special skill

---

## Known Issues / TODOs

1. **Level Completion**: Code to load next level is commented out in [game.gd](brickbreaker/scripts/game.gd#L92-L94)
2. **Brick Counting**: `count_remaining_bricks()` returns `count - 1`, might cause off-by-one errors
3. **Skill Functionality**: Player skill hitbox is set up but collision response isn't implemented
4. **Sound Integration**: Sound files exist but no code references them yet
5. **Multiple Brick Types**: PurpleBrick scene exists but behavior differences unclear

---

## Tips for Development

### Adding New Levels
1. Create new scene in `scenes/levels/`
2. Include "Bricks" node containing all brick instances
3. Include "LevelBoundaries" with "DeathZone" child
4. Save as `Level{N}.tscn`
5. Add button to LevelSelect scene

### Adding Brick Varieties
- Extend brick.gd or create new script
- Set different health values via export variable
- Use different sprites/colors
- Consider adding special behaviors (moving, regenerating, etc.)

### Implementing Power-ups
- Create Area2D scenes for power-up items
- Spawn from destroyed bricks
- Detect player collision
- Apply effects (multi-ball, bigger player, slower speed, etc.)

### Adding Sound
- Load audio files as AudioStreamPlayer nodes
- Play on events: brick destruction, ball collision, life loss, level completion
- Add background music to Game scene

---

## Architecture Highlights

### Signal-Based Communication
The project uses Godot's signal system effectively:
- GameManager emits signals for state changes
- UI listens to GameManager for updates
- Bricks emit destruction signals
- DeathZone emits ball loss signals

This keeps components decoupled and maintainable.

### Scene Instancing
- Ball is instantiated dynamically (not always in scene)
- Levels are loaded as separate scene files
- Pause menu instantiated on-demand

### Singleton Pattern
GameManager acts as an autoload singleton, providing global access to game state across all scenes.

---

## Next Steps Suggestions

1. **Enable Level Progression**: Uncomment and fix level completion code
2. **Fix Brick Counter**: Debug the `-1` in `count_remaining_bricks()`
3. **Implement Skill Effect**: Make player skill actually affect ball/bricks
4. **Add Sound Effects**: Integrate the existing sound files
5. **Create More Levels**: Design levels 2-5 with increasing difficulty
6. **Add Visual Feedback**: Particle effects for brick destruction
7. **High Score System**: Save best score to disk
8. **Mobile Controls**: Add touch/mouse controls for player

---

*Documentation generated on January 12, 2026*
