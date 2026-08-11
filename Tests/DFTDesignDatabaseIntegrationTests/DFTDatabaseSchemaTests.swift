import CircuiteFoundation
import DesignDatabaseCore
import DFTCore
import DFTDesignDatabaseSchema
import Foundation
import LogicDesignDatabaseSchema
import StandardCellLibraryDesignDatabaseSchema
import Testing

@Suite("DFT DesignDatabase schema")
struct DFTDatabaseSchemaTests {
    @Test("scan design state round-trips in canonical identity order")
    func canonicalRoundTrip() throws {
        let state = try makeDFTState()
        let data = try DFTDatabaseCanonicalCodec.encode(state)

        #expect(try DFTDatabaseCanonicalCodec.decode(data) == state)
        #expect(state.scanPlan.chains.map(\.id) == ["chain-a", "chain-z"])
        #expect(state.scanPlan.architecture.domains.map(\.id) == ["domain-a", "domain-z"])
    }

    @Test("scan totals must match the declared chains")
    func invalidTotalsAreRejected() throws {
        let fixture = try makeDFTState()
        let invalidPlan = DFTScanPlan(
            architecture: fixture.scanPlan.architecture,
            chains: fixture.scanPlan.chains,
            totalEstimatedElementCount: 99,
            maximumEstimatedChainLength: 99
        )

        #expect(throws: DFTDatabaseSchemaError.self) {
            try DFTDatabaseState(
                sourceLogic: fixture.sourceLogic,
                sourceLibrary: fixture.sourceLibrary,
                sourceArtifact: fixture.sourceArtifact,
                scanPlan: invalidPlan
            )
        }
    }

    @Test("ATPG policy cannot become canonical before scan realization")
    func atpgRequiresRealizedScan() throws {
        let fixture = try makeDFTState()

        #expect(throws: DFTDatabaseSchemaError.self) {
            try DFTDatabaseState(
                sourceLogic: fixture.sourceLogic,
                sourceLibrary: fixture.sourceLibrary,
                sourceArtifact: fixture.sourceArtifact,
                scanPlan: fixture.scanPlan,
                atpgConfiguration: DFTATPGConfiguration()
            )
        }
    }

    @Test("completed scan insertion result compiles one exact DFT mutation")
    func completedScanInsertionCompilesImport() throws {
        let state = try makeDFTState()
        let result = try makeDFTResult(
            status: .completed,
            scanPlan: state.scanPlan
        )
        let request = DFTDatabaseImportRequest(
            sourceLogic: state.sourceLogic,
            sourceLibrary: state.sourceLibrary,
            sourceArtifact: state.sourceArtifact,
            result: result,
            segmentID: try DesignMutationPlanSegmentID(rawValue: "dft-stage-import"),
            databaseID: state.sourceLogic.sourceRevision.databaseID,
            baseRevision: state.sourceLogic.sourceRevision,
            designSchemaBundleDigest: try dftDigest("20"),
            dependencyRootDigest: try dftDigest("21"),
            semanticDependencyGraphDigest: try dftDigest("22"),
            sourceEvidenceDigest: try dftDigest("23")
        )

        let plan = try DFTDatabaseImportPlanner().compileImport(request)

        #expect(plan.baseRevision == state.sourceLogic.sourceRevision)
        #expect(plan.segments.count == 1)
        #expect(plan.segments.first?.targetFacet.rawValue == "dft.design")
    }

    @Test("unsuccessful DFT result cannot produce a candidate plan")
    func unsuccessfulResultIsRejected() throws {
        let state = try makeDFTState()
        let result = try makeDFTResult(status: .blocked, scanPlan: nil)
        let request = DFTDatabaseImportRequest(
            sourceLogic: state.sourceLogic,
            sourceLibrary: state.sourceLibrary,
            sourceArtifact: state.sourceArtifact,
            result: result,
            segmentID: try DesignMutationPlanSegmentID(rawValue: "dft-stage-import"),
            databaseID: state.sourceLogic.sourceRevision.databaseID,
            baseRevision: state.sourceLogic.sourceRevision,
            designSchemaBundleDigest: try dftDigest("24"),
            dependencyRootDigest: try dftDigest("25"),
            semanticDependencyGraphDigest: try dftDigest("26"),
            sourceEvidenceDigest: try dftDigest("27")
        )

        #expect(throws: DFTDatabaseImportPlanningError.self) {
            try DFTDatabaseImportPlanner().compileImport(request)
        }
    }
}

private func makeDFTResult(
    status: DFTExecutionStatus,
    scanPlan: DFTScanPlan?
) throws -> DFTResult {
    try DFTResult(
        schemaVersion: 1,
        runID: "dft-stage-import",
        status: status,
        provenance: DFTExecutionSupport.provenance(
            engineID: "dft.scan-insertion",
            implementationID: "dft-stage-import-fixture",
            implementationVersion: "1",
            startedAt: Date(timeIntervalSince1970: 0),
            completedAt: Date(timeIntervalSince1970: 1),
            seed: 1
        ),
        payload: DFTPayload(
            transformedDesign: nil,
            faultCoverage: nil,
            scanPlan: scanPlan
        )
    )
}

private func makeDFTState() throws -> DFTDatabaseState {
    let databaseID = try DesignDatabaseID(high: 51, low: 52)
    let revision = DesignRevisionReference(
        databaseID: databaseID,
        revisionID: DesignRevisionID(high: 53, low: 54)
    )
    let logic = LogicDatabaseExactFacetBinding(
        sourceRevision: revision,
        sourceFacet: .gate,
        sourceRootDigest: try dftDigest("10")
    )
    let library = try StandardCellLibraryFacetSourceBinding(
        sourceRevision: revision,
        sourceRootDigest: try dftDigest("11")
    )
    let architecture = DFTScanArchitecture(
        name: "top-scan",
        clocks: [
            DFTScanClock(
                id: "scan-clock",
                signalName: "scan_clk",
                periodNanoseconds: 10
            ),
        ],
        domains: [
            DFTScanDomain(
                id: "domain-z",
                clockID: "scan-clock",
                chainCount: 1,
                estimatedElementCount: 3
            ),
            DFTScanDomain(
                id: "domain-a",
                clockID: "scan-clock",
                chainCount: 1,
                estimatedElementCount: 2
            ),
        ],
        scanEnableSignal: "scan_enable",
        testModeSignal: "test_mode"
    )
    let plan = DFTScanPlan(
        architecture: architecture,
        chains: [
            DFTScanChain(
                id: "chain-z",
                domainID: "domain-z",
                index: 0,
                estimatedElementCount: 3,
                scanInSignal: "scan_in_z",
                scanOutSignal: "scan_out_z"
            ),
            DFTScanChain(
                id: "chain-a",
                domainID: "domain-a",
                index: 0,
                estimatedElementCount: 2,
                scanInSignal: "scan_in_a",
                scanOutSignal: "scan_out_a"
            ),
        ],
        totalEstimatedElementCount: 5,
        maximumEstimatedChainLength: 3
    )
    return try DFTDatabaseState(
        sourceLogic: logic,
        sourceLibrary: library,
        sourceArtifact: ArtifactReference(
            id: try ArtifactID(digest: dftDigest("12"), byteCount: 100),
            descriptor: ArtifactDescriptor(
                role: .input,
                kind: .constraints,
                format: .json
            )
        ),
        scanPlan: plan
    )
}

private func dftDigest(_ byte: String) throws -> ContentDigest {
    try ContentDigest(
        algorithm: .sha256,
        hexadecimalValue: String(repeating: byte, count: 32)
    )
}
