// ================================================================================
// ==      This file is a part of Turbo Badger. (C) 2011-2014, Emil Segerås      ==
// ==                     See tb_core.h for more information.                    ==
// ================================================================================

#include "tb_system.h"

#ifdef TB_FILE_SDL3

#include <SDL3/SDL.h>

namespace tb {

class TBFileSDL3 : public TBFile
{
public:
	TBFileSDL3(SDL_IOStream *f) : _file(f) {}
	virtual ~TBFileSDL3() { SDL_CloseIO(_file); }

	virtual long Size()
	{
		return (long)SDL_GetIOSize(_file);
	}
	virtual size_t Read(void *buf, size_t elemSize, size_t count)
	{
		return SDL_ReadIO(_file, buf, elemSize * count) / elemSize;
	}
	virtual size_t Write(const void *buf, size_t elemSize, size_t count)
	{
		return SDL_WriteIO(_file, buf, elemSize * count) / elemSize;
	}
	virtual size_t Write(const TBStr & str)
	{
		return Write(str.CStr(), str.Length(), 1);
	}
private:
	SDL_IOStream *_file;
};

// static
TBFile *TBFile::Open(const TBStr & filename, TBFileMode mode)
{
	SDL_IOStream *f = nullptr;
	switch (mode)
	{
	case MODE_READ:
		f = SDL_IOFromFile(filename.CStr(), "rb");
		break;
	case MODE_WRITETRUNC:
		f = SDL_IOFromFile(filename.CStr(), "w");
		break;
	default:
		break;
	}
#if defined(TB_RUNTIME_DEBUG_INFO) && 1
	if (!f) {
		//char tmp[256];
		//TBDebugPrint("Cwd: '%s'\n", getcwd(tmp, sizeof(tmp)));
		//TBDebugPrint("TBFile::Open, unable to open file '%s'\n", filename.CStr());
	}
#endif
	if (!f)
		return nullptr;
	TBFileSDL3 *tbf = new TBFileSDL3(f);
	if (!tbf)
		SDL_CloseIO(f);
	return tbf;
}

} // namespace tb

#endif // TB_FILE_SDL3
