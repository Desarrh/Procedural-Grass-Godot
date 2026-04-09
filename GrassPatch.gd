@tool
class_name GrassPatch
extends Node2D

## Procedural pixel art vegetation patch with sway animation.
## Gently sways at rest, bends when the player walks through.
## Can generate grass, reeds, wheat, roots, rocks, crystals, and more.

enum OutlineMode { PER_BLADE, TOTAL }

# =============================================
#              PATCH
# =============================================
@export_group("Patch")
## Patch width in pixels (8 = one tile)
@export_range(1, 128) var patch_width: int = 8:
	set(v):
		patch_width = v
		_generate_blades()
		queue_redraw()
## Number of blades
@export_range(1, 40) var blade_count: int = 4:
	set(v):
		blade_count = v
		_generate_blades()
		queue_redraw()
## Maximum blade height (pixels)
@export_range(1, 200) var max_blade_height: int = 4:
	set(v):
		max_blade_height = v
		_generate_blades()
		queue_redraw()
## Minimum blade height (pixels)
@export_range(1, 200) var min_blade_height: int = 2:
	set(v):
		min_blade_height = v
		_generate_blades()
		queue_redraw()
## Minimum blade width at base (pixels)
@export_range(1, 30) var blade_width_min: int = 1:
	set(v):
		blade_width_min = v
		_generate_blades()
		queue_redraw()
## Maximum blade width at base (pixels)
@export_range(1, 30) var blade_width_max: int = 1:
	set(v):
		blade_width_max = v
		_generate_blades()
		queue_redraw()
## Blade width at the tip (1 = pointy, same as base = rectangular/rock)
@export_range(1, 30) var blade_width_top: int = 1:
	set(v):
		blade_width_top = v
		_bake_grass()
		queue_redraw()
## Taper curve (1 = linear, <1 = narrows fast, >1 = stays wide longer)
@export_range(0.2, 4.0, 0.1) var blade_taper_curve: float = 1.0:
	set(v):
		blade_taper_curve = v
		_bake_grass()
		queue_redraw()
## Segment spacing for dark stripes every N pixels (0 = none). Bamboo, reeds.
@export_range(0, 12) var segment_spacing: int = 0:
	set(v):
		segment_spacing = v
		_bake_grass()
		queue_redraw()
## Growth direction in degrees (0 = up, 90 = right, 180 = down for roots)
@export_range(-180.0, 180.0) var grow_angle: float = 0.0:
	set(v):
		grow_angle = v
		_bake_grass()
		queue_redraw()
## How much blades curve (0 = perfectly straight for rocks, 1 = normal, 2 = very bendy)
@export_range(0.0, 2.0, 0.05) var blade_curve_amount: float = 1.0:
	set(v):
		blade_curve_amount = v
		_bake_grass()
		queue_redraw()

# =============================================
#              COLORS
# =============================================
@export_group("Colors")
@export var main_color: Color = Color(0.22, 0.45, 0.18, 1.0):
	set(v):
		main_color = v
		_bake_grass()
		queue_redraw()
## Per-blade color randomness (0 = uniform, 0.5+ = very varied colors between blades)
@export_range(0.0, 1.0, 0.01) var color_variation_amount: float = 0.04:
	set(v):
		color_variation_amount = v
		_generate_blades()
		queue_redraw()
## Color palette — if non-empty, each blade picks a random color from this list instead of main_color
@export var color_palette: Array[Color] = []:
	set(v):
		color_palette = v
		_generate_blades()
		queue_redraw()

# =============================================
#              OUTLINE
# =============================================
@export_group("Outline")
## Draw a 1px outline around blades
@export var outline_enabled: bool = false:
	set(v):
		outline_enabled = v
		_bake_grass()
		queue_redraw()
## PER_BLADE: each blade gets its own outline. TOTAL: one outline around the combined shape.
@export var outline_mode: OutlineMode = OutlineMode.PER_BLADE:
	set(v):
		outline_mode = v
		_bake_grass()
		queue_redraw()
@export var outline_color: Color = Color.BLACK:
	set(v):
		outline_color = v
		_bake_grass()
		queue_redraw()
## Outline thickness in pixels
@export_range(1, 10) var outline_thickness: int = 1:
	set(v):
		outline_thickness = v
		_bake_grass()
		queue_redraw()

