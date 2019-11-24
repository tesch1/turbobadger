// ================================================================================
// ==      This file is a part of Turbo Badger. (C) 2011-2014, Emil Segerås      ==
// ==                     See tb_core.h for more information.                    ==
// ================================================================================

#ifndef TB_COLOR_H
#define TB_COLOR_H

#include "tb_types.h"
#include "tb_str.h"
#include "tb_id.h"
#include <map>

namespace tb {

class TBNode;
class TBSkin;

/** TBColor contains a 32bit color. */

class TBColor
{
public:
	TBColor() : b(0), g(0), r(0), a(255) {}
	TBColor(uint8_t r_, uint8_t g_, uint8_t b_, uint8_t a_ = 255) : b(b_), g(g_), r(r_), a(a_) {}
	TBColor(uint32_t bgra_) : bgra(bgra_) {}

	union {
		struct { uint8_t b, g, r, a; };
		uint32_t bgra;
	};

	void Set(const TBColor &color) { *this = color; }

	/** Set the color from string in any of the following formats:
		"#rrggbbaa", "#rrggbb", "#rgba", "#rgb" */
	void SetFromString(const TBStr & str);

	/** Write color to string with format #rrggbbaa */
	void GetString(TBStr & str) const;

	inline operator uint32_t () const		{ return bgra; }
	//inline bool operator == (const TBColor &c) const { return bgra == (uint32_t)c; }
	//inline bool operator != (const TBColor &c) const { return bgra != (uint32_t)c; }

	/** Premultiply alpha on the r, g, b components */
	inline void Premultiply() {
		const uint32_t a32 = a;
		r = (r * a32 + 1) >> 8;
		g = (g * a32 + 1) >> 8;
		b = (b * a32 + 1) >> 8;
	}

	/** Unpremultiply alpha on the r, g, b components */
	inline void Unpremultiply() {
		const uint32_t a32 = a;
		if (a32) {
			r = r * 255 / a32;
			g = g * 255 / a32;
			b = b * 255 / a32;
		}
	}
};

/** TBColorManager contains a map of global color names. */

class TBColorManager
{
public:

	/** Load a list of colors from a node. */
	void Load(TBNode *n, TBSkin *skin);

	/** Define a color, if not already defined. */
	bool Define(const TBStr & cid, TBColor color);

	/** Is the color defined? */
	bool IsDefined(const TBStr & cid) { return 0 != _id2color.count(cid); }

	/** Is the color defined? */
	bool IsDefined(const TBColor & color) { return 0 != _color2id.count(color); }

	/** (Re)Define a color, no matter what. */
	void ReDefine(const TBStr & cid, TBColor color);

	/** Clear the list of colors. */
	void Clear();

	/** Return the color with the given id.
	 * If there is no color with that id, 0 will be returned.
	 */
	TBColor GetColor(const TBStr & cid) const;

	/** Return the id of the given color, or 0.
	 * If there is no color with that id, an empty TBStr() will be returned.
	 */
	TBStr GetColorID(const TBColor & color) const;

	/** Return the cid of the given color, or 0.
	 * If there is no color with that cid, 0 will be returned.
	 */
	const std::map<TBStr, TBColor> GetColorMap() const { return _id2color; }

	/** Dump the current color map */
	void Dump(const TBStr & filename);

private:
	std::map<TBStr, TBColor> _id2color;
	std::map<TBColor, TBStr> _color2id;
};

} // namespace tb

#endif // TB_COLOR_H
