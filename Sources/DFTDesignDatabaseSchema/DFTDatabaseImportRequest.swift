import CircuiteFoundation
import DFTCore
import DesignDatabaseCore
import LogicDesignDatabaseSchema
import StandardCellLibraryDesignDatabaseSchema
import TimingDesignDatabaseSchema

public struct DFTDatabaseImportRequest: Sendable, Hashable {
    public let sourceLogic: LogicDatabaseExactFacetBinding
    public let sourceLibrary: StandardCellLibraryFacetSourceBinding
    public let sourceTiming: TimingDatabaseFacetSourceBinding?
    public let sourceArtifact: ArtifactReference
    public let result: DFTResult
    public let atpgConfiguration: DFTATPGConfiguration?
    public let metadata: [String: String]
    public let segmentID: DesignMutationPlanSegmentID
    public let databaseID: DesignDatabaseID
    public let baseRevision: DesignRevisionReference
    public let designSchemaBundleDigest: ContentDigest
    public let dependencyRootDigest: ContentDigest
    public let semanticDependencyGraphDigest: ContentDigest
    public let sourceEvidenceDigest: ContentDigest

    public init(
        sourceLogic: LogicDatabaseExactFacetBinding,
        sourceLibrary: StandardCellLibraryFacetSourceBinding,
        sourceTiming: TimingDatabaseFacetSourceBinding? = nil,
        sourceArtifact: ArtifactReference,
        result: DFTResult,
        atpgConfiguration: DFTATPGConfiguration? = nil,
        metadata: [String: String] = [:],
        segmentID: DesignMutationPlanSegmentID,
        databaseID: DesignDatabaseID,
        baseRevision: DesignRevisionReference,
        designSchemaBundleDigest: ContentDigest,
        dependencyRootDigest: ContentDigest,
        semanticDependencyGraphDigest: ContentDigest,
        sourceEvidenceDigest: ContentDigest
    ) {
        self.sourceLogic = sourceLogic
        self.sourceLibrary = sourceLibrary
        self.sourceTiming = sourceTiming
        self.sourceArtifact = sourceArtifact
        self.result = result
        self.atpgConfiguration = atpgConfiguration
        self.metadata = metadata
        self.segmentID = segmentID
        self.databaseID = databaseID
        self.baseRevision = baseRevision
        self.designSchemaBundleDigest = designSchemaBundleDigest
        self.dependencyRootDigest = dependencyRootDigest
        self.semanticDependencyGraphDigest = semanticDependencyGraphDigest
        self.sourceEvidenceDigest = sourceEvidenceDigest
    }
}
