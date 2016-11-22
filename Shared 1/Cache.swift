//
//  Cache.swift
//  Cache
//
//  Created by Todd Olsen on 11/1/16.
//
//

import Foundation

public struct Cache {

    public let name: String
    private let directory: FileManager.SearchPathDirectory

    public init(with name: String, directory: FileManager.SearchPathDirectory = .cachesDirectory) {
        self.name = name
        self.directory = directory
    }

    private static var _enabled = true

    public static func enable() {
        _enabled = true
    }

    public static func disable() {
        _enabled = false
    }

    private var hashedName: String {
        return String(UInt64(abs(name.hashValue)))
    }

    private var cacheFilename: URL {
        return URL(fileURLWithPath: String(UInt64(abs(name.hashValue))))
    }

    private var appCacheDirectory: URL {
        let directory = FileManager.SearchPathDirectory.documentDirectory
        let mask = FileManager.SearchPathDomainMask.userDomainMask
        guard let url = FileManager.default.urls(for: directory, in: mask).first else { fatalError() }
        return url
    }

    var cacheLocation: URL {
        return appCacheDirectory.appendingPathComponent(hashedName)
    }

    @discardableResult
    public func save(object: NSCoding) -> Bool {
        return NSKeyedArchiver.archiveRootObject(object, toFile: cacheLocation.path)
    }

    public func fetch() -> NSCoding {
        guard let object = NSKeyedUnarchiver.unarchiveObject(withFile: cacheLocation.path) as? NSCoding else { fatalError() }
        return object
    }


}
