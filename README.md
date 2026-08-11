# DFTDesignDatabaseIntegration

Host-only persistence integration for scan, ATPG, BIST, and source/evidence bindings.

| Product | Responsibility |
|---|---|
| `DFTDesignDatabaseSchema` | Canonical DFT state, exact source bindings, validation, and paging |
| `DFTDesignDatabaseRuntimeAdapter` | Candidate plan compilation and bounded exact-snapshot reads |

ATPG execution, coverage, and proof results remain evidence. Canonical state is admitted
only when its RTL, gate, standard-cell, and timing dependencies match the exact selected
roots.

## Verification

```bash
swift build --build-tests -j 4 \
  -Xswiftc -Xfrontend -Xswiftc -disable-round-trip-debug-types
```
