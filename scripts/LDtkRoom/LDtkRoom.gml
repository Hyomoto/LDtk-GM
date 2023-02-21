/// @param {real}	_x
/// @param {real}	_y
/// @param {struct.LDtkLevel}	_level
/// @param {struct} _mappings	A table of layer mappings.
/// @desc	A LDtk room created by instantiating a LDtk Level.  Contains helper
///		functions and data references to the layers and instances created from
///		the LDtk data.  It's worth noting that many GML-native functions will
///		still work, and this is provided as a convenience.
function LDtkRoom( _x, _y, _level, _mappings ) constructor {
	/// @desc	Hides this room.
	static hide	= function() {
		if ( hidden )
			return;
		var _i = 0; repeat( array_length( layers.byId )) {
			layer_set_visible( layers.byId[ _i++ ].layer, false );
			
		}
		hidden	= true;
		
	}
	/// @desc	Shows this room.
	static show	= function() {
		if ( not hidden )
			return;
		var _i = 0; repeat( array_length( layers.byId )) {
			layer_set_visible( layers.byId[ _i++ ].layer, true );
			
		}
		hidden	= false;
		
	}
	/// @desc	Deactivates all instances created as part of this room.
	static deactivate	= function() {
		var _i = 0; repeat( array_length( entities.list )) {
			instance_deactivate_object( entities.list[ _i++ ] );
			
		}
		
	}
	/// @desc	Activates all instances created as part of this room.
	static activate	= function() {
		var _i = 0; repeat( array_length( entities.list )) {
			instance_activate_object( entities.list[ _i++ ] );
			
		}
		
	}
	/// @desc	Cleans up all layers and instances created by this room.
	static destroy	= function() {
		activate();
		var _i = 0; repeat( array_length( layers.byId )) {
			layer_destroy( layers.byId[ _i++ ].layer );
			
		}
		var _i = 0; repeat( array_length( entities.list )) {
			instance_destroy( entities.list[ _i++ ] );
			
		}
		layers	= undefined;
		entities= undefined;
		
	}
	/// @desc	Returns if the given rectangle overlaps this room. Useful for checking if
	///		the room is in view of a camera.
	static rectInRoom	= function( _l, _t, _r, _b ) {
		return rectangle_in_rectangle( _l, _t, _r, _b, x, y, x + width - 1, y + height - 1 );
		
	}
	/// @desc	Returns if the given rectangle overlaps this room. Useful for checking if a
	///		interaction is taking place in this room.
	static pointInRoom	= function( _x, _y ) {
		return point_in_rectangle( _x, _y, x, y, x + width - 1, y + height - 1 );
		
	}
	static restart	= function() {
		destroy();
		
		layers	= {
			"byId"	: array_create( array_length( level.layers.byId )),
			"byKey"	: {}
		}
		entities= {
			"byLayer"	: {},
			"list"		: [],
		};
		build( level );
		
	}
	static build	= function( _level ) {
		var _i = 0; repeat( array_length( layers.byId )) {
			var _layer	= _level.layers.byId[ _i++ ];
			var _target	= mappings[$ _layer.id ] ?? layer_create( _i * 100 );
			var _result;
			
			switch( _layer.type ) {
				case "Entities" :
					var _entities	= _layer.entities;
					var _list		= [];
					
					entities.byLayer[$ _layer.id ]	= _list;
					
					var _j = 0; repeat( array_length( _entities )) {
						var _entity	= _entities[ _j++ ];
						var _inst	= _entity.create( _target, x, y );
						
						array_push( entities.list, _inst );
						array_push( _list, _inst );
						
					}
					_result	= { "layer" : _target, "tilemap" : undefined }
					
					break;
					
				default :
					var _tilemap= layer_tilemap_create( _target, x, y, _layer.tileset.index, _level.width, _level.height );
					var _tx = 0, _ty = 0;
					
					var _j = 0; repeat( array_length( _layer.tiles )) {
						tilemap_set( _tilemap, _layer.tiles[ _j++ ], _tx, _ty );
						if ( ++_tx == _layer.width ) {
							_tx	= 0;
							_ty	+= 1;
							
						}
						
					}
					_result	= { "layer" : _target, "tilemap" : _tilemap }
					
					break;
					
			}
			layers.byId[ _i - 1 ]		= _result;
			layers.byKey[$ _layer.id ]	= _result;
			
		}
		signal( "start" );
		
	}
	/// @param {Struct.LDtkLoader} _loader
	/// @desc	This function facillitates the "live reloading" of LDtk files
	///		during development.  When called, will read the data from the provided
	///		loader to create missing layers, add new ones, as well as add or remove
	///		any new instances.  Note this is NOT the same as restarting the room
	///		which does the same thing but "from scratch."
	static reload	= function( _loader ) {
		var _layers	= _loader.levels.byKey[$ source ].layers.byId;
		
		var _i = 0; repeat( array_length( _layers )) {
			var _layer	= _layers[ _i++ ];
			var _target	= layers.byId[ _i - 1 ];
			
			switch( _layer.type ) {
				case "Entities" :
					var _list	= entities.byLayer[$ _layer.id ];
					var _j = 0; repeat( array_length( _layer.entities )) {
						if ( array_find_index( _list, method({ "e" : _layer.entities[ _j++ ].iid }, function( _v ) { return _v.iid == e; })) > -1 )
							continue;
						var _inst	= _layer.entities[ _j - 1 ].create( _target.layer, x, y );
						array_push( _list, _inst );
						array_push( entities.list, _inst );
						
					}
					break;
					
				default :
					var _tilemap= _target.tilemap;
					var _tx = 0, _ty = 0;
				
					var _j = 0; repeat( array_length( _layer.tiles )) {
						tilemap_set( _tilemap, _layer.tiles[ _j++ ], _tx, _ty );
						if ( ++_tx == _layer.width ) {
							_tx	= 0;
							_ty	+= 1;
						
						}
					
					}
					break;
				
			}
			
		}
		signal( "reload" );
		
	}
	static signal	= function( _line, _value = undefined ) {
		var _signals	= signals[$ _line ] ?? [];
		var _i = 0; repeat( array_length( _signals )) {
			_signals[ _i++ ]( _value );
			
		}
		
	}
	static listen	= function( _line, _method ) {
		signals[$ _line ] ??= [];
		
		array_push( signals[$ _line ], _method );
		
		return _method;
		
	}
	static unlisten	= function( _line, _method ) {
		signals[$ _line ] ??= [];
		
		array_filter_ext( signals[$ _line ], method({ "v" : _method }, function( _v ) {
			return _v == v;
			
		}));
		
	}
	static hidden	= false;
	
	layers	= {
		"byId"	: array_create( array_length( _level.layers.byId )),
		"byKey"	: {}
	}
	entities= {
		"byLayer"	: {},
		"list"		: [],
	};
	
	x		= _x;
	y		= _y;
	width	= _level.width;
	height	= _level.height;
	source	= _level.id;
	level	= _level;
	signals	= {};
	mappings= _mappings;
	
	build( _level );
	
}
