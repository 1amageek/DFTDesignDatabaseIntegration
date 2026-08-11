import DesignDatabaseCore
import DesignDatabaseRuntime
import DFTDesignDatabaseSchema
import StandardCellLibraryDesignDatabaseSchema
import TimingDesignDatabaseSchema

public struct DFTDesignDatabaseSnapshotReader: Sendable {
    public init() {}

    public func readState(
        from snapshot: any DesignReadSnapshot,
        budget: DFTDatabaseReadBudget
    ) async throws -> DFTSnapshotState {
        let facetID = try DFTDatabaseFacet.design.designFacetID
        guard let root = snapshot.facetRoots.first(where: { $0.facetID == facetID })?.digest else {
            return DFTSnapshotState(dft: nil, invalidation: nil)
        }
        guard let runtimeSnapshot = snapshot as? DesignDatabaseRuntimeSnapshot else {
            throw DFTDatabaseReadError.unsupportedSnapshotImplementation
        }
        let state = try await runtimeSnapshot.withRuntimeReads(
            maximumReadCount: try budget.runtimeReadCount
        ) { reads in
            try await DFTDatabaseRuntimeStateReader().read(
                expectedRoot: root,
                from: reads,
                budget: budget
            )
        }
        return DFTSnapshotState(
            dft: state,
            invalidation: try invalidation(for: state, in: snapshot)
        )
    }

    private func invalidation(
        for state: DFTDatabaseState,
        in snapshot: any DesignReadSnapshot
    ) throws -> DFTFacetInvalidation? {
        let logicFacetID = try state.sourceLogic.sourceFacet.designFacetID
        let logicRoot = snapshot.facetRoots.first(where: { $0.facetID == logicFacetID })?.digest
        if logicRoot != state.sourceLogic.sourceRootDigest {
            return DFTFacetInvalidation(
                observedRevision: snapshot.revision,
                dependency: .logic,
                expectedRootDigest: state.sourceLogic.sourceRootDigest,
                actualRootDigest: logicRoot
            )
        }
        let libraryFacetID = try StandardCellLibraryDatabaseFacet.library.designFacetID
        let libraryRoot = snapshot.facetRoots.first(where: { $0.facetID == libraryFacetID })?.digest
        if libraryRoot != state.sourceLibrary.sourceRootDigest {
            return DFTFacetInvalidation(
                observedRevision: snapshot.revision,
                dependency: .standardCellLibrary,
                expectedRootDigest: state.sourceLibrary.sourceRootDigest,
                actualRootDigest: libraryRoot
            )
        }
        if let timing = state.sourceTiming {
            let timingFacetID = try TimingDatabaseFacet.timing.designFacetID
            let timingRoot = snapshot.facetRoots.first(where: { $0.facetID == timingFacetID })?.digest
            if timingRoot != timing.sourceRootDigest {
                return DFTFacetInvalidation(
                    observedRevision: snapshot.revision,
                    dependency: .timing,
                    expectedRootDigest: timing.sourceRootDigest,
                    actualRootDigest: timingRoot
                )
            }
        }
        return nil
    }
}
