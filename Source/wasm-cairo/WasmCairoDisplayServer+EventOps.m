
#import <Foundation/NSRunLoop.h>

#import <AppKit/NSEvent.h>
#import <AppKit/NSWindow.h>
#import <AppKit/NSApplication.h>
#include <AppKit/NSGraphics.h>

#import "wasm-cairo/WasmCairoDisplayServer.h"
#import "wasm_host_bindings.h"

void _log_sizes() {
	fprintf(stderr, "size of struct proxy_mouse_event = %lu\n", sizeof(struct proxy_mouse_event));
	fprintf(stderr, "size of struct proxy_mouse_move_event = %lu\n", sizeof(struct proxy_mouse_move_event));
	fprintf(stderr, "size of struct proxy_mouse_wheel_event %lu\n", sizeof(struct proxy_mouse_wheel_event));
	fprintf(stderr, "size of struct proxy_keyboard_event %lu\n", sizeof(struct proxy_keyboard_event));
	fprintf(stderr, "size of struct proxy_drag_event %lu\n", sizeof(struct proxy_drag_event));
}

static struct mouse_config_t *g_mouse_config;

struct mouse_config_t *lastMouseLocation()
{
	if (!g_mouse_config) {
		g_mouse_config = calloc(1, sizeof(struct mouse_config_t));
	}

	return g_mouse_config;
}

void _gstep_handle_mouse_down(struct proxy_mouse_event *evt)
{
#if 0
	//fprintf(stderr, "entered call at %s\n", __PRETTY_FUNCTION__);
	NSEventType eventType;
  	int clickCount = evt->clickCount;

	NSGraphicsContext *gcontext = GSCurrentContext();
	struct IOSurface_t *window = evt->window;
  	NSPoint eventLocation = NSMakePoint(evt->mouseX, window->height - evt->mouseY);
  	//fprintf(stderr, "eventLocation.x = %f eventLocation.y = %f in window-id: %i\n", eventLocation.x, eventLocation.y, (int)window->win_id);
  	NSTimeInterval timestamp = (NSTimeInterval) evt->timestamp / 1000.0;

  	// Check for drag by window frame.
  	// Check for resize
  	
    switch (evt->button) {
		case 1:
			eventType = NSLeftMouseDown;
			break;
		case 2:
			eventType = NSRightMouseDown;
			break;
		case 3:
			eventType = NSOtherMouseDown;
			break;
	}

	// saves the last state of the mouse for use within other APIs
	g_mouse_config->screenX = (int)evt->screenX;
	g_mouse_config->screenY = wcs_getScreen()->height - (int)evt->screenY;
	g_mouse_config->screen_id = evt->screen_id;

  	NSEvent *event = [NSEvent mouseEventWithType:eventType
			     location: eventLocation
			modifierFlags: evt->modifier
			    timestamp: timestamp
			 windowNumber: (int) window->win_id
			      context: gcontext
			  eventNumber: 1
			   clickCount: clickCount
			     pressure: 1.0
			 buttonNumber: evt->button
			       deltaX: 0.0
			       deltaY: 0.0
			       deltaZ: 0.0];

  	[GSCurrentServer() postEvent:event atStart:NO];

  	// fires one interation trough the NSApplication run-loop in order to evaulate the event.
  	_gstep_fire_runLoop();
  	/*
  	id distantFuture = [NSDate distantFuture];
  	NSEvent *e = [NSApp nextEventMatchingMask: (NSLeftMouseDownMask | NSRightMouseDownMask | NSOtherMouseDownMask) untilDate: distantFuture inMode: NSDefaultRunLoopMode dequeue: YES];

	if (e != nil) {
		NSEventType	type = [e type];
		[NSApp sendEvent: e];
	}

	[NSApp updateWindows];*/
#endif
}

