//
//  GameImageCache.swift
//  Winchester
//
//  Created by Todd Olsen on 11/21/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import UIKit
import Endgame

class GameImageCache {

    static let cache = GameImageCache()

    private let cacheURL: URL

    private let queue = OperationQueue()

    let placeholderImage: UIImage = #imageLiteral(resourceName: "placeholder")

    func image(for game: Game, completion: @escaping (UIImage) -> Void) {
        let url = cacheURL.appendingPathComponent(game.url.absoluteString)

        // Create an operation to process the request.
        let operation = BlockOperation {
            // Check if the sticker already exists at the URL.
            let fileManager = FileManager.default
            guard !fileManager.fileExists(atPath: url.absoluteString) else { return }

            // Create the sticker image and write it to disk.
            guard
                let image = UIImage(view: game.currentPosition.board.view(edge: 300)),
                let data = UIImagePNGRepresentation(image)
                else { fatalError() }

            do {
                try data.write(to: url, options: [.atomicWrite])
            } catch {
                fatalError("Failed to write sticker image to cache: \(error)")
            }
        }

        // Set the operation's completion block to call the request's completion handler.
        operation.completionBlock = {
            guard let image = UIImage(contentsOfFile: url.path) else { fatalError() }
            completion(image)
        }

        queue.addOperation(operation)

    }



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

extension UIImage {
    convenience init?(view: UIView) {
        UIGraphicsBeginImageContext(view.frame.size)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        view.layer.render(in: context)
        guard
            let image = UIGraphicsGetImageFromCurrentImageContext(),
            let cgImage = image.cgImage
            else { return nil }
        UIGraphicsEndImageContext()
        self.init(cgImage: cgImage)
    }
}
