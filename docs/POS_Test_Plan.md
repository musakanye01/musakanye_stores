# POS MVP — Transaction Test Plan

**Status:** Draft. Every test is **Not run** until executed against an authenticated test session.
**Scope:** Supabase transaction functions and the first vertical slice: open shift → cash sale → blind close.
**Currency:** USD; store amounts as integer cents.

## Verified by inspection (not end-to-end test results)

- Initial schema and `transactional_pos_operations` migrations were reported as successfully applied.
- 13 core tables were found with RLS enabled.
- Six transactional functions were found and executable by `authenticated`: `open_shift`, `close_shift`, `create_cash_sale`, `submit_stock_receipt`, `review_stock_receipt`, and `record_cash_movement`.
- Partial unique index `one_open_shift_per_cashier` enforces at most one row with `status = 'open'` per cashier.
- `open_shift` checks authentication, active cashier role, non-negative float, and idempotency.
- `close_shift` checks authentication, shift ownership, non-negative count, row-locks the shift, and handles identical repeated close requests.
- These facts do not mean any end-to-end test has passed.

## Agreed MVP decisions

- Shift states: `open`, `paused`, `closed`. A paused shift may be closed.
- Cashier submits a blind cash count; expected cash and variance are owner-only.
- USD only; integer cents; no multi-currency tender or split tender.
- Sale writes must be atomic and idempotent.
- Stock receipt submission increases stock provisionally once; owner review must not add stock again.

## Test environment record

- Environment/project: ____________________
- Migration/build version: ____________________
- Cashier test user ID: ____________________
- Owner test user ID: ____________________
- Test variant IDs and starting stock: ____________________
- Run date/operator: ____________________

> Run tests through the app or a controlled client authenticated as the test user. SQL Editor calls generally do not supply the intended `auth.uid()`. Use a test environment, not live shop data. Never put passwords, PINs, access tokens, or secrets in this document.

## A. Shift opening

| ID | Test | Expected result | Status |
|---|---|---|---|
| SHIFT-001 | Active cashier opens a shift with zero float | One open shift; response has shift ID, `status=open`, `duplicate=false` | Not run |
| SHIFT-002 | Active cashier opens with a positive float | Exact float stored in integer cents | Not run |
| SHIFT-003 | Negative float | Rejected; no shift created | Not run |
| SHIFT-004 | Unauthenticated call | Rejected; no shift created | Not run |
| SHIFT-005 | Owner calls `open_shift` | Rejected; active cashier profile required | Not run |
| SHIFT-006 | Retry same key and identical request | Existing shift returned as duplicate; no second shift | Not run |
| SHIFT-007 | Reuse key with different request data | Rejected as idempotency conflict | Not run |
| SHIFT-008 | Open another shift while one is already open, with a different key | Unique index prevents a second open shift; app handles error clearly | Not run |
| SHIFT-009 | Concurrent open requests with different keys | At most one open shift; losing request is handled | Not run |

## B. Cash sale and stock

| ID | Test | Expected result | Status |
|---|---|---|---|
| SALE-001 | Valid cash sale, open own shift, sufficient stock/tender | Sale, items, payment, stock decrement and movements commit atomically | Not run |
| SALE-002 | Tender equals total | Sale succeeds; zero change | Not run |
| SALE-003 | Tender exceeds total | Sale succeeds; correct change; change is not double-counted as cash received | Not run |
| SALE-004 | Tender below total | Rejected; no sale/payment/stock changes | Not run |
| SALE-005 | Insufficient stock | Rejected; no partial sale; stock unchanged | Not run |
| SALE-006 | Unknown/inactive variant | Rejected; no stock change | Not run |
| SALE-007 | Another cashier's shift | Rejected; no sale | Not run |
| SALE-008 | Closed or paused shift | Rejected for sales; sales are allowed only on an open shift | Not run |
| SALE-009 | Retry same sale ID, key, and payload | Duplicate recognized; no duplicate sale/payment/movement | Not run |
| SALE-010 | Reuse key with different payload | Rejected as idempotency conflict | Not run |
| SALE-011 | Concurrent attempts to sell the last unit | Stock never becomes negative; at most one succeeds | Not run |
| SALE-012 | Empty/malformed items, invalid quantity or tender | Rejected; no partial writes | Not run |
| SALE-013 | Server commits but response is lost; retry same request | No duplicate sale; client reports state honestly | Not run |

