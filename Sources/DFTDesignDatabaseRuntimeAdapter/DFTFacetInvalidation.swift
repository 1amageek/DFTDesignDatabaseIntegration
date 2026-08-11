import CircuiteFoundation

public struct DFTFacetInvalidation: Sendable, Hashable, Codable {
    public enum Dependency: String, Sendable, Hashable, Codable {
        case logic
        case standardCellLibrary
        case timing
    }
    public let observedRevision: DesignRevisionReference
    public let dependency: Dependency
    public let expectedRootDigest: ContentDigest
    public let actualRootDigest: ContentDigest?
}
