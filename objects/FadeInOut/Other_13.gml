/// @description Tick
switch state {
	case 0:
		alpha += 0.02
		
		if alpha >= 1 {
			state = 1
		}
	break
	
	case 3:
		alpha -= 0.02
		
		if alpha <= 0 {
			instance_destroy()
		}
	break
}