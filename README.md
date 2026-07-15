# Project description

A dbt project that transforms sales, inventory and staffing data from a multi-store bike shop chain into analytics-ready models, following a medallion architecture (staging → intermediate → mart) and exposing a star schema for Power BI.

[Slides analytic review.pdf](Slides%20analytic%20review.pdf) presents some analyses built on top of these models, in response to the initial business problem.

## Data source

Raw data comes from the `localbike_database` source (see [models/sources.yml](models/sources.yml)):

`brands`, `categories`, `customers`, `order_items`, `orders`, `products`, `staffs`, `stocks`, `stores`.

## Architecture

| Layer | Materialization | Purpose |
|---|---|---|
| `models/staging` | view | 1:1 cleaned/renamed copies of the source tables |
| `models/intermediate` | view | Business logic joining and aggregating staging models |
| `models/mart` | table | Star schema (facts + dimensions) consumed by BI tools |

### Staging

One model per source table (`stg_brands`, `stg_categories`, `stg_customers`, `stg_order_items`, `stg_orders`, `stg_products`, `stg_staffs`, `stg_stocks`, `stg_stores`).

### Intermediate

- **int_orders** — orders enriched with line-item aggregates and fulfillment metrics.
- **int_stock_vs_demand** — current stock vs. trailing twelve-month (TTM) demand per store-product.

### Mart (star schema)

Dimensions:
- **dim_stores** — one row per store.
- **dim_categories** — one row per product category.

Facts:
- **mart_store_performance** — monthly sales and fulfillment performance by store.
- **mart_stock_optimization** — stock health by store and category over a rolling 12-month window.
- **mart_staff_management** — store performance relative to active staff count (TTM).

## Requirements

- [dbt-core](https://docs.getdbt.com/docs/core/installation-overview) and a compatible adapter for your warehouse
- dbt packages listed in `packages.yml` (run `dbt deps`), currently [dbt_utils](https://github.com/dbt-labs/dbt-utils)
- A `profiles.yml` with a `user` profile configured for your target warehouse (not committed to source control)

## Tests

Generic tests (`unique`, `not_null`, `relationships`, `dbt_utils.unique_combination_of_columns`) are defined alongside each model in its `.yml` file. Singular tests live in [tests/](tests/):

- `assert_stg_order_items_total_amount_positive`
- `assert_int_orders_fulfillment_days_not_negative`
- `assert_int_stock_vs_demand_months_of_stock_remaining_not_negative`
