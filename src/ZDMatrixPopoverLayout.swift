//
//  ZDMatrixPopoverLayout.swift
//  ZDMatrixPopover
//
//  Created by Dmitriy Zakharkin on 1/7/17.
//  Copyright © 2017 Dmitriy Zakharkin. All rights reserved.
//

import Cocoa

@objc(ZDMatrixPopoverLayout)
class ZDMatrixPopoverLayout: NSCollectionViewLayout {

    private var contentSize = NSSize.zero
    private var itemCount: Int = 0
    private var layoutAttributes: [IndexPath: NSCollectionViewLayoutAttributes] = [:]

    override func prepare() {
        super.prepare()

        guard let collection = collectionView else {return}
        guard let delegate = collection.dataSource as? ZDMatrixPopoverController else {return}

        var rowHeight: Int = 0
        var colWidth: [Int] = []

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

        var y: Int = 2
        layoutAttributes = [:]
        for row in 0..<delegate.lastRowCount {
            var x: Int = 2
            for col in 0..<delegate.lastColumnCount {
                let cellRect = NSRect(x: x, y: y, width: colWidth[col], height: rowHeight)
                let attr = NSCollectionViewLayoutAttributes(forItemWith:
                    IndexPath(item: row*delegate.lastColumnCount + col, section: 0))
                attr.frame = cellRect
                attr.size = cellRect.size
                layoutAttributes[IndexPath(item: row*delegate.lastColumnCount + col, section: 0)] = attr
                x += colWidth[col] + 2
            }
            y += rowHeight + 2
        }

        var width = colWidth.reduce(0, +)
        width += (colWidth.count + 1) * 2
        var height = rowHeight * delegate.lastRowCount
        height += (delegate.lastRowCount + 1) * 2

        contentSize = NSSize(width: width, height: height)

        itemCount = delegate.lastRowCount * delegate.lastColumnCount
    }

    override var collectionViewContentSize: NSSize {
        get {
            return contentSize
        }
        set {}
    }
    override func layoutAttributesForItem(at indexPath: IndexPath) -> NSCollectionViewLayoutAttributes? {
        if indexPath.item >= itemCount {
            print("index \(indexPath.item) out of range \(itemCount)")
            return nil
        }
        return layoutAttributes[indexPath]
    }

    override func layoutAttributesForElements(in rect: NSRect) -> [NSCollectionViewLayoutAttributes] {
        return Array(layoutAttributes.values.filter { $0.frame.intersects(rect) })
    }

    override func shouldInvalidateLayout(forPreferredLayoutAttributes preferredAttributes: NSCollectionViewLayoutAttributes, withOriginalAttributes originalAttributes: NSCollectionViewLayoutAttributes) -> Bool {
        return true
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: NSRect) -> Bool {
        return true
    }
}
