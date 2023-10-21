
#include <Foundation/NSString.h>
#include <Foundation/NSArray.h>
#include <Foundation/NSValue.h>

#include <AppKit/NSGraphics.h>
#include <AppKit/DPSOperators.h>
#include <AppKit/NSWindow.h>
#include <AppKit/NSCursor.h>
#include <AppKit/NSEvent.h>

#import "wasm-cairo/WasmCairoDisplayServer.h"
#import "../../../libs-gui/Source/wasm/wasm-Appkit.h" // FIXME: where to put this header?
#import "wasm_host_bindings.h"


static struct wcs_screen_t* g_screen;

static struct IOSurface_t** _windows;
static int _nextWindowId = 0;

struct wcs_screen_t *wcs_getScreen()
{
	if (g_screen == NULL) {
		fprintf(stderr, "%s called before setup!\n", __PRETTY_FUNCTION__);
	}
	return g_screen;
}

static struct IOSurface_t *IOSurfaceForWindowId(int winId)
{
	int i = 0;
	int len = _nextWindowId;
	while (i < len) {
		if (_windows[i]->win_id == winId) {
			return _windows[i];
		}
		i++;
	}

	return NULL;
}

@implementation WasmCairoDisplayServer

+ (void)initializeBackend
{
	//fprintf(stderr, "calling %s now size of CGFloat is %lu bytes!\n", __PRETTY_FUNCTION__, sizeof(CGFloat));
	[GSDisplayServer setDefaultServerClass:[WasmCairoDisplayServer class]];
	_windows = calloc(128, sizeof(void*));
	lastMouseLocation();
	g_screen = calloc(1, sizeof(struct wcs_screen_t));
}

// MARK: Screen

- (NSArray *)screenList
{
  	NSMutableArray *screens = [NSMutableArray arrayWithCapacity:1];
	[screens addObject:[NSNumber numberWithInt:1]];

  	return screens;
}

- (NSRect) boundsForScreen: (int)screen
{
	//fprintf(stderr, "calling %s with screen: %d\n", __PRETTY_FUNCTION__, screen);
	if (screen <= 1) {
		struct proxy_screen_t *screenInfo = __gnustep_get_screen_size();
		NSRect rect = NSMakeRect(0, 0, screenInfo->width, screenInfo->height);
		g_screen->width = screenInfo->width;
		g_screen->height = screenInfo->height;
		fprintf(stderr, " screen %d size, width %u height %u\n", screen, screenInfo->width, screenInfo->height);
		free(screenInfo);
    return rect;
 	}
  return NSZeroRect;
}

- (NSSize) resolutionForScreen: (int)screen
{
  /*[self subclassResponsibility: _cmd];*/
  return NSMakeSize(72, 72);
}

- (NSWindowDepth) windowDepthForScreen:(int)screen
{
  return (_GSRGBBitValue | 8);
}


// MARK: Window


- (BOOL) handlesWindowDecorations
{
  return NO;
}

- (void) styleoffsets:(float *)l
			:(float *)r
		    :(float *)t
		    :(float *)b
		    :(unsigned int)style
{
  	if (!handlesWindowDecorations) {
			// If we don't handle decorations, all our windows are going to be
			// border- and decorationless. In that case, -gui won't call this method,
			// but we still use it internally.
			*l = *r = *t = *b = 0.0;
			return;
    }

  	if ((style & NSIconWindowMask) || (style & NSMiniWindowMask)) {
    	style = NSBorderlessWindowMask;
    }

	*l = *r = *t = *b = 1.0;
	if (NSResizableWindowMask & style) {
		*b = 9.0;
	}

	if ((style & NSTitledWindowMask) || (style & NSClosableWindowMask) || (style & NSMiniaturizableWindowMask)) {
		*t = 25.0;
	}
	
	//fprintf(stderr, "WindowMaker %f, %f, %f, %f", *l, *r, *t, *b);
}

