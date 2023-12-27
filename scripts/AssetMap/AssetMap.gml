function AssetMap() constructor {
	assets = ds_map_create()
	
	static load = function (_name) {}
	
	static get = function (_name) {
		gml_pragma("forceinline")
		
		return assets[? _name]
	}
	
	static fetch = function (_name) {
		gml_pragma("forceinline")
		
		load(_name)
		
		return get(_name)
	}
	
	static clear = function () {
		var _key = ds_map_find_last(assets)
		var _transient_key = undefined
		
		while _key != undefined {
			var _asset = assets[? _key]
			
			if _asset.transient {
				_transient_key = _key
				_key = ds_map_find_previous(assets, _key)
				
				continue
			}
			
			_asset.destroy()
			ds_map_delete(assets, _key)
			_key = _transient_key != undefined ? ds_map_find_previous(assets, _transient_key) : ds_map_find_last(assets)
		}
	}
}