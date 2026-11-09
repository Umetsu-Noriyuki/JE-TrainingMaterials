-- ==============================================================================
-- データベース設計とER図 基礎研修 サンプルスキーマ構築スクリプト
-- 対象RDBMS: Oracle Database (23ai 等)
-- ==============================================================================

-- 1. 既存テーブルのクリーンアップ（再実行できるようにCASCADE CONSTRAINTSを使用）
DROP TABLE order_details CASCADE CONSTRAINTS PURGE;
DROP TABLE orders CASCADE CONSTRAINTS PURGE;
DROP TABLE products CASCADE CONSTRAINTS PURGE;
DROP TABLE customers CASCADE CONSTRAINTS PURGE;

-- ==============================================================================
-- 2. テーブル作成 (エンティティの実装)
-- ==============================================================================

-- [顧客] テーブル
-- 注文と「1対多」のリレーションを持つ親テーブル
CREATE TABLE customers (
    customer_id   NUMBER(10,0) GENERATED ALWAYS AS IDENTITY,
    customer_name VARCHAR2(100) NOT NULL,
    email         VARCHAR2(255) NOT NULL,
    created_at    DATE DEFAULT SYSDATE NOT NULL,
    CONSTRAINT pk_customers PRIMARY KEY (customer_id),
    CONSTRAINT uq_customers_email UNIQUE (email) -- 第6章: カーディナリティとUNIQUEの一致
);
COMMENT ON TABLE customers IS '顧客情報を管理するテーブル';

-- [商品] テーブル
-- 注文明細と「1対多」のリレーションを持つ親テーブル
CREATE TABLE products (
    product_id    NUMBER(10,0) GENERATED ALWAYS AS IDENTITY,
    product_name  VARCHAR2(100) NOT NULL,
    price         NUMBER(10,0) NOT NULL,
    CONSTRAINT pk_products PRIMARY KEY (product_id)
);
COMMENT ON TABLE products IS '商品マスタ';

-- [注文] テーブル
-- 顧客(1)に対して多(N)となるテーブル
CREATE TABLE orders (
    order_id      NUMBER(10,0) GENERATED ALWAYS AS IDENTITY,
    customer_id   NUMBER(10,0) NOT NULL, -- 結合キーのデータ型を親と完全に一致させる(第6章)
    order_date    DATE DEFAULT SYSDATE NOT NULL,
    total_amount  NUMBER(10,0),
    CONSTRAINT pk_orders PRIMARY KEY (order_id),
    CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id) 
        REFERENCES customers (customer_id)
);
COMMENT ON TABLE orders IS '注文ヘッダ情報';

-- [注文明細] テーブル (交差テーブル)
-- 注文と商品の「多対多」を解消するために導入した中間テーブル (第3章)
CREATE TABLE order_details (
    order_id      NUMBER(10,0) NOT NULL,
    product_id    NUMBER(10,0) NOT NULL,
    quantity      NUMBER(4,0) NOT NULL,
    unit_price    NUMBER(10,0) NOT NULL,
    -- 第3章: 複合主キーの定義（この組み合わせで1行が一意になる）
    CONSTRAINT pk_order_details PRIMARY KEY (order_id, product_id),
    -- 第6章: 物理的な外部キー制約の付与
    CONSTRAINT fk_details_order FOREIGN KEY (order_id) 
        REFERENCES orders (order_id),
    CONSTRAINT fk_details_product FOREIGN KEY (product_id) 
        REFERENCES products (product_id)
);
COMMENT ON TABLE order_details IS '注文と商品を紐づける明細（交差）テーブル';


-- ==============================================================================
-- 3. パフォーマンスと安全性のためのインデックス作成 (第6章)
-- ==============================================================================
-- 親テーブルの主キー（PK）には自動的にインデックスが作成されますが、
-- 外部キー（FK）には手動でインデックスを作成し、テーブルロックの競合を防ぎます。

-- 注文テーブルの外部キー（customer_id）へのインデックス
CREATE INDEX idx_orders_customer_id ON orders (customer_id);

-- 注文明細テーブルの外部キー（product_id）へのインデックス
-- ※ order_id については複合主キー(order_id, product_id)の先頭列として
-- すでにインデックスが効くため、ここでは product_id 側のみ単独で作成します。
CREATE INDEX idx_order_details_product_id ON order_details (product_id);


-- ==============================================================================
-- 4. 検証用サンプルデータの投入
-- ==============================================================================
INSERT INTO customers (customer_name, email) VALUES ('山田 太郎', 'yamada@example.com');
INSERT INTO customers (customer_name, email) VALUES ('鈴木 花子', 'suzuki@example.com');

INSERT INTO products (product_name, price) VALUES ('ノートPC', 150000);
INSERT INTO products (product_name, price) VALUES ('ワイヤレスマウス', 5000);
INSERT INTO products (product_name, price) VALUES ('メカニカルキーボード', 15000);

-- 顧客1（山田さん）の注文
INSERT INTO orders (customer_id, order_date) VALUES (1, SYSDATE);
-- 顧客2（鈴木さん）の注文
INSERT INTO orders (customer_id, order_date) VALUES (2, SYSDATE);

-- 顧客1の注文明細（ノートPC 1台、マウス 1個）
INSERT INTO order_details (order_id, product_id, quantity, unit_price) VALUES (1, 1, 1, 150000);
INSERT INTO order_details (order_id, product_id, quantity, unit_price) VALUES (1, 2, 1, 5000);

-- 顧客2の注文明細（メカニカルキーボード 2個）
INSERT INTO order_details (order_id, product_id, quantity, unit_price) VALUES (2, 3, 2, 15000);

COMMIT;

-- 結合確認用クエリ（このクエリの「実行計画」を次フェーズで確認する想定）
-- SELECT 
--     c.customer_name, o.order_date, p.product_name, od.quantity
-- FROM 
--     customers c
-- JOIN orders o ON c.customer_id = o.customer_id
-- JOIN order_details od ON o.order_id = od.order_id
-- JOIN products p ON od.product_id = p.product_id;