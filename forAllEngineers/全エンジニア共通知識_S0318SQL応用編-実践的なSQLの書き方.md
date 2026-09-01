# 9. 実践的なSQLの書き方

## 9.1 読みやすいSQLを書く

SQLは、正しく実行できることだけでなく、他の人が読んだときに内容を理解しやすいことも重要です。

例えば、以下のSQLは実行できます。

```sql id="sq9x01"
SELECT name,department,salary FROM employees WHERE salary >= 300000 ORDER BY salary DESC;
```

しかし、改行やインデントを使用すると読みやすくなります。

```sql id="sq9x02"
SELECT
    name,
    department,
    salary
FROM employees
WHERE salary >= 300000
ORDER BY salary DESC;
```

SQLを記述するときは、一定のルールを決めて書式を統一することが重要です。

---

## 9.2 キーワードを大文字で記述する

SQLでは、以下のようなキーワードがあります。

```sql id="sq9x03"
SELECT
FROM
WHERE
JOIN
ORDER BY
GROUP BY
```

一般的には、SQLのキーワードを大文字で記述することが多いです。

```sql id="sq9x04"
SELECT
    name,
    salary
FROM employees
WHERE salary >= 300000;
```

ただし、SQLのキーワードを小文字で記述することも可能です。

```sql id="sq9x05"
select
    name,
    salary
from employees
where salary >= 300000;
```

重要なのは、チームやプロジェクト内で書き方を統一することです。

---

## 9.3 テーブル名やカラム名に別名を付ける

テーブル名やカラム名が長い場合は、**別名（エイリアス）**を使用できます。

```sql id="sq9x06"
SELECT
    e.name,
    e.salary
FROM employees AS e;
```

この例では、`employees` テーブルに `e` という別名を付けています。

JOINを使用する場合は、特にエイリアスを使用するとSQLが読みやすくなります。

```sql id="sq9x07"
SELECT
    e.name,
    d.department_name
FROM employees AS e
INNER JOIN departments AS d
    ON e.department_id = d.id;
```

---

## 9.4 SELECT * を必要以上に使用しない

`SELECT *` はすべてのカラムを取得するため、簡単に使用できます。

```sql id="sq9x08"
SELECT *
FROM employees;
```

しかし、実際に必要なカラムだけを取得したほうがよい場合があります。

```sql id="sq9x09"
SELECT
    name,
    department,
    salary
FROM employees;
```

必要なデータだけを取得することで、

* SQLの目的が分かりやすくなる
* 不要なデータを取得しない
* テーブル構造が変更された場合の影響を受けにくい

といったメリットがあります。

ただし、データ確認などを目的とした場合は `SELECT *` が便利なこともあります。

---

## 9.5 WHERE句でデータを絞り込む

大量のデータが存在するテーブルでは、必要なデータだけを取得することが重要です。

```sql id="sq9x10"
SELECT
    name,
    salary
FROM employees
WHERE department = '開発部';
```

条件を指定せずに大量のデータを取得すると、処理に時間がかかる場合があります。

そのため、必要なデータが決まっている場合は、適切に `WHERE` 句を使用します。

---

## 9.6 UPDATEやDELETEを実行するときの注意点

`UPDATE` や `DELETE` は、既存のデータを変更・削除します。

そのため、条件を指定せずに実行すると、多くのデータに影響する可能性があります。

例えば、以下のSQLはすべての社員の給与を変更します。

```sql id="sq9x11"
UPDATE employees
SET salary = 300000;
```

特定の社員だけを変更したい場合は、`WHERE` を指定します。

```sql id="sq9x12"
UPDATE employees
SET salary = 300000
WHERE id = 1;
```

`DELETE` についても同様です。

```sql id="sq9x13"
DELETE FROM employees
WHERE id = 1;
```

特に本番環境では、SQLを実行する前に対象となるデータを確認することが重要です。

例えば、先に `SELECT` 文で対象を確認します。

```sql id="sq9x14"
SELECT *
FROM employees
WHERE id = 1;
```

確認した後に、`UPDATE` や `DELETE` を実行すると、意図しないデータの変更や削除を防ぎやすくなります。

---

## 9.7 コメントを使用する

SQLにはコメントを記述できます。

1行コメントには `--` を使用します。

```sql id="sq9x15"
-- 開発部の社員を取得する
SELECT *
FROM employees
WHERE department = '開発部';
```

複数行のコメントには `/* */` を使用できます。

```sql id="sq9x16"
/*
開発部の社員を取得する
給与が30万円以上の社員を対象とする
*/
SELECT *
FROM employees
WHERE department = '開発部'
  AND salary >= 300000;
```

複雑なSQLでは、処理の目的をコメントとして残しておくと理解しやすくなります。

---

## 9.8 SQLの処理を段階的に確認する

複雑なSQLを一度に完成させようとすると、エラーが発生した場合に原因を特定しにくくなります。

例えば、

1. まず必要なテーブルからデータを取得する
2. `WHERE` で条件を追加する
3. `JOIN` を追加する
4. 集計を追加する
5. `ORDER BY` で並び替える

というように、少しずつSQLを作成し、その都度結果を確認すると問題を見つけやすくなります。

---

## 9.9 インデックスについて

データ量が多くなると、SQLの検索処理に時間がかかることがあります。

そのような場合、**インデックス**を使用することで検索速度を改善できる場合があります。

インデックスは、本の索引のようなものです。

例えば、

```sql id="sq9x17"
SELECT *
FROM employees
WHERE employee_id = 100;
```

のように特定のデータを検索する場合、適切なインデックスが設定されていると、データを探す処理を効率化できる場合があります。

ただし、インデックスを多く作成すれば必ず高速になるわけではありません。

インデックスにはデータの追加や更新時に処理が必要になる場合もあるため、適切に設計する必要があります。

---

## 9.10 SQLを書くときの基本的な考え方

SQLを記述するときは、以下の順番で考えると整理しやすくなります。

```text id="sq9x18"
1. 何を取得・変更したいか
        ↓
2. どのテーブルを使用するか
        ↓
3. 必要なカラムは何か
        ↓
4. どのような条件で絞り込むか
        ↓
5. テーブルを結合する必要があるか
        ↓
6. 集計する必要があるか
        ↓
7. どのような順番で表示するか
```

SQLを記述する前に、必要なデータを整理することで、複雑なSQLでも作成しやすくなります。

---

## 9.11 まとめ

* SQLは他の人が読みやすいように記述する
* 改行やインデントを使用して書式を整える
* SQLの書き方をチーム内で統一する
* テーブル名やカラム名には必要に応じてエイリアスを使用する
* `SELECT *` は必要に応じて使用する
* 大量のデータを扱う場合は適切に条件を指定する
* `UPDATE` や `DELETE` を実行する前には対象データを確認する
* コメントを使用してSQLの目的を分かりやすくする
* 複雑なSQLは段階的に作成する
* インデックスは検索を効率化できる場合がある

SQLは、単に「実行できるSQL」を書くだけでなく、**「安全で、読みやすく、修正しやすいSQL」を書くことも重要です。**
