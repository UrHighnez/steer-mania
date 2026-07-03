shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_burley, specular_schlick_ggx;

group_uniforms Colors;
uniform vec3 wet_sand_color : source_color = vec3(0.36, 0.30, 0.22);
uniform vec3 dry_sand_color : source_color = vec3(0.85, 0.76, 0.55);
uniform vec3 grass_color : source_color = vec3(0.28, 0.40, 0.16);
uniform vec3 rock_color : source_color = vec3(0.42, 0.38, 0.35);

group_uniforms Height_Anchors;
uniform float wet_sand_y = -3.0;
uniform float dry_sand_y = 0.5;
uniform float grass_y = 8.0;
uniform float rock_y = 35.0;

group_uniforms Slope_Rock;
// Slope (0 = flat .. 1 = vertical) at which rock STARTS and is FULLY reached. Widened defaults
// give a gentle ramp instead of a hard cutoff, so slopes a bit below "full rock" still read
// mostly rocky.
uniform float slope_rock_start : hint_range(0.0, 0.99) = 0.40;
uniform float slope_rock_end : hint_range(0.01, 1.0) = 0.80;
uniform float slope_rock_strength : hint_range(0.0, 1.0) = 1.0;
// The low-poly mesh has FLAT (faceted) normals, so a pure slope threshold lands on hard
// triangle edges → a choppy rock border. A procedural noise jitters the threshold per fragment
// so the transition mottles organically across and between triangles instead. amp = how far the
// threshold wanders; scale = noise frequency (1/wavelength in metres). 0 amp = old hard look.
uniform float rock_noise_amp : hint_range(0.0, 0.6) = 0.22;
uniform float rock_noise_scale = 0.07;

group_uniforms Underwater;
// Rock below the waterline reads as darker, wet stone. Multiplier applied to the rock colour,
// faded in over the first underwater_darken_depth metres below y = 0.
uniform float underwater_rock_darken : hint_range(0.2, 1.0) = 0.6;
uniform float underwater_darken_depth : hint_range(0.5, 20.0) = 3.0;

group_uniforms Surface;
uniform float roughness_value : hint_range(0.0, 1.0) = 0.9;
uniform float specular_value : hint_range(0.0, 1.0) = 0.2;

varying float world_y_var;
varying vec2 world_xz;


// --- Cheap value noise (hash-based) to break the faceted rock border ---------
float hash12(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * 0.1031);
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
}

float vnoise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float a = hash12(i);
	float b = hash12(i + vec2(1.0, 0.0));
	float c = hash12(i + vec2(0.0, 1.0));
	float d = hash12(i + vec2(1.0, 1.0));
	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}


void vertex() {
	// World-Y (for the height bands) + World-XZ (for the rock-border noise) as varyings.
	// Linear interpolation of position is correct, unlike interpolating normals.
	vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_y_var = world_pos.y;
	world_xz = world_pos.xz;
}

void fragment() {
	// Runtime clamp guards against an inverted smoothstep if the params are set badly.
	float safe_slope_end = max(slope_rock_end, slope_rock_start + 0.001);

	// World-space normal reconstructed from the view-space NORMAL (no varying interpolation
	// error, safe against scaling artefacts).
	vec3 world_normal = normalize((INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);

	float y = world_y_var;

	// Rock darkens to wet stone below the waterline (y < 0).
	float wet = smoothstep(0.0, -underwater_darken_depth, y);
	vec3 rock_c = mix(rock_color, rock_color * underwater_rock_darken, wet);

	vec3 base_color;
	if (y <= dry_sand_y) {
		base_color = mix(wet_sand_color, dry_sand_color, smoothstep(wet_sand_y, dry_sand_y, y));
	} else if (y <= grass_y) {
		base_color = mix(dry_sand_color, grass_color, smoothstep(dry_sand_y, grass_y, y));
	} else {
		base_color = mix(grass_color, rock_c, smoothstep(grass_y, rock_y, y));
	}

	// Slope → rock, with a two-octave noise jittering the effective slope so the border mottles
	// instead of snapping along triangle edges (the low-poly faceting otherwise reads as choppy).
	float slope = 1.0 - clamp(world_normal.y, 0.0, 1.0);
	float n = vnoise(world_xz * rock_noise_scale) * 0.65
		+ vnoise(world_xz * rock_noise_scale * 2.7) * 0.35;
	float jittered = slope + (n - 0.5) * rock_noise_amp;
	float rock_blend = smoothstep(slope_rock_start, safe_slope_end, jittered) * slope_rock_strength;

	ALBEDO = mix(base_color, rock_c, rock_blend);
	ROUGHNESS = roughness_value;
	SPECULAR = specular_value;
}