# =============================================
#              SHADING
# =============================================
@export_group("Shading")
## Use 3-color diagonal shading instead of main_color.
## When ON: light (top-left), mid (center), dark (bottom-right) replace main_color entirely.
## When OFF: uses main_color uniformly (gradient via shading_gradient/hue_shift).
@export var use_3color_shading: bool = false:
	set(v):
		use_3color_shading = v
		_bake_grass()
		queue_redraw()
## Vertical gradient: top bright, bottom dark.
@export_range(0.0, 2.0, 0.05) var shading_gradient: float = 0.0:
	set(v):
		shading_gradient = v
		_bake_grass()
		queue_redraw()
## Hue shift amount (0 = none, shifts warm at top, cool at bottom)
@export_range(0.0, 2.0, 0.05) var hue_shift_amount: float = 0.0:
	set(v):
		hue_shift_amount = v
		_bake_grass()
		queue_redraw()
## Light color — top-left (only when use_3color_shading is ON)
@export var shading_color_light: Color = Color(0.35, 0.65, 0.25):
	set(v):
		shading_color_light = v
		_bake_grass()
		queue_redraw()
## Mid color — center (only when use_3color_shading is ON)
@export var shading_color_mid: Color = Color(0.22, 0.45, 0.18):
	set(v):
		shading_color_mid = v
		_bake_grass()
		queue_redraw()
## Dark color — bottom-right (only when use_3color_shading is ON)
@export var shading_color_dark: Color = Color(0.12, 0.28, 0.10):
	set(v):
		shading_color_dark = v
		_bake_grass()
		queue_redraw()

# =============================================
#              AMBIENT SWAY
# =============================================
@export_group("Ambient Sway")
## Oscillation speed at rest
@export_range(0.5, 4.0) var ambient_speed: float = 1.5
## Amplitude at rest (1.0 = 1 pixel max movement)
@export_range(0.5, 3.0) var ambient_amplitude: float = 1.2:
	set(v):
		ambient_amplitude = v
		_bake_grass()
		queue_redraw()

# =============================================
#              PLAYER SWAY
# =============================================
@export_group("Player Sway")
## Amplitude when player passes through
@export_range(1.0, 5.0) var player_sway_amplitude: float = 2.5
## Return-to-calm speed (lower = slower)
@export_range(0.5, 5.0) var decay_speed: float = 1.5
## Player detection distance (pixels)
@export_range(4.0, 20.0) var detect_radius: float = 10.0

# =============================================
#              TIP TEXTURE
# =============================================
@export_group("Tip Texture")
## Optional texture drawn at blade tips (wheat ear, flower, etc.)
@export var tip_texture: Texture2D:
	set(v):
		tip_texture = v
		_bake_grass()
		queue_redraw()
## Offset relative to blade tip (negative Y = higher)
@export var tip_offset: Vector2 = Vector2(0, -2):
	set(v):
		tip_offset = v
		_bake_grass()
		queue_redraw()

# =============================================
#              LIGHT
# =============================================
@export_group("Light")
## Enable a PointLight2D (color = main_color automatically)
@export var light_enabled: bool = false:
	set(v):
		light_enabled = v
		_update_light()
## Light intensity
@export_range(0.0, 3.0) var light_energy: float = 0.6:
	set(v):
		light_energy = v
		_update_light()

var _light: PointLight2D = null

# =============================================
#              ANIMATION
# =============================================
@export_group("Animation")
## Preview sway animation in the editor
@export var editor_preview_animation: bool = false:
	set(v):
		editor_preview_animation = v
		if Engine.is_editor_hint():
			set_process(v)
			if not v:
				queue_redraw()

# =============================================
#              GENERATION
# =============================================
@export_group("Generation")
## Force a specific seed (0 = auto per instance)
@export var noise_seed: int = 0:
	set(v):
		noise_seed = v
		if v != 0:
			_effective_seed = v
		_generate_blades()
		queue_redraw()

# =============================================
#              INTERNALS
# =============================================
var _blades: Array = []
var _effective_seed: int = 0
var _current_sway: float = 0.0
var _sway_direction: float = 0.0
var _on_screen: bool = true
var _player_ref: CharacterBody2D = null
var _time: float = 0.0

