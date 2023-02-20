function LDtkCamera( _view, _width, _height, _world, _kwargs = {}) constructor {
	static background	= function( _script ) {
		camera_set_begin_script(camera, _script );
		
	}
	static move	= function( _x, _y ) {
		x	= clamp( _x - offsetX, bounds[ 0 ], bounds[ 2 ] );
		y	= clamp( _y - offsetY, bounds[ 1 ], bounds[ 3 ] );
		camera_set_view_pos( camera, x, y );
		
	}
	static update	= function( _rooms ) {
		if ( target == undefined )
			return;
		if ( is_array( target )) {
			var _x	= x + offsetX;
			var _y	= y + offsetY;
			
			if ( point_distance( _x, _y, target[ 0 ], target[ 1 ] ) < 0.5 ) {
				move( target[ 0 ], target[ 1 ] );
				target	= undefined;
				
			} else {
				move( lerp( _x, target[ 0 ], 0.5 ), lerp( _y, target[ 1 ], 0.5 ));
				
			}
			var _i = 0; repeat( array_length( _rooms )) {
				var _level	= _rooms[ _i++ ];
				if ( _level.rectInRoom( x, y, x + width - 1, y + height - 1 ))
					_level.show();
				else
					_level.hide();
				
			}
			
		}
		
	}
	static levelInCamera	= function( _level ) {
		return rectangle_in_rectangle(
			x, y, x + width, y + height,
			_level.x, _level.y, _level.x + _level.width, _level.y + _level.height
		);
		
	}
	view		= _view;
	camera		= view_camera[ _view ];
	width		= _width;
	height		= _height;
	x			= camera_get_view_x( camera );
	y			= camera_get_view_y( camera );
	offsetX		= 0;
	offsetY		= 0;
	world		= _world;
	bounds		= [ -infinity, -infinity, infinity, infinity ];
	target		= undefined;
	
	view_set_wport( _view, width );
	view_set_hport( _view, height );
	view_set_visible( _view, true );
	camera_set_view_size( camera, width, height );
	
	var _keys	= variable_struct_get_names( _kwargs );
	var _i = 0; repeat( array_length( _keys )) {
		if ( self[$ _keys[ _i ]] != undefined )
			self[$ _keys[ _i ]]	= _kwargs[$ _keys[ _i ]];
		++_i;
		
	}
	
}
