import CircuiteFoundation
import DesignDatabaseCore

public enum DFTDatabaseFacet: String, Sendable, Hashable, Codable, CaseIterable {
    case design = "dft.design"

    public var designFacetID: DesignFacetID {
        get throws { try DesignFacetID(rawValue: rawValue) }
    }
}
