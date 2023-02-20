/// @param {bool} _verbose	If true, outputs extra text during loading operations.
/// @desc	Used to read LDtk files into GM-friendly structs and arrays.
function LDtkLoader( _verbose = false ) constructor {
	/// @param {string} _filename	The name of the file to load.
	/// @param {struct} _tilesetMap	A struct containing key value pairs. The key should be the name of the tileset in LDtk, while the value is the index of the GM tileset asset.
	/// @param {struct} _objectMap	A struct containing key value pairs. The key should be the name of the entity in LDtk, while the value is the index of the GM object asset.
	/// @desc	Tries to open the provided filename with the given mappings.  Returns
	///		whether any errors occurred during loading.  This will not automatically
	///		crash the program, though crashes may be *likely* should missing data be
	///		referenced later.  If a mapping is not provided, the loader will try to
	///		convert LDtk asset names into GM ones.  If an asset can not be found, the
	///		layer/entity will be skipped entirely and an error shown.
	/// @returns {bool}
	static open	= function( _filename, _tilesetMap = mappings.tileset, _objectMap = mappings.objects ) {
		static tools	= new ( function() constructor {
			static readFile	= function( _filename ) {
				if ( file_exists( _filename ) == false )
					throw new LDtkError( LDtkException.FileNotFound, "Couldn't find '%'.  Is the filename spelled wrong?", _filename );
				var _file	= buffer_load( _filename );
				
				if ( _file == -1 )
					throw new LDtkError( LDtkException.FileAccessFailed, "Read to '%' was rejected.  OS did not grant permission to access file.", _filename );
				
				try { var _json = json_parse( buffer_read( _file, buffer_text )); }
				catch ( _ ) { throw new LDtkError( LDtkException.BadJSONFormat, "Couldn't decode '%', bad JSON format.", _filename ); }
				
				if ( _json[$ "__header__" ] == undefined )
					throw new LDtkError( LDtkException.BadLDtkFormat, "Format for '%' not recognized. Is this an LDtk file?", _filename );
				buffer_delete( _file );
				
				return _json;
				
			}
			static showError	= function( _message ) {
				var _i = 1; repeat( argument_count - 1 ) {
					_message	= string_replace( _message, "%", argument[ _i++ ] );
				}
				show_debug_message( "LDtkLoader :: " + _message );
				error	= true;
				
			}
			static say	= function( _message ) {
				var _i = 1; repeat( argument_count - 1 ) {
					_message	= string_replace( _message, "%", argument[ _i++ ] );
				}
				show_debug_message( "LDtkLoader :: " + _message );
				
			}
			static hasString	= function( _array, _value ) {
				return array_find_index( _array, method({ "v" : string_lower( _value )}, function( _v ) { return string_lower( _v ) == v; })) > -1;
				
			}
			static parseEnums	= function( _enums, _uids ) {
				var _result	= {};
				var _i = 0; repeat( array_length( _enums )) {
					var _enum	= _enums[ _i++ ];
					var _out	= {};
					var _values	= _enum.values;
					var _flags	= hasString( _enum.tags, "flags" );
					var _j = 0; repeat( array_length( _values )) {
						_out[$ _values[ _j ].id ] = _flags ? 1 << _j : _j; ++_j;
					
					}
					_uids.byId[ _enum.uid ]			= _out;
					_uids.byKey[$ _enum.identifier ]= _out;
					_result[$ _enum.identifier ]	= _out;
				
				}
				return _result;
			
			}
			static parseTilesets	= function( _tilesets, _tilesetMap, _uids ) {
				var _result	= {};
				var _i = 0; repeat( array_length( _tilesets )) {
					var _tileset	= _tilesets[ _i++ ];
					if ( hasString( _tileset.tags, "noimport" ))
						continue;
					var _out		= {
						"id"	: _tileset.identifier,
						"index" : _tilesetMap[$ _tileset.identifier ] ?? asset_get_index( _tileset.identifier ),
						"width"	: _tileset.__cWid,
						"height": _tileset.__cHei,
						"size"	: _tileset.tileGridSize,
						"flags"	: [],
						};
					
					if ( is_undefined( _out.index ) || _out.index == -1 ) {
						showError( "No match for tileset '%' exists. It was skipped.", _tileset.identifier );
						continue;
						
					}
					
					if ( _tileset.tagsSourceEnumUid != pointer_null ) {
						if ( _tileset.tagsSourceEnumUid < 0 || _tileset.tagsSourceEnumUid >= array_length( _uids.byId )) {
							showError( "Tileset '%' references enum which didn't exist.  Skipped.", _out.id );
							
						} else {
							var _enums		= _uids.byId[ _tileset.tagsSourceEnumUid ];
							var _enumTags	= _tileset.enumTags;
							var _flags		= array_create( _out.width * _out.height, 0 );
							
							var _j	= 0; repeat( array_length( _enumTags )) {
								var _enum	= _enumTags[ _j++ ];
								var _ids	= _enum.tileIds;
								var _value	= _enums[$ _enum[$ "enumValueId" ]];
								
								var _k = 0; repeat( array_length( _ids )) {
									_flags[ _ids[ _k++ ]] += _value;
									
								}
								
							}
							
						}
						_out[$ "flags" ]	= _flags;
						
					}
					_uids.byId[ _tileset.uid ]			= _out;
					_uids.byKey[$ _tileset.identifier ]	= _out;
					_result[$ _tileset.identifier ]	= _out;
					
				}
				return _result;
			
			}
			static parseLevels	= function( _levels, _external, _objectMap, _uids ) {
				var _result	= { byId : [], byKey : {}, byIid : {}};
				var _i = 0; repeat( array_length( _levels )) {
					var _level	= _external ? readFile( path + _levels[ _i++ ].externalRelPath ) : _levels[ _i++ ];
					var _out	= new LDtkLevel( _level, _objectMap, _uids );
					
					_out.source	= _external ? _levels[ _i - 1 ].externalRelPath : path;
					
					_uids.byId[ _level.uid ]			= _out;
					_uids.byKey[$ _level.identifier ]	= _out;
					_result.byId[ _i - 1 ]				= _out;
					_result.byKey[$ _level.identifier ]	= _out;
					_result.byIid[$ _level.iid ]		= _out;
					
				}
				return _result;
				
			}
			static open	= function( _self, _path ) {
				parent	= _self;
				error	= false;
				path	= _path ?? "";
				
			}
			parent	= self;
			error	= false;
			path	= "";
			
		})();
		
		var _json = tools.readFile( _filename );
		
		var _version	= _json[$ "jsonVersion" ];
		var _out		= undefined;
		var _uids		= { "byId" : [], "byKey" : {}};
		
		if ( verbose ) tools.say( "Opening '%', version '%'", _filename, _version );
		
		tools.open( self, filename_path( _filename ));
		
		enums	= tools.parseEnums( _json.defs.enums, _uids );
		tilesets= tools.parseTilesets( _json.defs.tilesets, _tilesetMap, _uids );
		levels	= tools.parseLevels( _json.levels, _json.externalLevels, _objectMap, _uids );
		
		path	= filename_path( _filename );
		source	= filename_name( _filename );
		
		mappings.tilesets	= _tilesetMap;
		mappings.objects	= _objectMap;
		
		uids	= _uids;
		
		signal( "open" );
		
		return tools.error;
		
	}
	/// @param {string} _levelId	The level to reload.
	/// @desc	Attempts to reload the level data from the source json.
	static reload	= function( _levelId ) {
		static readFile	= function( _filename ) {
			_filename	= string_replace_all( _filename, "/", "\\" );
			var _file	= buffer_load( _filename );
			if ( _file == -1 )
				return undefined;
			try { var _json = json_parse( buffer_read( _file, buffer_text )); }
			catch ( _ ) { throw new LDtkError( LDtkException.BadJSONFormat, "Couldn't decode '%', bad JSON format.", _filename ); }
			buffer_delete( _file );
			return _json;
			
		}
		var _json	= readFile( path + source );
		var _levels	= _json[$ "levels" ];
		var _i = 0; repeat( array_length( _levels )) {
			if ( _levels[ _i++ ].identifier != _levelId )
				continue;
			var _level	= _json.externalLevels ? readFile( path + _levels[ _i - 1 ].externalRelPath ) : _levels[ _i - 1 ];
			if ( is_undefined( _level ))
				continue;
			var _out	= new LDtkLevel( _level, mappings.objects, uids );
			
			uids.byId[ _level.uid ]				= _out;
			uids.byKey[$ _level.identifier ]	= _out;
			levels.byId[ _i - 1 ]				= _out;
			levels.byKey[$ _level.identifier ]	= _out;
			levels.byIid[$ _level.iid ]			= _out;
			
			break;
			
		}
		signal( "reload", _levelId );
		
	}
	static signal	= function( _line, _value ) {
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
	/// @param {string} ...	A filename or directory to watch.
	/// @desc	Starts the file watcher, as well as adds the specified files to the
	///		list of files to watch. Note that this only triggers the loader to reload
	///		the files.  To see the results in-game you would need an object to listen
	///		the "reload" signal and respond accordingly.
	static watch	= function() {
		watcher	??= ( function() { var _ts = time_source_create( time_source_global, 0.25, time_source_units_seconds, function() {
			array_foreach( watchList, function( _v ) {
				if ( sha1_file( path + _v.file ) == _v.hash )
					return;
				if ( _v == source ) {
					open( source );
					
				} else {
					var _name	= filename_name( _v.file );
					var _level	= string_copy( filename_name( _name ), 1, string_length( _name ) - string_length( filename_ext( _name )));
					reload( _level );
					_v.hash	= sha1_file( path + _v.file );
					
				}
				
			});
		}, [], -1 ); time_source_start( _ts ); return _ts; })();
		
		var _i = 0; repeat( argument_count ) {
			var _file	= argument[ _i++ ];
			if ( file_exists( path + _file )) {
				array_push( watchList, { "hash" : sha1_file( path + _file ), "file" : _file });
			
			} else if ( directory_exists( path + filename_path( _file ))) {
				var _dir	= filename_path( _file );
				var _mask	= filename_name( _file );
			
				var _next	= file_find_first( path + _dir + ( _mask == "" ? "*" : _mask ), 0 );
				while( _next != "" ) {
					array_push( watchList, { "hash" : sha1_file( path + _dir + _next ), "file" : _dir + _next });
					_next	= file_find_next();
				
				}
				file_find_close();
			
			}
			show_debug_message( "LDtk.watch :: Watching " + _file );
		
		}
		
	}
	/// @ignore
	verbose	= _verbose;
	levels	= { byId : [], byKey : {}, byIid : {}};
	enums	= {};
	tilesets= {};
	path	= "";
	source	= "";
	mappings= { "objects" : {}, "tilemaps": {}}
	uids	= { "byId" : [], "byKey" : {}};
	watcher	= undefined;
	watchList	= [];
	signals	= { "reload" : [ function( _v ) { if verbose show_debug_message( "LDtk::reload - " + string( _v ))} ] };
	
}
