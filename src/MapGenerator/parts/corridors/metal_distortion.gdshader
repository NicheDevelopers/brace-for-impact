shader_type spatial;

uniform float distortion_strength : hint_range(0.0, 1.0) = 0.3;
uniform float metallic : hint_range(0.0, 1.0) = 1.0;
uniform float roughness : hint_range(0.0, 1.0) = 0.2;

varying vec2 uv_coord;

// Random generator from UV
float rand(vec2 co) {
    return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

// 2D → 3D random direction
vec3 rand_dir(vec2 co) {
    float x = rand(co + vec2(1.0, 0.0)) * 2.0 - 1.0;
    float y = rand(co + vec2(0.0, 1.0)) * 2.0 - 1.0;
    float z = rand(co + vec2(1.0, 1.0)) * 2.0 - 1.0;
    return normalize(vec3(x, y, z));
}

void vertex() {
    vec3 dir = rand_dir(UV);
    VERTEX += dir * distortion_strength;
    uv_coord = UV;
}

void fragment() {
    // Solid metallic color
    ALBEDO = vec3(0.14, 0.14, 0.14);  // grey metallic
    METALLIC = metallic;
    ROUGHNESS = roughness;
}
