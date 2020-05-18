# brotli-luajit
[brotli](https://brotli.org/) binding using luajit ffi

# make
make brotli.lua using `luajit brotli-make.lua > brotli.lua`  
alternatively, use the included precompiled brotli.lua that i preprocessed for your convenience :)

# compress
you might want to take a look at the compress function in brotli-pre.lua. it has both an ordered argument interface and a table interface.

for modes you can pass these constants: 'default', 'generic', 'text', or 'font'. for a tiny bit of extra speed you can use  `brotli.modes.default`, or other constant.

`nil` picks the default.

this wrapper reuses the same buffer for compression. if you think you have compressed a large file and you dont want to keep those buffers around you can call `brotli.cleanup()` and the buffers will be `nil`ed out

# decompress
idk i havent written this part yet

# todo
* work on chunk api
* enough with the mud abuse
* write decompression wrappers
