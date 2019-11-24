// ================================================================================
// ==      This file is a part of Turbo Badger. (C) 2011-2014, Emil Segerås      ==
// ==                     See tb_core.h for more information.                    ==
// ================================================================================

#ifndef TB_STYLE_EDIT_CONTENT_H
#define TB_STYLE_EDIT_CONTENT_H

#include "tb_core.h"

namespace tb {

class TBTextFragment;

/** Content for a non-text TBTextFragment. */

class TBTextFragmentContent
{
public:
	virtual ~TBTextFragmentContent() {}

	/** Update the position of the content, relative to the first line of text (no scrolling applied). */
	virtual void UpdatePos(const TBBlock * block, int /*x*/, int /*y*/) {}

	virtual void Paint(const TBPaintProps *props, TBTextFragment *fragment) {}
	virtual void Click(const TBBlock *block, TBTextFragment *fragment, int button, uint32_t modifierkeys) {}
	virtual int32_t GetWidth(const TBBlock *block, TBFontFace *font, TBTextFragment *fragment) { return 0; }
	virtual int32_t GetHeight(const TBBlock *block, TBFontFace *font, TBTextFragment *fragment) { return 0; }
	virtual int32_t GetBaseline(const TBBlock *block, TBFontFace *font, TBTextFragment *fragment) { return GetHeight(block, font, fragment); }
	virtual bool GetAllowBreakBefore(const TBBlock *block) { return true; }
	virtual bool GetAllowBreakAfter(const TBBlock *block) { return true; }

	/** Get type of fragment content. All standard fragments return 0. */
	virtual uint32_t GetType()		{ return 0; }
};

/** A horizontal line for TBStyleEdit. */

class TBTextFragmentContentHR : public TBTextFragmentContent
{
public:
	TBTextFragmentContentHR(int32_t width_in_percent, int32_t height);

	virtual void Paint(const TBPaintProps *props, TBTextFragment *fragment);
	virtual int32_t GetWidth(const TBBlock *block, TBFontFace *font, TBTextFragment *fragment);
	virtual int32_t GetHeight(const TBBlock *block, TBFontFace *font, TBTextFragment *fragment);
private:
	int32_t width_in_percent, height;
};

/** Fragment content that enables underline in a TBStyleEdit */

class TBTextFragmentContentUnderline : public TBTextFragmentContent
{
public:
	TBTextFragmentContentUnderline() {}
	virtual void Paint(const TBPaintProps * props, TBTextFragment * fragment);
	virtual bool GetAllowBreakBefore(const TBBlock *block) { return true; }
	virtual bool GetAllowBreakAfter(const TBBlock *block) { return false; }
};

/** Fragment content that changes color in a TBStyleEdit */

class TBTextFragmentContentTextColor : public TBTextFragmentContent
{
public:
	TBColor color;
	TBTextFragmentContentTextColor(const TBColor &color) : color(color) {}
	virtual void Paint(const TBPaintProps * props, TBTextFragment * fragment);
	virtual bool GetAllowBreakBefore(const TBBlock *block) { return true; }
	virtual bool GetAllowBreakAfter(const TBBlock *block) { return false; }
};

/** Fragment content that changes size in a TBStyleEdit */

class TBTextFragmentContentTextSize : public TBTextFragmentContent
{
public:
	uint32_t _size;
	TBTextFragmentContentTextSize(uint32_t size) : _size(size) {}
	virtual void Paint(const TBPaintProps * props, TBTextFragment * fragment);
	//virtual int32_t GetHeight(TBFontFace * font, TBTextFragment * /*fragment*/);
	virtual bool GetAllowBreakBefore() { return true; }
	virtual bool GetAllowBreakAfter() { return false; }
};

/** Fragment content that changes size in a TBStyleEdit */

class TBTextFragmentContentSuperscript : public TBTextFragmentContent
{
public:
	uint32_t _size;
	TBTextFragmentContentSuperscript() {}
	virtual void Paint(const TBPaintProps * props, TBTextFragment * fragment);
	//virtual int32_t GetHeight(TBFontFace * font, TBTextFragment * /*fragment*/);
};

/** Fragment content that changes size in a TBStyleEdit */

class TBTextFragmentContentSubscript : public TBTextFragmentContent
{
public:
	uint32_t _size;
	TBTextFragmentContentSubscript() {}
	virtual void Paint(TBTextFragment *fragment, int32_t translate_x, int32_t translate_y, TBTextProps *props) {}
	//virtual int32_t GetHeight(TBFontFace * font, TBTextFragment * /*fragment*/);
};

/** Fragment content that ends a change of style in a TBStyleEdit */

class TBTextFragmentContentStylePop : public TBTextFragmentContent
{
public:
	virtual void Paint(const TBPaintProps * props, TBTextFragment * fragment);
	virtual bool GetAllowBreakBefore(const TBBlock * block) { return false; }
	virtual bool GetAllowBreakAfter(const TBBlock * block) { return true; }
};

} // namespace tb

#endif // TB_STYLE_EDIT_CONTENT_H
