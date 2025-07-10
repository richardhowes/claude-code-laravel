---
allowed-tools: all
description: Verify code quality, run tests, and ensure production readiness
---

# 🚨🚨🚨 CRITICAL REQUIREMENT: FIX ALL ERRORS! 🚨🚨🚨

**THIS IS NOT A REPORTING TASK - THIS IS A FIXING TASK!**

When you run `/check`, you are REQUIRED to:

1. **IDENTIFY** all errors, warnings, and issues
2. **FIX EVERY SINGLE ONE** - not just report them!
3. **USE MULTIPLE AGENTS** to fix issues in parallel:
   - Spawn one agent to fix linting issues
   - Spawn another to fix test failures
   - Spawn more agents for different files/modules
   - Say: "I'll spawn multiple agents to fix all these issues in parallel"
4. **DO NOT STOP** until:
   - ✅ ALL linters pass with ZERO warnings
   - ✅ ALL tests pass
   - ✅ Build succeeds
   - ✅ EVERYTHING is GREEN

**FORBIDDEN BEHAVIORS:**
- ❌ "Here are the issues I found" → NO! FIX THEM!
- ❌ "The linter reports these problems" → NO! RESOLVE THEM!
- ❌ "Tests are failing because..." → NO! MAKE THEM PASS!
- ❌ Stopping after listing issues → NO! KEEP WORKING!

**MANDATORY WORKFLOW:**
```
1. Run checks → Find issues
2. IMMEDIATELY spawn agents to fix ALL issues
3. Re-run checks → Find remaining issues
4. Fix those too
5. REPEAT until EVERYTHING passes
```

**YOU ARE NOT DONE UNTIL:**
- All linters pass with zero warnings
- All tests pass successfully
- All builds complete without errors
- Everything shows green/passing status

---

🛑 **MANDATORY PRE-FLIGHT CHECK** 🛑
1. Re-read ~/.claude/CLAUDE.md RIGHT NOW
2. Check current TODO.md status
3. Verify you're not declaring "done" prematurely

Execute comprehensive quality checks with ZERO tolerance for excuses.

**FORBIDDEN EXCUSE PATTERNS:**
- "This is just stylistic" → NO, it's a requirement
- "Most remaining issues are minor" → NO, ALL issues must be fixed
- "This can be addressed later" → NO, fix it now
- "It's good enough" → NO, it must be perfect
- "The linter is being pedantic" → NO, the linter is right

Let me ultrathink about validating this codebase against our exceptional standards.

🚨 **REMEMBER: Hooks will verify EVERYTHING and block on violations!** 🚨

**Universal Quality Verification Protocol:**

**Step 0: Hook Status Check**
- Run `~/.claude/hooks/smart-lint.sh` directly to see current state
- If ANY issues exist, they MUST be fixed before proceeding
- Check `~/.claude/hooks/violation-status.sh` if it exists

**Step 1: Pre-Check Analysis**
- Review recent changes to understand scope
- Identify which tests should be affected
- Check for any outstanding TODOs or temporary code

**Step 2: Laravel Quality Checks**
Run appropriate checks for Laravel projects:
- `composer lint` (PHPStan/Larastan)
- `composer refactor` (Rector)
- `composer refactor:annotate` (generate docblocks)
- `composer format` (Pint)
- `composer test` (Pest)
- `~/.claude/hooks/smart-lint.sh` for automatic detection

**Universal Requirements:**
- ZERO warnings across ALL linters
- ZERO disabled linter rules without documented justification
- ZERO "nolint" or suppression comments without explanation
- ZERO formatting issues (all code must be auto-formatted)

**For Laravel projects specifically:**
- ZERO warnings from PHPStan/Larastan (all checks enabled)
- No disabled linter rules without explicit justification
- No raw SQL queries - use Eloquent/Query Builder
- No direct $_GET/$_POST usage - use Laravel request validation
- Proper type hints on all methods
- No database queries in Livewire render methods
- Consistent naming following Laravel conventions

**Step 3: Test Verification**
Run `composer test` and ensure:
- ALL Pest tests pass without flakiness
- Test coverage is meaningful (not just high numbers)
- Pest tests for complex business logic
- No skipped tests without justification
- Tests for Livewire component interactions
- Tests for Filament resources when applicable
- Tests actually test behavior, not implementation details

