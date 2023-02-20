/// @param {struct} _source	The source LDtk struct for this level.
/// @param {struct} _objects	An object map to look up LDtk Entities in.
/// @param {struct} _uids	A struct of unique ids for LDtk assets.
/// @desc	Created by LDtkLoader from LDtk json data.  Trying to create one of these
///		via raw data is not recommended, though it is possible if you provide a properly
///		formatted LDtk level struct.
function LDtkLevel( _source, _objects, _uids ) constructor {
	/// @param {real} _x	The x position to instantiate at.
	/// @param {real} _y	The y position to instantiate at.
	/// @desc	Instantiates the level by creating layers and instances as described
	///		by the LDtk data.  If no _x or _y is provided, these will be done relative
	///		to the absolute position in LDtk.
	static create	= function( _x = x, _y = y ) {
		return new LDtkRoom( _x, _y, self );
		
	}
	id		= string( _source.identifier );
	uid		= string( _source.uid );
	iid		= string( _source.iid );
	x		= real( _source.worldX );
	y		= real( _source.worldY );
	z		= real( _source.worldDepth );
	width	= real( _source.pxWid );
	height	= real( _source.pxHei );
	neighbors	= array_map( _source.__neighbours, function( _v ) { return _v; });
	layers	= { byId : array_create( array_length( _source.layerInstances )), byKey: {}};
	fields	= {};
	
	ldtk_parse_field_instances( _source.fieldInstances, fields, _uids );
	
	var _layers	= _source.layerInstances;
	var _i = 0; repeat( array_length( _layers )) {
		var _layer	= new LDtkLayer( _layers[ _i++ ], _objects, _uids );
		layers.byId[ _i - 1 ]					= _layer;
		layers.byKey[$ _layer.id ]	= _layer;
		
	}
	
}
