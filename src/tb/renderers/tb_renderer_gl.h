// ================================================================================
// ==      This file is a part of Turbo Badger. (C) 2011-2014, Emil Segerås      ==
// ==                     See tb_core.h for more information.                    ==
// ================================================================================

#ifndef TB_RENDERER_GL_H
#define TB_RENDERER_GL_H

#include "tb_types.h"

#if defined(TB_RENDERER_GL)

#if defined(TB_RENDERER_GLES_1) && defined(TB_RENDERER_GLES_2)
#error "Both GLES_1 and GLES_2 defined"
#elif defined(TB_RENDERER_GLES_1) && defined(TB_RENDERER_GL3)
#error "Both GLES_1 and GL3 defined"
#elif defined(TB_RENDERER_GLES_2) && defined(TB_RENDERER_GL3)
#error "Both GLES_2 and GL3 defined"
#endif

#ifdef TB_RENDERER_GLES_1

#if defined(ANDROID) || defined(__ANDROID__)
#include <GLES/gl.h>
#else
#include <EGL/egl.h>
#include <GLES/gl.h>
#endif

#elif defined(TB_RENDERER_GLES_2)

#ifndef GL_GLEXT_PROTOTYPES
#define GL_GLEXT_PROTOTYPES 1
#endif
#if defined(__APPLE__)
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#elif defined(__ANDROID__) || defined (__EMSCRIPTEN__)
#include <GLES2/gl2.h>
#include <GLES2/gl2ext.h>
#else
#include <GLES/gl.h>
#endif
#if defined(ANDROID)
#include <android/ndk-version.h>
#endif
#if defined(ANDROID) && __NDK_MAJOR__ < 19
extern PFNGLBINDVERTEXARRAYOESPROC glBindVertexArrayOESEXT;
extern PFNGLDELETEVERTEXARRAYSOESPROC glDeleteVertexArraysOESEXT;
extern PFNGLGENVERTEXARRAYSOESPROC glGenVertexArraysOESEXT;
#define glDeleteVertexArrays glDeleteVertexArraysOESEXT
#define glGenVertexArrays glGenVertexArraysOESEXT
#define glBindVertexArray glBindVertexArrayOESEXT
#else
#define glGenVertexArrays glGenVertexArraysOES
#define glBindVertexArray glBindVertexArrayOES
#define glDeleteVertexArrays glDeleteVertexArraysOES
#define glIsVertexArray glIsVertexArrayOES
#endif

#elif defined(TB_RENDERER_GL3)

#if defined(__APPLE__)
#include <OpenGL/gl3.h>
#elif defined (_WIN32)
#ifndef GLEW_STATIC
#error "GLEW_STATIC NOT DEFINED!!!"
#endif
#define GL3_PROTOTYPES 1
#include <GL/glew.h>
//#include <GL3/gl3.h>
#else
#define GL_GLEXT_PROTOTYPES 1
#include <GL/gl.h>
#endif

#else // Standard GL1.1 Renderer

#if defined(_WIN32)
#include <windows.h> // make gl.h compile
#include <GL/glew.h>
#include <GL/gl.h>
#elif defined(TB_SYSTEM_MACOSX) || defined(TB_SYSTEM_IOS)
#include <OpenGL/gl.h>
#else
#include <GL/gl.h>
#endif

#endif

#include "renderers/tb_renderer_batcher.h"

namespace tb {

class TBRendererGL;

class TBBitmapGL : public TBBitmap
{
public:
	TBBitmapGL(TBRendererGL *renderer);
	~TBBitmapGL();
	bool Init(int width, int height, uint32_t *data);
	virtual int Width() { return m_w; }
	virtual int Height() { return m_h; }
	virtual void SetData(uint32_t *data);
public:
	TBRendererGL *m_renderer;
	int m_w, m_h;
	GLuint m_texture;
};

class TBRendererGL : public TBRendererBatcher
{
public:
	TBRendererGL();
	virtual ~TBRendererGL();

	// == TBRenderer ====================================================================

	virtual void BeginPaint(int render_target_w, int render_target_h);
	virtual void EndPaint();

	virtual TBBitmap *CreateBitmap(int width, int height, uint32_t *data);

	// == TBRendererBatcher ===============================================================

	virtual void RenderBatch(Batch *batch);
	virtual void SetClipRect(const TBRect &rect);

#if defined(TB_RENDERER_GLES_2) || defined(TB_RENDERER_GL3)
private:
	static const GLuint _NUM_VBOS = 256;
	GLuint LoadShader(GLenum type, const GLchar * shaderSrc);
	GLuint m_program;
	bool m_hasvao;
	GLuint m_vao[_NUM_VBOS];
	GLuint m_vbo[_NUM_VBOS];
	float m_ortho[16];
	GLuint _vboidx;
	GLint m_orthoLoc;
	GLint m_texLoc;
	TBBitmapGL m_white;
#endif
};

} // namespace tb

#endif // TB_RENDERER_GL
#endif // TB_RENDERER_GL_H