- (int) window:(NSRect) frame:(NSBackingStoreType)type :(unsigned int)style :(int)screen
{
	/*
	NSDebugLog(@"window: screen=%d frame=%@", screen, NSStringFromRect(frame));
	struct window *window;
	struct output *output;
	int		 width;
	int		 height;
	int		 altered = 0;*/

	// We're not allowed to create a zero rect window
	if (NSWidth(frame) <= 0 || NSHeight(frame) <= 0) {
		fprintf(stderr, "trying to create a zero rect window\n");
		frame.size.width = 2;
		frame.size.height = 2;
	}
	/*
	window = malloc(sizeof(struct window));
	memset(window, 0, sizeof(struct window));

	wl_list_for_each(output, &wlconfig->output_list, link) {
		if (output->server_output_id == screen) {
			window->output = output;
			break;
		}
	}

	if (!window->output) {
		NSDebugLog(@"can't find screen %d", screen);
		free(window);
		return 0;
	}

	window->wlconfig = wlconfig;
	window->instance = self;
	window->is_out = 0;
	window->width = width = NSWidth(frame);
	window->height = height = NSHeight(frame);
	window->x_pos = frame.origin.x;
	window->y_pos = NSToWayland(window, frame.origin.y);
	window->window_id = wlconfig->last_window_id;

	window->xdg_surface = NULL;
	window->toplevel = NULL;
	window->popup = NULL;
	window->layer_surface = NULL;
	window->configured = NO;

	window->buffer_needs_attach = NO;
	window->terminated = NO;

	window->moving = NO;
	window->resizing = NO;
	window->ignoreMouse = NO;

	// FIXME is this needed?
	if (window->x_pos < 0) {
		window->x_pos = 0;
		altered = 1;
	}

	NSDebugLog(@"creating new window with id=%d: pos=%fx%f, size=%fx%f",
	window->window_id, window->x_pos, window->y_pos, window->width,
	window->height);

	wl_list_insert(wlconfig->window_list.prev, &window->link);
	wlconfig->last_window_id++;
	wlconfig->window_count++;

	// creates a buffer for the window
	[self _setWindowOwnedByServer:(int) window->window_id];

	if (altered) {
		NSEvent *ev =
		[NSEvent otherEventWithType:NSAppKitDefined
		location:NSZeroPoint
		modifierFlags:0
		timestamp:0
		windowNumber:(int) window->window_id
		context:GSCurrentContext()
		subtype:GSAppKitWindowMoved
		data1:window->x_pos
		data2:WaylandToNS(window, window->y_pos)];
		[(GSWindowWithNumber(window->window_id)) sendEvent:ev];
		NSDebugLog(@"window: notifying of move=%fx%f", window->x_pos,
		WaylandToNS(window, window->y_pos));
	}

	return window->window_id;
	*/


  int x_pos = (int)NSMinX(frame);
  int y_pos = (int)NSMinY(frame);
  int width = (int)NSWidth(frame);
  int height = (int)NSHeight(frame);
  y_pos = g_screen->height - (y_pos + height);

	struct IOSurface_t* surface = malloc(sizeof(struct IOSurface_t));
	surface->x_pos = x_pos;
	surface->y_pos = y_pos;
	surface->width = width;
	surface->height = height;
	surface->nsWindow = NULL;
	surface->ctx = NULL;
	surface->win_id = 0;
	surface->screen_id = screen;
	_windows[_nextWindowId++] = surface;

	BOOL isImageCache = _isCreatingNSWindowForImageCache();

	//fprintf(stderr, "is creating window for image-cache: %s\n", (isImageCache ? "YES" : "NO"));

	int win_id;

	if (isImageCache) {
		win_id = __gnustep_increment_window_id();
		surface->win_id = win_id;
	} else {
		win_id = __gnustep_create_window(surface);
	}

	// Sets the WasmCairo backend as owner for the window (this forwards calls from GnuStep-gui to this DisplayServer).
  [self _setWindowOwnedByServer:(int) win_id];

	/*
	struct window_surface_t *res = __gnustep_create_window(screen, frame.origin.x, frame.origin.y, NSWidth(frame), NSHeight(frame));

	fprintf(stderr, "created window_surface; x_pos = %u y_pos = %u height = %u width = %u win_id = %u\n", res->x_pos, res->y_pos, res->width, res->height, res->win_id);

	struct IOSurface_t* surface = malloc(sizeof(struct IOSurface_t));
	surface->x_pos = res->x_pos;
	surface->y_pos = res->y_pos;
	surface->width = res->width;
	surface->height = res->height;
	surface->nsWindow = NULL;
	surface->ctx = NULL;
	surface->win_id = res->win_id;
	_windows[_nextWindowId++] = surface;

	return res->win_id;*/
	return win_id;
}

- (void)setwindowlevel:(int)level:(int)win
{
  //struct window *window = get_window_with_id(wlconfig, win);
  //window->level = level;

  //fprintf(stderr, "setwindowlevel: level=%d win=%d\n", level, win);
  __wmaker_setwindowlevel(level, win);
}

