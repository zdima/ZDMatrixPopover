//
//  ZDMatrixPopover.swift
//  ZDMatrixPopover
//
//  Created by Dmitriy Zakharkin on 1/7/17.
//  Copyright © 2017 Dmitriy Zakharkin. All rights reserved.
//
import Cocoa

@objc public protocol ZDMatrixPopoverDelegate {
    /// getColumnFormatter return an optional Formatter object to be use for specified column.
    /// This method is called when popup is constructed first time or when data size has changed since last call.
    /// This method can return nil if there is no formatter to be used.
    /// When attributedString is called, the withDefaultAttributes include following information:
    ///    "column"    : NSNumber()
    ///    "row"       : NSNumber
    ///    "alignment" : NSTextAlignment
    func getColumnFormatter(column: Int) -> Formatter?
    /// getColumnAlignment return an optional alignment attribute for specified column.
    /// This method is called when popup is constructed first time or when data size has changed since last call.
    /// This method can return nil if there is no special aligment needed.
    /// By default all count will be aligned to NSTextAlignment.left
    func getColumnAlignment(column: Int) -> NSTextAlignment
    /// getColumnWidth return width of the column.
    /// The width will be calculated based on content when getColumnWidth return -1.
    /// By default getColumnWidth will return -1.
    func getColumnWidth(column: Int) -> Int
}

@objc(ZDMatrixPopover)
@IBDesignable public class ZDMatrixPopover: NSObject {

    internal var controller: ZDMatrixPopoverController!

    public required override init() {
        super.init()
        controller = ZDMatrixPopoverController(owner:self)
    }

    public override func prepareForInterfaceBuilder() {
        titleFontSize = NSFont.systemFontSize(for: NSControlSize.regular)
    }

    /// Delegate object of type ZDMatrixPopoverDelegate
    /// Due to storyboard limitation we have to use AnyObject as type to allow storyboard binding.
    ///
    ///  Interface Builder
    ///
    ///  Interface Builder does not support connecting to an outlet in a Swift file
    ///  when the outlet’s type is a protocol. Declare the outlet's type as AnyObject
    ///  or NSObject, connect objects to the outlet using Interface Builder, then change
    ///  the outlet's type back to the protocol. (17023935)
    ///
    @IBOutlet public weak var delegate: AnyObject? {
        set {
            if let newDelegate = newValue as? ZDMatrixPopoverDelegate {
                self.controller.m_delegate = newDelegate
            }
        }
        get {
            return self.controller.m_delegate
        }
    }

    @IBInspectable public var titleFontSize: CGFloat = NSFont.systemFontSize(for: NSControlSize.regular)
    @IBInspectable public var dataFontSize: CGFloat = NSFont.systemFontSize(for: NSControlSize.regular)

    public func show(
        data: [[Any]],
        title: String,
        relativeTo rect: NSRect,
        of view: NSView,
        preferredEdge: NSRectEdge) throws {
        try controller.show(data: data, title: title, relativeTo: rect, of: view, preferredEdge: preferredEdge)
    }

    public func close() throws {
        try controller.close()
    }

    public private(set) var isShown: Bool {
        get {
            return controller.isShown
        }
        set {
        }
    }
}
