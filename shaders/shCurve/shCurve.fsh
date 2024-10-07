varying vec2 v_texcoord;
varying vec4 v_color;
varying vec2 v_fragcoord;

uniform vec4 u_curve; // curve, anaglyph, width, height

void main() {
	float anaglyph = u_curve.y;
	vec2 channel_center = vec2(0., -anaglyph);
	vec2 channel_center2 = vec2(0., anaglyph);
	vec2 channel_center3 = vec2(0.);
	
	vec2 uv = v_fragcoord.xy / vec2(u_curve.z, u_curve.w);
	vec2 uv_center = uv * 2. - 1.;
	
	vec4 color = vec4(0.);
	
	// 0
	vec2 d0 = channel_center - uv_center;
	float d2 = dot(d0, d0);
	float curve = u_curve.x;
	
	vec2 uv0 = uv_center / vec2(1. + curve * d2);
	vec4 sample1 = texture2D(gm_BaseTexture, uv0 * 0.5 + 0.5);
	
	color.r = sample1.r;
	
	// 1
	d0 = channel_center2 - uv_center;
	d2 = dot(d0, d0);
	
	vec2 uv1 = uv_center / vec2(1. + curve * d2);
	vec4 sample2 = texture2D(gm_BaseTexture, uv1 * 0.5 + 0.5);
	
	color.g = sample2.g;
	
	// 2
	d0 = channel_center3 - uv_center;
	d2 = dot(d0, d0);
	
	vec2 uv2 = uv_center / vec2(1. + curve * d2);
	vec4 sample3 = texture2D(gm_BaseTexture, uv2 * 0.5 + 0.5);
	
	color.b = sample3.b;
	
	color.a = (sample1.a + sample2.a + sample3.a) / 3.;
	gl_FragColor = v_color * color;
}