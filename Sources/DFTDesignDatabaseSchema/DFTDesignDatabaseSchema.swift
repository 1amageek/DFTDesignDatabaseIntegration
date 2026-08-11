import CircuiteFoundation
import DesignDatabaseCore

public enum DFTDesignDatabaseSchema {
    public static let adapterVersion = "1.0.0"
    public static let bindingManifest = """
    lsi.dft-design-database-schema/v1
    entity=DFTDatabaseFacetPage
    directory=design-database/dft-facets/{facetID}/{documentDigest}/pages
    fields=id,facetID,ordinal,pageCount,documentByteCount,documentDigest,payload
    facets=dft.design
    sourceBinding=exact-gate+standard-cell+optional-timing
    canonicalState=scan-plan+realized-scan+atpg-policy+bist-structure
    coverageAndPatterns=evidence-only
    pageByteCount=65536
    """

    public static var schemaID: DesignSchemaID {
        get throws { try DesignSchemaID(rawValue: "lsi.dft") }
    }
}