**Laravel Quality Checklist:**
- [ ] No raw SQL - use Eloquent or Query Builder
- [ ] No direct $_GET/$_POST - use Laravel request validation
- [ ] Type hints on all methods
- [ ] Early returns to reduce nesting
- [ ] Meaningful variable names ($userId not $id, $userAccountBalance not $balance)
- [ ] Self-documenting code with clear variable names - no inline comments
- [ ] Enum classes with methods (getLabel, getDescription, getColor, getIcon) instead of constants
- [ ] Proper Eloquent relationships with return types
- [ ] No database queries in Livewire render methods
- [ ] Livewire actions for user interactions
- [ ] Filament resources follow standard patterns
- [ ] Controllers kept thin - delegate to services
- [ ] No polling in Livewire/Filament - use Laravel Reverb + Echo
- [ ] Real-time updates via broadcast events instead of polling

**Code Hygiene Verification:**
- [ ] `composer refactor:annotate` can generate proper docblocks
- [ ] No commented-out code blocks
- [ ] No debugging dd() or dump() statements
- [ ] No placeholder implementations
- [ ] No inline comments within methods - code is self-documenting
- [ ] Consistent formatting (Pint)
- [ ] Dependencies are actually used
- [ ] No circular dependencies

**Security Audit:**
- [ ] Input validation on all external data
- [ ] Database queries use Eloquent/Query Builder
- [ ] No hardcoded secrets or credentials
- [ ] Proper permission checks (Gates/Policies)
- [ ] CSRF protection on all forms
- [ ] Mass assignment protection on models
- [ ] Sanitize user input in Livewire components

**Performance Verification:**
- [ ] No obvious N+1 queries (use eager loading)
- [ ] Livewire components don't query in render methods
- [ ] Appropriate use of caching
- [ ] Database indexes where needed
- [ ] No unnecessary queries in loops
- [ ] Efficient Eloquent relationships
- [ ] Proper pagination for large datasets
- [ ] Laravel Reverb configured for WebSocket performance
- [ ] Real-time updates via Echo instead of polling (reduces server load)

**Failure Response Protocol:**
When issues are found:
1. **IMMEDIATELY SPAWN AGENTS** to fix issues in parallel:
   ```
   "I found 15 linting issues and 3 test failures. I'll spawn agents to fix these:
   - Agent 1: Fix linting issues in files A, B, C
   - Agent 2: Fix linting issues in files D, E, F  
   - Agent 3: Fix the failing tests
   Let me tackle all of these in parallel..."
   ```
2. **FIX EVERYTHING** - Address EVERY issue, no matter how "minor"
3. **VERIFY** - Re-run all checks after fixes
4. **REPEAT** - If new issues found, spawn more agents and fix those too
5. **NO STOPPING** - Keep working until ALL checks show ✅ GREEN
6. **NO EXCUSES** - Common invalid excuses:
   - "It's just formatting" → Auto-format it NOW
   - "It's a false positive" → Prove it or fix it NOW
   - "It works fine" → Working isn't enough, fix it NOW
   - "Other code does this" → Fix that too NOW
7. **ESCALATE** - Only ask for help if truly blocked after attempting fixes

**Final Verification:**
The code is ready when:
✓ composer lint: PASSES with zero warnings
✓ composer test: PASSES all tests
✓ composer format: NO formatting issues
✓ composer refactor: NO code quality issues
✓ composer refactor:annotate: CAN generate proper docblocks
✓ All checklist items verified
✓ Feature works end-to-end in realistic scenarios
✓ Error paths tested and handle gracefully

**Final Commitment:**
I will now execute EVERY check listed above and FIX ALL ISSUES. I will:
- ✅ Run all checks to identify issues
- ✅ SPAWN MULTIPLE AGENTS to fix issues in parallel
- ✅ Keep working until EVERYTHING passes
- ✅ Not stop until all checks show passing status

I will NOT:
- ❌ Just report issues without fixing them
- ❌ Skip any checks
- ❌ Rationalize away issues
- ❌ Declare "good enough"
- ❌ Stop at "mostly passing"
- ❌ Stop working while ANY issues remain

**REMEMBER: This is a FIXING task, not a reporting task!**

The code is ready ONLY when every single check shows ✅ GREEN.

**Executing comprehensive validation and FIXING ALL ISSUES NOW...**