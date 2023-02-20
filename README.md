# LDtk-GM
 A simple LDtk-to-GM interpreter. Check the [Wiki](https://github.com/Hyomoto/LDtk-GM/wiki) for more detailed information.

## Philosophy
* LDtk-GM will convert LDtk data into GM layers, tilemaps and objects.  It usually allows the user to continue working with GM rooms, layers and instances the same way they would if LDtk were *not* being used.  If you create a "Entities" layer in LDtk, an "Entities" layer will be created in GM and can be used to spawn instances just as you would expect.  If you just want to use LDtk as a replacement for GM's rooms, you can easily do so.  However, thanks to the flexibility of the LDtk format and mappings, we can do some interesting things.  For example, if you wanted to make a bunch of "room pieces" in LDtk, you can set up some layer mappings and spawn them all into different positions on the same layers to build your maps.  This allows you to treat many LDtk levels as a single "room" in GM and opens up many possibilities.

* To facilitate rapid iteration and development, LDtk-GM also includes a file watcher which can detect changes to source files and reload them automatically.  This is not necessarily a feature of LDtk, but is included for development convenience.

* For simplicity, LDtk-GM does *not* use "Let it crash" design philosophy.  Any discovered errors will be indicated via the Output in GM, and are usually skipped.  For example, if a layer uses a tileset that hasn't been defined (and can't be discovered), that layer will simply not be loaded.  This ensures that live development can be done safely and mistakes can be fixed without large interruptions.

## Usage
The primary source of interaction is the LDtkLoader.  Start by making one:
```GML
loader = new LDtkLoader();
```
Now, we can use it to open an .ldtk file somewhere:
```GML
loader.open( "mygame.ldtk" );
```
By default, the LDtkLoader will try to convert LDtk Tilemaps and Entities into GM assets by name.  If a matching asset can be found, it will be used.  However, this is not usually a friendly solution as naming conventions in GML and LDtk aren't the same.  In this case, you can specify mappings to tell GM which assets it should be using.  You can pass these mappings in via the open() method, or define them directly:
```GML
loader.mappings.objects = { "Goblin" : objGoblin, "Chest" : objChest }
loader.mappings.tilesets= { "Castle" : tsCastleFg, "Shrubs" : tsShubs }
```
The mappings are simple key-value pairs where the key is the name of the LDtk asset, and the value is the Gamemaker asset index.

Lastly, to actually *create* your LDtk Level in GM you must look up the level and create it.  All levels are stored in `levels` on the loader:
```GML
level = loader.levels.byKey[$ "Level_0" ].create(0,0);
```
You can look up levels by their id, or index, using `byId`, the order they were stored in the project file, or `byKey` which will look the level up by the name.  The create function is called to instantiate the room and will return a LDtkRoom which represents the "live" data created.  It is provided for convenience and to facillitate live reloading.  For example, you can call `restart()` to clear all the instances and layers created, and then recreate them.  This behaves like `room_restart()` would except it only affects instances and layers created by the loader.

## File Watcher
The file watcher is used to reload changed files automatically.  When using the file watcher you can either provide a specific file, or a file mask.
```GML
loader.watch( "levels.ldtk" );
```
When a mask is used, *all* files matching that mask will be included in the watcher.  This can be used, for example, to include all files in a directory.  If you are using the separate files option in LDtk, you can use this to include all of them in the watcher easily.
```GML
loader.watch( "levels\\" );
```
This can be a powerful development tool, but two performance considerations should be had.  First off, if you have a large ldtk file, you should use the "separate levels" option instead as reloading one very large file each time a small change in a level is made could cause performance issues.  Secondly, the file watcher isn't optimized for use outside of development.  If you are having performance issues with the file watcher you have a few options.  The simplest is to only watch the file(s) you are editing, rather than all the files in your LDtk world.

By default, the watcher ticks every half second.  You can modify LDTK_WATCHER_TICK_RATE if you would like it to do so more or less often.  Lastly, the watcher *only* runs if called.  To turn it off, simply do not call it at all.  However, should you wish to pause or stop it manually, it is a GML time source and can be accessed through the `watcher` parameter of your LDtkLoader.

## Signals
While LDtk-GM tries to leverage as much of GM as possible, there are some events that are unique to LDtk and must be handled differently.  For example, while the file watcher automatically reload files when they change, this does not trigger LDtkRooms to restart or update.  Both LDtkLoader and LDtkRoom make use of "signals" to allow you to add code you want to run when certain events occur.  For those familiar, it is a simple pub-sub system.
```GML
loader.listen( "reload", function( _v ) { show_debug_message( _v )});
```
This would print the name of the level that reloaded to the output log. The signals produced by the LDtkLoader are:
* open - Called when LDtkLoader finishes an open operation.
* reload - When a level is reloaded, this signal is called and the level id will be passed as an argument.  If multiple levels were reloaded, this signal will be sent multiple times for each.
Additionally, an LDtkRoom also produces signals:
* start - Called when the room is created, or restarted.
* reload- Called when the room is reloaded.  See [reloading rooms](#reloading-rooms) for more.

As denoted above, signals can be "listened" to by calling `listen` on the loader/room and providing a method to call:
```GML
loader.listen( "reload", function( _v ) {
  if ( _v == level.id )
    level.reload( loader );
});
```
In this case, if the level reloaded was the current level, we call for the room to be reloaded.  If you want your levels to update in real time, this is the basis of making that happen.  The other major event is the LDtkRoom "start" signal.  Because instances created after a room exists do not trigger Room Start events, and this object event is often desirable to set up variables correctly, listening to the "start" signal we can mimic this behavior:
```GML
loader.listen( "start", function() {
  array_foreach( level.entities.list, function( _v ) {
    with( _v ) { event_perform( ev_other, ev_room_start ); }
  });
});
```
This will loop through all of the level entities and call the Room Start event on them.

## Reloading Rooms
Reloading rooms is a developer-oriented feature that allows changes in the LDtkLevel to be represented in the LDtkRoom.  From a technical perspective, all tilemaps will be rebuilt, and any instances that are *new* will be created.  This can be useful but it is important to understand this could cause problems.  While LDtkLoader tries to recover from errors, it offers no protection for your *game*.  Thus, a reload might cause errors or a crash you wouldn't normally experience.  In these cases you might opt to restart an LDtkRoom instead, which will clean up everything and rebuild it from scratch, much like `room_restart()`.

## Limitations
LDtk-GM supports most of LDtk's native features.  Notable exceptions are below:
* Tile-stacking - Safe to use, however only the *top* tile will end up being rendered.  This is because GM tilemaps do not support tile stacking, and thus the last tile written will be the tile that is displayed.
* Multi-world - Currently this feature is not supported and enabling it will cause issues.  In the future support will be added.
