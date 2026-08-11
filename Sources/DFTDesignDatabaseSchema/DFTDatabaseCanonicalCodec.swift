import Foundation

public enum DFTDatabaseCanonicalCodec {
    public static func encode(_ state: DFTDatabaseState) throws(DFTDatabaseSchemaError) -> Data {
        try state.validate()
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        do { return try encoder.encode(state) }
        catch { throw .encodingFailed(reason: String(describing: error)) }
    }

    public static func decode(
        _ data: Data,
        requireCanonicalEncoding: Bool = true
    ) throws(DFTDatabaseSchemaError) -> DFTDatabaseState {
        let state: DFTDatabaseState
        do { state = try JSONDecoder().decode(DFTDatabaseState.self, from: data) }
        catch { throw .decodingFailed(reason: String(describing: error)) }
        try state.validate()
        if requireCanonicalEncoding, try encode(state) != data { throw .nonCanonicalPayload }
        return state
    }
}
