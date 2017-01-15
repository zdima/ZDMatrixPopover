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

    private var owner: ZDMatrixPopover!
    private var bundle: Bundle!
    private var nib: NSNib!
    private var lastTimer: Timer?

    public required init(owner myOwner: ZDMatrixPopover! ) {
        owner = myOwner
        super.init()
        bundle = Bundle(for: ZDMatrixPopover.self)
        bundle.loadNibNamed("ZDMatrixPopover", owner: self, topLevelObjects: &objects)
        nib = NSNib(nibNamed: "NSCollectionViewItem", bundle: bundle)

        m_collectionView.register( nib, forItemWithIdentifier: "dataSourceItem")
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
        preferredEdge: NSRectEdge) {

        assert( m_popover != nil, "Failed to load 'ZDMatrixPopover'")

        if m_popover.isShown {
            if lastTimer != nil {
                lastTimer!.invalidate()
            }
            lastTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: Selector("timerShow:"), userInfo: [ "data": data, "title": title, "rect": rect, "view": view, "preferredEdge": preferredEdge], repeats: false)
            return
        }

        m_titleLabel.stringValue = title
        m_data = data

        if !m_popover.contentViewController!.isViewLoaded {
            m_popover.contentViewController!.loadView()
        }

        m_collectionView.collectionViewLayout!.prepare()
        m_collectionView.reloadData()

        let collectionSize = m_collectionView.collectionViewLayout!.collectionViewContentSize
        collectionWidthConstraint.constant = collectionSize.width
        collectionHeightConstraint.constant = collectionSize.height
        m_collectionView.needsLayout = true
        m_collectionView.superview?.layoutSubtreeIfNeeded()

        m_collectionView.reloadData()

        m_popover.contentViewController!.view.setFrameSize(m_popover.contentViewController!.view.fittingSize)


        m_popover.contentSize = m_popover.contentViewController!.view.bounds.size
        let mustSize = m_popover.contentSize

        m_popover.show(relativeTo:rect, of: view, preferredEdge: preferredEdge)
    }

    func timerShow(_ arg: Any?) {

        guard let timer = arg as? Timer else { return }
        guard let userInfoMap = timer.userInfo as? [String: Any?] else { return }

        DispatchQueue.main.async() {

            self.m_titleLabel.stringValue = userInfoMap["title"] as! String
            self.m_data = userInfoMap["data"] as! [[Any]]

            // make sure layout manager has been updated
            self.m_collectionView.collectionViewLayout!.prepare()
            self.m_collectionView.reloadData()

            let collectionSize = self.m_collectionView.collectionViewLayout!.collectionViewContentSize
            self.collectionWidthConstraint.constant = collectionSize.width
            self.collectionHeightConstraint.constant = collectionSize.height

            self.m_popover.positioningRect = userInfoMap["rect"] as! NSRect
            self.m_popover.contentViewController!.view.layoutSubtreeIfNeeded()
            self.m_popover.contentSize = self.m_popover.contentViewController!.view.bounds.size

            self.m_collectionView.reloadData()
        }
    }

    public func close() {
        assert( m_popover != nil, "Failed to load 'ZDMatrixPopover'")
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

            lastColumnCount = colCount
            lastRowCount = rowCount

            m_formatter = [Formatter?].init(repeating: nil, count: colCount)
            if m_delegate != nil {
                for col in 0..<colCount {
                    if let formatter = m_delegate!.getColumnFormatter(column: col) {
                        m_formatter[col] = formatter
                    }
                }
            }
            m_collectionView.reloadData()
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
        if m_data.count <= row { return }
        let rowData = m_data[row]
        if rowData.count <= col { return }
        let data = rowData[col]
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
            if attributedString != nil && m_delegate != nil {
                let alignment = m_delegate!.getColumnAlignment(column: col)
                if let mutableString = attributedString!.mutableCopy() as? NSMutableAttributedString {
                    let paragraph = NSMutableParagraphStyle()
                    paragraph.alignment = alignment
                    mutableString.addAttribute( NSParagraphStyleAttributeName, value: paragraph, range: NSMakeRange(0, mutableString.length))
                    attributedString = mutableString
                }
            }
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
        guard let item = NSCollectionViewItem(nibName: "NSCollectionViewItem", bundle: bundle) else { return NSCollectionViewItem() }
        item.loadView()

        let row = Int( indexPath.item / lastColumnCount )
        let col = Int( indexPath.item % lastColumnCount )

        initCellValue(textField: item.textField!, row: row, col: col)

        if let matrix = collectionView.collectionViewLayout as? ZDMatrixPopoverLayout,
            let attr = matrix.layoutAttributesForItem(at: indexPath ) {
            item.view.frame = attr.frame
        }

        return item
    }

    public func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        if m_data.count == 0 {
            return 0
        }
        return m_data.count * m_data[0].count
    }

    public func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
}
