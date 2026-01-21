# MVP Document - Robot Brick Breaker

## Executive Summary
This document defines the Minimum Viable Product (MVP) for Robot Brick Breaker. The MVP focuses on delivering a playable, fun core experience that demonstrates the unique robot-based mechanics while deferring complex systems like crafting, biomes, and meta progression to future phases.

---

## MVP Goal
**Create a playable single-level brick breaker where the player controls a robot character with a special attack bar that charges through gameplay, demonstrating the core robot identity and skill-based gameplay loop.**

---

## What's Already Implemented ✓

### Core Mechanics (Functional)
- ✓ Ball physics with progressive speed increase
- ✓ Smart player collision with momentum and angular control
- ✓ Player movement (keyboard-based)
- ✓ Brick destruction system
- ✓ Death zone (ball falling off screen)
- ✓ Basic scoring system
- ✓ Lives system
- ✓ Level boundaries
- ✓ Game state management (GameManager singleton)
- ✓ Main menu and level selection
- ✓ Pause menu

### UI Elements (Functional)
- ✓ Score display
- ✓ Lives display
- ✓ Menu navigation
- ✓ Scene transitions

### Special Mechanics (Partial)
- ✓ Player skill attack system (hitbox above player)
- ⚠️ Skill cooldown system implemented but not visually represented

---

## MVP Feature Set

### Phase 1: Core Loop Polish (PRIORITY)
**Goal:** Make the existing game feel good to play

#### 1.1 Robot Visual Identity
- [ ] Replace player sprite with robot sprite (use existing robot-idle-anim assets)
- [ ] Add idle animation to robot player
- [ ] Ensure robot visually responds to movement (animation states)
- [ ] Visual feedback when hitting ball (flash, particle effect, or animation frame)

#### 1.2 Special Bar System
- [ ] Create UI element for special bar (empty to full)
- [ ] Fill bar when player hits the ball (not from brick destruction)
- [ ] Bar fills progressively: each hit adds X% (balance to ~10-15 hits)
- [ ] Visual and audio feedback when bar reaches 100%
- [ ] Connect special bar to existing skill attack system
- [ ] Special attack depletes bar back to 0%
- [ ] Visual effect when special is active (glow, particles, color change)

#### 1.3 Polish Existing Mechanics
- [ ] Add sound effects for:
  - Ball hitting player
  - Ball hitting walls
  - Brick destruction (already have assets)
  - Special attack activation
  - Special attack hitting bricks
- [ ] Add particle effects:
  - Brick destruction
  - Special attack activation
  - Ball trail (optional, subtle)
- [ ] Screen shake on special attack
- [ ] Camera juice (slight zoom/shake on satisfying moments)

#### 1.4 Tutorial/First-Time Experience
- [ ] Simple text overlay explaining controls:
  - Move: Arrow Keys / A-D
  - Special Attack: [Key]
  - Pause: ESC
- [ ] Visual indicator showing how special bar fills (first time only)
- [ ] Clear "Press to Launch Ball" prompt

### Phase 2: Level Design & Progression
**Goal:** Create variety and replayability

#### 2.1 Level Content
- [ ] Design 3-5 distinct levels with increasing difficulty
- [ ] Vary brick layouts (patterns that are fun to break)
- [ ] Introduce purple bricks (multi-hit) strategically
- [ ] Balance brick count per level (completable in 2-5 minutes)

#### 2.2 Difficulty Curve
- [ ] Level 1: Introduction (easy layout, fewer bricks)
- [ ] Level 2-3: Ramp up (denser patterns, more purple bricks)
- [ ] Level 4-5: Challenge (complex patterns, timing required)

#### 2.3 Level Completion
- [ ] Victory screen when all bricks destroyed
- [ ] Display level completion stats (time, score, special uses)
- [ ] "Next Level" button
- [ ] Level select unlocks progressively

### Phase 3: Game Feel & Balance
**Goal:** Fine-tune for fun

#### 3.1 Balance Pass
- [ ] Tune special bar fill rate (too fast = boring, too slow = frustrating)
- [ ] Adjust ball speed progression (currently 5s intervals, is this good?)
- [ ] Review player speed (400 - feels good?)
- [ ] Balance special attack power/duration/cooldown
- [ ] Test lives count (3 is standard, but is it right for this game?)

#### 3.2 Feedback & Juice
- [ ] Satisfying brick break animations
- [ ] Combo system? (breaking bricks in quick succession)
- [ ] Score pop-ups when breaking bricks
- [ ] Better visual distinction between normal and special attacks

---

## Explicitly OUT OF SCOPE for MVP

### Deferred to Post-MVP
- ❌ Material collection and crafting system
- ❌ Multiple weapons/cores (stick to one "default" core)
- ❌ Biome system
- ❌ Boss fights
- ❌ Map/world navigation
- ❌ Equipment durability
- ❌ Upgrade/skill trees
- ❌ Meta progression
- ❌ Parry system (advanced timing mechanic)
- ❌ Slow motion zones
- ❌ Launch power-up at stage start
- ❌ Multiple special attacks (unique per core)
- ❌ Session duration options

### Reason for Deferment
These systems are complex and interdependent. Building them before validating the core gameplay loop risks wasting development time on features that may not work well together. The MVP proves:
1. Robot identity is compelling
2. Special bar mechanic is satisfying
3. Skill-based player gameplay is fun

Once the MVP is validated, these systems can be designed around a proven foundation.

---

## Success Criteria

### MVP is successful if:
1. **Core loop is fun:** Players want to replay levels to improve scores/time
2. **Robot identity is clear:** Player feels like they're controlling a robot, not a generic character
3. **Special attack is satisfying:** Players actively want to charge and use the special
4. **Technical foundation is solid:** No major bugs, smooth performance
5. **Scope is proven:** 3-5 levels demonstrate the game can scale

### Metrics to Watch
- Time to complete each level (should feel good, not tedious)
- How often players use special attack (if never = too hard to charge, if constantly = too easy)
- Player retention per level (drop-off indicates difficulty/fun issues)

---

## Technical Debt to Address

### Known Issues
- Player sprite is placeholder (needs robot art)
- No visual feedback for special bar charging
- Sound integration incomplete (files exist but not all hooked up)
- No combo or advanced scoring mechanics
- Level design is minimal (1 test level exists)

### Architecture Considerations
- GameManager is good foundation, no changes needed
- Ball/Player scripts are solid, may need minor tweaks for special bar integration
- Brick system works but could use visual enhancement (animations, particles)
- UI system functional but needs special bar widget

---

## Post-MVP Roadmap Preview

### After MVP validation, consider:
1. **Core System Layer:** Material drops, simple crafting (1-2 weapon types)
2. **Content Layer:** More levels, introduce biome aesthetics (not full system yet)
3. **Meta Progression Layer:** Unlock system, basic upgrade tree
4. **Advanced Mechanics Layer:** Parry system, multiple cores with unique specials
5. **Full Vision:** Boss fights, map navigation, full crafting ecosystem

Each layer builds on validated mechanics from the previous phase.

---

## Development Philosophy

### Iterate, Don't Waterfall
- Build feature → Test → Polish → Move on
- Get playable builds early and often
- Cut ruthlessly if something isn't fun
- The MVP can change if testing reveals better directions

### Quality Over Quantity
- 3 polished, fun levels > 10 mediocre ones
- One satisfying special attack > three underwhelming ones
- Better to ship a small, tight experience than an ambitious, janky one

---

## Next Steps
See [PROJECT_TIMELINE.md](PROJECT_TIMELINE.md) for detailed task breakdown and implementation order.
