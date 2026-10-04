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

All source bindings retain one exact base revision and their exact facet roots.
Adopt TimingDesignDatabaseIntegration
`697acf125836520f00f1379d04dc4a7521e1d1b4` so the host can compose the same exact
TimingEngine revision. The adopted timing integration leaves its schema and
runtime-adapter source/API unchanged from `bd11c27`; this adoption changes no DFT
source, state schema, public API or timing binding semantics.

## Verification and Change Impact

Manifest decoding checks the exact adoption, and the unchanged dependency source
diff checks the consumed API boundary. Xcircuite's dedicated host build compiles
both integration products against the exact closure and focused STA host tests
verify composition. Existing DFT schema/runtime behavior tests retain ownership
of the unchanged DFT state and publication contracts.
