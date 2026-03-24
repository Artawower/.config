---
name: deep-test
description: Builds a rigorous test strategy with multiple test-suite variants and critical review. Use when the user asks what to test, wants adversarial coverage, or needs a stronger test plan before or after implementation.
---

# Deep Test

Use this skill when a normal test list is not enough.

## Canonical Testing Input

Before generating the plan, load:

- `references/edge-case-tester.md`

Treat it as the base standard for edge cases, failure modes, and test-writing quality.

## Workflow

1. Analyze the target under test:
   - purpose
   - public interface
   - expected behavior
   - failure modes
   - hidden assumptions
2. Produce a strict test plan covering:
   - functional behavior
   - negative cases
   - black-box scenarios
   - edge cases and boundary conditions
   - stress or fuzz scenarios when relevant
   - repeatability and stability
3. Generate at least 3 self-contained test-suite variants.
4. Ensure each variant uses a meaningfully different strategy.
5. Critique every variant:
   - missing coverage
   - weak assertions
   - brittle or implementation-coupled tests
   - realism of failure scenarios
6. If multiple external reasoning or model-review tools are available, use them for an extra critique pass; otherwise perform the comparison yourself.
7. Produce one final synthesis with the strongest elements from all variants.

## Output Structure

Return a structured report with:
- target analysis
- test plan
- variant A / B / C
- critique per variant
- comparative ratings
- recommended final suite
- coverage gaps that still remain

## Constraints

- Prefer interface-level tests over implementation-level coupling.
- Make concrete test-case suggestions, not only categories.
- Call out untestable areas and why they are hard to test.
- Respond in the user's language.