void _gstep_handle_mouse_up(struct proxy_mouse_event *evt)
{
#if 0
	//fprintf(stderr, "entered call at %s\n", __PRETTY_FUNCTION__);

	NSEventType eventType;
  	int clickCount = evt->clickCount;

	NSGraphicsContext *gcontext = GSCurrentContext();
	struct IOSurface_t *window = evt->window;
  	NSPoint eventLocation = NSMakePoint(evt->mouseX, window->height - evt->mouseY);
  	//fprintf(stderr, "eventLocation.x = %f eventLocation.y = %f\n", eventLocation.x, eventLocation.y);
  	NSTimeInterval timestamp = (NSTimeInterval) evt->timestamp / 1000.0;

  	// Check for drag by window frame.
  	// Check for resize
  	
    switch (evt->button) {
		case 1:
			eventType = NSLeftMouseUp;
			break;
		case 2:
			eventType = NSRightMouseUp;
			break;
		case 3:
			eventType = NSOtherMouseUp;
			break;
	}

	// saves the last state of the mouse for use within other APIs
	g_mouse_config->screenX = (int)evt->screenX;
	g_mouse_config->screenY = wcs_getScreen()->height - (int)evt->screenY;
	g_mouse_config->screen_id = evt->screen_id;

  	NSEvent *event = [NSEvent mouseEventWithType:eventType
			     location:eventLocation
			modifierFlags: evt->modifier
			    timestamp:timestamp
			 windowNumber:(int) window->win_id
			      context:gcontext
			  eventNumber: 1
			   clickCount:clickCount
			     pressure:1.0
			 buttonNumber: evt->button
			       deltaX: 0.0
			       deltaY: 0.0
			       deltaZ: 0.0];

  	NSWindow *win = GSWindowWithNumber(window->win_id);
	if (GSHasTrackingListenerInWindow(win, eventType)) {
  		GSRunTrackingListenerInWindow(win, event);
  	} else {
	  	// fires one interation trough the NSApplication run-loop in order to evaulate the event.
	  	[GSCurrentServer() postEvent:event atStart:NO];
	  	//_gstep_fire_runLoop();
  	}
#endif
}

void _gstep_handle_mouse_move(struct proxy_mouse_move_event *evt)
{
#if 0
	NSEventType eventType;
  	int clickCount = 1;

	NSGraphicsContext *gcontext = GSCurrentContext();
	struct IOSurface_t *window = evt->window;
  	NSPoint eventLocation = NSMakePoint(evt->mouseX, window->height - evt->mouseY);
  	NSTimeInterval timestamp = (NSTimeInterval) evt->timestamp / 1000.0;

  	float deltaX = (float)evt->movementX;
  	float deltaY = (float)evt->movementY;

  	eventType = NSMouseMoved;

	// saves the last state of the mouse for use within other APIs
	g_mouse_config->screenX = (int)evt->screenX;
	g_mouse_config->screenY = wcs_getScreen()->height - (int)evt->screenY;
	g_mouse_config->screen_id = evt->screen_id;

  	// Check for drag by window frame.
  	// Check for resize
  	/*
    switch (evt->button) {
		case 1:
			eventType = NSLeftMouseUp;
			break;
		case 2:
			eventType = NSRightMouseUp;
			break;
		case 3:
			eventType = NSOtherMouseUp;
			break;
	}*/

  	NSEvent *event = [NSEvent mouseEventWithType:eventType
			     location:eventLocation
			modifierFlags: evt->modifier
			    timestamp:timestamp
			 windowNumber:(int) window->win_id
			      context:gcontext
			  eventNumber: 1
			   clickCount:clickCount
			     pressure:1.0
			 buttonNumber: 0
			       deltaX: deltaX
			       deltaY: deltaY
			       deltaZ: 0.0];

  	NSWindow *win = GSWindowWithNumber(window->win_id);
	if (GSHasTrackingListenerInWindow(win, eventType)) {
  		GSRunTrackingListenerInWindow(win, event);
  	} else {
	  	// fires one interation trough the NSApplication run-loop in order to evaulate the event.
	  	[GSCurrentServer() postEvent:event atStart:NO];
	  	//_gstep_fire_runLoop();
  	}
#endif
}

void _gstep_handle_mouse_click(struct proxy_mouse_event *evt)
{
	fprintf(stderr, "entered call at %s\n", __PRETTY_FUNCTION__);
}

void _gstep_handle_mouse_dbl_click(struct proxy_mouse_event *evt)
{
	fprintf(stderr, "entered call at %s\n", __PRETTY_FUNCTION__);
}

