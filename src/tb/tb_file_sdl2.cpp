// ================================================================================
// ==      This file is a part of Turbo Badger. (C) 2011-2014, Emil Segerås      ==
// ==                     See tb_core.h for more information.                    ==
// ================================================================================

#include "tb_system.h"

#ifdef TB_FILE_SDL2

#ifdef SDL_FRAMEWORK
#include "SDL2/SDL.h"
#else
#include "SDL.h"
#endif

namespace tb {

class TBFileSDL2 : public TBFile
{
public:
	TBFileSDL2(SDL_RWops *f) : _file(f) {}
	virtual ~TBFileSDL2() { SDL_RWclose(_file); }

	virtual long Size()
	{
		return (long)SDL_RWsize(_file);
	}
	virtual size_t Read(void *buf, size_t elemSize, size_t count)
	{
		return SDL_RWread(_file, buf, elemSize, count);
	}
	virtual size_t Write(const void *buf, size_t elemSize, size_t count)
	{
		return SDL_RWwrite(_file, buf, elemSize, count);
	}
	virtual size_t Write(const TBStr & str)
	{
		return Write(str.CStr(), str.Length(), 1);
	}
private:
	SDL_RWops *_file;
};

// static
TBFile *TBFile::Open(const TBStr & filename, TBFileMode mode)
{
	SDL_RWops *f = nullptr;
	switch (mode)
	{
	case MODE_READ:
		f = SDL_RWFromFile(filename.CStr(), "rb");
		break;
	case MODE_WRITETRUNC:
		f = SDL_RWFromFile(filename.CStr(), "w");
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
	TBFileSDL2 *tbf = new TBFileSDL2(f);
	if (!tbf)
		SDL_RWclose(f);
	return tbf;
}

} // namespace tb

#endif // TB_FILE_POSIX
