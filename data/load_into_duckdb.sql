-- ============================================================
-- 把模拟数据加载进 DuckDB
-- 用法：在仓库根目录下启动 DuckDB / DBeaver（路径是相对仓库根目录的），
--       打开这个文件，Alt + X 整体执行
-- ============================================================

-- 第 1 层 ------------------------------------------------------
CREATE OR REPLACE TABLE sales_simple AS
SELECT * FROM read_csv_auto('data/01_sales_simple.csv');

-- 第 2 层 ------------------------------------------------------
CREATE OR REPLACE TABLE dim_customer AS
SELECT * FROM read_csv_auto('data/02_dim_customer.csv');

CREATE OR REPLACE TABLE dim_product AS
SELECT * FROM read_csv_auto('data/02_dim_product.csv');

CREATE OR REPLACE TABLE dim_port AS
SELECT * FROM read_csv_auto('data/02_dim_port.csv');

CREATE OR REPLACE TABLE fact_sales AS
SELECT * FROM read_csv_auto('data/02_fact_sales.csv');

-- 第 3 层 ------------------------------------------------------
CREATE OR REPLACE TABLE fact_index_price AS
SELECT * FROM read_csv_auto('data/03_fact_index_price.csv');

CREATE OR REPLACE TABLE fact_port_inventory AS
SELECT * FROM read_csv_auto('data/03_fact_port_inventory.csv');


-- ============================================================
-- 验证：每张表的行数
-- 加载完先跑这一段，数字对上了再开始做题
-- ============================================================
SELECT 'sales_simple'        AS table_name, COUNT(*) AS rows FROM sales_simple
UNION ALL SELECT 'dim_customer',        COUNT(*) FROM dim_customer
UNION ALL SELECT 'dim_product',         COUNT(*) FROM dim_product
UNION ALL SELECT 'dim_port',            COUNT(*) FROM dim_port
UNION ALL SELECT 'fact_sales',          COUNT(*) FROM fact_sales
UNION ALL SELECT 'fact_index_price',    COUNT(*) FROM fact_index_price
UNION ALL SELECT 'fact_port_inventory', COUNT(*) FROM fact_port_inventory
ORDER BY table_name;

-- 期望结果：
--   dim_customer          13
--   dim_port               8
--   dim_product            7
--   fact_index_price     434
--   fact_port_inventory 4872
--   fact_sales          1843
--   sales_simple         320


-- ============================================================
-- 看一眼每张表长什么样（DESCRIBE 会列出列名和数据类型）
-- 养成习惯：拿到新表，先 DESCRIBE，再 SELECT *
-- ============================================================
-- DESCRIBE sales_simple;
-- DESCRIBE fact_sales;
-- SELECT * FROM sales_simple LIMIT 10;