# Bake
var _baked_texture: ImageTexture = null
var _bake_offset: Vector2 = Vector2.ZERO
var _is_baked: bool = false

func _ready() -> void:
	add_to_group("grass")
	if noise_seed != 0:
		_effective_seed = noise_seed
	else:
		_effective_seed = get_instance_id()
	_generate_blades()
	_bake_grass()
	_time = float(_effective_seed % 1000) / 100.0
	modulate = modulate  # preserve any existing modulate

	# Editor: process only if preview animation is on
	if Engine.is_editor_hint():
		set_process(editor_preview_animation)
		return

	# Optional light
	if light_enabled:
		_create_light()

	if not Engine.is_editor_hint():
		_find_player.call_deferred()
		# Screen culling
		var notifier := VisibleOnScreenNotifier2D.new()
		notifier.rect = Rect2(-2, -max_blade_height - 2, patch_width + 4, max_blade_height + 6)
		add_child(notifier)
		notifier.screen_entered.connect(func():
			_on_screen = true
			set_process(true)
			queue_redraw()
		)
		notifier.screen_exited.connect(_on_screen_exited)
		set_process(false)

func _create_light() -> void:
	_light = PointLight2D.new()
	var gradient := Gradient.new()
	gradient.set_color(0, Color.WHITE)
	gradient.set_color(1, Color(1, 1, 1, 0))
	var tex := GradientTexture2D.new()
	tex.gradient = gradient
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(0.5, 0.0)
	tex.set_width(64)
	tex.set_height(64)
	_light.texture = tex
	_light.color = main_color
	_light.energy = light_energy
	_light.texture_scale = 0.15
	_light.shadow_enabled = false
	_light.blend_mode = Light2D.BLEND_MODE_ADD
	_light.position = Vector2(float(patch_width) * 0.5, float(-max_blade_height) * 0.5)
	add_child(_light)


func _update_light() -> void:
	if not _light and light_enabled:
		_create_light()
	if _light:
		_light.visible = light_enabled
		_light.color = main_color
		_light.energy = light_energy


func _find_player() -> void:
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		_player_ref = players[0] as CharacterBody2D

func _generate_blades() -> void:
	_blades.clear()
	var rng := RandomNumberGenerator.new()
	rng.seed = _effective_seed if _effective_seed != 0 else randi()

	for i in blade_count:
		var base_x: float
		if blade_count > 1:
			base_x = (float(i) / float(blade_count - 1)) * float(patch_width)
		else:
			base_x = float(patch_width) / 2.0
		base_x += rng.randf_range(-1.0, 1.0)
		base_x = clampf(base_x, 0.0, float(patch_width))

		var w := blade_width_min
		if blade_width_max > blade_width_min:
			w = rng.randi_range(blade_width_min, blade_width_max)

		var blade_color: Color = main_color
		if color_palette.size() > 0:
			blade_color = color_palette[rng.randi() % color_palette.size()]

		_blades.append({
			"x": base_x,
			"height": rng.randi_range(min_blade_height, max_blade_height),
			"width": w,
			"phase_offset": rng.randf_range(0.0, TAU),
			"color_variation": rng.randf_range(-color_variation_amount, color_variation_amount),
			"blade_color": blade_color,
		})
	_bake_grass()


## Compute blade width at position t (0=base, 1=tip), accounting for taper curve
func _blade_width_at(base_w: int, t: float) -> int:
	var t_curved := pow(t, blade_taper_curve) if blade_taper_curve != 1.0 else t
	return maxi(1, roundi(lerpf(float(base_w), float(blade_width_top), t_curved)))


