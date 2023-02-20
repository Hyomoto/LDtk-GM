function ldtk_parse_field_instances( _fields, _to, _uids ) {
	static toValue	= function( _field, _uids ) {
		static strc	= function( _str, _pos ) { return string_copy( _str, _pos, 2 ); }
		
		var _value	= _field.__value;
		var _type	= _field.__type;
		
		if ( _value = pointer_null )
			_value	= undefined;
		
		switch( _type ) {
			case "Bool"		: case "Boolean" : return bool( _value ?? 0 );
			case "Integer"	: case "Int" : case "Float" : return real( _value ?? 0 );
			case "String"	: return string( _value );
			case "Color"	: return real( "0x" + strc( _value, 6 ) + strc( _value, 4 ) + strc( _value, 2 ));
			case "Point"	: return { "x" : _value.cx, "y" : _value.cy };
			case "Tile"		:
				if ( is_undefined( _value ))
					return undefined;
				var _tileset	= _uids.byId[ _value.tilesetUid ];
				return {
					"tileset" : _tileset,
					"rectangle" : [ _value.x, _value.y, _value.w, _value.h ],
					"tile" : ( _value.x div _tileset.size ) + ( _value.y div _tileset.size ) * _tileset.width,
					}
					
			case "EntityRef" :
				if ( is_undefined( _value ))
					return undefined;
				if ( is_array( _value )) {
					var _out	= array_create( array_length( _value ))
					var _i = 0; repeat( array_length( _out )) {
						_out[ _i ]	= _value[ _i ].entityIid;
						++_i;
					}
					return _out;
					
				}
				return _value.entityIid;
					
				
			default :
				var _enum	= _uids.byKey[$ string_delete( _type, 1, 10 ) ];
				return _enum[$ _value ];
			
		}
	}
	var _i = 0; repeat( array_length( _fields )) {
		var _field	= _fields[ _i++ ];
		_to[$ _field[ _i ].__identifier ] = toValue( _field, _uids );
		
	}
	
	
}