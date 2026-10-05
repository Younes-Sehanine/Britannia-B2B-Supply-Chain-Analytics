# Britannia Trade & Distribution — Insight Analysis
### Final Draft — 25 Stakeholder Questions

All figures reflect calendar year 2026 (the dashboard's locked date scope). Visual sources are cited in parentheses after each claim. Category margin figures use the corrected `[Total COGS]` measure, validated against the company-wide Total Purchase Cost and reconciled to the cent against Total Revenue.

---

## Commercial Director / Sales

### Q1. Is revenue growth broad-based, or is one segment carrying the trend?

| Segment | Jan | Dec | Growth |
|---|---|---|---|
| Wholesale | $90.9M | $126M | +38.6% |
| Business | $20M | $27.2M | +36.0% |
| Retail | $2.4M | $3.0M | +25.0% |
| Online | $847k | $1,680k | +98.3% |

*(Revenue by Month & Segment, Segment Revenue Trend)*

Growth is broad-based and moderate across Wholesale, Business, and Retail (25–39%), with Online as a percentage outlier that is not yet material to total revenue given its small base. December is a seasonal peak for several segments, so the Jan-to-Dec comparison somewhat overstates the year's underlying trend rather than reflecting steady growth throughout.

### Q2. Are we too dependent on a small number of accounts?

The top 20 of ~3,999 customers (0.5% of the customer base) account for ~13% of total revenue *(Revenue Concentration — Top 20 Customers)*. Not a dependency risk.

### Q3. Is our discounting strategy paying for itself?

Best-performing discount band per segment, by total revenue *(Discount Analysis, filtered by Customer Segment)*:

| Segment | Best Band | Revenue | Rev/Order | Orders |
|---|---|---|---|---|
| Wholesale | 5–10% | $361.0M | $29,525 | 12,228 |
| Business | 5–10% | $73.9M | $5,809 | 12,724 |
| Online | 5–10% | $5.3M | $392 | 13,436 |
| Retail | 0–5% | $12.2M | $562 | 21,782 |

For Online and Business specifically, 0–5% actually edges out 5–10% on *revenue-per-order* ($407 vs $392 for Online; $5,818 vs $5,809 for Business — effectively tied), but 5–10% wins on total revenue, which is the criterion used here. The 20–30% bands return less revenue per order across every segment that reaches them (Online and Retail have no orders above 15–20%, suggesting those discount tiers aren't used for those segments at all).

At the category level, average discount rates cluster narrowly between 7.0% (Toys) and 9.2% (Industrial) *(Revenue & Discount by Category)* — too narrow a spread to explain category-level revenue differences on its own. But cross-referencing discount against the now-corrected **margin rate** by category *(Category Revenue vs Margin Proxy)* surfaces a real problem:

**Grocery is discounted (8.1%) while running a −2.5% margin — every discounted unit sold currently loses money, and the discount is actively deepening that loss.** This is a materially different and more urgent finding than the original "moderate discount without proportional revenue" framing — it isn't a revenue-optimization question for Grocery, it's a margin-bleed question. Books (7.8% discount, 1.4% margin) sits in a similar near-break-even position where continued discounting leaves almost no room for error.

**Verdict:** discount rate alone doesn't explain category performance, but discount policy needs to be reassessed against margin, not revenue — Grocery and Books are the two categories where current discounting is actively working against profitability, not just underperforming on revenue.

### Q4. Which regions are underperforming relative to warehouse coverage?

Each of the 4 DCs maps to exactly one customer region *(dim_warehouses: Dagenham East→Northeast, Coventry Central→Midlands, Bristol Portbury→West, Lutterworth National→Southeast)*. Southwest has no dedicated warehouse.

Confirmed unfiltered revenue by customer region *(Revenue by Customer Region)*:

| Region | Revenue |
|---|---|
| Midlands | $208.36M |
| International | $255.83M |
| West | $253.58M |
| Northeast | $258.55M |
| Southeast | $220.94M |
| **Southwest** | **$286.57M** |
| **Total** | **$1,483.84M** |

Southwest — the one region with zero dedicated warehouse coverage — is the **highest-revenue region overall**, ahead of every region that has its own DC. It also has more active customers than Midlands (717 vs 658) and higher average revenue per customer ($399.7k vs $316.7k).

Cross-referencing DC throughput *(Warehouse Throughput Summary)*: Coventry Central (based in Midlands) ships $952M network-wide, while Midlands customers themselves only account for $208.36M in purchases. **DC location does not predict regional revenue in this network.** Midlands is the true underperforming region, and its shortfall is not a distribution/proximity problem since it already hosts a DC — the specific cause sits outside this dataset.

---

## Procurement Director

### Q5. Is the partial shipment rate a few bad suppliers or systemic?

8 of 60 suppliers sit above 90% partial shipment rate, 5 more between 80–90%, and 18/60 above 60% overall *(Partial Shipment Rate by Supplier)*, against a 42.4% company average. 27 of 60 suppliers sit above the company average — with nearly half the base above average, this reads as systemic rather than a few bad actors, though the 8 suppliers above 90% are the clearest first targets.

Cross-referencing tiers: the 10 worst-ranked suppliers by partial shipment average 6.4% quality rate (Red) and 21-day lead time (Amber); suppliers ranked 11–20 average 6.8% quality but a better 16-day lead time and 76.7% partial shipment. Quality rate stays close to the 6.3% company average across both tiers — partial shipment and quality appear to be largely independent problems.

### Q6. Are we too concentrated in a small number of suppliers?

Supplier 354 alone accounts for 19% of total purchase cost *(Top 10 Suppliers by Spend)*. The top 10 suppliers combined account for **53.1%** of total spend ($658.1M / $1,239.2M) — a real supply-continuity concentration risk, independent of quality.

On quality: supplier 354's 6% quality rate is marginally better than the 6.3% company average *(Payment Terms Exposure: Net30 predominant; Lead Time by Delivery Method: 67.04% Ground Standard)*. But every one of the top 15 suppliers by issue rate also runs Red on quality *(Supplier Quality Issues)*. **This is a systemic quality issue across the supplier base, not a single-supplier problem** — even the best-performing, highest-spend supplier can't clear the Red threshold.

### Q7. Do our fastest delivery methods justify their cost?

*(Lead Time by Delivery Method, purchases side)*

| Delivery Method | Avg Lead Time | Avg Transport Cost |
|---|---|---|
| Sea Economy | 43 days | $30.72 |
| Rail | 22 days | $72.62 |
| Ground Standard | 15 days | $224.59 |
| Express Overnight | 10 days | $396.05 |
| Air Express | 9 days | $258.72 |

Inbound, Express Overnight is dominated — slower **and** more expensive than Air Express.

**Separate finding, outbound side** *(Lead Time by Ship Mode)*: the same label behaves differently — Express Overnight is the *fastest* outbound option (2 days vs Express Air's 3), at a cost premium ($148.70 vs $130). The finding above applies to inbound decisions only.

### Q8. Is our payment terms exposure a real risk?

Spend by term *(Payment Terms Exposure)*: Net30 $0.80bn (64.5%), Net60 $0.21bn, Net15 $0.09bn, Net90 $0.08bn, Immediate $0.06bn — sums to $1.24bn, matching Total Purchase Cost.

Extended supplier payment terms generally favor Britannia's cash position, so there may be room to negotiate more Net30 spend onto Net60 — but this can't be recommended outright, since suppliers sometimes price in a premium for extended terms, which this dataset can't detect. **Recommend Procurement evaluate this with a small set of high-spend Net30 suppliers first.**

---

## Operations / DC Managers

### Q9. Is the late-delivery problem one warehouse, one carrier, or broader?

Service level is similar across all 4 DCs, 72–74% on-time *(Service Level by DC)*. In the final two months of the year, the network average dropped sharply from ~74% to 63% *(On-Time Rate Trend by DC)* — a time-based pattern, not a single-site issue.

By ship mode *(Transport Cost by Ship Mode × DC, cross-filtered against the On-Time Rate KPI card)*:

| Ship Mode | Avg Lead Time (Sales) | Avg Transport Cost |
|---|---|---|
| Sea Economy | 39 days | $41.70 |
| Rail Freight | 14 days | $31.70 |
| Standard Ground | 8 days | $54.00 |
| Express Air | 3 days | $130.00 |
| Express Overnight | 2 days | $148.70 |

Sea Economy shows the lowest on-time performance, consistent with its longer transit window. **Ship mode, not warehouse, is the primary lever** — the DC breakdown shows a broad, network-wide pattern rather than one underperforming site.

### Q10. Are backorders concentrated in specific categories?

Backorder rate is flat across categories (8.5%–9.6%, no clear outlier) *(Backorder Analysis)*. Automotive is highest overall (9.6%) but dips to 7.7% in Q2 — the lowest rate of any category/quarter combination. Prod-1227 (Automotive) is the single highest-backorder SKU at 12.9% *(Product Quality Risk)*.

### Q11. Are cancellations and returns explainable, or random?

**Clothing returns:** 21% return rate, more than double the next-highest category *(Return Rate by Category)*, and Clothing tops Supplier Quality Rate at 7.7% *(Product Quality Risk)* — correlational, not confirmed causation (no `return_reason` field exists). Clothing ranks 3rd-lowest in backorder rate (8.7%) and 4th-lowest in discount (7.4%), ruling out both as contributing factors. Notably, Clothing is also the **highest-margin category in the catalog (39.8%)** — this is a category performing very well commercially despite a serious, unresolved quality-return problem.

**Toys cancellations:** tops cancellation rate at 9.8% *(Cancellation Rate by Category)*, ranks 2nd in backorder rate. Revenue is flat most of the year (~$399K/month) before rising sharply to $555K → $850K → $1,695K in the final quarter *(Monthly Revenue by Category)*. Toys shows no shipped orders from Coventry Central, the network's highest-volume DC *(Service Level by Warehouse, filtered to Toys)*.

**Verdict:** both trace to identifiable, data-supported patterns rather than appearing random — a likely supply-quality signal for Clothing, a likely fulfillment-capacity strain for Toys — though neither is fully confirmed at the causal-mechanism level.

---

## Logistics Head

### Q12. Are all four DCs pulling their weight?

*(Warehouse Throughput Summary)*

| DC | Revenue | Share |
|---|---|---|
| Coventry Central | $952M | 64.3% |
| Bristol Portbury | ~$263.7M | ~17.8% |
| Lutterworth National | $154.9M | 10.4% |
| Dagenham East | $113M | 7.6% |

Coventry Central dominates network throughput. Dagenham East and Lutterworth National generate disproportionately low revenue relative to their outbound volume, which is roughly comparable across sites — the gap is in revenue per unit shipped, likely reflecting order/segment mix differences rather than a simple efficiency gap.

### Q13. Is transport spend proportional to revenue by DC?

| DC | Transport Cost % of Own Revenue | Network Index |
|---|---|---|
| Dagenham East | 1.64% | +5.4 pts over |
| Bristol Portbury | — | +3.4 pts over |
| Lutterworth National | — | +1.5 pts over |
| Coventry Central | 0.81% | −10.3 pts under |

*(Transport Cost % of Revenue by DC)*

Coventry Central is markedly more cost-efficient. Dagenham East's absolute freight spend (~$1.9M) is actually lower than Coventry's (~$7.7M) — its ratio is elevated because revenue per unit is low, not because freight spend is heavy.

### Q14. Do any DCs sit on more inventory than they move?

*(Inbound vs Outbound by Warehouse)*

| DC | Surplus (units) | Surplus as % of Outbound |
|---|---|---|
| Dagenham East | 1.3M | ~31% |
| Bristol Portbury | 1.1M | — |
| Lutterworth National | 0.7M | — |
| Coventry Central | 0.1M | — |

Dagenham East and Bristol Portbury show the most significant imbalance; Coventry Central shows the most balanced material flow.

---

## Category Manager / Buying Team

### Q15. Which product categories are actually profitable?

Using the corrected COGS measure — the full 14-category breakdown reconciles to the cent against validated company totals ($1,483.84M revenue; category-level COGS sums to $1.084bn, below the $1.24bn company-wide Total Purchase Cost as expected, since COGS reflects only units actually sold while Total Purchase Cost includes unsold inventory) *(Category Revenue vs Margin Proxy)*.

The categories that define the range:

| Category | Revenue | Margin % | |
|---|---|---|---|
| Clothing | $50.1M | **39.8%** | highest margin rate |
| Industrial | $539.5M | 31.1% | largest $ contributor ($167.6M) |
| — | — | **27.0%** | company average |
| Electronics | $238.9M | **12.4%** | 2nd-highest revenue, thin margin |
| Movies | $8.0M | 10.6% | |
| Books | $9.0M | 1.4% | near break-even |
| Grocery | $15.8M | **−2.5%** | margin-negative |

**Industrial remains the largest profit contributor in absolute dollars**, but **Clothing is the highest-margin category by rate** despite a tenth of Industrial's revenue. **Electronics, Movies, Books, and Grocery are the four categories where margin rate lags well behind revenue scale** — Electronics in particular combines strong revenue with one of the thinnest margins in the catalog, and Grocery is outright unprofitable per unit sold. The remaining 7 categories (Health, Tools, Sports, Office, Home, Baby, Automotive, Toys) all sit within a tight 24–33% band around the company average and don't individually change this picture — full figures are in the live dashboard if a specific one needs checking.

### Q16. Which categories have a return-rate problem tracing to supply quality?

Clothing carries a 21% return rate, more than double the next-highest category (Electronics, 9.1%) *(Return Rate by Category)*, and the highest supplier quality issue rate at 7.7% *(Product Quality Risk)*. Worth noting: this is happening in Britannia's best-margin category (39.8%) — the return problem isn't dragging down profitability yet, but it represents real exposure in the business's most valuable-per-unit category.

### Q17. Is our purchasing calendar aligned to category seasonality?

**Electronics:** revenue spikes heavily Nov–Dec. Unit purchase cost dropped from $141.50 (Aug) to a trough of $128.90 (Oct) ahead of the spike, settling at $137.80 (Dec) *(Purchase Cost Trend by Category, Monthly Revenue by Category)* — purchasing timing aligns well with demand. **However, Electronics' margin (12.4%) is still thin despite this good timing** — the margin issue here looks like a cost-*level* problem (unit purchase price relative to sale price), not a cost-*timing* problem.

**Industrial:** demand spiked in October; unit cost climbed *through* the spike itself (Aug $83.84 → Oct $93.83) — reactive, not anticipatory, the opposite pattern from Electronics.

**Verdict:** purchasing alignment varies by category — Electronics shows genuine anticipatory buying, Industrial does not — but Electronics' good timing hasn't translated into a healthy margin, suggesting its underlying unit economics need review independent of when purchases happen.

---

## Account Management

### Q18. Are our highest-value accounts served better than average?

Aggregate finding (Q20): top-20 accounts as a group receive better-than-average service. Individually, Olympus Trade Wholesale stands out (90% on-time, 1.6% return, 30 orders) — the best-served top-20 account, though its low order count means this shouldn't be read as broadly representative. $8.9M of Olympus's $9.3M full-year spend traces to a single October order for 'platform trolly 500kg' (Prod-1178, order ORD-00052478, qty 44,914) *(Top 20 Customers, drillthrough)*.

**Exception:** Ironclad Wholesale Foods (72.1% on-time, 10.5% return) is the worst-performing top-20 account. Drilling into Ironclad's own order mix *(Customer Account Detail drillthrough)*: their Immediate and Net15 orders show markedly worse on-time performance (57.1% and 33.3%) than their Net30/60/90 orders (70–78%) — specific to Ironclad's order mix, not a network-wide pattern. This narrows the cause of their poor overall rate to specifically those payment-term orders.

### Q19. Is any customer segment systematically underserved?

*(Segment Performance Table)*

| Segment | Revenue | Orders | On-Time Rate | Return Rate |
|---|---|---|---|---|
| Wholesale | ~$1.2B | — | 75.8% | 6.6% |
| Business | $235.9M | 42,836 | 74.5% | 6.8% |
| Retail | $29.2M | 54,434 | 72.3% | 7.2% |
| Online | $13.7M | 35,500 | 67.3% | 9.4% |

Online is the most underserved segment on every metric. Retail is next, despite having the highest order count of any segment. Business performs comfortably in the middle, closer to Wholesale's service level than to Retail/Online's.

### Q20. Is account-management attention proportional to revenue?

Top-20 accounts (0.5% of customers, 13% of revenue) receive a 76.2% on-time rate (vs. 72.7% global) and 6.3% return rate (vs. 6.7% global) — **not neglected, served slightly better than average.** Redline Trade Supply (11.0% return) and Ironclad Wholesale Foods (10.5% return, 72.1% on-time) are individual exceptions, not a segment-wide pattern.

Bottom 250 accounts (6.25% of customers) generate a combined $133.7K — 0.009% of total revenue. Bottom 14 accounts show zero net revenue (fully returned) and no repeat purchases within the observed window.

No direct measure of account-management time exists in this dataset — service outcomes are used as the closest available proxy for "attention," not a direct measurement of it.

---

## CFO / Cross-Functional

### Q21. Are rising procurement costs hitting margins, or being absorbed?

Industrial unit cost trend, confirmed *(Purchase Cost Trend by Category)*:

| Month | Avg Unit Cost |
|---|---|
| Aug | $83.84 |
| Sep | $91.30 |
| Oct | $93.83 |
| Nov | $91.41 |
| Dec | $95.30 |

Cost climbed steadily from August and hit its yearly peak in December — pressure did not relax by year-end.

With the COGS fix, Industrial's **annual** margin is confirmed at 31.1% — solidly healthy overall. A month-by-month margin trend (rather than the annual figure used here) would be needed to confirm whether margin dipped and recovered within the year as originally hypothesized; that level of granularity hasn't been pulled yet. What's confirmed is that Industrial ends the year as a well-margined category despite sustained cost pressure — the commercial side appears to be managing this cost trend successfully at the annual level, even if the month-to-month path isn't yet fully mapped.

### Q22. If we had to cut costs by 10%, where's the least painful start?

**Delivery method shift (inbound):** shifting Express Overnight to Air Express saves $137.33/order and 1 day, with 6,046 inbound receipts currently on Express Overnight — **~$830,300** in potential savings at full volume, with no service tradeoff since Air Express is also faster inbound *(Lead Time by Delivery Method)*.

**Inventory rebalancing (separate lever):** Dagenham East (1.3M surplus) and Bristol Portbury (1.1M surplus) carry the most excess inbound inventory *(Inbound vs Outbound by Warehouse)*. Shifting new stock allocation toward Coventry Central frees working capital rather than cutting spend directly — a related but distinct lever from the delivery-method savings.

**Grocery's negative margin (lowest-risk, fastest-acting lever):** Grocery runs a −2.5% margin *(Category Revenue vs Margin Proxy, Q15)* — every unit currently sold loses money. Unlike the two levers above, this isn't a cost reduction, it's the elimination of a guaranteed loss, and arguably the single most actionable item in this review. This dataset can't currently distinguish whether the cause is cost-side (unfavorable supplier pricing specific to Grocery) or pricing-side (units sold too cheaply, possibly compounded by the 8.1% discount already flagged in Q3) — that split needs further drill-down before a specific fix is proposed, but the direction (stop losing money on every Grocery sale) doesn't require further diagnosis to justify action.

### Q23. Are service-level failures costing us in revenue, or are customers tolerating it?

Wholesale (~$1.2B) has the best on-time rate (75.8%) and lowest return rate (6.6%); Online still grew ~98% despite the worst on-time rate in the network. The network-wide on-time dip in Nov–Dec (74% → 63%) didn't produce a corresponding revenue drop in the same window.

No direct evidence that current service failures are suppressing revenue — customers appear to be tolerating current service levels. This is an **unpriced risk, not a currently realized cost**: Wholesale's 75.8% on-time rate is mediocre for the segment carrying the bulk of company revenue, with no guarantee that tolerance persists against a stronger competing offer.

### Q24. Root cause behind operational problems this year

Traces to more than one source:

**Supplier-side quality:** Clothing's 21% return rate correlates with its 7.7% supplier quality issue rate — plausible, not fully confirmed, and notably occurring in the company's highest-margin category.

**Warehouse-side imbalance:** Dagenham East and Bristol Portbury carry the largest inbound-vs-outbound surpluses, consistent with slower-turning inventory at those sites.

**A separate, time-bound event — the May revenue drop:** company-wide revenue fell $12.87M (−18.7%) in May, heavily concentrated in Wholesale × West region ($5.7M, −28.9% for that slice), with $1.31M of that drop tracing specifically to Industrial. Presented separately since it's a discrete one-month event, distinct from the ongoing supplier-quality and warehouse-imbalance issues above.

### Q25. Which single fix would move the most KPIs at once?

Enforcing stricter inbound Supplier SLAs — targeting the 42.4% Partial Shipment Rate and 6.3% Supplier Quality Issue Rate — has the highest potential leverage **if the underlying causal chain holds**: Procurement issues → Fulfillment's backorder/return rates → Executive on-time rate.

This is a working hypothesis, not fully confirmed: inbound fill rate is ≥97.7% at every DC, inbound consistently exceeds outbound everywhere, and backorder rate is nearly flat across categories (8.5–9.6%) despite wide variation in supplier-level partial shipment and quality rates. **Recommended before acting:** test backorder rate against partial shipment/inbound fill rate, broken out by supplier or DC, to confirm the chain holds. If confirmed, expected to move Partial Shipment Rate, Supplier Quality Rate, and Inbound Fill Rate directly, and plausibly cascade to Backorder Rate, Fill Rate, Return Rate, and On-Time Rate — a wider reach than isolated warehouse or discount fixes.

---

## Summary — Data Quality Items

1. **[Total COGS] measure — now fixed and validated.** Original version silently dropped ~78% of cost via a broken cross-fact-table `SUMX`/context-transition pattern. Rebuilt to iterate `dim_products` instead of `fact_sales_orders`, reconciles exactly against Total Revenue and is now the basis for all margin figures in this document.
2. **RAG threshold re-verification** (pre-existing, project record) — the Date Range slicer now permits selection outside the originally-validated CY2026 range, which may affect KPI card color verdicts.
