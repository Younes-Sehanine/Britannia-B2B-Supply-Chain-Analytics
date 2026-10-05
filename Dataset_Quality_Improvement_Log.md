# Dataset Quality & Improvement Log — Consolidated
## Britannia Trade & Distribution Ltd — Supply Chain Dataset (FY2026)

**Dataset files:** `sales.csv` · `purchases.csv` (and the re-audited `sales_corrected_final.csv` · `purchases_corrected_final.csv`)

**Business context:** UK B2B trade & distribution — 4 distribution centres, 14 product categories, 340 products, 60 suppliers, 4,000 customers

**Document type:** Consolidation of three separate quality documents into one log (see §1)

> ### ⚠️ Scope notice — this log is a part of the problems, not all of them
>
> Everything below is what was **surfaced, diagnosed and documented** during the review passes presented here.
>
> It is **not an exhaustive record** of the problems encountered while building and cleaning this dataset.
>
> **Further problems exist that are not presented in this log** (see §13).
>
> Read every "PASS" / "0 violations" result as *"0 violations among the checks that were run"*, not as a guarantee that the dataset is free of defects.

---

## Table of Contents

1. [Scope and Sources](#1-scope-and-sources)
2. [Dataset Evolution](#2-dataset-evolution)
3. [Master Issue Register](#3-master-issue-register)
4. [Phase 0 — Design-Level Flaws](#4-phase-0--design-level-flaws)
5. [Pass 1 — Issues R1-01 to R1-07](#5-pass-1--issues-r1-01-to-r1-07)
6. [Pass 2 — Issues R2-A to R2-L](#6-pass-2--issues-r2-a-to-r2-l)
7. [Pass 3 — Issues R3-I to R3-VIII](#7-pass-3--issues-r3-i-to-r3-viii)
8. [Pass 4 — Independent Correction and Re-Audit](#8-pass-4--independent-correction-and-re-audit)
9. [Fix Chains and Recurring Root Causes](#9-fix-chains-and-recurring-root-causes)
10. [Validation Results](#10-validation-results)
11. [Remaining Limitations and Open Observations](#11-remaining-limitations-and-open-observations)
12. [Reconciliation Notes — Where the Source Documents Disagree](#12-reconciliation-notes--where-the-source-documents-disagree)
13. [Problems Not Presented in This Log](#13-problems-not-presented-in-this-log)
14. [Dataset Logic Reference](#14-dataset-logic-reference)

---

## 1. Scope and Sources

This log merges three documents that were previously kept separately.

| Ref | Source document | Version / date | What it contributes |
|---|---|---|---|
| **S1** | `dataset_quality_documentation.docx` | v2.0 — review pass of 30 Apr 2026 | Issues 01–10 and A–L, with *how each issue was discovered*; schema; version history |
| **S2** | `dataset_quality_log.md` | v3.0 | Design flaws D1–D4; review pass v3 (I–VIII); price-collapse discovery; 21-check validation; limitations; logic reference |
| **S3** | `supply_chain_correction_report.html` | May 2026 | Independent correction and re-audit: 8 fixes, 15 checks, minor observations |

**How the sources were merged**

- Issues were given unified IDs by pass: `D#` (design), `R1-##`, `R2-X`, `R3-X`, `R4-##`. The original IDs are kept in the register so nothing loses traceability.
- Where two sources describe the same issue (e.g. S1 "Issue 10" = S2 "D1"), they were combined into one entry.
- **No figures were invented.** Where the sources disagree, both values are shown and the conflict is listed in §12 with a suggested check.
- Severity uses the scale 🔴 Critical · 🟠 High · 🟡 Medium · 🟢 Low. S1 and S3 used their own scales; they were mapped onto this one (S2's rating wins where S1 and S2 overlap).

---

## 2. Dataset Evolution

| Stage | Date (per source) | Sales rows | Purchase rows | What changed |
|---|---|---|---|---|
| v1.0 | 2026-04-22 | ~100,000 (single flat table) | — | Original: one denormalised table, January only |
| v2.0 | 2026-04-22 | — | — | Split into `sales` + `purchases`; 12 months; seasonality; B2B quantities (D1–D3) |
| v2.1 | 2026-04-23 | 175,000 | ~30,000 | Scaled up; anomaly rates tuned |
| v2.2 | 2026-04-24 | 175,000 | ~30,000 | R1-01 — transport cap + margin floor |
| v2.3 | 2026-04-24 | 175,000 | ~30,000 | R1-02 — mode-specific lead times |
| v2.4 | 2026-04-24 | 175,000 | ~30,000 | R1-03 / R1-04 — 4,000 unique customer names |
| v2.5 | 2026-04-30 | 175,000 | 37,665 (30,071 + 7,594 top-ups) | Pass 2 (A–L) |
| v3.0 | not dated in sources | 175,000 | 37,707 (incl. 7,636 top-ups) | Pass 3 (I–VIII), price/cost rebuild |
| Re-audit | May 2026 | 178,272 | 37,707 | Pass 4 — files `*_corrected_final.csv` (see §12 for how this relates to v3.0) |

---

## 3. Master Issue Register

**39 entries — 36 fixed, 3 confirmed clean.**

| ID | Legacy ID | Issue | Severity | Tables | Status |
|---|---|---|---|---|---|
| **Phase 0 — Design-level** | | | | | |
| D1 | S1 #10 · S2 D1 | Sales and purchases stored in one flat row with the same date | 🔴 Critical | Both | ✅ Fixed |
| D2 | S1 #08 · S2 D2 | Only January data (single month) | 🔴 Critical | Both | ✅ Fixed |
| D3 | S1 #09 · S2 D3 | All prices / costs identical — no variation | 🔴 Critical | Both | ✅ Fixed |
| D4 | S2 D4 | One warehouse, one region only | 🟠 High | Both | ✅ Fixed |
| **Pass 1** | | | | | |
| R1-01 | 01 | Selling price below landed cost in 42.6% of rows | 🔴 Critical | Both | ✅ Fixed |
| R1-02 | 02 | All ship modes deliver in the same time | 🔴 Critical | Both | ✅ Fixed |
| R1-03 | 03 | 244 customer names for 4,000 customer IDs | 🟠 High | Sales | ✅ Fixed |
| R1-04 | 04 | Customer names ending in #2 … #9 | 🟠 High | Sales | ✅ Fixed |
| R1-05 | 05 | Customers buy from all 14 categories | 🔴 Critical | Sales | ✅ Fixed (deepened in R2-E) |
| R1-06 | 06 | 3,999 of 4,000 customers use all 4 warehouses — no geography | 🔴 Critical | Sales | ✅ Fixed (refined in R3-II) |
| R1-07 | 07 | Suppliers cover all categories — no specialisation | 🔴 Critical | Purchases | ✅ Fixed (deepened in R2-G) |
| **Pass 2** | | | | | |
| R2-A | A | Outbound transport cost identical across ship modes | 🔴 Critical | Sales | ✅ Fixed |
| R2-B | B | All 11,041 backorder rows marked Early / On Time | 🔴 Critical | Sales | ✅ Fixed |
| R2-C | C | Transport null rate 3.43% (target < 1%) | 🟠 High | Sales | ✅ Fixed |
| R2-D | D | 91.4% of product-warehouse stock balances go negative | 🔴 Critical | Both | ✅ Fixed |
| R2-E | E | Customer–category affinity still too broad after R1-05 | 🟠 High | Sales | ✅ Fixed |
| R2-F | F | Warehouse routing coherence check | — | Sales | ✅ Confirmed clean |
| R2-G | G | Supplier specialisation still too broad after R1-07 | 🟠 High | Purchases | ✅ Fixed |
| R2-H | H | Cancelled rows carrying `return_flag = True` | 🟡 Medium | Sales | ✅ Fixed |
| R2-I | I | 5,289 rows with `net_quantity = 0` not flagged | 🟢 Low | Sales | ✅ Fixed |
| R2-J | J | Purchase transport cost identical across delivery methods | 🔴 Critical | Purchases | ✅ Fixed |
| R2-K | K | Return quantity never exceeds shipped quantity | — | Sales | ✅ Confirmed clean |
| R2-L | L | Revenue = net quantity × net unit price | — | Sales | ✅ Confirmed clean |
| **Pass 3** | | | | | |
| R3-I | I (v3) | `'Midwest'` used as a UK region label | 🟠 High | Both | ✅ Fixed |
| R3-II | II | Routing percentages perfectly fixed (60 / 58 / 62 / 59%) | 🟠 High | Sales | ✅ Fixed |
| R3-III | III | Absurd price ranges (A4 paper £11 – £1,069) | 🔴 Critical | Sales | ✅ Fixed (superseded by R3-VI) |
| R3-IV | IV | Payment terms uniformly random — exactly 20% each | 🟠 High | Both | ✅ Fixed |
| R3-V | V | Silverton Trade Group covers 6 categories (max = 5) | 🟡 Medium | Purchases | ✅ Fixed |
| R3-VI | VI | **All 14 categories average £66–71 — no price differentiation** | 🔴 Critical | Both | ✅ Fixed |
| R3-VII | VII | Purchase costs collapsed (Rice costs the same as a TV, ~£34) | 🔴 Critical | Purchases | ✅ Fixed |
| R3-VIII | VIII | Top-up PO transport £738 avg vs £21 for regular POs | 🟠 High | Purchases | ✅ Fixed |
| **Pass 4** | | | | | |
| R4-01 | S3 #1 | Warehouse name / region mismatch for its ID | 🔴 Critical | Both | ✅ Fixed |
| R4-02 | S3 #2 | `partial_shipment_flag` wrong in 39.5% of purchase rows | 🔴 Critical | Purchases | ✅ Fixed |
| R4-03 | S3 #3 | Cancelled-order logic ambiguous / impossible states | 🟠 High | Sales | ✅ Fixed |
| R4-04 | S3 #4 | `purchase_month` off by one month on 2,560 rows | 🟠 High | Purchases | ✅ Fixed |
| R4-05 | S3 #5 | 4,642 zero-shipped orders with no status reason | 🟡 Medium | Sales | ✅ Fixed |
| R4-06 | S3 #6 | `partial_fill_flag` true on 406 fully-filled orders | 🟡 Medium | Sales | ✅ Fixed |
| R4-07 | S3 #7 | Discount values hyper-granular (3,727 distinct) | 🟡 Medium | Sales | ✅ Fixed |
| R4-08 | S3 #8 | Two products selling below cost (891 rows) | 🟢 Low | Sales | ✅ Fixed |

---

## 4. Phase 0 — Design-Level Flaws

Structural problems in the original flat dataset. They could not be patched and required a full regeneration.

### D1 — Sales and Purchases in the Same Row, Same Date
**Severity:** 🔴 Critical · **Tables:** both · **Status:** ✅ Fixed

- **Problem:** Purchase and sale data sat in the same row with the same date. Goods must be received before they can be sold — a sale cannot happen on, or before, the arrival date.
- **Root cause:** Denormalised single-table design, a common synthetic-data shortcut.
- **Impact:** No lead-time analysis, no inventory calculation, no supplier-to-customer flow tracing; a fundamental logical contradiction (selling stock before receiving it).
- **Solution:** Redesigned into two independent fact tables:
  - `sales.csv` — one row per customer order line
  - `purchases.csv` — one row per supplier purchase-order line
  - Joined analytically on `product_id + warehouse_id` only (no direct foreign key)
  - **Date rule enforced:** every sale date is ≥ 1 day after the earliest supplier delivery for that `(product_id, warehouse_id)` pair (100% compliance)

### D2 — Only January Data
**Severity:** 🔴 Critical · **Tables:** both · **Status:** ✅ Fixed

- **Problem:** All ~100,000 original rows were dated within January 2026.
- **Root cause:** Generation used a fixed single-month date range.
- **Impact:** No seasonality, trend or time-series analysis; inventory turnover meaningless; lead times could not cross month boundaries.
- **Solution:** Fully regenerated over 12 months (Jan–Dec 2026) with per-category seasonal multipliers (e.g. Electronics +70% in December, Toys +80% in Nov–Dec), four lifecycle curves (Growing / Mature / Stable / Declining) and compounding monthly inflation of 0.3–1.0%.

### D3 — All Prices Identical
**Severity:** 🔴 Critical · **Tables:** both · **Status:** ✅ Fixed

- **Problem:** Near-zero variance in `unit_price` and `purchase_unit_cost` across products, segments and time.
- **Root cause:** Prices were assigned without noise, seasonality, segment multipliers or supplier-specific cost differences.
- **Impact:** Price-elasticity analysis, segment pricing studies and margin-variance decomposition impossible; gross margin uniform and meaningless.
- **Solution:** Five variation sources introduced:
  - Segment multipliers — Wholesale 0.88×, Business 0.95×, Online 1.05×, Retail 1.10×
  - Monthly seasonal factor per category
  - Compounding monthly inflation
  - Supplier cost multipliers (0.82–1.25×)
  - Row-level log-normal noise (±9% on sales price, ±7% on purchase cost)
  - Plus supplier promotions on 4% of POs and a customer discount drawn from Beta(1.5, 8)

### D4 — One Warehouse, One Region
**Severity:** 🟠 High · **Tables:** both · **Status:** ✅ Fixed

- **Problem:** Only `WH-01` and a single region (`Southwest`) existed.
- **Solution:** Expanded to four distribution centres across England:

| ID | Name | Region |
|---|---|---|
| WH-01 | Dagenham East DC | Northeast |
| WH-02 | Coventry Central Fulfilment Hub | Midlands |
| WH-03 | Bristol Portbury Logistics Park | West |
| WH-04 | Lutterworth National DC | Southeast |

---

## 5. Pass 1 — Issues R1-01 to R1-07

### R1-01 — Selling Price Below Landed Cost
**Severity:** 🔴 Critical · **Tables:** both · **Status:** ✅ Fixed

- **Discovered by:** Querying `unit_price` against average purchase cost.
- **Confirmed:** 42.6% of sale rows had `net_unit_price` below the average landed cost of that `(product, DC)` pair.
- **Root cause:** Two compounding errors.
  1. Inbound `transport_cost = distance × rate × qty^0.45` was unbounded — per-unit freight on bulk, long-distance orders exceeded the product's margin.
  2. `unit_price` was generated independently of `purchase_unit_cost`, with no margin floor.
- **Impact:** 42.6% of rows were loss-making sales; any margin or profitability model would be systematically wrong.
- **Solution:**
  1. Capped inbound `transport_cost` at 15% of PO value (`purchase_unit_cost × received_quantity`) — affected 69.3% of purchase rows.
  2. Raised `unit_price` wherever `net_unit_price < avg_landed_cost × 1.20` (minimum 20% markup) — affected 9.2% of sale rows.
  3. Secondary fix for 291 deep-discount rows that still fell below landed cost.
  4. Recomputed `net_unit_price` and `sales_revenue`; the `discount` column was left untouched.
- **Result:** 0% of rows below landed cost; 84.3% of rows have ≥ 20% gross margin over landed cost; median margin per unit £13.02.
- **See also:** the 15% cap was later removed (R2-J); the floor was rebuilt (R3-VI) and re-checked (R4-08).

### R1-02 — All Ship Modes Deliver in the Same Time
**Severity:** 🔴 Critical · **Tables:** both · **Status:** ✅ Fixed

- **Discovered by:** Observing that delivery dates fell a similar distance after `sale_date` whatever the `ship_mode`. Measured averages for all five modes were 9.3–9.8 days — Express Overnight and Sea Economy were statistically indistinguishable.
- **Root cause:** Delivery lag was drawn from one `np.random.exponential(4.5)` for every order. Ship mode was a cosmetic label with no effect on the calculation. The same flaw applied to purchase `lead_time_days` vs `delivery_method`.
- **Impact:** Ship mode had no predictive power for delivery time; SLA compliance and logistics cost-efficiency analysis meaningless.
- **Solution:** Mode-specific normal distributions on both tables; `service_level_status` recomputed with mode-specific SLA windows.

| Sales — ship mode | Mean | Range |
|---|---|---|
| Express Overnight | 1 day | 1–2 |
| Express Air | 2.5 days | 1–4 |
| Standard Ground | 5.5 days | 3–9 |
| Rail Freight | 11 days | 6–18 |
| Sea Economy | 28 days | 14–50 |

| Purchases — delivery method | Mean | Range |
|---|---|---|
| Express Overnight | 2 days | 1–3 |
| Air Express | 4 days | 2–7 |
| Ground Standard | 10 days | 5–18 |
| Rail | 18 days | 10–30 |
| Sea Economy | 38 days | 20–65 |

### R1-03 — 244 Customer Names for 4,000 Customer IDs
**Severity:** 🟠 High · **Tables:** sales · **Status:** ✅ Fixed

- **Discovered by:** `COUNT(DISTINCT customer_name)` vs `COUNT(DISTINCT customer_id)` → 244 vs 4,000 (a 16:1 ratio).
- **Root cause:** Name pools held only ~123 base names across four segments; modulo-index cycling repeated them. Total distinct name + suffix combinations reached only 244.
- **Impact:** Customer-level analysis (CLV, repeat rates, segmentation) invalid; entity matching would merge unrelated accounts.
- **Solution:** Rebuilt with combinatorial generation — `{prefix} + {trade noun} + {suffix}` — giving one globally unique name per `customer_id`.
- **Result:** 4,000 distinct names, 0 duplicates.

### R1-04 — Customer Names with #2, #3 … #9 Suffixes
**Severity:** 🟠 High · **Tables:** sales · **Status:** ✅ Fixed

- **Discovered by:** Visible suffixes such as `Albion Wholesale Foods Ltd #2` and `Harbour Lights Home Furnishings #3`.
- **Root cause:** Fallback de-duplication in the generation loop appended a numeric suffix when the name pool ran out (some reached `#9`).
- **Impact:** Exposes the generation logic to any analyst; NLP / entity-matching treats `Company X` and `Company X #2` as related.
- **Solution:** Resolved by the R1-03 rebuild — no suffix fallback is needed any more.

### R1-05 — Customers Buy from All 14 Categories
**Severity:** 🔴 Critical · **Tables:** sales · **Status:** ✅ Fixed (deepened in R2-E)

- **Discovered by:** `DISTINCT product_category` per `customer_id` averaged **13.2**; 1,780 customers bought all 14.
- **Root cause:** Products were assigned to orders by random selection from the full catalogue with no customer–category affinity.
- **Impact:** Segmentation, product-affinity and recommendation models would conclude that customer type has zero predictive power.
- **Solution (v1):** Customer profiles assigned from name keywords; 44,469 rows had their product swapped. Mean categories per customer fell from 13.2 to **8.3** — still too broad (see R2-E).

### R1-06 — No Geographic Warehouse Routing
**Severity:** 🔴 Critical · **Tables:** sales · **Status:** ✅ Fixed (refined in R3-II)

- **Discovered by:** `warehouse_id` counts per customer — 3,999 of 4,000 customers ordered from all four warehouses; Northeast customers used the Northeast DC only ~25% of the time.
- **Root cause:** `warehouse_id` was assigned randomly per order, weighted only by a demand multiplier; customer region had no influence.
- **Impact:** Warehouse capacity planning, regional fulfilment cost modelling and DC benchmarking meaningless.
- **Solution:** Home-warehouse assignment by region — 75% of orders to the home DC, 20% to an adjacent DC, 5% to any DC.
- **Result:** Northeast → WH-01 = 60%, West → WH-03 = 62%, Southeast → WH-04 = 58%, Midlands → WH-02 = 59% (the Midlands was labelled "Midwest" at this stage — see R3-I).

### R1-07 — Suppliers Span All Categories
**Severity:** 🔴 Critical · **Tables:** purchases · **Status:** ✅ Fixed (deepened in R2-G)

- **Discovered by:** Categories per `supplier_id` averaged **8.9**, maximum 13; grocery suppliers also appeared in Automotive.
- **Root cause:** Suppliers were sampled at random from the 60-supplier pool with no specialisation constraint.
- **Impact:** Spend-by-category, dual-sourcing risk and category-level procurement analysis distorted.
- **Solution (v1):** Supplier profiles assigned by name — applied to *new* data only (see R2-G).

---

## 6. Pass 2 — Issues R2-A to R2-L

All issues were confirmed against the live data before any correction was applied.

### R2-A — Outbound Transport Cost Identical Across Ship Modes
**Severity:** 🔴 Critical · **Tables:** sales · **Status:** ✅ Fixed

- **Discovered by:** `SELECT ship_mode, AVG(transport_cost) … GROUP BY ship_mode` → all five modes between £316 and £321.
- **Root cause:** `random.uniform(4, 95) × qty^0.38` drew from one shared distribution; ship mode was assigned after the cost was computed.
- **Impact:** Express Overnight should cost ~10–20× more per unit than Sea Economy; mode-mix and freight-budget modelling would show all modes as cost-equivalent.
- **Solution:** Mode-specific rate bands; `transport_cost = rate × sqrt(ordered_quantity)` for all non-cancelled rows.

| Ship mode | Rate band (£ per unit^0.5) | Mean before | Mean after | Ratio vs Sea |
|---|---|---|---|---|
| Express Overnight | £10–£90 | £319 | £90.69 | 20.0× |
| Express Air | £5–£70 | £321 | £52.56 | 11.6× |
| Standard Ground | £1.2–£22 | £317 | £15.44 | 3.4× |
| Rail Freight | £0.8–£15 | £319 | £10.46 | 2.3× |
| Sea Economy | £0.3–£7 | £318 | £4.53 | 1.0× |

### R2-B — Backorders Marked Early or On Time
**Severity:** 🔴 Critical · **Tables:** sales · **Status:** ✅ Fixed

- **Discovered by:** `DISTINCT service_level_status WHERE backorder_flag = TRUE` returned only `Early` and `On Time`; average delivery days for the 11,041 backorder rows was 9.6 — identical to normal orders.
- **Root cause:** `backorder_flag` was assigned stochastically (3.5% of non-cancelled rows) with no link to stock, timing or SLA, and delivery dates were never pushed back afterwards.
- **Business rule violated:** A backorder means stock was short, so the remainder ships only when replenishment arrives — a backorder is by definition a service failure.
- **Solution:** For all 11,041 backorder rows `customer_delivery_date = sale_date + MODE_NORMAL_MAX + extra_delay`, with `extra_delay` a random 5–45 days; status = `Late` if extra ≤ 20 days, `Very Late` if > 20.
- **Result:** 0 backorder rows Early / On Time; min delivery days = 7; mean = 41.4 (41.3 in S2).

| Before | After |
|---|---|
| 100% Early or On Time | 100% Late or Very Late |
| Mean 9.6 days (same as normal orders) | Mean ~41 days |
| Min 1 day | Min 7 days |

### R2-C — Transport Null Rate 3.43%
**Severity:** 🟠 High · **Tables:** sales · **Status:** ✅ Fixed

- **Discovered by:** `AVG(transport_cost IS NULL) WHERE cancelled_flag = FALSE` → 3.43% (spec < 1%).
- **Root cause:** Null injection of 0.007 per row ran on top of the (correct) nulls on cancelled rows.
- **Impact:** Distorts freight-spend analysis and creates gaps in unit economics.
- **Solution:** Injection reduced to 0.5% of non-cancelled rows; cancelled rows stay null (no shipment = no freight).
- **Result:** 0.47% null rate.

### R2-D — 91.4% of Stock Balances Go Negative
**Severity:** 🔴 Critical · **Tables:** both · **Status:** ✅ Fixed

- **Discovered by:** Running stock (`cumulative received − cumulative sold`) per `(product_id, warehouse_id)` — 1,243 of 1,360 combinations went negative in at least one month.
- **Root cause:** Purchase and sales volumes came from two separate formulas calibrated independently, so sales regularly outran purchases over the 12 months.
- **Impact:** Stock turnover, days of coverage, safety stock and replenishment planning all produce nonsense. Stock-outs were meant to be exceptional (30 planned combinations), not the default for 91% of products.
- **Solution:** Walked each combination month by month; whenever running stock would go negative, inserted a **top-up PO** (`PUR-TU-` prefix):
  - delivered on day 1–7 of that month; PO dated 8–15 days earlier
  - quantity = shortfall + random safety buffer (15–60 units)
  - assigned to the product's primary supplier, average cost ± 5%, Ground Standard delivery
  - the pass was **re-run from scratch** after R2-E re-assigned products, to stay consistent with the new sales distribution
- **Result:** 7,594 top-up POs added (7,636 in the later v3.0 file); 0 / 1,360 combinations negative; purchase rows 30,071 → 37,665.

### R2-E — Customer–Category Affinity (Deep Fix of R1-05)
**Severity:** 🟠 High · **Tables:** sales · **Status:** ✅ Fixed

- **Discovered by:** Post-R1-05 diagnostic — mean still 8.3 categories per customer; hardware stores still buying baby formula and movies.
- **Root cause:** The R1-05 swap enforcement was weak; the 5% "any category" escape hatch and the adjacent-category probability were too permissive.
- **Solution:**
  1. Rebuilt profile inference with precise keyword matching across **20 retail archetypes, 10 business types** and segment-level defaults.
  2. Cut escape hatches to 80% primary cluster / 15% adjacent / 5% any. Adjacent categories are now contextual (a hardware store's adjacent set = Tools + Automotive + Industrial, not Baby + Movies).
  3. 44,469 rows had `product_id`, `product_name`, `product_category` swapped; every other column was left unchanged.
- **Result:** Mean categories per customer = **5.8**; only 11 customers buy all 14 (generic wholesale accounts); 0 single-category buyers.

### R2-F — Warehouse Routing (Confirmed Clean)
**Severity:** — · **Tables:** sales · **Status:** ✅ Confirmed clean

- Cross-tab of `customer_region` × `warehouse_id` showed dominant home-DC usage — the R1-06 fix was intact.
- Northeast → WH-01 60% · West → WH-03 62% · Southeast → WH-04 58% · Midlands → WH-02 59% · Southwest (no dedicated DC) split WH-03 35% / WH-02 42%.
- **No change applied.** (R3-II later judged these perfectly fixed percentages too deterministic.)

### R2-G — Supplier Category Specialisation (Deep Fix of R1-07)
**Severity:** 🟠 High · **Tables:** purchases · **Status:** ✅ Fixed

- **Discovered by:** Post-R1-07 diagnostic — mean still 8.9 categories per supplier; 56 of 60 suppliers covered more than 5; Greenfield Wholesale (food) still supplied Industrial and Automotive.
- **Root cause:** The R1-07 mapping applied only to new generation; existing purchase rows kept their random suppliers.
- **Solution:** Built a `SUPPLIER_PROFILES` dictionary mapping each of the 60 suppliers to 2–5 categories by name keyword (e.g. *Greenfield* → Grocery, Health, Baby; *Apex Industrial* → Industrial, Tools, Automotive). Every row whose supplier did not cover its `product_category` was re-linked (`supplier_id` + `supplier_name`) to a random specialist. **21,431 rows re-linked.**
- **Result (S1):** mean categories per supplier 3.3; max **6**; 1 supplier above 5 (Silverton — fixed in R3-V, giving the final max of 4).

### R2-H — Cancelled Rows with `return_flag = True`
**Severity:** 🟡 Medium · **Tables:** sales · **Status:** ✅ Fixed

- **Discovered by:** `COUNT WHERE cancelled_flag = TRUE AND return_flag = TRUE`.
- **Root cause:** Cancellations and returns were independent random events; nothing shipped means nothing can be returned.
- **Impact:** Would imply a physical return on an order that was never shipped and corrupt returns-rate / reverse-logistics analysis.
- **Solution:** For all cancelled rows: `return_flag = False`, `return_quantity = 0`, `return_date = NULL`.
- **Result:** 0 violations. (Related issue found later in R4-03.)

### R2-I — `net_quantity = 0` Rows Not Flagged
**Severity:** 🟢 Low · **Tables:** sales · **Status:** ✅ Fixed

- **Discovered by:** `COUNT WHERE net_quantity = 0 AND cancelled_flag = FALSE` → 5,289 rows.
- **Root cause:** Rows where `shipped_quantity = return_quantity` (100% return) had correct £0 revenue but were indistinguishable from cancellations in aggregate; they inflate shipped totals and distort return-rate denominators.
- **Solution:** Added boolean `full_return_flag` = `net_quantity = 0 AND cancelled_flag = FALSE AND return_flag = TRUE`.
- **Result:** 496 rows flagged in S1 (S2 still quotes 5,289) — see §12, item C5.

### R2-J — Purchase Transport Cost Undifferentiated by Delivery Method
**Severity:** 🔴 Critical · **Tables:** purchases · **Status:** ✅ Fixed

- **Discovered by:** `SELECT delivery_method, AVG(transport_cost) … GROUP BY` — Ground Standard and Air Express nearly equal despite a ~5× speed difference; Sea Economy only marginally cheaper.
- **Root cause:** The 15%-of-value cap from R1-01 was consistently binding for cheap bulk items, pushing every method up toward the same ceiling.
- **Impact:** Freight modal analysis (cost per unit by method, Air vs Sea by category) unreliable.
- **Solution:** Method-specific rate bands; formula `rate × sqrt(received_quantity) × (1 + distance_km / 1000)`; the 15% cap removed and replaced by an absolute floor of £1 and ceiling of £50,000 per PO. Top-up PO transport was corrected in the same pass (mean had been ~£1,853).

| Delivery method | Rate band (£ per unit^0.5) | Mean after | Ratio vs Sea |
|---|---|---|---|
| Express Overnight | £3–£5 | £210.14 | 51.8× |
| Air Express | £1.5–£3 | £122.40 | 30.1× |
| Ground Standard | £0.2–£0.6 | £21.19 | 5.2× |
| Rail | £0.1–£0.3 | £10.76 | 2.7× |
| Sea Economy | £0.03–£0.12 | £4.06 | 1.0× |

### R2-K / R2-L — Arithmetic Integrity (Confirmed Clean)
**Status:** ✅ Confirmed clean — no change applied.

| Check | Result |
|---|---|
| `return_quantity > shipped_quantity` | 0 violations (return = `randint(1, shipped + 1)`, correctly bounded) |
| `net_quantity ≠ shipped_quantity − return_quantity` | 0 violations |
| `sales_revenue ≠ net_quantity × net_unit_price` (±£0.05) | 0 violations (revenue recomputed in R1-01 and stayed consistent) |

---

## 7. Pass 3 — Issues R3-I to R3-VIII

### R3-I — 'Midwest' Used as a UK Region
**Severity:** 🟠 High · **Tables:** both · **Status:** ✅ Fixed

- **Problem:** `customer_region` and `warehouse_region` contained `'Midwest'` — an American designation with no UK equivalent.
- **Impact:** Routing and distance analysis on region names semantically wrong; the dataset could not be presented as a realistic UK business.
- **Solution:** Renamed `'Midwest'` → `'Midlands'` in both columns of both files.

### R3-II — Routing Percentages Perfectly Fixed
**Severity:** 🟠 High · **Tables:** sales · **Status:** ✅ Fixed

- **Problem:** Northeast → WH-01 was exactly 60.1%, West → WH-03 exactly 62.0% — identical across every cohort, i.e. formulaic assignment rather than operational routing.
- **Root cause:** One fixed probability vector per region, with no per-customer variation.
- **Impact:** Every customer in a region routed identically; real routing varies by account history, preference and stock.
- **Solution:** Per-customer **Dirichlet-sampled** weight vectors — region-coherent but unique per customer.
- **Result (aggregate %):**

| Customer region | WH-01 | WH-02 | WH-03 | WH-04 |
|---|---|---|---|---|
| Northeast | 68 | 15 | 7 | 10 |
| Midlands | 14 | 63 | 10 | 13 |
| West | 8 | 18 | 64 | 10 |
| Southeast | 11 | 19 | 7 | 63 |
| Southwest | 9 | 41 | 37 | 13 |
| International | 37 | 21 | 29 | 13 |

### R3-III — Pricing Absurd Range
**Severity:** 🔴 Critical · **Tables:** sales · **Status:** ✅ Fixed (superseded by R3-VI)

- **Problem:** Individual products spanned ~100× in price — A4 Copy Paper £11 → £1,069; Organic Brown Rice £11 → £844.
- **Root cause:** An earlier "Fix 3" clipped prices to [0.40×, 2.50×] of the *observed* median — but that median was already distorted by prior price corruption, so the clip anchored on a wrong value.
- **Solution (first attempt):** Clipped `unit_price` to a band around a median derived from known base prices. This removed the worst outliers but did not cure the underlying collapse — see R3-VI.

### R3-IV — Payment Terms Randomly Uniform
**Severity:** 🟠 High · **Tables:** both · **Status:** ✅ Fixed

- **Problem:** `Immediate`, `Net15`, `Net30`, `Net60`, `Net90` were each ~20% of rows.
- **Root cause:** `random.choice(PAYMENT_TERMS)` with uniform weights, regardless of segment.
- **Impact:** A wholesale account and an online micro-seller looked identical; no credit-risk differentiation; unrealistic for B2B.
- **Solution:** Segment-specific distributions on sales; purchase terms reflect typical supplier credit (Net30 dominant at 42%).

| Segment | Immediate | Net15 | Net30 | Net60 | Net90 |
|---|---|---|---|---|---|
| Wholesale | 3% | 5% | 22% | 38% | 32% |
| Business | 5% | 10% | 40% | 35% | 10% |
| Retail | 8% | 30% | 45% | 14% | 3% |
| Online | 30% | 40% | 25% | 4% | 1% |

### R3-V — Silverton Trade Group Covers 6 Categories
**Severity:** 🟡 Medium · **Tables:** purchases · **Status:** ✅ Fixed

- **Problem:** Silverton supplied Automotive, Baby, Books, Clothing, Electronics and Grocery — implausible, and above the 5-category cap.
- **Solution:** 59 Automotive and 65 Baby rows re-linked to specialists (Automotive → Apex Industrial Supply Co, Redline Supply Co; Baby → Greenfield Wholesale, Goldcrest Wholesale).
- **Result:** Silverton now covers 4 categories (Books, Clothing, Electronics, Grocery); maximum per supplier = 4.

### R3-VI — All 14 Categories Average £66–71 *(most fundamental pricing flaw)*
**Severity:** 🔴 Critical · **Tables:** both · **Status:** ✅ Fixed

- **Discovered by:** Diagnostic query on mean price per category.

| Category | Mean price before | Mean price after |
|---|---|---|
| Electronics | £68 | £145 |
| Industrial | £68 | £88 |
| Grocery | £68 | £24 |
| Baby | £69 | £37 |
| Health | £68 | £37 |
| Books | £71 | £59 |
| All others | £66–71 | correctly differentiated |

Electronics ÷ Grocery ratio: **1.0×** before → **6.0×** after (expected 5–15× for a B2B catalogue).

| Product | Expected B2B price | Price found in data |
|---|---|---|
| Organic Brown Rice 5kg | £8–15 | £67 |
| 4K Smart TV 55" | £400–600 | £68 |
| COSHH Cabinet Steel 45L | £250–350 | £67 |
| Treadmill Folding 1.5HP Home | £300–450 | £69 |
| A4 Copy Paper ×5 Ream | £15–30 | £71 |

- **Root cause:** The R3-III clip to the observed median. Through earlier multiplicative distortion, a TV's median and a bag of rice's median had converged to ~£67–68; clipping to that corrupted anchor squeezed every product into the same £48–134 band.
- **Solution:** Restored the true base prices from the original product catalogue (340 products, all verified) and recomputed `unit_price` from scratch:

```
unit_price = base_price × segment_mult × seasonal_mult × inflation × lognormal_noise(0, 0.09)
```

Margin floor: `net_unit_price ≥ corrected_purchase_unit_cost × 1.25`.

### R3-VII — Purchase Costs Also Collapsed (~£34 for everything)
**Severity:** 🔴 Critical · **Tables:** purchases · **Status:** ✅ Fixed

- **Problem:** A £12 grocery item and a £620 TV had the same purchase cost.

| Product | Expected cost | Cost found |
|---|---|---|
| Organic Brown Rice 5kg | ~£7 | £34 |
| 4K Smart TV 55" | ~£360 | £36 |
| COSHH Cabinet Steel 45L | ~£186 | £38 |
| Treadmill Folding 1.5HP Home | ~£336 | £45 |

- **Root cause:** Same distortion as R3-VI — generation noise plus several clipping passes collapsed every product's cost into one range.
- **Solution:** Recomputed from scratch:

```
purchase_unit_cost = base_price × 0.58 × supplier_cost_mult × monthly_inflation × lognormal_noise(0, 0.07)
```

`0.58` = standard COGS ratio · `supplier_cost_mult` = stable per-supplier multiplier (0.82–1.22×, seeded per `supplier_id`) · promotional discount applied where `supplier_discount` is populated.
- **Result:**

| Product | Mean sell price | Mean purchase cost | Margin |
|---|---|---|---|
| Organic Brown Rice 5kg | £13 | £7 | 46% |
| 4K Smart TV 55" | £725 | £351 | 52% |
| COSHH Cabinet Steel 45L | £316 | £210 | 34% |
| A4 Copy Paper ×5 Ream | £29 | £18 | 38% |
| Cordless Drill 18V Kit | £150 | £94 | 37% |

### R3-VIII — Top-up PO Transport Cost Anomaly
**Severity:** 🟠 High · **Tables:** purchases · **Status:** ✅ Fixed

- **Problem:** All 7,636 top-up POs use Ground Standard, yet averaged **£738** transport vs **£21** for regular Ground Standard POs.
- **Root cause:** The top-up script used its own formula (`rate × qty^0.45 × distance_factor(30–100)`), inconsistent with the corrected regular-PO formula; with a mean received quantity of 1,324 units it inflated the cost.
- **Solution:** Applied the correct Ground Standard rate band (£0.20–£0.60 per unit^0.5) to all top-up rows.
- **Result:** Top-up mean = £21, matching regular Ground Standard POs.

---

## 8. Pass 4 — Independent Correction and Re-Audit

**Source:** S3 (May 2026) · **Files:** `sales_corrected_final.csv` (178,272 rows, 32 columns) · `purchases_corrected_final.csv` (37,707 rows, 23 columns)

**Outcome reported:** 8 / 8 issues corrected · 15 / 15 audit checks passing · 0 new problems introduced · realism score 9.2 (was 6.5)

> ℹ️ This pass reports different row counts and a different date span from the v3.0 files (see §12, items C1–C2, C13). It is logged here as its own pass; confirm which file lineage it was applied to before merging its fixes with R3.

### R4-01 — Warehouse Name / ID Mismatch
**Severity:** 🔴 Critical · **Tables:** both · **Status:** ✅ Fixed

- **Problem:** 46,850 sales rows (26.3%) carried the wrong warehouse name for their ID; all 4 IDs were affected in purchases too.
- **Root cause / fix:** The names were re-derived deterministically from a static lookup built on the most frequent (modal) name and region per ID, for every row in both files.
- **Result:** Each warehouse ID → exactly 1 name and 1 region; 0 mismatches in 178,272 sales rows and 37,707 purchase rows.

### R4-02 — `partial_shipment_flag` Wrong in Purchases
**Severity:** 🔴 Critical · **Tables:** purchases · **Status:** ✅ Fixed

- **Problem:** 14,896 rows (39.5%) had `flag = False` even though `received_quantity < ordered_quantity`.
- **Fix:** Flag re-derived deterministically: `partial_shipment_flag = (received_quantity < ordered_quantity)`.
- **Result:** False = 21,726 · True = 15,981; 0 false negatives, 0 false positives.

### R4-03 — Cancelled-Order Logic
**Severity:** 🟠 High · **Tables:** sales · **Status:** ✅ Fixed

- **Problem:** 8,551 cancelled orders had revenue > 0 with no explanation; 1,035 sat in the impossible state *cancelled + returned + shipped = 0*.
- **Fix:** New column **`cancellation_type`** next to `cancelled_flag`, separating *pre-dispatch* (shipped = 0) from *post-dispatch* (shipped > 0, goods already en route or delivered). No data was discarded. 25 rows with cancelled + returned + shipped = 0 had their return flags cleared.
- **Result:** pre_dispatch 253 · post_dispatch 9,121; 0 impossible states; `cancellation_type` is null on every non-cancelled row.

### R4-04 — `purchase_month` Accuracy
**Severity:** 🟠 High · **Tables:** purchases · **Status:** ✅ Fixed

- **Problem:** 2,560 rows (6.8%) had the wrong month label, clustered at month-end / month-start — a timezone / cut-off bug during generation.
- **Fix:** Re-derived from `purchase_order_date` with `dt.to_period('M').astype(str)`.
- **Result:** 0 mismatches across 37,707 rows.

### R4-05 — Zero-Shipped Unclassified Orders
**Severity:** 🟡 Medium · **Tables:** sales · **Status:** ✅ Fixed

- **Problem:** 4,642 orders (2.6%) had `shipped_quantity = 0` but were neither cancelled nor backordered — no status reason at all.
- **Fix:** Reclassified as `backorder_flag = True` (what an ERP does with unfulfilled, non-cancelled orders).
- **Result:** 0 unclassified zero-shipped orders. *Follow-up check recommended — §12, item C12.*

### R4-06 — `partial_fill_flag` (Sales)
**Severity:** 🟡 Medium · **Tables:** sales · **Status:** ✅ Fixed

- **Problem:** 406 fully-fulfilled orders had `partial_fill_flag = True`.
- **Fix:** Re-derived as `(shipped_quantity < ordered_quantity) AND (shipped_quantity > 0)` — zero-shipped orders are backorders, not partial fills.
- **Result:** 10,629 correctly flagged partial fills; 0 false positives; 0 missed under-ships.

### R4-07 — Discount Granularity
**Severity:** 🟡 Medium · **Tables:** sales · **Status:** ✅ Fixed

- **Problem:** 3,727 distinct discount values from 0.0001 to 0.4071 — clearly continuous-sampled, not a real pricing system.
- **Fix:** Replaced with a segment-aware tier schedule (Wholesale up to 30%; Online and Retail lower, up to 15–20%). Revenue and net unit prices fully recalculated.
- **Result:** 11 distinct values — 0, 3, 5, 8, 10, 12, 15, 18, 20, 25, 30%; 0 revenue / net-price mismatches; full-return revenue = 0.

### R4-08 — Negative-Margin Products
**Severity:** 🟢 Low · **Tables:** sales · **Status:** ✅ Fixed

- **Problem:** PROD-1030 (−2.4% margin) and PROD-1046 (−3.7%) occasionally sold below purchase cost — 891 rows in total.
- **Fix:** Floor price = average purchase cost × 1.10 (≥ 10% gross margin) applied to the affected rows; net unit price and revenue recalculated.
- **Result:** PROD-1030 → +9.4%, PROD-1046 → +10.3%; 0 negative-margin products; overall margin range 1.0%–53.5%, mean 31.8%.

### Pass 4 dataset snapshot

| Sales file | | Purchases file | |
|---|---|---|---|
| Rows / columns | 178,272 / 32 | Rows / columns | 37,707 / 23 |
| Total revenue | £1.50bn | Partial shipments | 15,981 (42.4%) |
| Average order value | £9,196 | Fill rate | 93.8% |
| Return rate | 10.7% | Quality issues | 6.3% |
| On-time rate | 72.6% | Lead times | 3–127 days |
| Cancellation rate | 5.3% | Suppliers | 60 |

---

## 9. Fix Chains and Recurring Root Causes

### 9.1 Fix chains — where one correction created or exposed the next problem

| Chain | Sequence |
|---|---|
| **Price / margin** | R1-01 margin floor ×1.20 → an earlier "Fix 3" median clip → R3-III absurd ranges → R3-VI category collapse at £66–71 → R3-VII cost collapse → rebuild from base prices (floor ×1.25) → R4-08 two products still below cost |
| **Customer affinity** | R1-05 (13.2 → 8.3 categories) → R2-E (→ 5.8) → forced a full re-run of the R2-D top-up POs |
| **Supplier specialisation** | R1-07 (new data only) → R2-G (21,431 rows re-linked) → R3-V (Silverton) |
| **Warehouse routing** | R1-06 → R2-F "clean" → R3-II "too deterministic" → R3-I region rename → R4-01 name/ID mismatch |
| **Transport cost** | R1-01 15% cap → R2-J cap removed → R3-VIII top-up formula inconsistent |
| **Backorders** | R2-B (backorder ⇒ late) → R4-05 (4,642 more rows reclassified as backorder) |

### 9.2 Recurring root causes

1. **Coupled variables generated independently** — price vs cost, purchases vs sales volume, transport vs ship mode, backorder flag vs delivery date.
2. **Label assigned after the value** — ship mode and delivery method were cosmetic labels attached after cost and lead time were already drawn.
3. **Uniform random choice where business logic was needed** — payment terms, category selection, warehouse routing, supplier choice.
4. **Pool exhaustion and fallback hacks** — the customer-name pool and its `#2 … #9` suffixes.
5. **Derived fields stored instead of derived** — `partial_shipment_flag`, `partial_fill_flag`, `purchase_month`, warehouse name/region drifted from their source columns until re-derived deterministically.
6. **Patching already-patched data** — clipping to a corrupted median, re-linking suppliers row by row, re-running top-ups. S1's recommendation: design customer / supplier / product profiles **into the generator from scratch** instead of correcting random assignments afterwards.

---

## 10. Validation Results

### 10.1 Pass 1–3 checks (S2, run on the v3.0 files)

| Check | Target | Result | Status |
|---|---|---|---|
| `net_unit_price ≥ avg_purchase_cost` | 100% | 100.00% | ✅ |
| Transport ratio Overnight ÷ Sea (sales) | > 10× | 20.0× | ✅ |
| Transport ratio Overnight ÷ Sea (purchases) | > 10× | 52.0× | ✅ |
| Backorder rows Early / On Time | 0 | 0 | ✅ |
| Backorder minimum delivery days | > 7 as written* | Min 7, mean 41.3 | ✅ |
| Transport null rate (non-cancelled sales) | < 1% | 0.47% | ✅ |
| Negative stock (product + DC + month) | 0 | 0 / 1,360 | ✅ |
| Avg categories per customer | < 7 | 5.8 | ✅ |
| Customers buying all 14 categories | < 15 | 11 (generic wholesale) | ✅ |
| Northeast customers using WH-01 | > 50% | 68% | ✅ |
| Avg categories per supplier | ≤ 4 | 3.3 | ✅ |
| Max categories per supplier | ≤ 5 | 4 | ✅ |
| Cancelled rows with `return_flag = True` | 0 | 0 | ✅ |
| Cancelled rows with `transport_cost` | 0 | 0 | ✅ |
| `return_quantity > shipped_quantity` | 0 | 0 | ✅ |
| Revenue arithmetic mismatch (> £0.05) | 0 | 0 | ✅ |
| All region names UK-appropriate | Yes | No 'Midwest' | ✅ |
| Payment terms vary by segment | Yes | Confirmed | ✅ |
| Electronics ÷ Grocery price ratio | 5–15× | 6.0× | ✅ |
| 4K Smart TV mean price | £400–800 | £725 | ✅ |
| Organic Brown Rice mean price | £8–20 | £13 | ✅ |
| Ground Standard transport, regular vs top-up PO | consistent | £21 = £21 | ✅ |

\* The source target reads "> 7" while the result is exactly 7 and was marked PASS — read as "≥ 7" (see §12, C8).

### 10.2 Pass 4 re-audit (S3, run on the `*_corrected_final.csv` files)

| # | Check | Result |
|---|---|---|
| 01 | Warehouse name / region consistency (both files) | PASS — 1 name, 1 region per ID |
| 02 | Partial-shipment flag accuracy (purchases) | PASS — 0 false negatives / positives |
| 03 | Date ordering (no delivery before order, no return before sale) | PASS — 0 violations |
| 04 | Revenue arithmetic integrity | PASS — 0 mismatches; full-return revenue = 0 |
| 05 | Cancelled-order logic (`cancellation_type` coverage) | PASS — 0 impossible states |
| 06 | Zero-shipped orders classification | PASS — 0 unexplained |
| 07 | `partial_fill_flag` correctness | PASS — 0 false positives / missed under-ships |
| 08 | `purchase_month` vs `purchase_order_date` | PASS — 0 mismatches / 37,707 rows |
| 09 | Discount tier realism | PASS — 11 discrete, segment-aware values |
| 10 | Product gross margin | PASS — 0 negative-margin products; range 1.0–53.5%, mean 31.8% |
| 11 | Net-quantity integrity (shipped − returned = net; return ≤ shipped ≤ ordered) | PASS — 0 mismatches |
| 12 | Lead-time distributions non-negative and mode-appropriate | PASS — Sea p50 38d · Ground p50 6d · Overnight p50 2d |
| 13 | Product cross-file consistency | PASS — 340 products in both files, 0 orphans, 0 name discrepancies |
| 14 | Duplicate order / purchase IDs | PASS — 0 in either file |
| 15 | New-field consistency (`cancellation_type` scope, flag conflicts) | PASS |

---

## 11. Remaining Limitations and Open Observations

Known simplifications — documented as design decisions, not bugs.

| # | Limitation | Source |
|---|---|---|
| L1 | **Payment terms not correlated with order size** within a segment; large orders often negotiate longer terms in reality | S2 |
| L2 | **Return freight not captured** — `transport_cost` is outbound only; no reverse-logistics cost analysis possible | S2 |
| L3 | **No warehouse-level price variation** — same base price at all four DCs | S2 |
| L4 | **Top-up POs are analytically transparent** — the `PUR-TU-` prefix (7,636 rows) would not exist in a real ERP | S2 |
| L5 | **11 customers buy all 14 categories** — generic wholesale distributors (e.g. "National Bulk Distribution"); intentional | S1, S2 |
| L6 | **No tax** — all values exclude VAT | S2 |
| L7 | **Single currency (GBP)** — no FX modelling | S2 |
| L8 | **No inter-DC stock transfers** — an order routed to a non-home DC implicitly assumes that DC holds the stock | S2 |
| L9 | **Sea Economy on domestic routes** (~79% of sea shipments) — plausible as inbound import leg or coastal route, but should be stated in any data dictionary | S3 |
| L10 | **Dataset covers a future period** (S3: Dec 2025 – Jan 2027) — intentional for synthetic data; matters when reading trends | S3 |
| L11 | **Post-dispatch cancellations (9,121) have no reason code** — a `cancellation_reason` field would enrich the data (enhancement, not a defect) | S3 |
| L12 | **67:1 customer-to-supplier ratio** (4,000 vs 60) — reflects the business model, but limits supplier-concentration analysis | S3 |

**Recommended next step (from S1):** regenerate with coherent entity design baked into the generator (customer / supplier / product profiles) so that the product-swap and supplier-relink passes are no longer needed.

---

## 12. Reconciliation Notes — Where the Source Documents Disagree

The three documents were written at different times and do not always agree. Nothing below was silently "corrected" — both values are preserved. Items marked **verify** are worth a quick query on the actual files.

| # | Topic | What the sources say | Treatment / suggested check |
|---|---|---|---|
| C1 | Sales row count | S1, S2: 175,000 · S3: 178,272 | Different file lineages likely. **Verify** which file is canonical. |
| C2 | Date span | S1, S2: 1 Jan – 31 Dec 2026 · S3: Dec 2025 – Jan 2027 | Same as C1. **Verify** `MIN/MAX(sale_date)`. |
| C3 | Purchase rows / top-ups | S1: 37,665 (7,594 top-ups) · S2, S3: 37,707 (S2: 7,636 top-ups) | Difference of 42 rows; consistent with a top-up re-run. Latest figure used. |
| C4 | Max categories per supplier after R2-G | S1: max 6, one supplier above 5 · S2's G entry: max 4 | S2's "4" matches the state *after* R3-V (Silverton). S1 value used for R2-G; final = 4. |
| C5 | `full_return_flag` count | S2: 5,289 rows · S1: 496 rows flagged "reduced from 5,289" | S1 attributes the drop to product reassignment, yet R2-E states quantities were unchanged. **Verify** `COUNT(*) WHERE full_return_flag`. A possible cause (unconfirmed): the 5,289 may have included zero-shipped, non-cancelled rows that R4-05 later reclassified. |
| C6 | Top-up transport mean before fix | S1: ~£1,853 · S2: £738 | Likely different stages (before / after a top-up re-run). Both fixed to ~£21. |
| C7 | Backorder mean delivery days | S1: 41.4 · S2: 41.3 | Rounding or re-run drift; immaterial. |
| C8 | Backorder min-days target | S2 target "> 7", result 7, marked PASS | Treated as "≥ 7". |
| C9 | Rows swapped for affinity | 44,469 quoted for both the v1 fix (R1-05) and the v2 fix (R2-E) | Identical count for two different passes — **verify** against the change logs. |
| C10 | Purchase quality-issue rate | S1 schema: 2.4% flagged · S3: 6.3% | Different files or definitions. **Verify**. |
| C11 | Cancelled-order semantics | S2: cancelled = *before shipment* (never freight, never returned) · S3: 9,121 *post-dispatch* cancellations with shipped > 0, and 8,551 cancelled rows with revenue > 0 | Definition widened in R4-03. **Verify** that "cancelled rows with transport_cost = 0" still holds under the new definition. |
| C12 | R4-05 vs R2-B | R2-B: every backorder must be Late / Very Late with delivery ≥ mode SLA ceiling · R4-05 added 4,642 backorders (shipped = 0) | **Verify** that those 4,642 rows have consistent `service_level_status` and delivery dates. |
| C13 | Margin floors | R1-01: ×1.20 · R3-VI: ×1.25 · R4-08: ×1.10 — and S3 still found 891 below-cost rows after S2 reported 100% compliance | Suggests S3 audited a different lineage than the v3.0 files. **Verify**. |
| C14 | Column counts | S3: sales 32 / purchases 23 · S1 schema lists 31 / 22, without `partial_fill_flag` or `purchase_month` | Schema in S1 is incomplete relative to later passes. Update the data dictionary. |
| C15 | Discount logic | S1, S2: continuous Beta(1.5, 8), schema "0.0–0.35" · S3: 11 tiers up to 30% | If R4 is adopted, update §14 and the schema. |
| C16 | Issue R1-02 wording | S1 title "~4 day average delivery" · measured averages 9.3–9.8 days (S2) | The ~4 days refers to the generating distribution (exponential, mean 4.5); measured value differed. |
| C17 | Version labels | S1: current = v2.5, v3.0 "planned full regeneration" · S2: v3.0 current, but its content is another correction pass · S3: unlabelled | Unclear whether v3.0 was a full regeneration. Version history in §2 reflects this uncertainty. |
| C18 | Undocumented v2 step | S2 refers to a v2 "Fix 3" (median clip) that does not appear in S1's list of v2 issues A–L | A fix step that exists but was never logged — an example of the gaps discussed in §13. |
| C19 | Severity scales | S1: HIGH / MEDIUM / LOW · S2: 🔴🟠🟡 · S3: Critical / High / Medium / Low | Mapped to one scale (§1). |

---

## 13. Problems Not Presented in This Log

> **This log covers only part of the problems encountered with this dataset.**
>
> Additional problems were found beyond the ones documented above and are **not presented here**. They may belong to earlier or intermediate generation steps, to fixes that were tried and replaced, or to checks that were run but not written up. C18 above is a concrete example of a fix step that was applied but never logged.

Consequences for anyone using this document:

- It is a **representative record, not a complete audit trail**.
- Passing every check in §10 shows the *documented* problems are resolved; it does not prove no other problem exists.
- Before relying on the dataset for a specific analysis, run checks relevant to that analysis rather than assuming the log covers it.

**Template for adding further entries** (suggested ID: `U-01`, `U-02`, …):

```markdown
### U-01 — <short title>
**Severity:** 🔴/🟠/🟡/🟢 · **Tables:** sales | purchases | both · **Status:** Open | Fixed | Clean

- **Discovered by:** <query / observation>
- **Root cause:** <what in the generation logic caused it>
- **Impact:** <what analysis it would break>
- **Solution:** <exact correction applied, with row counts>
- **Result:** <before → after numbers>
```

---

## 14. Dataset Logic Reference

### 14.1 Price and cost construction

```
unit_price         = base_price × segment_mult × seasonal_mult[month] × inflation[month] × noise
noise              ~ LogNormal(0, 0.09)

net_unit_price     = unit_price × (1 − discount)        # discount: continuous in S2; 11 tiers after R4-07
sales_revenue      = net_quantity × net_unit_price

purchase_unit_cost = base_price × 0.58 × supplier_cost_mult × inflation[month] × noise
noise              ~ LogNormal(0, 0.07)
```

### 14.2 Stock flow

```
Stock(month) = Stock(month−1) + received_quantity(month) − shipped_quantity(month)
Stock(month) ≥ 0 always        # enforced by top-up POs (PUR-TU-)
```

### 14.3 Flag logic

| Flag | True when | Mutually exclusive with | Origin |
|---|---|---|---|
| `cancelled_flag` | Order cancelled (before or — after R4-03 — after dispatch) | `return_flag = True` on pre-dispatch cancellations | S2, S3 |
| `cancellation_type` | `pre_dispatch` (shipped = 0) or `post_dispatch` (shipped > 0); null otherwise | — | R4-03 |
| `backorder_flag` | `shipped_quantity < ordered_quantity` due to stock; also zero-shipped, non-cancelled orders after R4-05 | `service_level_status ∈ {Early, On Time}` | S2, R4-05 |
| `partial_fill_flag` | `0 < shipped_quantity < ordered_quantity` | zero-shipped orders | R4-06 |
| `return_flag` | Any units returned post-delivery | `cancelled_flag = True` (pre-dispatch) | S2 |
| `full_return_flag` | `net_quantity = 0` and not cancelled and `return_flag = True` | — | R2-I |
| `partial_shipment_flag` (purchases) | `received_quantity < ordered_quantity` | — | R4-02 |
| `quality_flag = Issue` | Inbound quality inspection failed | — | S1, S2 |

### 14.4 Transport cost

| Table | Formula |
|---|---|
| Sales (outbound) | `rate × sqrt(ordered_quantity)` — `rate` is ship-mode-specific |
| Purchases (inbound) | `rate × sqrt(received_quantity) × (1 + distance_km / 1000)`; floor £1, ceiling £50,000 |

**NULL when:** sales — cancelled orders (always) + 0.47% of fulfilled orders (DDP arrangements); purchases — ~0.7% of rows (freight consolidated or included in product price).

### 14.5 Columns added or re-derived across passes

| Column | Table | Change | Pass |
|---|---|---|---|
| `delivery_days` | sales | Added | R2 |
| `full_return_flag` | sales | Added | R2-I |
| `cancellation_type` | sales | Added | R4-03 |
| `partial_fill_flag` | sales | Re-derived | R4-06 |
| `purchase_month` | purchases | Re-derived | R4-04 |
| `warehouse_name`, `warehouse_region` | both | Re-derived from ID (and `Midwest` → `Midlands`) | R3-I, R4-01 |
| `partial_shipment_flag` | purchases | Re-derived | R4-02 |
| `discount`, `net_unit_price`, `sales_revenue` | sales | Re-tiered / recalculated | R4-07 |

### 14.6 Joining the two tables

```sql
-- Inventory balance
SELECT s.product_id, s.warehouse_id, DATE_TRUNC('month', s.sale_date) AS month,
       SUM(p.received_quantity) AS received,
       SUM(s.shipped_quantity)  AS shipped
FROM sales s
LEFT JOIN purchases p
  ON p.product_id   = s.product_id
 AND p.warehouse_id = s.warehouse_id
 AND p.supplier_delivery_date_to_warehouse <= s.sale_date
GROUP BY 1, 2, 3
```

> ⚠️ **Never join on `purchase_id`** — it does not exist in `sales.csv`.
>
> **Always include both `product_id` AND `warehouse_id`** in the join condition.

---

*Consolidated log — merges S1 (documentation v2.0), S2 (quality log v3.0) and S3 (correction & re-audit report, May 2026). Britannia Trade & Distribution Ltd — FY2026 supply chain dataset. This document is a partial record; see §13.*
