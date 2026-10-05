# Universal Engineering & Architecture Principles Implementation Plan

Create a framework-agnostic, technology-independent architectural guidelines document (`docs/developer_context.md`). This guide focuses on universal software engineering principles, design patterns, and problem-solving strategies that remain evergreen even if the underlying tech stack or libraries (e.g., framework, state management, or persistence tools) change.

## Proposed Changes

---

### Documentation (`docs/`)

#### [NEW] [developer_context.md](file:///C:/Users/Illia/StudioProjects/personal_finance_tracker/docs/developer_context.md)
Create a universal engineering blueprint structured around core paradigms rather than specific packages:
1. **Unidirectional Data Flow & Layer Isolation (Clean Architecture)**
   - Strict separation of concerns across Domain, Data, and Presentation layers.
   - Decoupling raw data representations from pure domain entities via explicit boundary mapping.
2. **State Machines & Exhaustive Pattern Matching**
   - Modeling application states as finite, mutually exclusive states (discriminated unions / sealed hierarchies).
   - Enforcing exhaustive branch handling to eliminate runtime unhandled state bugs.
3. **Type Safety & Domain Modeling**
   - Eliminating primitive obsession (magic strings/numbers) in favor of domain-specific typed enums and value objects.
4. **Dependency Inversion & Testability**
   - Depending on abstractions (interfaces) rather than concrete implementations.
   - Managing dependency lifecycles consciously (transient vs scoped vs singleton) based on resource usage.
5. **UI Composition & Reusability**
   - Favouring component composition over inheritance or inline procedural widget builder functions.
   - Isolating subtree rebuilds to optimize performance.
6. **Robust Error Boundaries & Exception Translation**
   - Encapsulating low-level infrastructure failures into domain-meaningful exceptions/failures at the layer boundary.
7. **Resilient Data Mutations & Offline-First Thinking**
   - Architecting mutations around optimistic vs. pessimistic consistency models.
   - Designing data pipelines resilient to network/storage interruptions.

---

## Verification Plan

### Automated Verification
- Verify `docs/developer_context.md` is created and well-formatted.
- Run `flutter test` and `flutter analyze` to ensure zero code regressions.