## Get pixel color based on mode + apply gradient and hue shift.
## 3-color mode: 3 bands based on horizontal position (same as ProceduralTree trunk).
## Normal mode: uses blade_base_color uniformly (gradient via shading_gradient/hue_shift).
## Gradient goes diagonally: top-left = bright, bottom-right = dark.
func _get_pixel_color(wx: int, total_w: int, blade_t: float, color_var: float, blade_base_color: Color = Color.BLACK) -> Color:
	var col: Color
	if use_3color_shading:
		# 3 bands: left = light, center = mid, right = dark
		if total_w <= 1:
			col = shading_color_mid
		else:
			var ratio := float(wx) / float(total_w - 1)
			if ratio < 0.35:
				col = shading_color_light
			elif ratio > 0.65:
				col = shading_color_dark
			else:
				col = shading_color_mid
	else:
		col = blade_base_color
		col.r = clampf(col.r + color_var, 0.0, 1.0)
		col.g = clampf(col.g + color_var, 0.0, 1.0)

	# Diagonal gradient: top-left bright (1.0), bottom-right dark (0.0)
	var x_ratio := float(wx) / float(maxi(total_w - 1, 1))
	var gradient_t := blade_t * 0.6 + (1.0 - x_ratio) * 0.4

	# Brightness — same coefficients as ProceduralTree._apply_trunk_gradient
	if shading_gradient > 0.0:
		var brightness := lerpf(1.0 - shading_gradient * 0.4, 1.0 + shading_gradient * 0.15, gradient_t)
		col = Color(
			clampf(col.r * brightness, 0.0, 1.0),
			clampf(col.g * brightness, 0.0, 1.0),
			clampf(col.b * brightness, 0.0, 1.0),
			col.a
		)

	# Hue shift — same formula as ProceduralTree._apply_trunk_gradient
	if hue_shift_amount > 0.0:
		var shade_t := 1.0 - gradient_t  # 0=top-left, 1=bottom-right
		var hue_rotate := (shade_t - 0.5) * hue_shift_amount * 0.08
		var h := fmod(col.h + hue_rotate + 1.0, 1.0)
		var s := clampf(col.s * (1.0 + hue_shift_amount * 0.1), 0.0, 1.0)
		var v := clampf(col.v * lerpf(1.0, lerpf(1.1, 0.8, shade_t), hue_shift_amount * 0.3), 0.0, 1.0)
		col = Color.from_hsv(h, s, v, col.a)

	return col


