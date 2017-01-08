//
//  ZDMatrixPopoverLayout.swift
//  ZDMatrixPopover
//
//  Created by Dmitriy Zakharkin on 1/7/17.
//  Copyright © 2017 Dmitriy Zakharkin. All rights reserved.
//

import Cocoa

@objc(ZDMatrixPopoverLayout)
class ZDMatrixPopoverLayout: NSCollectionViewGridLayout {

    internal var rowHeight: Int = 0
    internal var colWidth: [Int] = []
    internal var contentSize = NSSize.zero

    override func prepare() {
        guard let collection = collectionView else {return}
        guard let delegate = collection.dataSource as? ZDMatrixPopoverController else {return}

        let textField: NSTextField!
        if #available(OSX 10.12, *) {
            textField = NSTextField(labelWithString: "xyx" )
        } else {
            textField = NSTextField()
            textField.translatesAutoresizingMaskIntoConstraints = false
            textField.isEditable = false
            textField.isBezeled = false
            textField.drawsBackground = false
            textField.isSelectable = false
            textField.alignment = .center
        }
        textField.maximumNumberOfLines = 1

        colWidth = [Int].init(repeating: 0, count: delegate.lastColumnCount)
        for row in 0..<delegate.lastRowCount {
            for col in 0..<delegate.lastColumnCount {
                var width: Int!
                if let popupDelegate = delegate.m_delegate {
                    width = popupDelegate.getColumnWidth(column: col)
                } else {
                    width = -1
                }
                if width == -1 || rowHeight == 0 {
                    delegate.initCellValue(textField: textField, row: row, col: col)
                    textField.sizeToFit()
                    rowHeight = max( rowHeight, Int(textField.fittingSize.height))
                }
                if width == -1 {
                    width = Int(textField.fittingSize.width)
                }
                colWidth[col] = max(colWidth[col], width)
            }
        }

        var width = colWidth.reduce(0, +)
        width += (colWidth.count + 1) * 2
        var height = rowHeight * delegate.lastRowCount
        height += (delegate.lastRowCount + 1) * 2

        contentSize = NSSize(width: width, height: height)
    }

    override var collectionViewContentSize: NSSize {
        get {
            return contentSize
        }
        set {}
    }

    override func layoutAttributesForElements(in rect: NSRect) -> [NSCollectionViewLayoutAttributes] {
        guard let collection = collectionView else {return []}
        guard let delegate = collection.dataSource as? ZDMatrixPopoverController else {return []}
        var attrs: [NSCollectionViewLayoutAttributes] = []
        var y: Int = 2
        for row in 0..<delegate.lastRowCount {
            var x: Int = 2
            for col in 0..<delegate.lastColumnCount {
                let cellRect = NSRect(x: x, y: y, width: colWidth[col], height: rowHeight)
                if rect.contains(cellRect) {
                    let attr = NSCollectionViewLayoutAttributes(forItemWith:
                        IndexPath(item: row*delegate.lastColumnCount + col, section: 0))
                    attr.frame = cellRect
                    attrs.append(attr)
                }
                x += colWidth[col] + 2
            }
            y += rowHeight + 2
        }
        return attrs
    }
}