## C. Blind close and reconciliation

| ID | Test | Expected result | Status |
|---|---|---|---|
| CLOSE-001 | Cashier closes own open shift with non-negative count | Shift closes; response reveals no expected cash or variance | Not run |
| CLOSE-002 | Cashier closes a paused shift | Shift closes, per agreed MVP rule | Not run |
| CLOSE-003 | Negative counted cash | Rejected; shift unchanged | Not run |
| CLOSE-004 | Unauthenticated close | Rejected | Not run |
| CLOSE-005 | Cashier closes another cashier's shift | Rejected; other shift unchanged | Not run |
| CLOSE-006 | Retry identical count and note | Duplicate response; no second close | Not run |
| CLOSE-007 | Retry closed shift with a different count or note | Rejected; original close record unchanged | Not run |
| CLOSE-008 | Owner reviews closed shift | Owner sees expected, counted, variance; totals reconcile to float, cash sales, refunds, expenses, drops and top-ups as implemented | Not run |
| CLOSE-009 | Cashier reads own closed shift | Expected cash, variance, cost and profit remain hidden | Not run |
| CLOSE-010 | Concurrent close requests | One consistent closing record; retries handled | Not run |

## D. Authorization and RLS

| ID | Test | Expected result | Status |
|---|---|---|---|
| AUTH-001 | Cashier reads own sales/shifts/receipts | Only permitted own records returned | Not run |
| AUTH-002 | Cashier reads another cashier's records | Unauthorized records not returned | Not run |
| AUTH-003 | Cashier directly writes protected transactional tables | Direct write denied where RPC is required | Not run |
| AUTH-004 | Owner reads operational data and audit trail | Owner sees permitted management data | Not run |
| AUTH-005 | Cashier attempts owner-only management operation | Server denies it; UI hiding alone is not relied on | Not run |
| AUTH-006 | Inactive profile calls a function requiring an active profile | Request rejected | Not run |

## E. Stock receipts and cash movements (follow-on)

| ID | Test | Expected result | Status |
|---|---|---|---|
| STOCK-001 | Submit valid stock receipt | Pending review; provisional stock increment and movements occur once | Not run |
| STOCK-002 | Retry same receipt request | No duplicate receipt or stock increment | Not run |
| STOCK-003 | Owner approves pending receipt | Status changes; stock is not incremented again | Not run |
| STOCK-004 | Owner rejects receipt | Status/audit reflect rejection; provisional stock correction behavior matches implementation | Not run |
| STOCK-005 | Invalid/non-positive receipt quantity | Rejected; no partial stock change | Not run |
| CASH-001 | Record allowed cash movement with reason | Recorded once against cashier's shift | Not run |
| CASH-002 | Retry same movement | No duplicate movement | Not run |
| CASH-003 | Invalid movement type/amount or unauthorized caller | Rejected | Not run |

## F. Offline and sync (after Drift queue exists)

| ID | Test | Expected result | Status |
|---|---|---|---|
| SYNC-001 | Record supported sale while offline | Persisted locally and marked pending, not server-synced | Not run |
| SYNC-002 | Reconnect | Queue retries safely; successful item marked synced | Not run |
| SYNC-003 | Restart app with pending operations | Pending queue survives and resumes | Not run |
| SYNC-004 | Repeated validation failure | Visible failed state and actionable error; not silently discarded | Not run |
| SYNC-005 | Retry after uncertain timeout | Server idempotency prevents duplicate financial/stock writes | Not run |
| SYNC-006 | Upgrade local schema | Drift migration preserves data and passes migration tests | Not run |

## Results log

For each executed test, record date/time, test ID, role, sanitized test inputs, actual response/database observations, pass/fail, and defect reference. Do not mark a test Pass from source inspection alone. Use statuses **Not run**, **Passed**, **Failed**, or **Blocked** and distinguish inspection findings from executed tests.
