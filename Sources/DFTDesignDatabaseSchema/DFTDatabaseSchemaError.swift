public enum DFTDatabaseSchemaError: Error, Sendable, Hashable {
    case unsupportedSchemaVersion(Int)
    case invalidSourceBinding(reason: String)
    case invalidSourceArtifactDescriptor
    case invalidDFTState([String])
    case nonCanonicalOrdering
    case encodingFailed(reason: String)
    case decodingFailed(reason: String)
    case nonCanonicalPayload
    case invalidPageByteCount(Int)
    case pageCountOverflow
}
