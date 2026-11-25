# Devlog

## Stage 4: OTIF rule

**Overall check** (analyses/otif_overall_by_year.sql, finalized orders):

| Year | Orders | On time % | In full % | OTIF % | Avg delay (days) |
|---|---|---|---|---|---|
|           2016 |              297 |        89,6 |        88,9 |     87,9 |          -36,3 |
|           2017 |            39450 |        93,0 |        98,3 |     93,0 |          -12,2 |
|           2018 |            57965 |        91,4 |        99,1 |     91,4 |          -11,6 |

**Findings**
- Average delivery arrives 11-12 days before the promised date: the promise is conservative, so a high OTIF reflects the promise as much as the operation.
- 8 orders have status `delivered` but no delivery date. Counted as failures (no proof of delivery).
- Counting items instead of orders inflated seller totals by 12459 and every generic test still passed. Rule-level tests come in stage 5.

**Decisions**
- Orders in transit are out of the denominator.
- On time is compared by date, not time.
- Reference month is the month of the promised date.

## Stage 5: data quality

**What changed**
- 2 singular tests: deliveries before purchase (warn, 0 cases) and mart total reconciles with source orders.
- 2 unit tests: OTIF flags against the README rule (5 fictitious orders, one per case) and one order counted once per seller.
- Source freshness on `_loaded_at`: warn after 7 days, error after 30.

**Findings**
- Removing the `distinct` from the seller mart, which passed every test in stage 4, now fails the unit test before the table is built, and the reconciliation test fails on real data.
- Comparing delivery by time instead of date turns an order delivered at 23:00 on the promised day into a late one. The unit test catches it.

**Decisions**
- Deliveries before purchase are a warning, not an error: the source is public and cannot be fixed, so the count is documented instead.
- Unit tests run in development and CI, not in production runs (`--exclude-resource-type unit_test`): the logic does not change between runs.