- (void) placewindow: (NSRect)frame : (int) win
{
  //fprintf(stderr, "calling %s for window-id: %d frame: { %f %f %f %f }\n", __PRETTY_FUNCTION__, win, NSMinX(frame), NSMinY(frame), NSWidth(frame), NSHeight(frame));

  struct IOSurface_t *surface = IOSurfaceForWindowId(win);

  if (surface == NULL) {
  	fprintf(stderr, "found no matching IOSurface id: %d\n", win);
  	return;
  }
  
  NSRect oldFrame = NSMakeRect(surface->x_pos, surface->height - surface->y_pos, surface->width, surface->height);
	BOOL resize = NO;
  BOOL move = NO;

  if (NSEqualRects(frame, oldFrame) == YES) {
    return;
  }
  if (NSEqualSizes(frame.size, oldFrame.size) == NO) {
    resize = YES;
    move = YES;
  }
  if (NSEqualPoints(frame.origin, oldFrame.origin) == NO) {
    move = YES;
  }

  int x_pos = (int)NSMinX(frame);
  int y_pos = (int)NSMinY(frame);
  int width = (int)NSWidth(frame);
  int height = (int)NSHeight(frame);
  y_pos = g_screen->height - (y_pos + height);

  surface->x_pos = x_pos;
	surface->y_pos = y_pos;
	surface->width = width;
	surface->height = height;

	if (resize == YES) {
		NSEvent *evt = [NSEvent otherEventWithType: NSAppKitDefined
																		 location: frame.origin
																modifierFlags: 0
																    timestamp: 0
																 windowNumber: win
																		  context: GSCurrentContext()
																		  subtype: GSAppKitWindowResized
																				data1: frame.size.width
																				data2: frame.size.height];
		// NSDebugLog(@"notify resize=%fx%f", frame.size.width, frame.size.height);
		[(GSWindowWithNumber(surface->win_id)) sendEvent:evt];
		// NSDebugLog(@"notified resize=%fx%f", frame.size.width, frame.size.height);
		// we have a new buffer
	} else if (move) {
      NSEvent *evt = [NSEvent otherEventWithType: NSAppKitDefined
			     location: NSZeroPoint
			modifierFlags: 0
			    timestamp: 0
			 windowNumber: win
			      context: GSCurrentContext()
			      subtype: GSAppKitWindowMoved
				data1: frame.origin.x
				data2: frame.origin.y];
      [(GSWindowWithNumber(surface->win_id)) sendEvent:evt];
	}

  __wmaker_placewindow(win, x_pos, y_pos, width, height);
}

- (void) orderwindow: (int) op : (int) otherWin : (int) winNum
{
	struct IOSurface_t *surface = IOSurfaceForWindowId(winNum);

	//fprintf(stderr, "calling %s for op: %d window-id: %d other-window-id: %d\n", __PRETTY_FUNCTION__, op, winNum, otherWin);
	NSRect rect = NSMakeRect(surface->x_pos, surface->y_pos, surface->width, surface->height);
  //[self flushwindowrect:rect:surface->win_id];
  __wmaker_orderwindow(op, otherWin, winNum);
}

/** 
 * Sets the window title
 */
- (void) titlewindow: (NSString *) window_title : (int) win
{
	const char *title = [window_title UTF8String];
	__gnustep_setWindowTitle(win, title);
	// Do not call super! 
}

/*
 * Window ordering
 *
typedef enum _NSWindowOrderingMode
{
  NSWindowAbove,
  NSWindowBelow,
  NSWindowOut

} NSWindowOrderingMode; */

/*
 * Window input state
typedef enum _GSWindowInputState
{
  GSTitleBarKey = 0,
  GSTitleBarNormal = 1,
  GSTitleBarMain = 2

} GSWindowInputState; */

/** 
 * Sets the input state for the window given by the
 * GSWindowInputState constant.  Instructs the window manager that the
 * specified window is 'key', 'main', or just a normal window.
 */
- (void) setinputstate: (int)state : (int)win
{
	//fprintf(stderr, "did set inputstate for window %d to state: %d\n", win, state);
	__wmaker_setinputstate(state, win);
}

/** 
 * Sets the document edited flag for the window
 */
- (void) docedited: (int) edited : (int) win
{
	//fprintf(stderr, "did set document-is-edited flag to '%s' (%d) for window %d\n", (edited == 1 ? "YES" : "NO"), edited, win);
}

/** 
 * Set the maximum size (pixels) of the window
 */
- (void) setmaxsize: (NSSize)size : (int) win
{
	//fprintf(stderr, "did set the maximum size to {%f %f} for window %d\n", size.width, size.height, win);
}

/** 
 * Set the minimum size (pixels) of the window
 */
- (void) setminsize: (NSSize)size : (int) win
{
	//fprintf(stderr, "did set the minimum size to {%f %f} for window %d\n", size.width, size.height, win);
}

