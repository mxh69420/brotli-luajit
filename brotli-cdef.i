void *malloc(size_t);
void free(void *);

struct brotli_constants {
	static const int default_mode		=  0;
	static const int default_quality	= 11;
	static const int default_window		= 22;
	static const int max_input_block_bits	= 24;
	static const int max_quality		= 11;
	static const int max_window_bits	= 24;
	static const int min_input_block_bits	= 16;
	static const int min_quality		=  0;
	static const int min_window_bits	= 10;
};

struct brotli_modes {
	static const int default		=  0;
	static const int generic		=  0;
	static const int text			=  1;
	static const int font			=  2;
};

struct brotli_encoder_parameters {
	static const int mode			=  0;
	static const int quality		=  1;
	static const int lgwin			=  2;
	static const int lgblock		=  3;
	static const int disable_literal_context_modeling =  4;
	static const int size_hint		=  5;
};

typedef int BROTLI_BOOL;

BROTLI_BOOL BrotliEncoderCompress(int, int, int, size_t, const int8_t *, size_t *, int8_t *);
