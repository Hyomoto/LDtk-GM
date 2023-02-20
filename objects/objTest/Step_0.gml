if ( mouse_check_button( mb_left )) {
	camera.target	= [ mouse_x, mouse_y ];
	
}
camera.update( rooms );

var _h	= keyboard_check( vk_right ) - keyboard_check( vk_left );
var _v	= keyboard_check( vk_down ) - keyboard_check( vk_up );

camera_set_view_pos( view_camera[ 0 ],
	camera_get_view_x( view_camera[ 0 ] ) + _h,
	camera_get_view_y( view_camera[ 0 ] ) + _v
);

if ( keyboard_check_pressed( vk_space )) {
	if ( keyboard_check( vk_shift )) {
		loader.reload( "Level_0" );
		rooms[ 0 ].reload( loader );
		
	} else {
		rooms[ 0 ].restart( loader );
		
	}
	
}
