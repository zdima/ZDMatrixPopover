//
//  ZDMatrixPopoverController.swift
//  ZDMatrixPopover
//
//  Created by Dmitriy Zakharkin on 1/7/17.
//  Copyright © 2017 Dmitriy Zakharkin. All rights reserved.
//
// swiftlint:disable variable_name force_cast

import Cocoa

extension ZDMatrixPopoverDelegate {
    func getColumnAlignment(column: Int) -> NSTextAlignment {
        return .left
    }
}

class ZDMatrixPopoverController: NSObject,
        NSCollectionViewDelegate,
        NSCollectionViewDataSource,
        NSCollectionViewDelegateFlowLayout {

    var owner: ZDMatrixPopover!

    public required init(owner myOwner: ZDMatrixPopover! ) {
        owner = myOwner
        super.init()
        Bundle.main.loadNibNamed("ZDMatrixPopover", owner: self, topLevelObjects: &objects)
        m_collectionView.register(NSCollectionViewItem.self, forItemWithIdentifier: "dataSourceItem")
        m_collectionView.backgroundColors = [ NSColor.clear, NSColor.clear]
        m_titleLabel.font = NSFont.titleBarFont(ofSize: owner.titleFontSize)
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
        didSet {
            m_delegate = delegate as? ZDMatrixPopoverDelegate
        }
    }

    public func show(
        data: [[Any]],
        title: String,
        relativeTo rect: NSRect,
        of view: NSView,
        preferredEdge: NSRectEdge) throws {
        if m_popover == nil {
            // swiftlint:disable force_cast
            throw NSException(name: NSExceptionName.nibLoadingException,
                              reason: "Failed to load 'ZDMatrixPopover'", userInfo: nil) as! Error
            // swiftlint:enable force_cast
        }
        m_data = data
        m_titleLabel.stringValue = title

        m_collectionView.collectionViewLayout!.prepare()
        let collectionSize = m_collectionView.collectionViewLayout!.collectionViewContentSize
        collectionWidthConstraint.constant = collectionSize.width
        collectionHeightConstraint.constant = collectionSize.height
        m_popover.contentViewController!.view.setFrameSize(m_popover.contentViewController!.view.fittingSize)
        m_popover.contentSize = m_popover.contentViewController!.view.bounds.size
        m_popover.show(relativeTo:rect, of: view, preferredEdge: preferredEdge)
    }

    public func close() throws {
        if m_popover == nil {
            // swiftlint:disable force_cast
            throw NSException(name: NSExceptionName.nibLoadingException,
                              reason: "Failed to load 'ZDMatrixPopover'", userInfo: nil) as! Error
            // swiftlint:enable force_cast
        }
        m_popover.close()
    }

    public private(set) var isShown: Bool {
        get {
            if m_popover == nil {
                return false
            }
            return m_popover.isShown
        }
        set {
        }
    }

    internal weak var m_delegate: ZDMatrixPopoverDelegate?

    internal var lastColumnCount: Int = -1
    internal var lastRowCount: Int = -1

    private var m_data: [[Any]] = [[]] {
        didSet {
            let colCount = m_data.reduce(0) { (r, a) in return max(r, a.count)}
            let rowCount = m_data.count

            if lastColumnCount != colCount || lastRowCount != rowCount {
                setupCollectionView(columnCount: colCount, rowCount: rowCount)
            }
            m_collectionView.reloadData()
            m_collectionView.collectionViewLayout!.invalidateLayout()
            m_collectionView.needsDisplay = true
        }
    }

    @IBOutlet internal var m_popover: NSPopover!
    @IBOutlet internal var m_popoverView: NSView!
    @IBOutlet internal weak var m_titleLabel: NSTextField!
    @IBOutlet internal weak var m_collectionView: NSCollectionView!
    @IBOutlet internal weak var collectionHeightConstraint: NSLayoutConstraint!
    @IBOutlet internal weak var collectionWidthConstraint: NSLayoutConstraint!
    @IBOutlet internal var collectionBackgroundView: NSView!

    private var objects: NSArray = []
    private var m_formatter: [Formatter?] = []

    private func setupCollectionView(columnCount: Int, rowCount: Int) {

        lastColumnCount = columnCount
        lastRowCount = rowCount

        m_collectionView.maxNumberOfColumns = columnCount
        m_collectionView.collectionViewLayout!.invalidateLayout()

        m_formatter = [Formatter?].init(repeating: nil, count: columnCount)
        if m_delegate != nil {
            for col in 0..<columnCount {
                if let formatter = m_delegate!.getColumnFormatter(column: col) {
                    m_formatter[col] = formatter
                }
            }
        }
    }

    internal func initCellValue( textField: NSTextField, row: Int, col: Int) {
        textField.font = NSFont.labelFont(ofSize: owner.dataFontSize)
        // Configure the item with an image from the app's data structures
        let data = m_data[row][col]
        var attributedString: NSAttributedString?
        var string: String?
        if m_delegate != nil {
            textField.alignment = m_delegate!.getColumnAlignment(column: col)
        }
        if let formatter = m_formatter[col] {
            attributedString = formatter.attributedString(for: data, withDefaultAttributes: [
                "column": NSNumber(value: col),
                "row": NSNumber(value: row),
                "alignment": textField.alignment])
            string = formatter.string(for: data)
        } else if let attributedStringData = data as? NSAttributedString {
            attributedString = attributedStringData
        } else if let stringData = data as? String {
            string = stringData
        } else {
            string = ""
        }

        if attributedString != nil {
            textField.attributedStringValue = attributedString!
        } else if string != nil {
            textField.stringValue = string!
        }
    }

    public func collectionView(_ collectionView: NSCollectionView,
                               itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {

        // Recycle or create an item.
        let item = m_collectionView.makeItem(withIdentifier: "dataSourceItem", for: indexPath)

        let row = Int( indexPath.item / m_collectionView.maxNumberOfColumns )
        let col = Int( indexPath.item % m_collectionView.maxNumberOfColumns )

        initCellValue(textField: item.textField!, row: row, col: col)

        return item
    }

    public func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return lastColumnCount * lastRowCount
    }

    public func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
}
