// ================================================================================
// ==      This file is a part of Turbo Badger. (C) 2011-2014, Emil Segerås      ==
// ==                     See tb_core.h for more information.                    ==
// ================================================================================

#include "image/tb_image_widget.h"
#include "tb_widgets_reader.h"
#include "tb_node_tree.h"
#include "tb_system.h"

#ifdef TB_IMAGE

namespace tb {

PreferredSize TBImageWidget::OnCalculatePreferredContentSize(const SizeConstraints & /*constraints*/)
{
	//TBDebugPrint("PCS: %d x %d\n", m_image.Width(), m_image.Height());
	return PreferredSize(m_image.Width(), m_image.Height());
}

void TBImageWidget::OnPaint(const PaintProps &paint_props)
{
	TBRect pr = GetPaddingRect();
#ifdef TB_RUNTIME_DEBUG_INFO
	// Debug: show red rectangle where image would be if image is missing
	if (!m_image.GetBitmap()) {
		TBDebugPrint("TBImageWidget::OnPaint - no bitmap, rect=(%d,%d,%d,%d)\n",
			pr.x, pr.y, pr.w, pr.h);
	}
#endif
	if (TBBitmapFragment *fragment = m_image.GetBitmap()) {
		if (m_adapt_text_color)
			g_renderer->DrawBitmapColored(pr,
										  TBRect(0, 0, m_image.Width(), m_image.Height()),
										  paint_props.text_color, fragment);
		else
			g_renderer->DrawBitmap(pr,
								   TBRect(0, 0, m_image.Width(), m_image.Height()), fragment);
	}
}


} // namespace tb

#endif // TB_IMAGE
