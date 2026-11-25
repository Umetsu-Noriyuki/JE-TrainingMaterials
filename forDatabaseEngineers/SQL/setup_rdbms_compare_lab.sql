-- ============================================================================
-- 研修名: 3大RDBMS徹底比較編（Oracle / PostgreSQL / MySQL）
-- ファイル名: setup_rdbms_compare_lab.sql
-- 目的: 第3章〜第6章のハンズオン検証用テーブル構築・テストデータ投入・比較クエリ集
-- 対象RDBMS: Oracle Database / PostgreSQL / MySQL (InnoDB)
-- ============================================================================

-- ============================================================================
-- SECTION 1: 共通ベーステーブル構築 & テストデータ投入 (ANSI SQL準拠ベース)
-- ※ 各RDBMSの検証環境へ接続後、まず本セクションを実行してください。
-- ============================================================================

-- 既存テーブルのクリーンアップ（必要に応じてコメント解除）
-- DROP TABLE order_items;
-- DROP TABLE orders;
-- DROP TABLE customers;
-- DROP TABLE dialect_test;

-- 1. 顧客マスタ (customers)
CREATE TABLE customers (
    customer_id   INT          NOT NULL,
    customer_code VARCHAR(20)  NOT NULL,
    customer_name VARCHAR(100) NOT NULL,
    email         VARCHAR(255),
    prefecture    VARCHAR(20),
    status        VARCHAR(10)  DEFAULT 'ACTIVE' NOT NULL,
    created_at    TIMESTAMP    NOT NULL,
    CONSTRAINT pk_customers PRIMARY KEY (customer_id),
    CONSTRAINT uq_customers_code UNIQUE (customer_code)
);

-- 2. 注文ヘッダ (orders)
CREATE TABLE orders (
    order_id      INT            NOT NULL,
    customer_id   INT            NOT NULL,
    order_date    DATE           NOT NULL,
    total_amount  DECIMAL(12, 2) NOT NULL,
    order_status  VARCHAR(20)    NOT NULL,
    note          VARCHAR(200),
    CONSTRAINT pk_orders PRIMARY KEY (order_id),
    CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id) REFERENCES customers (customer_id)
);

-- 3. 注文明細 (order_items)
CREATE TABLE order_items (
    order_item_id INT            NOT NULL,
    order_id      INT            NOT NULL,
    product_code  VARCHAR(30)    NOT NULL,
    quantity      INT            NOT NULL,
    unit_price    DECIMAL(10, 2) NOT NULL,
    CONSTRAINT pk_order_items PRIMARY KEY (order_item_id),
    CONSTRAINT fk_items_order FOREIGN KEY (order_id) REFERENCES orders (order_id)
);

-- サンプルデータ投入: customers
INSERT INTO customers (customer_id, customer_code, customer_name, email, prefecture, status, created_at)
VALUES (1, 'CUST-001', '株式会社アルファ', 'info@alpha.example.com', '東京都', 'ACTIVE', TIMESTAMP '2026-01-10 09:00:00');

INSERT INTO customers (customer_id, customer_code, customer_name, email, prefecture, status, created_at)
VALUES (2, 'CUST-002', 'ベータ商事株式会社', NULL, '大阪府', 'ACTIVE', TIMESTAMP '2026-02-15 14:30:00');

INSERT INTO customers (customer_id, customer_code, customer_name, email, prefecture, status, created_at)
VALUES (3, 'CUST-003', '有限会社ガンマテック', 'support@gamma.example.com', '福岡県', 'INACTIVE', TIMESTAMP '2026-03-20 11:15:00');

INSERT INTO customers (customer_id, customer_code, customer_name, email, prefecture, status, created_at)
VALUES (4, 'CUST-004', 'デルタ物産', 'sales@delta.example.com', '愛知県', 'ACTIVE', TIMESTAMP '2026-04-05 16:45:00');

-- サンプルデータ投入: orders
INSERT INTO orders (order_id, customer_id, order_date, total_amount, order_status, note)
VALUES (1001, 1, DATE '2026-05-01', 150000.00, 'COMPLETED', '初回大口発注');

INSERT INTO orders (order_id, customer_id, order_date, total_amount, order_status, note)
VALUES (1002, 1, DATE '2026-05-10', 45000.00, 'COMPLETED', NULL);

INSERT INTO orders (order_id, customer_id, order_date, total_amount, order_status, note)
VALUES (1003, 2, DATE '2026-05-12', 82000.00, 'SHIPPED', '午前中指定');

INSERT INTO orders (order_id, customer_id, order_date, total_amount, order_status, note)
VALUES (1004, 4, DATE '2026-05-15', 12000.00, 'PENDING', NULL);

-- サンプルデータ投入: order_items
INSERT INTO order_items (order_item_id, order_id, product_code, quantity, unit_price)
VALUES (1, 1001, 'PRD-SRV-01', 1, 150000.00);

INSERT INTO order_items (order_item_id, order_id, product_code, quantity, unit_price)
VALUES (2, 1002, 'PRD-SW-05', 3, 15000.00);

INSERT INTO order_items (order_item_id, order_id, product_code, quantity, unit_price)
VALUES (3, 1003, 'PRD-STG-02', 2, 41000.00);

INSERT INTO order_items (order_item_id, order_id, product_code, quantity, unit_price)
VALUES (4, 1004, 'PRD-CBL-10', 10, 1200.00);

