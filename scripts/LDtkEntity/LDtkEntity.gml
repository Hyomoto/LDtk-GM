/// @param {struct} _source	The source LDtk struct for this layer.
/// @param {Asset.GMObject} _index	The GM object associated with this entity.
/// @param {struct} _uids	A struct of unique ids for LDtk assets.
/// @desc	Created by LDtkLayer from LDtk json data.  Trying to create one of these
///		via raw data is not recommended, though it is possible if you provide a properly
///		formatted LDtk entity struct and accompanying GM object.
function LDtkEntity( _source, _index, _uids ) constructor {
	/// @param {Id.Layer} _layer
	static create	= function( _layer, _x = 0, _y = 0 ) {
		var _fields	= fields;
		
		with( instance_create_layer( x + _x, _y + y, _layer, index )) {
			var _keys	= variable_struct_get_names( _fields );
			var _i = 0; repeat( array_length( _keys )) {
				self[$ _keys[ _i ]]	= _fields[$ _keys[ _i ]];
				
			}
			image_xscale	= sprite_index == -1 ? 1 : sprite_get_width( sprite_index ) / other.width;
			image_yscale	= sprite_index == -1 ? 1 : sprite_get_height(sprite_index ) / other.height;
			
			return id;
			
		}
		
	}
	id		= string( _source.__identifier );
	uid		= string( _source.defUid );
	iid		= string( _source.iid );
	index	= _index; //_objectMap[$ _source.__identifier ];
	x		= real( _source.px[ 0 ] );
	y		= real( _source.px[ 1 ] );
	width	= real( _source.width );
	height	= real( _source.height );
	fields	= { "iid" : _source.iid }
	
	ldtk_parse_field_instances( _source.fieldInstances, fields, _uids );
	
}
