/// @description Tick
if state > 0 and state < 3 {
	exit
}

if timer >= 36 or timer2 != 0 {
	if timer2 >= 20 {
		if state == 0 {
			state = 1
		}
		
		timer -= fade_out_speed
		fade_out_speed += 0.25
		
		if timer < 0 {
			instance_destroy()
		
			exit
		}
	}
	
	++timer2
} else {
	timer += 1.5
}