import DFTDesignDatabaseSchema

public struct DFTSnapshotState: Sendable, Hashable, Codable {
    public let dft: DFTDatabaseState?
    public let invalidation: DFTFacetInvalidation?
    public var isSemanticallyCurrent: Bool { invalidation == nil }
}
