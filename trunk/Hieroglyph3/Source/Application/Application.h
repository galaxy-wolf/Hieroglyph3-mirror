//--------------------------------------------------------------------------------
// This file is a portion of the Hieroglyph 3 Rendering Engine.  It is distributed
// under the MIT License, available in the root of this distribution and 
// at the following URL:
//
// http://www.opensource.org/licenses/mit-license.php
//
// Copyright (c) 2003-2010 Jason Zink 
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
// Application
//
// This class represents the base application available to the end user.  The 
// Windows Main function is contained withing the .cpp file, and automatically
// checks for an instance of a CApplication class.  If one is not found then the
// program is exited.
//
// The application currently supports Input, Sound, Rendering, Logging, Timing, 
// and profiling.  These are all available to the user when building an 
// application.
//--------------------------------------------------------------------------------
#ifndef Application_h
#define Application_h
//--------------------------------------------------------------------------------
#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif
//--------------------------------------------------------------------------------
#include "PCH.h"

#include "Log.h"
#include "Timer.h"
#include "EventManager.h"
#include "IEventListener.h"
#include "IWindowProc.h"
#include "Scene.h"
// Window Events
#include "EvtWindowResize.h"

// Keyboard Events
#include "EvtChar.h"
#include "EvtKeyUp.h"
#include "EvtKeyDown.h"

// Mouse Events
#include "EvtMouseWheel.h"
#include "EvtMouseMove.h"
#include "EvtMouseLeave.h"
#include "EvtMouseLButtonUp.h"
#include "EvtMouseLButtonDown.h"
#include "EvtMouseMButtonUp.h"
#include "EvtMouseMButtonDown.h"
#include "EvtMouseRButtonUp.h"
#include "EvtMouseRButtonDown.h"
//--------------------------------------------------------------------------------
namespace Glyph3
{
	class Application : public IEventListener, public IWindowProc
	{
	public:
		Application();
		virtual ~Application();

		// Initialization functions
		static Application* GetApplication( );

		// Overloadable functions for end user
		virtual bool ConfigureEngineComponents() = 0;
		virtual void ShutdownEngineComponents() = 0;
		virtual void Initialize() = 0;
		virtual void Update() = 0;
		virtual void Shutdown() = 0;
		virtual void MessageLoop();
		virtual LRESULT WindowProc(HWND hwnd, UINT msg, WPARAM wparam, LPARAM lparam); 

		virtual bool HandleEvent( IEvent* pEvent );

		// Request an exit from windows
		void RequestTermination();

		// Helpers
		Timer* m_pTimer;

		// Engine Components
		EventManager* m_pEventMgr;

		Scene* m_pScene;

	protected:
		// CApplication pointer to ensure single instance
		static Application* ms_pApplication;
	};
};
//--------------------------------------------------------------------------------
#endif // Application_h