WITH acct_snapshot AS (
    SELECT
        a.customer_id,
        a.account_no,
        a.product_type,
        a.balance,
        a.status,
        a.snapshot_date
    FROM dwd_account_balance_snapshot a
    WHERE a.snapshot_date = '${biz_date}'
      AND a.status = 'ACTIVE'
),
corp_accounts AS (
    SELECT
        s.customer_id,
        s.account_no,
        s.product_type,
        s.balance
    FROM acct_snapshot s
    INNER JOIN dim_customer c
        ON s.customer_id = c.customer_id
    WHERE c.customer_type = 'CORP'
      AND c.is_internal = 0
),
agg AS (
    SELECT
        product_type,
        SUM(balance) AS ending_balance,
        COUNT(DISTINCT account_no) AS active_account_cnt
    FROM corp_accounts
    GROUP BY product_type
)
SELECT
    '${biz_date}' AS report_date,
    product_type,
    ending_balance,
    active_account_cnt
FROM agg;