/**
 * Returns the last known location of the mouse on screen.
 */
- (NSPoint) mouseLocationOnScreen: (int)aScreen window: (int *)win
{
	struct mouse_config_t *loc = lastMouseLocation();
	if (loc->screen_id != aScreen) {
		return NSZeroPoint;
	}
	return NSMakePoint(loc->screenX, loc->screenY);
}

- (void) setresizeincrements: (NSSize)size : (int) win
{
	// simply ignored..
}

// Not implemented at currently but marked as subclass-responsibility in GSDisplayServer
// - (void) restrictWindow: (int)win toImage: (NSImage*)image
// - (int) findWindowAt: (NSPoint)screenLocation windowRef: (int*)windowRef excluding: (int)win
// - (const NSWindowDepth *) availableDepthsForScreen: (int)screen
// - (void *) serverDevice
// - (void *) windowDevice: (int)win
// - (void) beep
// - (NSImage *) contentsOfScreen: (int)screen inRect: (NSRect)rect
- (void) termwindow: (int) win
{
	struct IOSurface_t *surface = IOSurfaceForWindowId(win);
	__wmaker_finalize_surface(win);
}
// - (int) nativeWindow: (void *)winref : (NSRect*)frame : (NSBackingStoreType*)type : (unsigned int*)style : (int*)screen
// - (void) stylewindow: (unsigned int) style : (int) win
// - (void) windowbacking: (NSBackingStoreType)type : (int) win
- (void) miniwindow: (int) win
{

}
// - (BOOL) hideApplication: (int) win
// - (void) windowdevice: (int)winNum
// - (void) movewindow: (NSPoint)loc : (int) win
// - (NSRect) windowbounds: (int) win
// - (void) setwindowlevel: (int) level : (int) win
// - (int) windowlevel: (int) win
// - (int) windowdepth: (int) win
// - (void) setresizeincrements: (NSSize)size : (int) win
// - (void) setalpha: (float)alpha : (int) win
// - (void) setShadow: (BOOL)hasShadow : (int)win
// - (NSPoint) mouselocation
// - (void) releasemouse
// - (void) setMouseLocation: (NSPoint)mouseLocation onScreen: (int)aScreen
// - (void) imagecursor: (NSPoint)hotp : (NSImage *) image : (void**) cid
// - (void) setcursorcolor: (NSColor *)fg : (NSColor *)bg : (void*) cid
// - (void) recolorcursor: (NSColor *)fg : (NSColor *)bg : (void*) cid
// - (void) setcursor: (void*) cid
// - (void) freecursor: (void*) cid
- (void) setParentWindow: (int)parentWin  forChildWindow: (int)childWin
{
  if (parentWin == 0) {
    return;
  }
  fprintf(stderr, "setParentWindow: parent=%d child=%d\n", parentWin, childWin);
}
// - (void) setIgnoreMouse: (BOOL)ignoreMouse : (int)win

// MARK: Window Styling

/*
- (void) styleoffsets: (float *) l : (float *) r : (float *) t : (float *) b
		     : (unsigned int) style : (struct IOSurface_t) win
{

  	if (!handlesWindowDecorations) {
		// If we don't handle decorations, all our windows are going to be
		// border- and decorationless. In that case, -gui won't call this method,
		// but we still use it internally.
		*l = *r = *t = *b = 0.0;
		return;
    }

  	if ((style & NSIconWindowMask) || (style & NSMiniWindowMask)) {
    	style = NSBorderlessWindowMask;
    }

	*l = *r = *t = *b = 1.0;
	if (NSResizableWindowMask & style) {
		*b = 9.0;
	}

	if ((style & NSTitledWindowMask) || (style & NSClosableWindowMask) || (style & NSMiniaturizableWindowMask)) {
		*t = 25.0;
	}
	
	fprintf(stderr, "Window %lu, windowmaker %f, %f, %f, %f", win, *l, *r, *t, *b);
}

- (void) stylewindow: (unsigned int)style : (int) win
{
	fprintf(stderr, "called %s\n", __PRETTY_FUNCTION__);*/
	/*
	gswindow_device_t *window;

	NSAssert(handlesWindowDecorations, @"-stylewindow:: called when handlesWindowDecorations==NO");

	window = IOSurfaceForWindowId(win);
	if (!window) {
		return;
	}
	*//*
}*/

// MARK: Window Rendering

