JFHotkeyManager
===============

&copy; 2010 Jason Frame [ [jason@onehackoranother.com](mailto:jason@onehackoranother.com) / [@jaz303](http://twitter.com/jaz303) ]  
Released under the MIT License.

JFHotkeyManager is a small Cocoa convenience wrapper around Carbon's mechanism for implementing global hotkeys. It allows you to add hotkeys to your app with a couple of lines of code.

Installation
------------

Copy `JFHotkeyManager.h` and `JFHotkeyManager.m` into your Xcode project

Usage
-----

Hotkeys can be bound either by individually specifying keycode/modifiers, or symbolically using a string. The latter is more convenient but probably less reliable across international keyboards.

    // Initialise a new hotkey manager
    JFHotkeyManager *hkm = [[JFHotkeyManager alloc] init];

    // Bind a hotkey by key code reference number and modifiers:
    // (when hotkey is triggered, sends mySelector1 to self)
    [hkm bindKeyRef:49
      withModifiers:cmdKey + optionKey + shiftKey
             target:self
             action:@selector(mySelector1)];
    
    // Bind a hotkey symbolically
    // (when hotkey is triggered, sends mySelector2 to self)
    [hkm bind:@"command shift up" target:self action:@selector(mySelector2)];
    
The bind methods return an opaque value of type `JFHotKeyRef` that can be latter passed to `unbind:` to unbind the hotkey.

Credits
-------

[Program Global Hotkeys in Cocoa Easily](http://dbachrach.com/blog/2005/11/program-global-hotkeys-in-cocoa-easily/) by Dustin Bachrach