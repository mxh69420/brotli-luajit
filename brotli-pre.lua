local ffi = require "ffi"
local C, cast, ffi_gc, ctol = ffi.C, ffi.cast, ffi.gc, ffi.string
local type = type

local size_t	= ffi.typeof "size_t"
local size_p	= ffi.typeof "size_t[1]"
local intptr_t	= ffi.typeof "intptr_t"
local int8_p	= ffi.typeof "int8_t*"

ffi.load("brotlienc", true)
--ffi.load("brotlidec", true) --todo
--ffi.load("brotlicommon", true) --todo

local function malloc(size) --a quick helper function wrapping malloc
	local ret = int8_p(C.malloc(size))
	assert(cast(intptr_t, ret) ~= 0, "cant allocate memory")
	ffi_gc(ret, C.free)
	return ret
end

local brotli = {}

ffi.cdef[[__BROTLI_CDEF_I__]]

local brotli_constants 		= ffi.new "struct brotli_constants"
local brotli_modes 		= ffi.new "struct brotli_modes"
local brotli_encoder_parameters	= ffi.new "struct brotli_encoder_parameters"

brotli.constants		= brotli_constants
brotli.modes			= brotli_modes
brotli.encoder_parameters	= brotli_encoder_parameters

--	size_t BrotliEncoderMaxCompressedSize(size_t) __attribute__((const));
--	reimplemented so lua can optimize better
local bit = require "bit"
local rshift = bit.rshift
local function max_compressed_size(size) --> size_t cdata, please use tonumber if needed
	--[[	getting wrong answers around 4.2b (maybe 0xffffffff?) without this line
		its also profiling faster for me
		probably using integer registers now
	]]
	size = size_t(size)

	if size == 0 then return 2 end

	local num_large_blocks = rshift(size, 14)
	local overhead = (4 * num_large_blocks) + 6 --does luajit collapse operators in bytecode?
	local result = size + overhead

	return result < size and 0 or result
end
brotli.max_compressed_size = max_compressed_size

local function _compress_wrap(quality, lgwin, mode, input_size, input_buffer, encoded_size, encoded_buffer)

	encoded_size = size_p(encoded_size)

	local ret = C.BrotliEncoderCompress(quality, lgwin, mode, input_size, input_buffer, encoded_size, encoded_buffer)
	return ret == 0 and nil or encoded_size[0]
end
brotli.compress_raw = _compress_wrap

local function _compress_string(quality, lgwin, mode, input, buffer_size, buffer)
	local needs_size = max_compressed_size(#input)

	if not buffer or needs_size > buffer_size then
		buffer_size = needs_size
		buffer = malloc(needs_size)
	end

	return _compress_wrap(quality, lgwin, mode, #input, input, buffer_size, buffer), buffer_size, buffer
end

local current_buffer, current_buffer_size

local function compress(quality, lgwin, mode, input)
	if type(quality) == 'table' then
	  --we are actually passing a table of options
		local options = quality

		return compress(
			options.quality,
			options.lgwin,
			options.mode,
			options.input or options[1]
		)
	end

	quality = quality or brotli_constants.default_quality
	lgwin 	= lgwin or brotli_constants.default_window

	if not mode then
		mode = brotli_modes.default
	elseif type(mode) == 'string' then
		mode = brotli_modes[mode]
	end

	local size, buffer_size, buffer = _compress_string(quality, lgwin, mode, input, current_buffer_size, current_buffer)
	current_buffer = buffer
	current_buffer_size = buffer_size

	--nil is returned in place of size if failed
	assert(size, "brotli returned false")

	return ctol(buffer, size)
end
brotli.compress = compress
function brotli.cleanup() --frees current buffer
	current_buffer = nil
	current_buffer_size = nil
end

return brotli