void _gstep_handle_mouse_wheel(struct proxy_mouse_wheel_event *evt)
{
#if 0
	//fprintf(stderr, "entered call at %s\n", __PRETTY_FUNCTION__);
  	int clickCount = 1;

	NSGraphicsContext *gcontext = GSCurrentContext();
	struct IOSurface_t *window = evt->window;
  	NSPoint eventLocation = NSMakePoint(evt->mouseX, window->height - evt->mouseY);
  	//fprintf(stderr, "eventLocation.x = %f eventLocation.y = %f in window-id: %i\n", eventLocation.x, eventLocation.y, (int)window->win_id);
  	NSTimeInterval timestamp = (NSTimeInterval) evt->timestamp / 1000.0;

  	float deltaX = evt->wheelDeltaX;
  	float deltaY = evt->wheelDeltaY;

  	NSEvent *event = [NSEvent mouseEventWithType: NSScrollWheel
			     location: eventLocation
			modifierFlags: evt->modifier
			    timestamp: timestamp
			 windowNumber: (int) window->win_id
			      context: gcontext
			  eventNumber: 1
			   clickCount: clickCount
			     pressure: 1.0
			 buttonNumber: 0
			       deltaX: deltaX
			       deltaY: deltaY
			       deltaZ: 0.0];

  	[GSCurrentServer() postEvent:event atStart:NO];

  	// fires one interation trough the NSApplication run-loop in order to evaulate the event.
  	//_gstep_fire_runLoop();
#endif
}

void _gstep_handle_keyboard_key_down(struct proxy_keyboard_event *evt)
{
#if 0
	//fprintf(stderr, "entered call at %s\n", __PRETTY_FUNCTION__);

	NSGraphicsContext *gcontext = GSCurrentContext();
	struct IOSurface_t *window = evt->window;
	NSTimeInterval timestamp = (NSTimeInterval) evt->timestamp / 1000.0;
	/*
		uint32_t eventId;
	uint32_t modifier;
	uint64_t timestamp;
	void *window; 		   // IOSurface_t;
	uint32_t keyCode;	   //
	uint32_t charsIgnoringModifiers; //
	char isRepeat; 		   // boolean
	char defaultPrevented; // boolean
	
	+ (NSEvent*) keyEventWithType: (NSEventType)type
                     location: (NSPoint)location
                modifierFlags: (NSUInteger)flags
                    timestamp: (NSTimeInterval)time
                 windowNumber: (NSInteger)windowNum
                      context: (NSGraphicsContext*)context        
                   characters: (NSString *)keys        
  charactersIgnoringModifiers: (NSString *)ukeys
                    isARepeat: (BOOL)repeatKey        
                      keyCode: (unsigned short)code;*/
	NSEvent *event = [NSEvent keyEventWithType: NSKeyDown
                     location: NSZeroPoint
                modifierFlags: evt->modifier
                    timestamp: timestamp
                 windowNumber: (int)window->win_id
                      context: gcontext      
                   characters: [NSString stringWithUTF8String: evt->chars]
  charactersIgnoringModifiers: [NSString stringWithUTF8String: evt->charsIgnoringModifiers]
                    isARepeat: (BOOL)evt->isRepeat        
                      keyCode: evt->keyCode];

	[GSCurrentServer() postEvent:event atStart:NO];

	// fires one interation trough the NSApplication run-loop in order to evaulate the event.
  	//_gstep_fire_runLoop();
#endif
}

void _gstep_handle_keyboard_key_up(struct proxy_keyboard_event *evt)
{
#if 0
	//fprintf(stderr, "entered call at %s\n", __PRETTY_FUNCTION__);

	NSGraphicsContext *gcontext = GSCurrentContext();
	struct IOSurface_t *window = evt->window;
	NSTimeInterval timestamp = (NSTimeInterval) evt->timestamp / 1000.0;


	NSEvent *event = [NSEvent keyEventWithType: NSKeyUp
                     location: NSZeroPoint
                modifierFlags: evt->modifier
                    timestamp: timestamp
                 windowNumber: (int)window->win_id
                      context: gcontext      
                   characters: [NSString stringWithUTF8String: evt->chars]
  charactersIgnoringModifiers: [NSString stringWithUTF8String: evt->charsIgnoringModifiers]
                    isARepeat: (BOOL)evt->isRepeat        
                      keyCode: evt->keyCode];

	[GSCurrentServer() postEvent:event atStart:NO];

	// fires one interation trough the NSApplication run-loop in order to evaulate the event.
  	//_gstep_fire_runLoop();
#endif
}

