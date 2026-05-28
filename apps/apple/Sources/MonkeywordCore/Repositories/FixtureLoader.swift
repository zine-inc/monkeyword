import Foundation

public enum FixtureLoaderError: Error, LocalizedError, Equatable {
    case missingResource(String)

    public var errorDescription: String? {
        switch self {
        case .missingResource(let name):
            "Fixture not found: \(name)"
        }
    }
}

public enum FixtureLoader {
    public static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .useDefaultKeys
        return decoder
    }

    public static var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.keyEncodingStrategy = .useDefaultKeys
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }

    public static func load<T: Decodable>(
        _ type: T.Type,
        named name: String,
        subdirectory: String = "Fixtures/data"
    ) throws -> T {
        try load(type, named: name, subdirectory: subdirectory, bundle: .module)
    }

    public static func load<T: Decodable>(
        _ type: T.Type,
        named name: String,
        subdirectory: String = "Fixtures/data",
        bundle: Bundle
    ) throws -> T {
        guard let url = bundle.url(forResource: name, withExtension: "json", subdirectory: subdirectory)
            ?? developmentResourceURL(named: name, subdirectory: subdirectory) else {
            throw FixtureLoaderError.missingResource("\(subdirectory)/\(name).json")
        }
        let data = try Data(contentsOf: url)
        return try decoder.decode(T.self, from: data)
    }

    public static func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        try decoder.decode(T.self, from: data)
    }

    private static func developmentResourceURL(named name: String, subdirectory: String) -> URL? {
        let sourceFile = URL(fileURLWithPath: #filePath)
        let coreDirectory = sourceFile
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let resourceURL = coreDirectory
            .appendingPathComponent("Resources")
            .appendingPathComponent(subdirectory)
            .appendingPathComponent("\(name).json")
        return FileManager.default.fileExists(atPath: resourceURL.path) ? resourceURL : nil
    }
}
