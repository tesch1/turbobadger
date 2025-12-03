// ================================================================================
// ==      This file is a part of Turbo Badger. (C) 2011-2014, Emil Segerås      ==
// ==                     See tb_core.h for more information.                    ==
// ================================================================================

#include "tb_system.h"

#ifdef TB_CLIPBOARD_SDL3

#define GL_GLEXT_PROTOTYPES 1

#include <SDL3/SDL.h>

namespace tb {

// == TBClipboard =====================================

void TBClipboard::Empty()
{
	SetText("");
}

bool TBClipboard::HasText()
{
	return SDL_HasClipboardText();
}

bool TBClipboard::SetText(const TBStr & text)
{
	return (0 == SDL_SetClipboardText((const char *)text));
}

bool TBClipboard::GetText(TBStr &text)
{
	if (const char *str = SDL_GetClipboardText())
		return text.Set(str);
	return false;
}

} // namespace tb

#endif // TB_CLIPBOARD_SDL3
