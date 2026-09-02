# 8. CTE（WITH句）

## 8.1 CTEとは

**CTE（Common Table Expression）** とは、SQLの中で一時的な結果セットに名前を付けて使用する方法です。

CTEは `WITH` 句を使用して定義します。

例えば、部署ごとの平均給与を一度計算し、その結果を利用する場合は以下のように記述できます。

```sql id="ct8x01"
WITH department_average AS (
    SELECT
        department,
        AVG(salary) AS average_salary
    FROM employees
    GROUP BY department
)
SELECT *
FROM department_average;
```

このSQLでは、`department_average` という名前の一時的な結果セットを作成しています。

その後、通常のテーブルと同じように `SELECT` 文で使用できます。

---

## 8.2 WITH句の基本構文

基本的な構文は以下のとおりです。

```sql id="ct8x02"
WITH CTE名 AS (
    SQL文
)
SELECT
    カラム
FROM CTE名;
```

`WITH` の中でSQLを定義し、その結果に名前を付けます。

```text id="ct8x03"
WITH
 ↓
一時的な結果を作成

CTE名 AS (...)
 ↓
結果に名前を付ける

SELECT
 ↓
CTEを使用する
```

CTEは、複雑なSQLを複数の処理に分けて記述したい場合に便利です。

---

## 8.3 サブクエリとの違い

CTEとサブクエリは、どちらもSQLの途中結果を利用するために使用できます。

例えば、サブクエリを使用する場合は以下のようになります。

```sql id="ct8x04"
SELECT *
FROM (
    SELECT
        department,
        AVG(salary) AS average_salary
    FROM employees
    GROUP BY department
) AS department_average;
```

同じ処理をCTEで記述すると、以下のようになります。

```sql id="ct8x05"
WITH department_average AS (
    SELECT
        department,
        AVG(salary) AS average_salary
    FROM employees
    GROUP BY department
)
SELECT *
FROM department_average;
```

処理内容は似ていますが、CTEを使用すると途中の処理に名前を付けられるため、複雑なSQLを読みやすくできます。

---

## 8.4 CTEを使用した条件検索

CTEで取得した結果に対して、さらに条件を指定することもできます。

例えば、部署ごとの平均給与を計算し、その平均給与が30万円以上の部署を取得します。

```sql id="ct8x06"
WITH department_average AS (
    SELECT
        department,
        AVG(salary) AS average_salary
    FROM employees
    GROUP BY department
)
SELECT *
FROM department_average
WHERE average_salary >= 300000;
```

このように、

1. CTEでデータを集計する
2. 集計結果を取得する
3. 条件で絞り込む

というように、処理を段階的に記述できます。

---

## 8.5 複数のCTEを使用する

`WITH` 句では、複数のCTEを定義することもできます。

複数のCTEを使用する場合は、カンマで区切ります。

```sql id="ct8x07"
WITH
department_average AS (
    SELECT
        department,
        AVG(salary) AS average_salary
    FROM employees
    GROUP BY department
),
high_salary_department AS (
    SELECT *
    FROM department_average
    WHERE average_salary >= 300000
)
SELECT *
FROM high_salary_department;
```

この例では、

```text id="ct8x08"
employees
    ↓
department_average
    ↓
high_salary_department
    ↓
SELECT
```

という順番で処理を分けています。

複雑なSQLを作成する場合、処理の内容ごとにCTEを分けることで、SQLの構造を理解しやすくできます。

---

## 8.6 CTEとJOIN

CTEの結果は、通常のテーブルと同じように `JOIN` できます。

例えば、部署ごとの平均給与と社員情報を結合する場合は以下のように記述できます。

```sql id="ct8x09"
WITH department_average AS (
    SELECT
        department,
        AVG(salary) AS average_salary
    FROM employees
    GROUP BY department
)
SELECT
    e.name,
    e.department,
    e.salary,
    d.average_salary
FROM employees AS e
INNER JOIN department_average AS d
    ON e.department = d.department;
```

これにより、各社員の給与と所属部署の平均給与を同時に取得できます。

---

## 8.7 CTEを使用するときの注意点

CTEはSQLを分かりやすくするために便利ですが、必要以上に細かく分けすぎると、逆に処理の流れが分かりにくくなる場合があります。

以下のような場合に使用を検討するとよいでしょう。

* サブクエリが長くなっている
* 同じような処理を複数回使用する
* SQLの処理を段階的に整理したい
* 複雑な集計結果をさらに利用したい

ただし、CTEのパフォーマンスはデータベース製品やSQLの内容によって異なります。

大量のデータを扱う場合は、実行計画などを確認することも重要です。

---

## 8.8 まとめ

* CTEは `WITH` 句を使用して定義する
* SQLの途中結果に名前を付けることができる
* 複雑なSQLを読みやすく整理できる
* 複数のCTEを定義できる
* CTEの結果はテーブルのように使用できる
* `JOIN` や `WHERE` などと組み合わせられる
* SQLを必要以上に細かく分けすぎないように注意する

CTEを使用することで、複雑なSQLを段階的に整理できます。

特に、**「何をしているSQLなのか分かりやすくする」** という点で非常に役立ちます。
