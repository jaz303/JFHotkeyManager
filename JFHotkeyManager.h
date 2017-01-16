//
//  JFHotkeyManager.h
//  JFHotkeyManager
//
//  Created by Jason Frame on 23/02/2010.
//  Copyright 2010 Jason Frame. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>

typedef NSUInteger JFHotKeyRef;

@interface JFHotkeyManager : NSObject {

	NSMutableDictionary		*_hotkeys;
	UInt32  				_nextId;
	
}

- (JFHotKeyRef)bind:(NSString *)commandString
			 target:(id)target
			 action:(SEL)selector;

- (JFHotKeyRef)bindKeyRef:(UInt32)keyRef
			withModifiers:(UInt32)modifiers
				   target:(id)target
				   action:(SEL)selector;

- (void)unbind:(JFHotKeyRef)keyRef;

- (void)_dispatch:(NSUInteger)hotkeyId;

@end

@interface __JFHotkey : NSObject {
	id				_target;
	SEL				_action;
	EventHotKeyRef	_ref;
}

- (id)initWithHotkeyID:(UInt32)hotkeyID
				keyRef:(UInt32)keyRef
			 modifiers:(UInt32)modifiers
				target:(id)target
				action:(SEL)selector;

- (void)invoke;

@end