void _gstep_handle_drag_evt(struct proxy_drag_event *evt)
{
	// Check the X-backend for their event dispatching for this.
	fprintf(stderr, "entered call at %s\n", __PRETTY_FUNCTION__);
}

void _gstep_handle_drag_end_evt(struct proxy_drag_event *evt)
{
	fprintf(stderr, "entered call at %s\n", __PRETTY_FUNCTION__);
}

void _gstep_handle_drag_enter_evt(struct proxy_drag_event *evt)
{
	fprintf(stderr, "entered call at %s\n", __PRETTY_FUNCTION__);
}

void _gstep_handle_drag_leave_evt(struct proxy_drag_event *evt)
{
	fprintf(stderr, "entered call at %s\n", __PRETTY_FUNCTION__);
}

void _gstep_handle_drag_over_evt(struct proxy_drag_event *evt)
{
	fprintf(stderr, "entered call at %s\n", __PRETTY_FUNCTION__);
}

void _gstep_handle_drag_start_evt(struct proxy_drag_event *evt)
{
	fprintf(stderr, "entered call at %s\n", __PRETTY_FUNCTION__);
}

void _gstep_handle_drag_drop_evt(struct proxy_drag_event *evt)
{
	fprintf(stderr, "entered call at %s\n", __PRETTY_FUNCTION__);
}

/*
static void _gstep_handle_keyboard_key(void *data, struct wl_keyboard *keyboard, uint32_t serial, uint32_t time, uint32_t key, uint32_t state_w)
{
	// NSDebugLog(@"keyboard_handle_key: %d", key);
	WaylandConfig		*wlconfig = data;
	wlconfig->event_serial = serial;
	uint32_t		     code, num_syms;
	enum wl_keyboard_key_state state = state_w;
	const xkb_keysym_t	     *syms;
	xkb_keysym_t		     sym;
	struct window		*window = wlconfig->pointer.focus;

	if (!window) {
		return;
	}

	code = 0;
	if (key == 28) {
		sym = NSCarriageReturnCharacter;
  	} else if (key == 14) {
      	sym = NSDeleteCharacter;
    } else {
      	code = key + 8;

      	num_syms = xkb_state_key_get_syms(wlconfig->xkb.state, code, &syms);

      	sym = XKB_KEY_NoSymbol;
      	
      	if (num_syms == 1) {
			sym = syms[0];
      	}
    }

	NSString *s = [NSString stringWithUTF8String:&sym];
	NSEventType eventType;

  	if (state == WL_KEYBOARD_KEY_STATE_PRESSED) {
     	eventType = NSKeyDown;
    } else {
      	eventType = NSKeyUp;
    }

    NSEvent *ev = [NSEvent keyEventWithType:eventType location:NSZeroPoint modifierFlags:wlconfig->modifiers
				timestamp:time / 1000.0
			     windowNumber:window->window_id
				  context:GSCurrentContext()
			       characters:s
	      charactersIgnoringModifiers:s
				isARepeat:NO
				  keyCode:code];

  [GSCurrentServer() postEvent:ev atStart:NO];

  // NSDebugLog(@"keyboard_handle_key: %@", s);
}*/


/*void _gstep_dispatch_display_timing(uint64_t ms)
{
    fprintf(stderr, "entered call at %s\n", __PRETTY_FUNCTION__);
}
void _gstep_dispatch_runloop_timer(id runloop, id ctx, uint64_t ms)
{
	fprintf(stderr, "entered call at %s\n", __PRETTY_FUNCTION__);
}*/
void _gstep_dispatch_runloop(uint64_t ms)
{
	fprintf(stderr, "entered call at %s\n", __PRETTY_FUNCTION__);
}

