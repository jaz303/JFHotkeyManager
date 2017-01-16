//
//  JFHotkeyManager.m
//  JFHotkeyManager
//
//  Created by Jason Frame on 23/02/2010.
//  Copyright 2010 Jason Frame. All rights reserved.
//

#import "JFHotkeyManager.h"

static OSStatus hotkeyHandler(EventHandlerCallRef hnd,
							  EventRef evt,
							  void *data) {
	
	EventHotKeyID hkID;
	GetEventParameter(evt, kEventParamDirectObject, typeEventHotKeyID, NULL, sizeof(hkID), NULL, &hkID);
	
	JFHotkeyManager *hkm = (__bridge JFHotkeyManager *)data;
	[hkm _dispatch:hkID.id];
	
	return noErr;
	
}

static NSMutableDictionary *keyMap;
static NSMutableDictionary *modMap;

static void mapKey(NSString *s, NSUInteger key) {
    keyMap[s] = @(key);
}

static void mapMod(NSString *s, NSUInteger mod) {
    modMap[s] = @(mod);
}


@implementation __JFHotkey
- (id)initWithHotkeyID:(UInt32)hotkeyID
				keyRef:(UInt32)keyRef
			 modifiers:(UInt32)modifiers
				target:(id)target
				action:(SEL)selector {
	if (self = [super init]) {
		
		EventHotKeyID kID;
		kID.id = kID.signature = hotkeyID;
		
		RegisterEventHotKey(keyRef, modifiers, kID, GetApplicationEventTarget(), 0, &_ref);
		
		_target = target;
		_action = selector;
		
	}
	return self;
}

- (void)dealloc {
	UnregisterEventHotKey(_ref);
}

- (void)invoke {
    IMP imp = [_target methodForSelector:_action];
    void (*func)(id, SEL) = (void *)imp;
    func(_target, _action);
}
@end


@implementation JFHotkeyManager

+ (void)initialize {
	
	modMap = [[NSMutableDictionary alloc] init];
	keyMap = [[NSMutableDictionary alloc] init];
	
	// Is this guaranteed to be the same across systems/keyboards?
	// Probably not.
	
	//
	// Keys
	
	mapKey(@"a",		0x00);
	mapKey(@"b",		0x0B);
	mapKey(@"c",		0x09);
	mapKey(@"d",		0x02);
	mapKey(@"e",		0x0E);
	mapKey(@"f",		0x03);
	mapKey(@"g",		0x05);
	mapKey(@"h",		0x04);
	mapKey(@"i",		0x22);
	mapKey(@"j",		0x26);
	mapKey(@"k",		0x29);
	mapKey(@"l",		0x25);
	mapKey(@"m",		0x2E);
	mapKey(@"n",		0x2D);
	mapKey(@"o",		0x1F);
	mapKey(@"p",		0x23);
	mapKey(@"q",		0x0C);
	mapKey(@"r",		0x0F);
	mapKey(@"s",		0x01);
	mapKey(@"t",		0x11);
	mapKey(@"u",		0x20);
	mapKey(@"v",		0x09);
	mapKey(@"w",		0x0D);
	mapKey(@"x",		0x07);
	mapKey(@"y",		0x10);
	mapKey(@"z",		0x06);
	
	mapKey(@"0",		0x1D);
	mapKey(@"1",		0x12);
	mapKey(@"2",		0x13);
	mapKey(@"3",		0x14);
	mapKey(@"4",		0x15);
	mapKey(@"5",		0x17);
	mapKey(@"6",		0x16);
	mapKey(@"7",		0x1A);
	mapKey(@"8",		0x1C);
	mapKey(@"9",		0x19);
	
	mapKey(@",",		0x2B);
	mapKey(@".",		0x2F);
	mapKey(@"/",		0x2C);
	
	mapKey(@"f1",		0x7A);
	mapKey(@"f2",		0x79);
	mapKey(@"f3",		0x63);
	mapKey(@"f4",		0x76);
	mapKey(@"f5",		0x60);
	mapKey(@"f6",		0x61);
	mapKey(@"f7",		0x62);
	mapKey(@"f8",		0x64);
	mapKey(@"f9",		0x65);
	mapKey(@"f10",		0x6D);
	mapKey(@"f11",		0x67);
	mapKey(@"f12",		0x6F);
	mapKey(@"f13",		0x69);
	mapKey(@"f14",		0x6B);
	mapKey(@"f15",		0x71);
	
	mapKey(@"escape",	0x35);
	mapKey(@"esc",		0x35);
	mapKey(@"space",	0x31);
	mapKey(@"enter",	0x24);
	mapKey(@"tab",		0x30);
	mapKey(@"backspace",0x33);
	mapKey(@"bkspc",	0x33);
	
	mapKey(@"left",		0x7B);
	mapKey(@"right",	0x7C);
	mapKey(@"down",		0x7D);
	mapKey(@"up",		0x7E);
	
	//
	// Modifiers
	
	mapMod(@"apple",	cmdKey);
	
	mapMod(@"ctrl",		controlKey);
	mapMod(@"ctl",		controlKey);
	mapMod(@"control",	controlKey);
	
	mapMod(@"opt",		optionKey);
	mapMod(@"option",	optionKey);
	mapMod(@"alt",		optionKey);
	
	mapMod(@"cmd",		cmdKey);
	mapMod(@"command",	cmdKey);
	mapMod(@"apple",	cmdKey);
	
	mapMod(@"shift",	shiftKey);
	
}

- (id)init {
	if (self = [super init]) {
		
		_hotkeys = [[NSMutableDictionary alloc] init];
		_nextId = 1;
		
		EventTypeSpec evtType;
		evtType.eventClass = kEventClassKeyboard;
		evtType.eventKind = kEventHotKeyPressed;
		InstallApplicationEventHandler(&hotkeyHandler,
									   1,
									   &evtType,
									   (__bridge void*)self,
									   NULL);
		
	}
	return self;
}

- (JFHotKeyRef)bind:(NSString *)commandString
	  target:(id)target
	  action:(SEL)selector {
	
	UInt32 keyRef		= 0;
	UInt32 modifiers	= 0;
	
	NSArray *bits = [[commandString lowercaseString] componentsSeparatedByString:@" "];
	for (NSString *bit in bits) {
		
		NSNumber *code = modMap[bit];
		if (code != nil) {
			modifiers += [code unsignedIntValue];
			continue;
		}
		
		code = keyMap[bit];
		if (code != nil) {
			keyRef = [code unsignedIntValue];
			continue;
		}
		
	}
	
	return [self bindKeyRef:keyRef
			  withModifiers:modifiers
				     target:target
					 action:selector];

}

- (JFHotKeyRef)bindKeyRef:(UInt32)keyRef
	 withModifiers:(UInt32)modifiers
		    target:(id)target
			action:(SEL)selector {
	
	UInt32 keyID = _nextId;
	_nextId++;
	
	__JFHotkey *hk = [[__JFHotkey alloc] initWithHotkeyID:keyID
												   keyRef:keyRef
												modifiers:modifiers
												   target:target
												   action:selector];
	
	_hotkeys[@(keyID)] = hk;
	
	return keyID;

}

- (void)unbind:(JFHotKeyRef)keyRef {
	[_hotkeys removeObjectForKey:@(keyRef)];
}

- (void)_dispatch:(NSUInteger)hotkeyId {
	[_hotkeys[@(hotkeyId)] invoke];
}

@end
