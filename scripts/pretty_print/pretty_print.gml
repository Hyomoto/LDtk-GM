function pretty_print( _source, _indent = "", _mask = [] ) {
	static printValue	= function( _indent, _value, _mask, _key = "" ) {
		if ( is_struct( _value )) {
			if ( variable_struct_names_count( _value ) == 0 )
				show_debug_message( _indent + _key + "{}");
			else if ( array_contains( _mask, _value )) 
				show_debug_message( _indent + _key + "{...}");
			else {
				array_push( _mask, _value );
				show_debug_message( _indent + _key + "{");
					pretty_print( _value, _indent + "  ", _mask );
				show_debug_message( _indent + "}");
			}
		} else if ( is_array( _value )) {
			if ( array_length( _value ) == 0 )
				show_debug_message( _indent + _key + "[]");
			else if ( array_contains( _mask, _value )) 
				show_debug_message( _indent + _key + "[...]");
			else {
				if ( array_find_index( _value, function( _v ) { return is_struct( _v ) || is_array( _v ); }) > -1 ) {
					array_push( _mask, _value );
					show_debug_message( _indent + _key + "[");
						pretty_print( _value, _indent + "  ", _mask );
					show_debug_message( _indent + "]");
					
				}
				else
					show_debug_message( _indent + _key + string( _value ));
					
			}
		} else
			show_debug_message( _indent + _key + string( _value ));
		
	}
	
	if ( is_struct( _source )) {
		var _keys	= variable_struct_get_names( _source );
		array_sort( _keys, method({"l" : _source }, function( _a, _b ) {
			if ( is_struct( l[$ _a ] ) || is_array( l[$ _a ] ))
				return 1;
			if ( is_struct( l[$ _b ] ) || is_array( l[$ _b ] ))
				return -1;
			if ( _a < _b )
				return -1;
			if ( _a == _b )
				return 0;
			return 1;
			
		}));
		var _i	= 0; repeat( array_length( _keys )) {
			var _value	= _source[$ _keys[ _i ]];
			printValue( _indent, _value, _mask, _keys[ _i++ ] + " = " );
			
		}
		
	} else if ( is_array( _source )) {
		var _i	= 0; repeat( array_length( _source )) {
			printValue( _indent, _source[ _i++ ], _mask );
			
		}
	} else
		show_debug_message( _indent + string( _source ));
	
}
