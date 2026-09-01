# 3. JOINを使いこなす

基礎編では、`JOIN` を使用して2つのテーブルを結合する方法を学習しました。

実際の業務では、2つのテーブルだけではなく、複数のテーブルを結合してデータを取得することがあります。

ここでは、複数のJOINやJOINと他のSQL構文を組み合わせる方法について説明します。

---

## 3.1 複数のテーブルをJOINする

3つ以上のテーブルを結合することができます。

例えば、以下の3つのテーブルがあるとします。

### usersテーブル

| id | name |
| -- | ---- |
| 1  | 山田太郎 |
| 2  | 佐藤花子 |

### ordersテーブル

| id | user_id | product_id |
| -- | ------- | ---------- |
| 1  | 1       | 101        |
| 2  | 2       | 102        |

### productsテーブル

| id  | product_name |  price |
| --- | ------------ | -----: |
| 101 | ノートPC        | 100000 |
| 102 | マウス          |   5000 |

この3つのテーブルを結合する場合は、以下のように記述できます。

```sql
SELECT
    users.name,
    products.product_name,
    products.price
FROM users
INNER JOIN orders
    ON users.id = orders.user_id
INNER JOIN products
    ON orders.product_id = products.id;
```

このように、`JOIN` を複数回記述することで、複数のテーブルを結合できます。

---

## 3.2 JOINとWHEREを組み合わせる

`JOIN` した後のデータに対して、`WHERE` で条件を指定できます。

例えば、価格が10,000円以上の商品を購入したユーザーを取得する場合は以下のように記述します。

```sql
SELECT
    users.name,
    products.product_name,
    products.price
FROM users
INNER JOIN orders
    ON users.id = orders.user_id
INNER JOIN products
    ON orders.product_id = products.id
WHERE products.price >= 10000;
```

---

## 3.3 JOINとGROUP BYを組み合わせる

JOINしたデータを集計することもできます。

例えば、ユーザーごとの注文金額の合計を取得する場合は以下のように記述できます。

```sql
SELECT
    users.name,
    SUM(products.price) AS total_price
FROM users
INNER JOIN orders
    ON users.id = orders.user_id
INNER JOIN products
    ON orders.product_id = products.id
GROUP BY users.id, users.name;
```

結果は以下のようになります。

| name | total_price |
| ---- | ----------: |
| 山田太郎 |      100000 |
| 佐藤花子 |        5000 |

---

## 3.4 JOINとHAVINGを組み合わせる

集計した結果に条件を指定する場合は、`HAVING` を使用します。

例えば、注文金額の合計が50,000円以上のユーザーだけを取得する場合は以下のように記述できます。

```sql
SELECT
    users.name,
    SUM(products.price) AS total_price
FROM users
INNER JOIN orders
    ON users.id = orders.user_id
INNER JOIN products
    ON orders.product_id = products.id
GROUP BY users.id, users.name
HAVING SUM(products.price) >= 50000;
```

---

## 3.5 JOINとORDER BYを組み合わせる

JOINしたデータを並べ替えることもできます。

例えば、注文金額の合計が多いユーザーから順番に表示する場合は以下のように記述できます。

```sql
SELECT
    users.name,
    SUM(products.price) AS total_price
FROM users
INNER JOIN orders
    ON users.id = orders.user_id
INNER JOIN products
    ON orders.product_id = products.id
GROUP BY users.id, users.name
ORDER BY total_price DESC;
```

---

## 3.6 JOIN条件に注意する

JOINでは、`ON` に指定する条件が重要です。

```sql
INNER JOIN orders
    ON users.id = orders.user_id
```

この例では、`users.id` と `orders.user_id` を関連付けています。

結合するカラムを間違えると、意図しないデータが取得される可能性があります。

そのため、JOINを使用するときは、**各テーブルの主キー・外部キーなどの関係を確認することが重要です。**

---

## 3.7 JOINによる重複に注意する

JOINすると、1つのレコードに対して複数のレコードが結合される場合があります。

例えば、1人のユーザーが複数の商品を注文している場合、

```text
users
  ↓
orders
  ↓
products
```

という関係になるため、ユーザー1人に対して複数の結果が取得されます。

そのため、JOINした結果の件数や集計結果を確認するときは、**テーブル同士のデータの関係が1対1なのか、1対多なのか**を意識する必要があります。

---

## 3.8 JOINを使いこなすためのポイント

JOINを使用するときは、以下の点を意識します。

1. どのテーブルを結合するか
2. どのカラムを使って結合するか
3. `INNER JOIN` と `LEFT JOIN` のどちらが必要か
4. JOINによってレコード数が増えないか
5. `WHERE` や `GROUP BY` などと組み合わせる必要があるか

---

## 3.9 まとめ

* `JOIN` を複数回使用して3つ以上のテーブルを結合できる
* `JOIN` と `WHERE` を組み合わせて条件を指定できる
* `JOIN` と `GROUP BY` を組み合わせてデータを集計できる
* `HAVING` でJOIN後の集計結果に条件を指定できる
* `ORDER BY` でJOIN後の結果を並べ替えられる
* JOINによってレコード数が増える場合があるため、テーブル同士の関係を理解することが重要
