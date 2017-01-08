//
//  ViewController.swift
//  ZDMatrixPopover
//
//  Created by Dmitriy Zakharkin on 1/7/17.
//  Copyright © 2017 Dmitriy Zakharkin. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, ZDMatrixPopoverDelegate {

    @IBOutlet var popover: ZDMatrixPopover!

    @IBAction func clickMe(_ sender: Any) {

        guard let button = sender as? NSView else {return}

        if popover == nil {
            popover = ZDMatrixPopover()
        }

        if popover!.isShown {
            do { try popover!.close() } catch { print("exception:\(error)") }
            return
        }

        let rightAlign: NSMutableParagraphStyle = NSMutableParagraphStyle()
        rightAlign.alignment = .right

        do {
            try popover!.show(data: [
                ["1", "2 aa", "3", "x"],
                ["4 aaa", "5", NSAttributedString(string: "6", attributes: [
                    NSForegroundColorAttributeName: NSColor.red,
                    NSParagraphStyleAttributeName: rightAlign
                    ]), "x"],
                ["7", "8", "9 a", "NSParagraphStyleAttributeName"]
                ], title: "Test popover with long title",
                   relativeTo: button.frame, of: button.superview!, preferredEdge: .maxY)
        } catch { print("exception:\(error)") }
    }

    func getColumnFormatter(column: Int) -> Formatter? {
        return nil
    }

    func getColumnAlignment(column: Int) -> NSTextAlignment {
        if column == 2 {
            return .right
        }
        return .left
    }

    func getColumnWidth(column: Int) -> Int {
        return -1
    }
}