COMMIT;


-- ============================================================================
-- SECTION 2: 第3章 物理データ構造・インデックス確認用クエリ
-- ============================================================================
-- 検索用セカンダリインデックスの作成
CREATE INDEX idx_orders_customer_date ON orders (customer_id, order_date);

/*
[検証ポイント]
- MySQL (InnoDB): 主キー(order_id)自体がクラスタインデックスとなり、リーフノードに行データ全体が格納される。
  そのため、idx_orders_customer_date のリーフには主キー値(order_id)が保持される。
- Oracle / PostgreSQL: ヒープ構成表のため、主キーもセカンダリインデックスも
  物理行位置（Oracle: ROWID / PostgreSQL: CTID）を指し示す。

以下のクエリで物理行識別子の違いを確認できます:
-- [Oracle]
SELECT ROWID, order_id, customer_id FROM orders;

-- [PostgreSQL]
SELECT ctid, order_id, customer_id FROM orders;
*/


-- ============================================================================
-- SECTION 3: 第4章 トランザクション分離レベルとMVCC（同時実行制御）検証
-- ============================================================================
/*
[ハンズオン手順: 2つのセッション（Session A / Session B）を開いて実行]

1. 現在の分離レベル確認:
   - Oracle: デフォルトは READ COMMITTED
   - PostgreSQL: SHOW transaction_isolation; -> read committed
   - MySQL: SELECT @@transaction_isolation; -> REPEATABLE-READ

2. ファジーリード（Non-Repeatable Read）の挙動比較:
   [Session A] BEGIN; (Oracleは暗黙開始)
   [Session A] SELECT total_amount FROM orders WHERE order_id = 1004; -- 12000.00
   [Session B] UPDATE orders SET total_amount = 99999.00 WHERE order_id = 1004;
   [Session B] COMMIT;
   [Session A] SELECT total_amount FROM orders WHERE order_id = 1004;
               -> Oracle / PostgreSQL: 99999.00 が見える（ステートメント単位のスナップショット）
               -> MySQL (InnoDB): 12000.00 のまま（トランザクション開始時点のスナップショット）
   [Session A] COMMIT;

3. PostgreSQL 追記型アーキテクチャとデッドタプル（ctid変化）の観察:
   -- [PostgreSQLのみ]
   SELECT ctid, xmin, xmax, order_id, total_amount FROM orders WHERE order_id = 1004;
   UPDATE orders SET total_amount = 15000.00 WHERE order_id = 1004;
   SELECT ctid, xmin, xmax, order_id, total_amount FROM orders WHERE order_id = 1004;
   -- 更新前と更新後で ctid（ブロック番号, 行番号）が変化することを確認！
*/


-- ============================================================================
-- SECTION 4: 第5章 SQL方言・データ型・NULLの落とし穴 検証用スクリプト
-- ============================================================================

-- 4-1. 空文字 ('') と NULL の扱い
CREATE TABLE dialect_test (
    id       INT PRIMARY KEY,
    str_val  VARCHAR(20)
);

INSERT INTO dialect_test (id, str_val) VALUES (1, '');
INSERT INTO dialect_test (id, str_val) VALUES (2, NULL);
COMMIT;

-- 空文字検索とNULL検索の比較:
SELECT id, str_val FROM dialect_test WHERE str_val IS NULL;
-- [結果の違い]
-- Oracle: id=1 と id=2 の「2件」が返る（空文字 '' を NULL と同一視するため）
-- PostgreSQL / MySQL: id=2 の「1件」のみ返る（空文字とNULLを厳密に区別する）

-- 4-2. ページネーション（上位N件取得）の方言比較
/*
-- [ANSI SQL / Oracle 12c+ / PostgreSQL]
SELECT order_id, total_amount FROM orders ORDER BY order_id FETCH FIRST 2 ROWS ONLY;

-- [PostgreSQL / MySQL]
SELECT order_id, total_amount FROM orders ORDER BY order_id LIMIT 2 OFFSET 0;
*/

-- 4-3. 自動採番（Auto-Increment / Identity / Sequence）の定義比較
/*
-- [Oracle 12c+ / PostgreSQL 10+ (標準SQL準拠)]
CREATE TABLE sample_seq_std (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(50)
);

-- [MySQL]
CREATE TABLE sample_seq_mysql (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50)
);
*/


-- ============================================================================
-- SECTION 5: 第6章 実行計画取得・統計情報更新コマンド比較リファレンス
-- ============================================================================
/*
-- 1. 実行計画の取得
-- [Oracle]
EXPLAIN PLAN FOR SELECT * FROM orders WHERE customer_id = 1;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- [PostgreSQL] (実測値付き実行計画)
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM orders WHERE customer_id = 1;

-- [MySQL 8.0+] (ツリー形式および実測値付き実行計画)
EXPLAIN FORMAT=TREE SELECT * FROM orders WHERE customer_id = 1;
EXPLAIN ANALYZE SELECT * FROM orders WHERE customer_id = 1;

-- 2. 統計情報の手動更新
-- [Oracle]
EXEC DBMS_STATS.GATHER_TABLE_STATS(OWNNAME => USER, TABNAME => 'ORDERS');

-- [PostgreSQL] (統計情報更新 + 不要領域の回収)
VACUUM ANALYZE orders;

-- [MySQL]
ANALYZE TABLE orders;
*/
