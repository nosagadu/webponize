import Cocoa

class DropView: NSView, NSDraggingDestination {
    
    var cwebp: Cwebp = Cwebp()
    var config: ApplicationConfig = ApplicationConfig()
    
    override init(frame: NSRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        // configure as default if not set
        config.setDefaultValues()
    }
    
    override func drawRect(dirtyRect: NSRect) {
        
        //NSColor(calibratedWhite: 255.0, alpha: 0.8).set()
        //NSRectFillUsingOperation(dirtyRect, NSCompositingOperation.CompositeSourceOver)
        //super.drawRect(dirtyRect)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        let acceptDragTypes = [
            NSPasteboardTypePNG,
            NSColorPboardType,
            NSFilenamesPboardType
            //NSImage.imagePasteboardTypes()
        ]

        registerForDraggedTypes(acceptDragTypes)
    }
    
    override func performDragOperation(sender: NSDraggingInfo) -> Bool {
        
        let compressionLevel: Int = config.getCompressionLevel()
        let isLossless: Bool = config.getIsLossless()
        let isNoAlpha: Bool = config.getIsNoAlpha()
        
        // get dragged files' path
        let pboard: NSPasteboard = sender.draggingPasteboard()
        let filePaths: [String] = pboard.propertyListForType(NSFilenamesPboardType) as [String]
        
        // load dropped files using NSFileManager
        let manager: NSFileManager = NSFileManager.defaultManager()
        var error: NSError?

        for filePath in filePaths {
            let converter = libwebp(filePath: filePath)
            converter.encode(compressionLevel, isLossless: isLossless, isNoAlpha: isNoAlpha);
        }
        
        return true
    }
    
    var onDraggingEnteredHandler: ((sender: NSDraggingInfo) -> Void)?
    
    var onDraggingExitedHandler: ((sender: NSDraggingInfo) -> Void)?
    
    var onDraggingEndedHandler: ((sender: NSDraggingInfo) -> Void)?
    
    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation  {
        
        // delegate to view controller
        self.onDraggingEnteredHandler?(sender: sender)
        
        return NSDragOperation.Copy
    }
    
    override func draggingExited(sender: NSDraggingInfo?) {
        
        // delegate to view controller
        self.onDraggingExitedHandler?(sender: sender!)
    }

    override func draggingEnded(sender: NSDraggingInfo?) {
        
        // delegate to view controller
        self.onDraggingEndedHandler?(sender: sender!)
    }
}
