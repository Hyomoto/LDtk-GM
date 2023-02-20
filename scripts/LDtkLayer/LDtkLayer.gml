/// @param {struct} _source	The source LDtk struct for this layer.
/// @param {struct} _objects	An object map to look up LDtk Entities in.
/// @param {struct} _uids	A struct of unique ids for LDtk assets.
/// @desc	Created by LDtkLevel from LDtk json data.  Trying to create one of these
///		via raw data is not recommended, though it is possible if you provide a properly
///		formatted LDtk layer struct.
function LDtkLayer( _source, _objects, _uids ) constructor {
	id		= string( _source.__identifier );
	type	= string( _source.__type );
	width	= real( _source.__cWid );
	height	= real( _source.__cHei );
	size	= real( _source.__gridSize  );
	offsetX	= real( _source.__pxTotalOffsetX );
	offsetY	= real( _source.__pxTotalOffsetY );
	entities= [];
	intGrid	= [];
	tiles	= [];
	tileset	= -1;
	
	switch( type ) {
		case "Entities"	:
			var _i = 0; repeat( array_length( _source.entityInstances )) {
				var _entity	= _source.entityInstances[ _i++ ];
				var _index	= _objects[$ _entity.__identifier ];
				
				if ( is_undefined( _index ))
					continue; // need some way to propagate errors upwards, or just handle it here
				array_push( entities, new LDtkEntity( _entity, _index,  _uids ));
				
			}
			break;
			
		case "AutoLayer" : case "IntGrid" :
			intGrid	= _source.intGridCsv;
			
		case "Tiles" :
			var _tiles	= ( _source.__type == "Tiles" ? _source.gridTiles : _source.autoLayerTiles );
			
			if ( _source.__tilesetDefUid != pointer_null && _source.__tilesetDefUid < array_length( _uids.byId ))
				tileset	= _uids.byId[ _source.__tilesetDefUid ];
			tiles	= array_create( width * height, 0 );
			
			var _j = 0; repeat( array_length( _tiles )) {
				var _tile	= _tiles[ _j++ ];
				var _x	= _tile.px[ 0 ] div size;
				var _y	= _tile.px[ 1 ] div size;
				var _t	= _tile.t;
				
				if ( _tile.f & 0x1 > 0 ) _t	= tile_set_mirror( _t, true );
				if ( _tile.f & 0x2 > 0 ) _t	= tile_set_flip( _t, true );
				
				tiles[ _x + width * _y ]	= _t;
				
			}
			break;
		
	}
	
}
