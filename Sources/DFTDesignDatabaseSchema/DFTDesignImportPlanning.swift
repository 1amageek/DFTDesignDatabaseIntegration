import DesignDatabaseCore

public protocol DFTDesignImportPlanning: Sendable {
    func compileImport(
        _ request: DFTDatabaseImportRequest
    ) throws(DFTDatabaseImportPlanningError) -> DesignMutationPlan
}
