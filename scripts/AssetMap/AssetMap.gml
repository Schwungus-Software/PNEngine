function AssetMap() constructor {
	assets = ds_map_create()
	
	static load = function (_name) {}
	
	static get = function(_name) {
		gml_pragma("forceinline")
		
		return assets[? _name]
	}
	
	static clear = function () {
		repeat ds_map_size(assets) {
			var _asset = ds_map_find_first(assets)
			
			assets[? _asset].destroy()
			ds_map_delete(assets, _asset)
		}
	}
}