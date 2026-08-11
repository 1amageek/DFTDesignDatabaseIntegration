import DatabaseKit
import DatabaseTypes

@Persistable
public struct DFTDatabaseFacetPage {
    #Directory<DFTDatabaseFacetPage>(
        "design-database", "dft-facets",
        \DFTDatabaseFacetPage.facetID,
        \DFTDatabaseFacetPage.documentDigest,
        "pages", layer: .partition
    )
    public var id: String = ""
    public var facetID: String = ""
    public var ordinal: UInt64 = 0
    public var pageCount: UInt64 = 0
    public var documentByteCount: UInt64 = 0
    public var documentDigest: String = ""
    public var payload: ByteString = ByteString()
}
