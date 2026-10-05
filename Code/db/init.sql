-- 01-init.sql — schema base para el proyecto Retail Sales & Profitability
-- La carga real de datos la hace el notebook via pandas to_sql(if_exists='replace').
-- Este archivo garantiza que la DB arranca con la tabla y tipos correctos
-- aunque el notebook todavía no haya corrido.

CREATE TABLE IF NOT EXISTS sales_data (
    order_id         TEXT,
    order_date       DATE,
    ship_date        DATE,
    ship_mode        TEXT,
    customer_id      TEXT,
    customer_name    TEXT,
    segment          TEXT,
    country          TEXT,
    city             TEXT,
    state            TEXT,
    postal_code      VARCHAR(10),
    region           TEXT,
    product_id       TEXT,
    category         TEXT,
    sub_category     TEXT,
    product_name     TEXT,
    sales            DOUBLE PRECISION,
    quantity         INTEGER,
    discount         DOUBLE PRECISION,
    profit           DOUBLE PRECISION,
    returned         TEXT,
    order_year       INTEGER,
    order_month_year TEXT
);

-- Índices para las queries del proyecto (02 a 07)
CREATE INDEX IF NOT EXISTS idx_sales_category ON sales_data (category, sub_category);
CREATE INDEX IF NOT EXISTS idx_sales_region ON sales_data (region, state);
CREATE INDEX IF NOT EXISTS idx_sales_discount ON sales_data (discount);
CREATE INDEX IF NOT EXISTS idx_sales_order ON sales_data (order_id);
