--a lua script that replaces the __BROTLI_CDEF_I__ with the contents of brotli-cdef.i so i can use syntax highlighting while writing the cdefs

local io = require "io"
local function readfile(file)
	local file = assert(io.open(file, 'r'))
	local contents = assert(file:read('*a'))
	file:close()
	return contents
end

local brotli_pre = readfile("brotli-pre.lua")
local brotli_cdef = readfile("brotli-cdef.i")

local result = brotli_pre:gsub("__BROTLI_CDEF_I__", brotli_cdef)
io.write(result)
