# DFT DesignDatabase Integration

## Purpose and Scope

Host-only package composing canonical DFT state with exact source facet bindings.
Parent: [LSI](../DESIGN.md). Existing schema and runtime-adapter targets retain
their public responsibilities; this adoption changes dependency identity.

## Responsibilities and Boundaries

The schema validates DFT state and exact logic, library and optional timing
bindings. The runtime adapter validates publication against exact base revision
and dependency roots. Domain engines own analysis; DesignDatabase owns storage.

## Related Designs

| Design | Relationship | Contract Used | Summary | Cautions |
|---|---|---|---|---|
| [LSI](../DESIGN.md) | parent | Host-only domain integration | Package composition | Portable engines remain independent |
| [Timing integration](../TimingDesignDatabaseIntegration/DESIGN.md) | depends on | Exact timing facet source binding | Optional timing dependency | Use the exact revision adopted by the host |
| [DesignDatabase](../DesignDatabase/DESIGN.md) | depends on | Exact revision and candidate validation | Immutable publication | Source revisions and roots remain required |
| [Xcircuite](../Xcircuite/DESIGN.md) | used by | Schema and runtime adapter products | Host composition | Revision requirements must resolve consistently |

## Architecture

```text
DFTCore + exact facet bindings -> DFTDesignDatabaseSchema
    -> DFTDesignDatabaseRuntimeAdapter -> DesignDatabase candidate validation
```

## Contracts and Invariants

Source bindings retain one exact base revision and exact facet roots.
[Package.swift](Package.swift) is the authority for the exact dependency closure
shared with Xcircuite. Adopted TimingEngine contracts include
[TimingCore strict source characterization](../TimingEngine/Sources/TimingCore/DESIGN.md).
Domain semantics remain owned by those dependencies; this package preserves its
schema and runtime-adapter source bytes without asserting that transitive
dependency source or behavior is unchanged.

## Verification and Change Impact

Manifest inspection checks every exact requirement before host resolution.
Xcircuite compiles and exercises the consumed products against that closure.
Existing schema/runtime behavioral tests own state admission and publication;
dependency source-contract changes require the corresponding composing host
verification and remain distinct from process qualification.