- (void)setWindowdevice:(int)winId forContext:(NSGraphicsContext *)ctxt
{
  //fprintf(stderr, "[%d] setWindowdevice", winId);
  
  struct IOSurface_t *surface = IOSurfaceForWindowId(winId);
  // FIXME we could resize the current surface instead of creating a new one
  if (surface->wcs) {
      //fprintf(stderr, "[%d] window has already a surface\n", winId);
   }
  GSSetDevice(ctxt, surface, 0.0, surface->height);
  DPSinitmatrix(ctxt);
  DPSinitclip(ctxt);
}

- (NSRect)windowbounds:(int)win
{
  struct IOSurface_t *surface = IOSurfaceForWindowId(win);
  fprintf(stderr, "windowbounds: win=%d, pos=%dx%d size=%dx%d", surface->win_id, surface->x_pos, surface->y_pos, surface->width, surface->height);

  return NSMakeRect(surface->x_pos, surface->height - surface->y_pos, surface->width, surface->height);
}


- (void)flushwindowrect:(NSRect)rect:(int)win
{
  //fprintf(stderr, "[%d] flushwindowrect: { %f %f %f %f }\n", win, NSMinX(rect), NSMinY(rect), NSWidth(rect), NSHeight(rect));
  struct IOSurface_t *surface = IOSurfaceForWindowId(win);

  [[GSCurrentContext() class] handleExposeRect:rect forDriver:surface->wcs];

  //fprintf(stderr, "does this even run?\n");
  // extract rect into top-lef bottom-right coordinates to normalize.
  int x = (int)rect.origin.x;
  int y = (int)(surface->height - rect.origin.y);
  int w = (int)(rect.origin.x + rect.size.width);
  int h = (int)(surface->height - (rect.origin.y + rect.size.height));

  if (x < w) {
  	w = w - x;
  } else { // x >= w
  	int tmp = w;
  	w = x - w;
  	x = tmp;
  }

  if (y < h) {
  	h = h - y;
  } else { // y >= h
  	int tmp = h;
  	h = y - h;
  	y = tmp;
  }

  __gnustep_flushDirtyRect(win, x, y, w, h);
}

// MARK: Event Managing

- (BOOL)capturemouse:(int)win
{
  struct IOSurface_t *window = IOSurfaceForWindowId(win);
  //wlconfig->pointer.captured = window;
  fprintf(stderr, "TODO: implement %s\n", __PRETTY_FUNCTION__);
  return YES;
}

- (void) releasemouse
{
	fprintf(stderr, "TODO: implement %s\n", __PRETTY_FUNCTION__);
}

- (void) setinputfocus: (int) win
{
		fprintf(stderr, "called %s win: %d\n", __PRETTY_FUNCTION__, win);
}

// MARK: Mouse Cursor

- (void) standardcursor: (int)style : (void **)cid
{
	const char *cssCursor = nil;

	switch (style) {
		case GSArrowCursor:
			cssCursor = "default";
			break;
		case GSIBeamCursor:
			cssCursor = "text";
			break;
		case GSDragLinkCursor:
			cssCursor = "alias";
			break;
		case GSOperationNotAllowedCursor:
			cssCursor = "no-drop";
			break;
		case GSClosedHandCursor:
			cssCursor = "grabbing";
			break;
		case GSOpenHandCursor:
			cssCursor = "grab";
			break;
		case GSPointingHandCursor:
			cssCursor = "pointer";
			break;
		case GSResizeLeftCursor:
			cssCursor = "w-resize";
			break;
		case GSResizeRightCursor:
			cssCursor = "e-resize";
			break;
		case GSResizeLeftRightCursor:
			cssCursor = "col-resize";
			break;
		case GSCrosshairCursor:
			cssCursor = "crosshair";
			break;
		case GSResizeUpCursor:
			cssCursor = "n-resize";
			break;
		case GSResizeDownCursor:
			cssCursor = "s-resize";
			break;
		case GSResizeUpDownCursor:
			cssCursor = "row-resize";
			break;
		case GSContextualMenuCursor:
			cssCursor = "context-menu";
			break;
		case GSDisappearingItemCursor:
			cssCursor = "auto";
			break;
		case GSGreenArrowCursor:
			cssCursor = "auto";
			break;
		default:
			cssCursor = NULL;
			break;

	}

  fprintf(stderr, "called %s result = '%s'\n", __PRETTY_FUNCTION__, cssCursor);

  if (cssCursor != NULL) {
  	*cid = (void*)cssCursor;
  }
}

- (void) setcursor: (void*) cid
{
  __gsc_set_cursor(0, cid);
}

- (void) hidecursor
{
  __gsc_hide_cursor();
}

- (void) showcursor
{
  __gsc_show_cursor();
}


@end