import Database
import DesignDatabaseRuntime
import DFTDesignDatabaseSchema

extension DFTDesignDatabaseRuntimeAdapter:
    DesignDatabaseRuntimePhysicalWriteReclaimer
{
    static let physicalStorageType =
        "DFTDesignDatabaseSchema.DFTDatabaseFacetPage.v1"

    public var storageType: String { Self.physicalStorageType }

    public func deleteImmutableWrite(
        _ identity: DesignDatabaseRuntimeImmutableWriteIdentity,
        from transaction: any DatabaseTransactionWriting
    ) async throws(DesignDatabaseRuntimePhysicalWriteReclaimerError) {
        let components = try DesignDatabaseRuntimePhysicalWriteDeletion
            .requirePartitionComponents(identity, storageType: storageType, count: 2)
        var partition = DirectoryPath<DFTDatabaseFacetPage>()
        partition.set(DFTDatabaseFacetPage.fields.facetID, to: components[0])
        partition.set(DFTDatabaseFacetPage.fields.documentDigest, to: components[1])
        try await DesignDatabaseRuntimePhysicalWriteDeletion.delete(
            identity,
            model: DFTDatabaseFacetPage.self,
            identifiedBy: identity.modelID,
            in: partition,
            expectedIdentity: Self.physicalWriteIdentity,
            from: transaction
        )
    }

    static func physicalWriteIdentity(
        _ page: DFTDatabaseFacetPage
    ) throws(DesignDatabaseRuntimePreparedMutationError)
        -> DesignDatabaseRuntimeImmutableWriteIdentity {
        try DesignDatabaseRuntimeImmutableWriteIdentity(
            storageType: physicalStorageType,
            partitionComponents: [page.facetID, page.documentDigest],
            modelID: page.id
        )
    }
}
