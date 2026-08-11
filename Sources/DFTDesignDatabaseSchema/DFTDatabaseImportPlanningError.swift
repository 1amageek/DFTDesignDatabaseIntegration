import CircuiteFoundation

public enum DFTDatabaseImportPlanningError: Error, Sendable, Hashable {
    case unsuccessfulResult
    case missingScanPlan
    case sourceRevisionMismatch(
        source: String,
        expected: DesignRevisionReference,
        actual: DesignRevisionReference
    )
    case invalidCanonicalState(reason: String)
    case mutationPlanCompilationFailed(reason: String)
}
