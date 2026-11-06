-- ========================================================
-- ファイル名: setup_sample_data.sql
-- 概要: 実行計画学習用サンプルテーブル構築・ダミーデータ投入スクリプト
-- 対象DB: Oracle Database
-- ========================================================

SET SERVEROUTPUT ON;
SET TIMING ON;

PROMPT 1. 既存テーブルのクリーンアップ...
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE orders PURGE';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE customers PURGE';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

PROMPT 2. テーブルおよびインデックスの作成...
-- 親テーブル: 顧客テーブル（約1,000件想定）
CREATE TABLE customers (
    customer_id   NUMBER(10)      CONSTRAINT pk_customers PRIMARY KEY,
    customer_code VARCHAR2(10)    NOT NULL, -- 第5章の型変換検証用（文字列型）
    customer_name VARCHAR2(100)   NOT NULL,
    created_at    DATE            DEFAULT SYSDATE
);

-- 子テーブル: 注文テーブル（約100,000件想定）
CREATE TABLE orders (
    order_id      NUMBER(10)      CONSTRAINT pk_orders PRIMARY KEY,
    customer_id   NUMBER(10)      NOT NULL,
    order_date    DATE            NOT NULL, -- 第5章の関数適用検証用（日付型）
    total_amount  NUMBER(10)      NOT NULL,
    status        VARCHAR2(20)    NOT NULL
);

-- インデックス作成
CREATE INDEX idx_customers_code     ON customers(customer_code);
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_order_date  ON orders(order_date);

PROMPT 3. ダミーデータの高速生成・投入...
-- 顧客データ: 1,000件
INSERT /*+ APPEND */ INTO customers (customer_id, customer_code, customer_name, created_at)
SELECT 
    LEVEL,
    LPAD(TO_CHAR(LEVEL), 6, '0'), -- '000001', '000002'...
    'Customer_' || LEVEL,
    DATE '2025-01-01' + MOD(LEVEL, 365)
FROM DUAL 
CONNECT BY LEVEL <= 1000;
COMMIT;

-- 注文データ: 100,000件（顧客1人あたり約100件）
INSERT /*+ APPEND */ INTO orders (order_id, customer_id, order_date, total_amount, status)
SELECT 
    LEVEL,
    TRUNC(DBMS_RANDOM.VALUE(1, 1001)),
    DATE '2026-01-01' + MOD(LEVEL, 300),
    ROUND(DBMS_RANDOM.VALUE(1000, 50000), -2),
    CASE MOD(LEVEL, 10) 
        WHEN 0 THEN 'CANCELLED' 
        ELSE 'COMPLETED' 
    END
FROM DUAL 
CONNECT BY LEVEL <= 100000;
COMMIT;

PROMPT 4. オプティマイザ統計情報の収集（CBOに正確な地図を渡す）...
EXEC DBMS_STATS.GATHER_TABLE_STATS(USER, 'CUSTOMERS', CASCADE => TRUE);
EXEC DBMS_STATS.GATHER_TABLE_STATS(USER, 'ORDERS',    CASCADE => TRUE);

PROMPT セットアップが完了しました。