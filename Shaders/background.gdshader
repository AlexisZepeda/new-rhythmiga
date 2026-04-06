shader_type canvas_item;

group_uniforms Background;
uniform vec4 first_color: source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 second_color: source_color = vec4(0.0, 0.0, 0.196, 1.0);
uniform float position: hint_range(-0.5, 0.5) = 0.25;
uniform float size: hint_range(0.5, 2) = 1.5;
uniform float angle: hint_range(0.0, 360.0) = 270.0;

group_uniforms Waves;
uniform vec4 background_color : source_color = vec4(0.518, 0.384, 0.0, 1.0);
uniform float GWM = 1.5;
uniform float TM = 0.25;
uniform float wave_speed: hint_range(-2, 2) = 0.2;
uniform sampler2D tex;


float getAmp(float frequency) {
	return texture(tex, vec2(frequency / 512.0, 0)).x; //512.0
}

float getWeight(float f) {
	return (getAmp(f - 2.0) + getAmp(f - 1.0) +
			getAmp(f + 2.0) + getAmp(f + 1.0) +
			getAmp(f)) / 5.0;
}



void fragment() {
	float pivot = position + 0.5;
	//vec2 uv = UV - pivot;
	
	vec2 uvTrue =  FRAGCOORD.xy / (1.0 / SCREEN_PIXEL_SIZE);
	vec2 uv = 2.0 * uvTrue - 1.0 - pivot;
	
	float rotated = uv.x * cos(radians(angle)) - uv.y * sin(radians(angle)); 
	float pos = smoothstep((1.0 - size) + position, size + 0.0001 + position, rotated + pivot);
	//COLOR = mix(first_color, second_color, pos);
	//
	//
	vec4 backdrop = mix(first_color, second_color, pos);


	float li;
	float gw;
	float ts;

	vec4 color = vec4(0.0);

	for(float i = 0.0; i < 1.0; i++) {
		uv.y += (wave_speed * sin(uv.x + i / 7.0 - TIME * 0.6));
		float Y = uv.y + getWeight(pow(i, 2.0) * 20.0) * (texture(tex, vec2(uvTrue.x, 1)).x - 0.5);
		li = 0.4 + pow(1.6 * abs(mod(uvTrue.x + i / 1.1 + TIME, 2.0) - 1.0), 2.0);
		gw = abs(li / (150.0 * Y));

        ts = gw * (GWM + sin(TIME * TM));
		color += vec4(ts, ts, ts, 1.0);
	}

	COLOR = vec4(color + backdrop);
	COLOR = mix(color + backdrop, backdrop, background_color);
}