import CircuiteFoundation
import Database
import DesignDatabaseCore
import DesignDatabaseRuntime
import DFTDesignDatabaseSchema

struct DFTPreparedMutation: DesignDatabaseRuntimePreparedMutation {
    let segmentID: DesignMutationPlanSegmentID
    let pages: [DFTDatabaseFacetPage]
    let facetRootDigest: ContentDigest
    let changeContributionDigest: ContentDigest
    var writeCount: UInt64 { UInt64(pages.count) }

    func immutableWriteIdentity(
        at index: UInt64
    ) throws(DesignDatabaseRuntimePreparedMutationError)
        -> DesignDatabaseRuntimeImmutableWriteIdentity {
        guard let pageIndex = Int(exactly: index),
              pages.indices.contains(pageIndex) else {
            throw .invalidImmutableWriteIndex(index: index, writeCount: writeCount)
        }
        let page = pages[pageIndex]
        return try DFTDesignDatabaseRuntimeAdapter.physicalWriteIdentity(page)
    }

    func stageImmutableWrite(
        at index: UInt64,
        to transaction: any DatabaseTransactionWriting
    ) async throws {
        guard let pageIndex = Int(exactly: index),
              pages.indices.contains(pageIndex) else {
            throw DesignDatabaseRuntimePreparedMutationError
                .invalidImmutableWriteIndex(index: index, writeCount: writeCount)
        }
        let page = pages[pageIndex]
        var partition = DirectoryPath<DFTDatabaseFacetPage>()
        partition.set(DFTDatabaseFacetPage.fields.facetID, to: page.facetID)
        partition.set(DFTDatabaseFacetPage.fields.documentDigest, to: page.documentDigest)
        if let existing = try await transaction.fetch(
            DFTDatabaseFacetPage.self,
            identifiedBy: page.id,
            in: partition
        ) {
            guard existing.id == page.id,
                  existing.facetID == page.facetID,
                  existing.ordinal == page.ordinal,
                  existing.pageCount == page.pageCount,
                  existing.documentByteCount == page.documentByteCount,
                  existing.documentDigest == page.documentDigest,
                  existing.payload == page.payload else {
                throw DFTPreparedMutationError.contentAddressCollision
            }
            return
        }
        try await transaction.save(page, precondition: .none)
    }
}

private enum DFTPreparedMutationError: Error, Sendable {
    case contentAddressCollision
}
