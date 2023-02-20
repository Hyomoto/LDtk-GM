loader	= new LDtkLoader(true);
var _error	= loader.open( filename_path( GM_project_filename ) + "datafiles\\metroidtest.ldtk", { "AlphaBG_tileset" : tsTiles, }, { "Entity" : objEntity });

window_scale( 256, 240, 0.4 );

camera	= new LDtkCamera( 0, 256, 240, loader, { offsetX : 128, offsetY : 120 });
camera.background( function() { draw_clear( #050505 ); });
camera.move( 216, 136 );

show_debug_message( _error ? "An error occurred." : "No errors detected!" );

#macro print show_debug_message

rooms	= array_create_ext( array_length( loader.levels.byId ), method({"s" : loader.levels.byId }, function( _i ) {
	return s[ _i ].create();
	
}));

moveTo	= undefined;

loader.watch( "metroidtest\\*.ldtkl" );
loader.listen( "reload", function( _v ) {
	array_foreach( rooms, method({ "v" : _v, "l" : loader }, function( _v ) {
		if ( _v.source == v )
			_v.reload( l );
			
	}));
	
});
