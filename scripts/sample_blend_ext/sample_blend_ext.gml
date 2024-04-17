function sample_blend_ext(_sample, _sample1, _sample2, _amount, _mask) {
	gml_pragma("forceinline")
	
	var i = 0
	var j = 0
	var n = array_length(_sample1)
	
	while i < n {
		if not _mask[j++] {
			i += 8
			
			continue
		}
		
		var _i1 = -~i
		var _i2 = i + 2
		var _i3 = i + 3
		var _i4 = i + 4
		var _i5 = i + 5
		var _i6 = i + 6
		var _i7 = i + 7
		var s = sign(_sample1[i] * _sample2[i] + _sample1[_i1] * _sample2[_i1] + _sample1[_i2] * _sample2[_i2] + _sample1[_i3] * _sample2[_i3])
		
		_sample[i] = lerp(_sample1[i], _sample2[i] * s, _amount)
		_sample[_i1] = lerp(_sample1[_i1], _sample2[_i1] * s, _amount)
		_sample[_i2] = lerp(_sample1[_i2], _sample2[_i2] * s, _amount)
		_sample[_i3] = lerp(_sample1[_i3], _sample2[_i3] * s, _amount)
		_sample[_i4] = lerp(_sample1[_i4], _sample2[_i4] * s, _amount)
		_sample[_i5] = lerp(_sample1[_i5], _sample2[_i5] * s, _amount)
		_sample[_i6] = lerp(_sample1[_i6], _sample2[_i6] * s, _amount)
		_sample[_i7] = lerp(_sample1[_i7], _sample2[_i7] * s, _amount)
		i += 8
	}
}