func _bake_grass() -> void:
	if _blades.is_empty() or not is_node_ready():
		return

	var angle_rad := deg_to_rad(grow_angle)
	var grow_dir := Vector2(sin(angle_rad), -cos(angle_rad))

	# Compute bounding box
	var sway_margin := amplitude_to_px() + 4
	var min_x: int = -sway_margin
	var max_x: int = patch_width + sway_margin
	var min_y: int = 0
	var max_y: int = 1

	for blade in _blades:
		var bx: float = blade["x"]
		var h: int = blade["height"]
		var w: int = blade["width"]
		var top_pos := Vector2(bx, 0.0) + grow_dir * float(h)
		min_x = mini(min_x, roundi(top_pos.x) - sway_margin - w)
		max_x = maxi(max_x, roundi(top_pos.x) + sway_margin + w)
		min_y = mini(min_y, roundi(top_pos.y) - 4)
		max_y = maxi(max_y, roundi(top_pos.y) + 4)

	# Tip texture margin
	if tip_texture:
		min_y -= ceili(tip_texture.get_height())
		min_x -= ceili(tip_texture.get_width())
		max_x += ceili(tip_texture.get_width())

	# Outline margin
	if outline_enabled:
		min_x -= outline_thickness
		max_x += outline_thickness
		min_y -= outline_thickness
		max_y += outline_thickness

	var img_w := max_x - min_x
	var img_h := max_y - min_y
	if img_w <= 0 or img_h <= 0:
		return

	_bake_offset = Vector2(min_x, min_y)
	var img := Image.create(img_w, img_h, true, Image.FORMAT_RGBA8)
	var ox := -min_x
	var oy := -min_y

	var sway_dir := Vector2(grow_dir.y, -grow_dir.x)

	# Collect all blade + tip pixel positions and colors
	var blade_data: Array = []
	var all_filled: Dictionary = {}
	var _tip_img: Image = null
	if tip_texture:
		_tip_img = tip_texture.get_image()

	for blade in _blades:
		var x: float = blade["x"]
		var height: int = blade["height"]
		var base_w: int = blade["width"]
		var color_var: float = blade["color_variation"]
		var b_color: Color = blade.get("blade_color", main_color)
		var phase: float = blade["phase_offset"]
		var static_curve: float = sin(phase) * ambient_amplitude * 0.8 * blade_curve_amount

		var filled: Dictionary = {}
		var pixels: Array = []

		for py in height:
			var along := grow_dir * float(py)
			var curve_t: float = float(py) / float(height - 1) if height > 1 else 1.0
			var curve_offset := sway_dir * (static_curve * curve_t * curve_t)
			var pixel_pos := Vector2(x, 0.0) + along + curve_offset
			var px := roundi(pixel_pos.x) + ox
			var ppy := roundi(pixel_pos.y) + oy
			var t: float = float(py) / float(height - 1) if height > 1 else 1.0
			var w := _blade_width_at(base_w, t)
			var half := w / 2

			for wx in w:
				var pcol := _get_pixel_color(wx, w, t, color_var, b_color)
				if segment_spacing > 0 and py > 0 and py % segment_spacing == 0:
					pcol = pcol.darkened(0.3)
				var pos := Vector2i(px + wx - half, ppy)
				filled[pos] = true
				pixels.append([pos, pcol])
				all_filled[pos] = true

		# Tip texture — add to filled set so outline wraps around tips
		var tip_info = null
		if _tip_img:
			var top_py := height - 1
			var tip_curve_t: float = float(top_py) / float(height - 1) if height > 1 else 1.0
			var tip_curve := sway_dir * (static_curve * tip_curve_t * tip_curve_t)
			var tip_pos := Vector2(x, 0.0) + grow_dir * float(top_py) + tip_curve
			var tw := _tip_img.get_width()
			var th := _tip_img.get_height()
			var tdx := roundi(tip_pos.x) + ox + roundi(tip_offset.x) - ceili(tw * 0.5)
			var tdy := roundi(tip_pos.y) + oy + roundi(tip_offset.y) - ceili(th * 0.5)
			tip_info = {"dx": tdx, "dy": tdy, "tw": tw, "th": th}
			for ty in th:
				for tx in tw:
					if _tip_img.get_pixel(tx, ty).a > 0.01:
						var pos := Vector2i(tdx + tx, tdy + ty)
						if pos.x >= 0 and pos.x < img_w and pos.y >= 0 and pos.y < img_h:
							filled[pos] = true
							all_filled[pos] = true

		blade_data.append({"filled": filled, "pixels": pixels, "tip": tip_info})

	# Render outline + fill + tips to image
	if outline_enabled and outline_mode == OutlineMode.PER_BLADE:
		for bd in blade_data:
			# Outline (includes tip border)
			for pos in bd.filled:
				for ddx in range(-outline_thickness, outline_thickness + 1):
					for ddy in range(-outline_thickness, outline_thickness + 1):
						if ddx == 0 and ddy == 0:
							continue
						var n := Vector2i(pos.x + ddx, pos.y + ddy)
						if not bd.filled.has(n) and n.x >= 0 and n.x < img_w and n.y >= 0 and n.y < img_h:
							img.set_pixel(n.x, n.y, outline_color)
			# Fill blade pixels
			for p in bd.pixels:
				if p[0].x >= 0 and p[0].x < img_w and p[0].y >= 0 and p[0].y < img_h:
					img.set_pixel(p[0].x, p[0].y, p[1])
			# Tip texture (alpha blended)
			if bd.tip and _tip_img:
				var ti = bd.tip
				var t_dx: int = ti.dx
				var t_dy: int = ti.dy
				for ty in int(ti.th):
					for tx in int(ti.tw):
						var src := _tip_img.get_pixel(tx, ty)
						if src.a < 0.01:
							continue
						var fx := t_dx + tx
						var fy := t_dy + ty
						if fx >= 0 and fx < img_w and fy >= 0 and fy < img_h:
							var dst := img.get_pixel(fx, fy)
							var out_a := src.a + dst.a * (1.0 - src.a)
							if out_a > 0.001:
								img.set_pixel(fx, fy, Color(
									(src.r * src.a + dst.r * dst.a * (1.0 - src.a)) / out_a,
									(src.g * src.a + dst.g * dst.a * (1.0 - src.a)) / out_a,
									(src.b * src.a + dst.b * dst.a * (1.0 - src.a)) / out_a,
									out_a))
	else:
		# Fill all blades
		for bd in blade_data:
			for p in bd.pixels:
				if p[0].x >= 0 and p[0].x < img_w and p[0].y >= 0 and p[0].y < img_h:
					img.set_pixel(p[0].x, p[0].y, p[1])
		# All tip textures
		for bd in blade_data:
			if bd.tip and _tip_img:
				var ti = bd.tip
				var t_dx: int = ti.dx
				var t_dy: int = ti.dy
				for ty in int(ti.th):
					for tx in int(ti.tw):
						var src := _tip_img.get_pixel(tx, ty)
						if src.a < 0.01:
							continue
						var fx := t_dx + tx
						var fy := t_dy + ty
						if fx >= 0 and fx < img_w and fy >= 0 and fy < img_h:
							var dst := img.get_pixel(fx, fy)
							var out_a := src.a + dst.a * (1.0 - src.a)
							if out_a > 0.001:
								img.set_pixel(fx, fy, Color(
									(src.r * src.a + dst.r * dst.a * (1.0 - src.a)) / out_a,
									(src.g * src.a + dst.g * dst.a * (1.0 - src.a)) / out_a,
									(src.b * src.a + dst.b * dst.a * (1.0 - src.a)) / out_a,
									out_a))
		# Total outline (includes tip positions in all_filled)
		if outline_enabled:
			var outline_set: Dictionary = {}
			for pos in all_filled:
				for ddx in range(-outline_thickness, outline_thickness + 1):
					for ddy in range(-outline_thickness, outline_thickness + 1):
						if ddx == 0 and ddy == 0:
							continue
						var n := Vector2i(pos.x + ddx, pos.y + ddy)
						if not all_filled.has(n) and n.x >= 0 and n.x < img_w and n.y >= 0 and n.y < img_h:
							outline_set[n] = true
			for pos in outline_set:
				img.set_pixel(pos.x, pos.y, outline_color)

	_baked_texture = ImageTexture.create_from_image(img)
	_is_baked = true


