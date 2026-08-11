import CircuiteFoundation
import CircuiteFoundationCrypto
import Database
import DatabaseTypesFoundation
import DesignDatabaseRuntime
import DFTDesignDatabaseSchema
import Foundation

public struct DFTDatabaseRuntimeStateReader: Sendable {
    public init() {}

    public func read(
        expectedRoot: ContentDigest,
        from reads: DesignDatabaseRuntimeReadSnapshot,
        budget: DFTDatabaseReadBudget
    ) async throws -> DFTDatabaseState {
        var partition = DirectoryPath<DFTDatabaseFacetPage>()
        partition.set(DFTDatabaseFacetPage.fields.facetID, to: DFTDatabaseFacet.design.rawValue)
        partition.set(DFTDatabaseFacetPage.fields.documentDigest, to: expectedRoot.hexadecimalValue)
        var pages: [DFTDatabaseFacetPage] = []
        var continuation: DatabaseScanContinuation?
        repeat {
            let page = try await reads.scan(
                DFTDatabaseFacetPage.self,
                in: partition,
                after: continuation,
                limit: budget.pageFetchLimit
            )
            pages.append(contentsOf: page.items)
            guard pages.count <= budget.maximumPageCount else {
                throw DFTDatabaseReadError.pageBudgetExceeded(limit: budget.maximumPageCount)
            }
            continuation = page.continuation
        } while continuation != nil
        guard let first = pages.first else { throw DFTDatabaseReadError.missingFacetPages }
        let ordered = pages.sorted { $0.ordinal < $1.ordinal }
        guard first.pageCount == UInt64(ordered.count),
              ordered.allSatisfy({
                  $0.facetID == DFTDatabaseFacet.design.rawValue
                    && $0.pageCount == first.pageCount
                    && $0.documentByteCount == first.documentByteCount
                    && $0.documentDigest == first.documentDigest
              }) else { throw DFTDatabaseReadError.inconsistentPageMetadata }
        for (index, page) in ordered.enumerated() where page.ordinal != UInt64(index) {
            throw DFTDatabaseReadError.nonContiguousPages
        }
        guard let capacity = Int(exactly: first.documentByteCount) else {
            throw DFTDatabaseReadError.inconsistentPageMetadata
        }
        var data = Data()
        data.reserveCapacity(capacity)
        for page in ordered {
            page.payload.withUnsafeBytes { data.append($0.bindMemory(to: UInt8.self)) }
        }
        guard UInt64(data.count) == first.documentByteCount else {
            throw DFTDatabaseReadError.byteCountMismatch(expected: first.documentByteCount, actual: UInt64(data.count))
        }
        let actual = try SHA256ContentDigester().digest(data: data)
        guard actual == expectedRoot else {
            throw DFTDatabaseReadError.facetRootMismatch(expected: expectedRoot, actual: actual)
        }
        do { return try DFTDatabaseCanonicalCodec.decode(data) }
        catch let error { throw DFTDatabaseReadError.decodeFailed(error) }
    }
}
