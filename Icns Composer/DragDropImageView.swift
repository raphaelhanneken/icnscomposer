//
//  DragDropImageView.swift
//  DragDropImageView
//
//  Created by Raphael Hanneken on 25/05/15.
//  Copyright (c) 2015 Raphael Hanneken. All rights reserved.
//

import Cocoa

class DragDropImageView: NSImageView, NSDraggingSource {
    
    var mouseDownEvent: NSEvent?       // Holds the last mouse down event, to track the drag distance.
    
    

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        // Assure editable is set to true, to enable drop capabilities.
        self.editable = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        // Assure editable is set to true, to enable drop capabilities.
        self.editable = true
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
    }
    
    
    
    // MARK: - NSDraggingSource
    
    // Since we only want to copy/delete the current image we register ourselfes 
    // for .Copy and .Delete operations.
    func draggingSession(session: NSDraggingSession, sourceOperationMaskForDraggingContext context: NSDraggingContext) -> NSDragOperation {
        return .Copy | .Delete
    }
    
    // Clear the ImageView on delete operation; e.g. the image gets
    // dropped on the trash can in the dock.
    func draggingSession(session: NSDraggingSession, endedAtPoint screenPoint: NSPoint, operation: NSDragOperation) {
        if operation == .Delete {
            self.image = nil
        }
    }
    
    // Track mouse down events and safe the to the poperty.
    override func mouseDown(theEvent: NSEvent) {
        self.mouseDownEvent = theEvent
    }
    
    // Track mouse dragged events to handle dragging sessions.
    override func mouseDragged(theEvent: NSEvent) {
        // Calculate the drag distance...
        let mouseDown    = self.mouseDownEvent!.locationInWindow
        let dragPoint    = theEvent.locationInWindow
        let dragDistance = hypot(mouseDown.x - dragPoint.x, mouseDown.y - dragPoint.y)
        
        // ...to cancel the dragging session in case of accidental drag.
        if dragDistance < 3 {
            return
        }
        
        // Unwrap the image property
        if let image = self.image {
            // Do some math to properly resize the given image.
            let size = NSSize(width: log10(image.size.width) * 30, height: log10(image.size.height) * 30)
            let img  = image.copyWithSize(size)!
            
            // Create a new NSDraggingItem with the image as content.
            let draggingItem        = NSDraggingItem(pasteboardWriter: image)
            // Calculate the mouseDown location from the window's coordinate system to the 
            // ImageView's coordinate system, to use it as origin for the dragging frame.
            let draggingFrameOrigin = convertPoint(mouseDown, fromView: nil)
            // Build the dragging frame and offset it by half the image size on each axis
            // to center the mouse cursor within the dragging frame.
            let draggingFrame       = NSRect(origin: draggingFrameOrigin, size: img.size).rectByOffsetting(dx: -img.size.width / 2, dy: -img.size.height / 2)
            
            // Assign the dragging frame to the draggingFrame property of our dragging item.
            draggingItem.draggingFrame = draggingFrame
            
            // Provide the components of the dragging image.
            draggingItem.imageComponentsProvider = {
                let component = NSDraggingImageComponent(key: NSDraggingImageComponentIconKey)
                
                component.contents = image
                component.frame    = NSRect(origin: NSPoint(), size: draggingFrame.size)
                return [component]
            }
            
            // Begin actual dragging session. Woohow!
            beginDraggingSessionWithItems([draggingItem], event: mouseDownEvent!, source: self)
        }
    }
}
