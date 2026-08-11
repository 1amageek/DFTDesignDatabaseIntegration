import CircuiteFoundation
import DesignDatabaseCore

public struct DFTDatabaseImportPlanner: DFTDesignImportPlanning, Sendable {
    public init() {}

    public func compileImport(
        _ request: DFTDatabaseImportRequest
    ) throws(DFTDatabaseImportPlanningError) -> DesignMutationPlan {
        guard request.result.status == .completed else {
            throw .unsuccessfulResult
        }
        guard let scanPlan = request.result.payload.scanPlan else {
            throw .missingScanPlan
        }
        try requireBaseRevision(
            request.sourceLogic.sourceRevision,
            source: "logic",
            request: request
        )
        try requireBaseRevision(
            request.sourceLibrary.sourceRevision,
            source: "standard-cell-library",
            request: request
        )
        if let sourceTiming = request.sourceTiming {
            try requireBaseRevision(
                sourceTiming.sourceRevision,
                source: "timing",
                request: request
            )
        }
        let state: DFTDatabaseState
        do {
            state = try DFTDatabaseState(
                sourceLogic: request.sourceLogic,
                sourceLibrary: request.sourceLibrary,
                sourceTiming: request.sourceTiming,
                sourceArtifact: request.sourceArtifact,
                scanPlan: scanPlan,
                scanImplementation: request.result.payload.scanImplementation,
                atpgConfiguration: request.atpgConfiguration,
                bistStructures: request.result.payload.bistStructure.map { [$0] } ?? [],
                metadata: request.metadata
            )
        } catch {
            throw .invalidCanonicalState(reason: String(describing: error))
        }
        do {
            return try DFTDatabaseMutationPlanCompiler().compile(
                state,
                segmentID: request.segmentID,
                databaseID: request.databaseID,
                baseRevision: request.baseRevision,
                designSchemaBundleDigest: request.designSchemaBundleDigest,
                dependencyRootDigest: request.dependencyRootDigest,
                semanticDependencyGraphDigest: request.semanticDependencyGraphDigest,
                sourceEvidenceDigest: request.sourceEvidenceDigest
            )
        } catch {
            throw .mutationPlanCompilationFailed(reason: String(describing: error))
        }
    }

    private func requireBaseRevision(
        _ actual: DesignRevisionReference,
        source: String,
        request: DFTDatabaseImportRequest
    ) throws(DFTDatabaseImportPlanningError) {
        guard actual == request.baseRevision else {
            throw .sourceRevisionMismatch(
                source: source,
                expected: request.baseRevision,
                actual: actual
            )
        }
    }
}
