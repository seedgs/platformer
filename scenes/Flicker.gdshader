shader_type canvas_item;

/* 这里是添加一个着色器 */
uniform vec3 color :source_color = vec3(1.0); /* vec3()里面需要3个值， 如果这3个值都相同，可以简写成1个 */
/* 这里是添加一个可左右拉动的功能，范围是 0-1，初始值是0 */
uniform float amount: hint_range(0.0, 1.0) = 0.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {

	vec3 original_color = texture(TEXTURE, UV).rgb;
	COLOR.rgb = mix(original_color, color, amount);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