func amplitude_to_px() -> int:
	return ceili(ambient_amplitude + player_sway_amplitude + 2.0)


func _on_screen_exited() -> void:
	_on_screen = false
	set_process(false)
	_current_sway = 0.0
	_sway_direction = 0.0
	queue_redraw()

func _process(delta: float) -> void:
	_time += delta

	if not Engine.is_editor_hint():
		# Distance-based player detection — no Area2D, zero collision pairs
		if _player_ref and is_instance_valid(_player_ref):
			var center := global_position + Vector2(patch_width * 0.5, -4.0)
			var dist := center.distance_to(_player_ref.global_position)
			if dist < detect_radius:
				if abs(_player_ref.velocity.x) > 10.0:
					_sway_direction = signf(_player_ref.velocity.x)
				_current_sway = move_toward(_current_sway, player_sway_amplitude, delta * 6.0)
			else:
				_current_sway = move_toward(_current_sway, 0.0, delta * decay_speed)
				_sway_direction = move_toward(_sway_direction, 0.0, delta * decay_speed * 0.5)
		else:
			_current_sway = move_toward(_current_sway, 0.0, delta * decay_speed)
			_sway_direction = move_toward(_sway_direction, 0.0, delta * decay_speed * 0.5)

	queue_redraw()

func _draw() -> void:
	if not _on_screen and not Engine.is_editor_hint():
		return

	# Static display (editor without animation): draw baked texture directly
	if Engine.is_editor_hint() and not editor_preview_animation:
		if _is_baked and _baked_texture:
			draw_texture(_baked_texture, _bake_offset)
		return

	# Animated display: compute per-frame positions
	var angle_rad := deg_to_rad(grow_angle)
	var grow_dir := Vector2(sin(angle_rad), -cos(angle_rad))
	var sway_dir := Vector2(grow_dir.y, -grow_dir.x)

	# Collect all blade + tip pixel data for this frame
	var blade_render: Array = []
	var all_filled: Dictionary = {}
	var _tip_img_draw: Image = null
	if tip_texture:
		_tip_img_draw = tip_texture.get_image()

	for blade in _blades:
		var x: float = blade["x"]
		var height: int = blade["height"]
		var base_w: int = blade["width"]
		var phase: float = blade["phase_offset"]
		var color_var: float = blade["color_variation"]
		var b_color: Color = blade.get("blade_color", main_color)

		var amb: float = sin(_time * ambient_speed + phase) * ambient_amplitude * blade_curve_amount
		var ps: float = 0.0
		if _current_sway > 0.01:
			ps = sin(_time * 4.0 + phase) * _current_sway * 0.3 + _sway_direction * _current_sway * 0.7
		var sway_raw: float = amb + ps

		var filled: Dictionary = {}
		var pixels: Array = []

		for py in height:
			var along := grow_dir * float(py)
			var sf: float = float(py) / float(height - 1) if height > 1 else 1.0
			var lateral := sway_dir * (sway_raw * sf)
			var ppos := Vector2(x, 0.0) + along + lateral
			var px := roundi(ppos.x)
			var py_r := roundi(ppos.y)
			var t: float = float(py) / float(height - 1) if height > 1 else 1.0
			var w := _blade_width_at(base_w, t)
			var half := w / 2

			for wx in w:
				var pcol := _get_pixel_color(wx, w, t, color_var, b_color)
				if segment_spacing > 0 and py > 0 and py % segment_spacing == 0:
					pcol = pcol.darkened(0.3)
				var pos := Vector2i(px + wx - half, py_r)
				filled[pos] = true
				pixels.append([pos, pcol])
				all_filled[pos] = true

		var tp = null
		if tip_texture:
			var top_py := height - 1
			var sf_top: float = float(top_py) / float(height - 1) if height > 1 else 1.0
			tp = Vector2(x, 0.0) + grow_dir * float(top_py) + sway_dir * (sway_raw * sf_top)
			# Add tip pixels to filled set so outline wraps around tips
			if _tip_img_draw:
				var tex_size := tip_texture.get_size()
				var dp := Vector2(roundi(tp.x), roundi(tp.y)) + tip_offset - tex_size * 0.5
				for ty in _tip_img_draw.get_height():
					for tx in _tip_img_draw.get_width():
						if _tip_img_draw.get_pixel(tx, ty).a > 0.01:
							var pos := Vector2i(roundi(dp.x) + tx, roundi(dp.y) + ty)
							filled[pos] = true
							all_filled[pos] = true

		blade_render.append({"filled": filled, "pixels": pixels, "tip_pos": tp})

	# Render outline + fill
	if outline_enabled and outline_mode == OutlineMode.PER_BLADE:
		# Per blade: interleaved outline then fill
		for bd in blade_render:
			for pos in bd.filled:
				for ddx in range(-outline_thickness, outline_thickness + 1):
					for ddy in range(-outline_thickness, outline_thickness + 1):
						if ddx == 0 and ddy == 0:
							continue
						var n := Vector2i(pos.x + ddx, pos.y + ddy)
						if not bd.filled.has(n):
							draw_rect(Rect2(Vector2(n.x, n.y), Vector2(1, 1)), outline_color)
			for p in bd.pixels:
				draw_rect(Rect2(Vector2(p[0].x, p[0].y), Vector2(1, 1)), p[1])
	elif outline_enabled and outline_mode == OutlineMode.TOTAL:
		# Total: outline of combined shape, then all fills
		var outline_set: Dictionary = {}
		for pos in all_filled:
			for ddx in range(-outline_thickness, outline_thickness + 1):
				for ddy in range(-outline_thickness, outline_thickness + 1):
					if ddx == 0 and ddy == 0:
						continue
					var n := Vector2i(pos.x + ddx, pos.y + ddy)
					if not all_filled.has(n):
						outline_set[n] = true
		for pos in outline_set:
			draw_rect(Rect2(Vector2(pos.x, pos.y), Vector2(1, 1)), outline_color)
		for bd in blade_render:
			for p in bd.pixels:
				draw_rect(Rect2(Vector2(p[0].x, p[0].y), Vector2(1, 1)), p[1])
	else:
		# No outline: direct fill
		for bd in blade_render:
			for p in bd.pixels:
				draw_rect(Rect2(Vector2(p[0].x, p[0].y), Vector2(1, 1)), p[1])

	# Tip textures
	if tip_texture:
		for bd in blade_render:
			if bd.tip_pos != null:
				var tex_size := tip_texture.get_size()
				var dp := Vector2(roundi(bd.tip_pos.x), roundi(bd.tip_pos.y)) + tip_offset - tex_size * 0.5
				draw_texture(tip_texture, dp)
