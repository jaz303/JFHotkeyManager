#import "JFHotkeyManagerAppDelegate.h"
#import "JFHotkeyManager.h"

@implementation JFHotkeyManagerAppDelegate {
    JFHotkeyManager *hkm;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

	hkm = [[JFHotkeyManager alloc] init];
	
	// Bind using key code and modifiers
	[hkm bindKeyRef:49 withModifiers:cmdKey + optionKey + shiftKey target:self action:@selector(hotkey1)];
	
	// Bind using command string
	[hkm bind:@"cmd shift up" target:self action:@selector(hotkey2)];
	
}

- (void)hotkey1 {
	NSLog(@"Hotkey 1 pressed");
}

- (void)hotkey2 {
	NSLog(@"Hotkey 2 pressed");
}

@end
