# 4. サブクエリ

## 4.1 サブクエリとは

**サブクエリ（Subquery）**とは、SQL文の中に記述された別のSQL文のことです。

サブクエリを使用すると、あるSQLの実行結果を、別のSQLの条件や取得する値として利用できます。

例えば、「全社員の平均年齢より年齢が高い社員」を取得する場合を考えます。

まず、平均年齢を取得します。

```sql
SELECT AVG(age)
FROM employees;
```

このSQLで取得した平均年齢を条件として使用することで、平均年齢より高い社員を取得できます。

```sql
SELECT *
FROM employees
WHERE age > (
    SELECT AVG(age)
    FROM employees
);
```

このように、`()` の中に別の `SELECT` 文を記述することで、サブクエリを作成できます。

---

## 4.2 サブクエリの基本構造

サブクエリは、主に以下のような構造になります。

```sql
SELECT カラム
FROM テーブル
WHERE カラム 演算子 (
    SELECT カラム
    FROM テーブル
    WHERE 条件
);
```

外側のSQLを**外側のクエリ**、内側のSQLを**サブクエリ**と呼びます。

```text
外側のクエリ
    ↓
  条件として利用
    ↑
サブクエリ
```

---

## 4.3 サブクエリの実行順序

サブクエリを理解するときは、まず内側のSQLが実行され、その結果が外側のSQLで使用されると考えると分かりやすくなります。

例えば、以下のSQLを考えます。

```sql
SELECT *
FROM employees
WHERE age > (
    SELECT AVG(age)
    FROM employees
);
```

この場合、まず以下のサブクエリが実行されます。

```sql
SELECT AVG(age)
FROM employees;
```

仮に結果が `30` だった場合、外側のSQLは以下のような条件として扱われます。

```sql
SELECT *
FROM employees
WHERE age > 30;
```

このように、サブクエリの結果を外側のクエリで利用できます。

---

## 4.4 INとサブクエリ

サブクエリは `IN` と組み合わせて使用することもできます。

例えば、「営業部に所属している社員の名前を取得する」場合を考えます。

社員情報が `employees` テーブル、部署情報が `departments` テーブルに保存されているとします。

### departmentsテーブル

| id | name |
| -- | ---- |
| 1  | 営業部  |
| 2  | 開発部  |
| 3  | 総務部  |

### employeesテーブル

| id | name | department_id |
| -- | ---- | ------------- |
| 1  | 山田太郎 | 1             |
| 2  | 佐藤花子 | 2             |
| 3  | 鈴木一郎 | 1             |

部署名から部署IDを取得し、その結果を利用する場合は以下のように記述できます。

```sql
SELECT *
FROM employees
WHERE department_id IN (
    SELECT id
    FROM departments
    WHERE name = '営業部'
);
```

サブクエリによって営業部の `id` を取得し、そのIDを持つ社員を外側のクエリで取得しています。

---

## 4.5 EXISTS

**`EXISTS`** は、サブクエリの結果が1件以上存在するかどうかを確認するときに使用します。

例えば、「注文履歴が存在するユーザー」を取得する場合は以下のように記述できます。

```sql
SELECT *
FROM users
WHERE EXISTS (
    SELECT 1
    FROM orders
    WHERE orders.user_id = users.id
);
```

サブクエリで、現在のユーザーに対応する注文データが存在するかを確認しています。

注文データが1件以上存在するユーザーが結果として取得されます。

---

## 4.6 EXISTSとINの違い

`EXISTS` と `IN` は、どちらも条件に合うデータを検索するために使用できます。

例えば、以下の2つのSQLは似た目的で使用できます。

### INを使用する場合

```sql
SELECT *
FROM users
WHERE id IN (
    SELECT user_id
    FROM orders
);
```

### EXISTSを使用する場合

```sql
SELECT *
FROM users
WHERE EXISTS (
    SELECT 1
    FROM orders
    WHERE orders.user_id = users.id
);
```

どちらを使用するかは、SQLの目的やデータ構造によって判断します。

特に `EXISTS` は、「条件に一致するデータが存在するか」を確認したい場合に適しています。

---

## 4.7 サブクエリで集計結果を利用する

サブクエリでは、集計関数の結果を利用することもできます。

例えば、「平均価格より高い商品」を取得する場合は以下のように記述できます。

```sql
SELECT *
FROM products
WHERE price > (
    SELECT AVG(price)
    FROM products
);
```

このSQLでは、

1. サブクエリで商品の平均価格を取得する
2. 取得した平均価格を外側のクエリで使用する
3. 平均価格より高い商品を取得する

