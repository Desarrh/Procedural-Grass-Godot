# Procedural Pixel Art Grass for Godot 4

A single `@tool` script that generates procedural pixel art grass, reeds, roots, wheat, bamboo, and more — directly in the Godot editor. No external dependencies. Just drop it in your project.

<!-- Add your screenshots/GIFs here -->

## Features

### Blades
- **Randomized blades**: configurable count, height range, and width range per patch
- **Growth direction**: angle-based growth (not just upward — roots, hanging vines)
- **Color gradient**: smooth base-to-tip color interpolation with per-blade variation
- **Segment spacing**: dark stripes for segmented look (bamboo, reeds)
- **Tip textures**: optional sprites on blade tips (flowers, wheat ears, sakura petals)

### Animation
- **Ambient sway**: continuous sine-wave oscillation with configurable speed and amplitude
- **Player interaction**: proximity-triggered wobble + directional push when the player walks through
- **Smooth decay**: natural return to rest after player passes
- **Per-blade phase offsets**: each blade moves independently for organic motion

### Rendering
- **Pixel-by-pixel rendering** via `_draw()` for crisp pixel art
- **Screen culling** via VisibleOnScreenNotifier2D — zero cost when off-screen
- **Optional PointLight2D**: real light for glowing vegetation (firefly grass, bioluminescent plants)
- **Deterministic seed**: same position = same grass, every time

## Quick Start

1. Copy `GrassPatch.gd` into your Godot 4 project
2. Create a new `Node2D` scene and attach the script
3. Tweak parameters in the Inspector — everything updates in real-time

Or open the included `grass_patch.tscn` scene directly.

## What Can You Make?

| Type | Key Parameters |
|------|---------------|
| **Grass** | Default settings, green colors, short blades |
| **Tall grass** | Higher max_blade_height, more blade_count |
| **Wheat** | Tip texture (wheat ear sprite), segment_spacing, golden colors |
| **Bamboo** | Tall blades, segment_spacing, wider blade_width |
| **Reeds** | Tall, thin, slight sway, brownish colors |
| **Roots** | grow_angle = 180 (downward), dark brown colors |
| **Hanging vines** | grow_angle = 180, green, high sway |
| **Wildflowers** | Tip texture (flower sprites), colorful tip_color |
| **Sakura petals** | Pink tip_color, tip texture, high scatter |
| **Crystal grass** | Cyan/purple colors, light_enabled, low sway |

## Parameters Overview

| Group | Parameters |
|-------|-----------|
| **Patch** | patch_width, blade_count, max/min_blade_height, blade_width_min/max, segment_spacing, grow_angle |
| **Colors** | base_color, tip_color |
| **Ambient Sway** | ambient_speed, ambient_amplitude |
| **Player Sway** | player_sway_amplitude, decay_speed, detect_radius |
| **Tip Texture** | tip_texture, tip_offset |
| **Light** | light_enabled, light_energy |
| **Generation** | noise_seed |

## Requirements

- **Godot 4.3+** (tested on 4.4 and 4.6)
- No plugins, no dependencies, no autoloads
- Works with any renderer (Forward+, Mobile, Compatibility)
- Player interaction requires a node in the `"player"` group

## Tips

- Set `texture_filter` to **Nearest** in your project settings for crisp pixel art
- Use `grow_angle = 180` to make roots or hanging vegetation
- Combine multiple GrassPatch instances with different colors for variety
- The `noise_seed` parameter (0 = auto per instance) ensures deterministic generation
- Add a tip texture sprite for flowers, wheat ears, or decorative tips

## Made for Snaily

This tool was built for **Snaily**, a pixel art open-world platformer made in Godot 4.

Built with the help of Claude (AI pair programming).

## License

MIT — use it however you want, credit appreciated.
