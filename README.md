# LDtk-GM
 A simple LDtk-to-GM interpreter.

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