という処理を行っています。

---

## 4.8 サブクエリをFROM句で使用する

サブクエリは `WHERE` だけではなく、`FROM` でも使用できます。

例えば、部署ごとの社員数を一度集計し、その結果を別のSQLで利用する場合は以下のように記述できます。

```sql
SELECT *
FROM (
    SELECT
        department_id,
        COUNT(*) AS employee_count
    FROM employees
    GROUP BY department_id
) AS department_summary;
```

`FROM` の中に記述したサブクエリを、1つのテーブルのように扱っています。

このようなサブクエリを**派生テーブル**と呼ぶことがあります。

---

## 4.9 サブクエリをSELECT句で使用する

サブクエリは `SELECT` の中で使用することもできます。

例えば、各社員の名前と、全社員の平均年齢を一緒に表示する場合は以下のように記述できます。

```sql
SELECT
    name,
    age,
    (
        SELECT AVG(age)
        FROM employees
    ) AS average_age
FROM employees;
```

結果は以下のようになります。

| name | age | average_age |
| ---- | --: | ----------: |
| 山田太郎 |  25 |          30 |
| 佐藤花子 |  35 |          30 |
| 鈴木一郎 |  30 |          30 |

このように、サブクエリの結果を取得するカラムの一部として使用することもできます。

---

## 4.10 相関サブクエリ

**相関サブクエリ**とは、外側のクエリの値をサブクエリ内で参照するサブクエリです。

例えば、「自分が所属する部署の平均年齢より年齢が高い社員」を取得する場合を考えます。

```sql
SELECT *
FROM employees AS e
WHERE age > (
    SELECT AVG(age)
    FROM employees
    WHERE department_id = e.department_id
);
```

このSQLでは、外側のクエリで取得している社員の `department_id` を、サブクエリ内でも使用しています。

そのため、社員ごとに所属部署の平均年齢を計算し、その平均年齢より高い社員を取得します。

---

## 4.11 サブクエリとJOINの使い分け

サブクエリと `JOIN` は、同じような結果を取得できる場合があります。

例えば、ユーザーと注文情報を関連付ける場合、`JOIN` を使用すると以下のようになります。

```sql
SELECT DISTINCT users.*
FROM users
INNER JOIN orders
    ON users.id = orders.user_id;
```

サブクエリを使用すると、以下のように記述できます。

```sql
SELECT *
FROM users
WHERE EXISTS (
    SELECT 1
    FROM orders
    WHERE orders.user_id = users.id
);
```

どちらが正しいというわけではなく、**取得したいデータやSQLの目的に応じて使い分けることが重要です。**

「関連するデータそのものを取得したい」のか、「関連するデータが存在するかだけを確認したい」のかを考えると、使い分けやすくなります。

---

## 4.12 サブクエリを使用するときの注意点

サブクエリは便利ですが、SQLが複雑になりやすいという特徴があります。

特に以下の点に注意します。

* サブクエリが何を返しているのか確認する
* サブクエリの結果が1件なのか、複数件なのか確認する
* 外側のクエリとの関係を確認する
* サブクエリを複雑にしすぎない
* 必要に応じて `JOIN` や `WITH` など別の方法も検討する

例えば、以下のSQLでは `=` を使用しているため、サブクエリが複数の値を返すとエラーになる可能性があります。

```sql
SELECT *
FROM employees
WHERE department_id = (
    SELECT id
    FROM departments
);
```

複数の部署IDが返る可能性がある場合は、`IN` を使用します。

```sql
SELECT *
FROM employees
WHERE department_id IN (
    SELECT id
    FROM departments
);
```

このように、**サブクエリが返すデータの件数を意識することが重要です。**

---

## 4.13 まとめ

* サブクエリはSQL文の中に記述する別のSQL文
* サブクエリの実行結果を外側のクエリで利用できる
* `IN` と組み合わせて複数の値を条件として使用できる
* `EXISTS` を使用してデータの存在を確認できる
* `FROM` の中にサブクエリを記述して、結果をテーブルのように扱える
* `SELECT` の中にサブクエリを記述することもできる
* 外側のクエリを参照するサブクエリを相関サブクエリという
* サブクエリの結果が1件なのか複数件なのかを意識することが重要
* `JOIN` や `WITH` など、別の方法が適している場合もある

サブクエリを使用することで、単純な条件指定だけでは取得しにくいデータも検索できるようになります。

ただし、サブクエリを多用するとSQLが複雑になる場合があるため、**「何を取得したいのか」「どのような条件で絞り込みたいのか」**を整理したうえで使用することが重要です。
