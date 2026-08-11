import CircuiteFoundation
import DFTCore
import LogicDesignDatabaseSchema
import StandardCellLibraryDesignDatabaseSchema
import TimingDesignDatabaseSchema

public struct DFTDatabaseState: Sendable, Hashable, Codable {
    public static let currentSchemaVersion = 1
    public let schemaVersion: Int
    public let sourceLogic: LogicDatabaseExactFacetBinding
    public let sourceLibrary: StandardCellLibraryFacetSourceBinding
    public let sourceTiming: TimingDatabaseFacetSourceBinding?
    public let sourceArtifact: ArtifactReference
    public let scanPlan: DFTScanPlan
    public let scanImplementation: DFTScanImplementation?
    public let atpgConfiguration: DFTATPGConfiguration?
    public let bistStructures: [DFTBISTStructure]
    public let metadata: [String: String]

    public init(
        sourceLogic: LogicDatabaseExactFacetBinding,
        sourceLibrary: StandardCellLibraryFacetSourceBinding,
        sourceTiming: TimingDatabaseFacetSourceBinding? = nil,
        sourceArtifact: ArtifactReference,
        scanPlan: DFTScanPlan,
        scanImplementation: DFTScanImplementation? = nil,
        atpgConfiguration: DFTATPGConfiguration? = nil,
        bistStructures: [DFTBISTStructure] = [],
        metadata: [String: String] = [:]
    ) throws(DFTDatabaseSchemaError) {
        schemaVersion = Self.currentSchemaVersion
        self.sourceLogic = sourceLogic
        self.sourceLibrary = sourceLibrary
        self.sourceTiming = sourceTiming
        self.sourceArtifact = sourceArtifact
        self.scanPlan = Self.canonical(scanPlan)
        self.scanImplementation = scanImplementation.map(Self.canonical)
        self.atpgConfiguration = atpgConfiguration.map(Self.canonical)
        self.bistStructures = bistStructures.map(Self.canonical).sorted { $0.name < $1.name }
        self.metadata = metadata
        try validate()
    }

    public func validate() throws(DFTDatabaseSchemaError) {
        guard schemaVersion == Self.currentSchemaVersion else { throw .unsupportedSchemaVersion(schemaVersion) }
        do {
            try sourceLogic.validate()
            try sourceLibrary.validate()
            try sourceTiming?.validate()
        } catch { throw .invalidSourceBinding(reason: String(describing: error)) }
        guard sourceLogic.sourceFacet == .gate else {
            throw .invalidSourceBinding(reason: "DFT state must bind the exact gate facet.")
        }
        let revision = sourceLogic.sourceRevision
        guard sourceLibrary.sourceRevision == revision,
              sourceTiming?.sourceRevision == nil || sourceTiming?.sourceRevision == revision else {
            throw .invalidSourceBinding(reason: "DFT dependencies must bind one exact base revision.")
        }
        guard sourceArtifact.descriptor.role == .input,
              sourceArtifact.descriptor.kind == .constraints,
              sourceArtifact.descriptor.format == .json else {
            throw .invalidSourceArtifactDescriptor
        }
        let report = DFTCanonicalStateValidator().validate(
            scanPlan: scanPlan,
            scanImplementation: scanImplementation,
            atpgConfiguration: atpgConfiguration,
            bistStructures: bistStructures
        )
        guard report.isValid else {
            throw .invalidDFTState(report.findings.map {
                [$0.code, $0.summary, $0.entity].compactMap { $0 }.joined(separator: ": ")
            })
        }
        guard scanPlan == Self.canonical(scanPlan),
              scanImplementation == scanImplementation.map(Self.canonical),
              atpgConfiguration == atpgConfiguration.map(Self.canonical),
              bistStructures == bistStructures.map(Self.canonical).sorted(by: { $0.name < $1.name }) else {
            throw .nonCanonicalOrdering
        }
    }

    private static func canonical(_ source: DFTScanPlan) -> DFTScanPlan {
        let architecture = DFTScanArchitecture(
            name: source.architecture.name,
            clocks: source.architecture.clocks.sorted { $0.id < $1.id },
            resets: source.architecture.resets.sorted { $0.id < $1.id },
            domains: source.architecture.domains.sorted { $0.id < $1.id },
            compression: source.architecture.compression,
            scanEnableSignal: source.architecture.scanEnableSignal,
            testModeSignal: source.architecture.testModeSignal,
            scanInPrefix: source.architecture.scanInPrefix,
            scanOutPrefix: source.architecture.scanOutPrefix
        )
        return DFTScanPlan(
            architecture: architecture,
            chains: source.chains.sorted { $0.id < $1.id },
            totalEstimatedElementCount: source.totalEstimatedElementCount,
            maximumEstimatedChainLength: source.maximumEstimatedChainLength
        )
    }

    private static func canonical(
        _ source: DFTScanImplementation
    ) -> DFTScanImplementation {
        DFTScanImplementation(
            architectureName: source.architectureName,
            sourceDesignDigest: source.sourceDesignDigest,
            transformedDesignDigest: source.transformedDesignDigest,
            scanEnableSignal: source.scanEnableSignal,
            scanEnableNetID: source.scanEnableNetID,
            testModeSignal: source.testModeSignal,
            testModeNetID: source.testModeNetID,
            chains: source.chains.map {
                DFTRealizedScanChain(
                    chainID: $0.chainID,
                    domainID: $0.domainID,
                    scanInSignal: $0.scanInSignal,
                    scanInNetID: $0.scanInNetID,
                    scanOutSignal: $0.scanOutSignal,
                    scanOutNetID: $0.scanOutNetID,
                    elements: $0.elements.sorted { $0.position < $1.position }
                )
            }.sorted { $0.chainID < $1.chainID }
        )
    }

    private static func canonical(
        _ source: DFTATPGConfiguration
    ) -> DFTATPGConfiguration {
        DFTATPGConfiguration(
            maximumPatternCount: source.maximumPatternCount,
            patternLength: source.patternLength,
            abortLimit: source.abortLimit,
            randomSeed: source.randomSeed,
            supportedProcessFamilies: Array(Set(source.supportedProcessFamilies)).sorted(),
            patternFormat: source.patternFormat,
            faultSource: source.faultSource,
            maximumExhaustiveInputCount: source.maximumExhaustiveInputCount,
            maximumSequentialCycleCount: source.maximumSequentialCycleCount,
            sequentialCellContracts: source.sequentialCellContracts
        )
    }

    private static func canonical(_ source: DFTBISTStructure) -> DFTBISTStructure {
        DFTBISTStructure(
            name: source.name,
            kind: source.kind,
            controllerCellName: source.controllerCellName,
            targetInstances: source.targetInstances.sorted(),
            patternCount: source.patternCount,
            signatureRegisterName: source.signatureRegisterName,
            seed: source.seed,
            testModeSignal: source.testModeSignal,
            logicCellMapping: source.logicCellMapping,
            memoryBindings: source.memoryBindings?.sorted { $0.instanceName < $1.instanceName },
            memoryCellMapping: source.memoryCellMapping
        )
    }
}
