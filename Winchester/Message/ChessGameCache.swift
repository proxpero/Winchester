//
//  ChessGameCache.swift
//  Winchester
//
//  Created by Todd Olsen on 11/18/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import UIKit
import Messages
import Endgame

class ChessGameCache {

    static let cache = ChessGameCache()

    private let cacheURL: URL

    private let queue = OperationQueue()

    let placeholderSticker: MSSticker = {
        let bundle = Bundle.main
        guard let placeholderURL = bundle.url(forResource: "sticker_placeholder", withExtension: "png") else {
            fatalError("Unable to find a placeholder sticker image")
        }

        do {
            let description = NSLocalizedString("A chess game sticker", comment: "")
            return try MSSticker(contentsOfFileURL: placeholderURL, localizedDescription: description)
        }
        catch {
            fatalError("Failed to create placeholder sticker: \(error)")
        }
    }()

    private init() {
        let fileManager = FileManager.default
        let tempPath = NSTemporaryDirectory()
        let directoryName = UUID().uuidString

        do {
            cacheURL = URL(fileURLWithPath: tempPath).appendingPathComponent(directoryName)
            try fileManager.createDirectory(at: cacheURL, withIntermediateDirectories: true, attributes: nil)
        }
        catch {
            fatalError("Unable to create cache URL: \(error)")
        }
    }

    deinit {
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: cacheURL)
        }
        catch {
            print("Unable to remove cache directory: \(error)")
        }
    }

}
