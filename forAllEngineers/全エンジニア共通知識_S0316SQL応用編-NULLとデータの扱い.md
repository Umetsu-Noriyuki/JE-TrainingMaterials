# 7. NULLとデータの扱い

## 7.1 NULLとは

**`NULL`** とは、データが存在しないことや、値が不明であることを表す特殊な値です。

例えば、社員情報に電話番号が登録されていない場合、電話番号のカラムが `NULL` になっていることがあります。

```text
id | name       | phone
---|------------|-----------
1  | 山田太郎   | 090-1234-5678
2  | 佐藤花子   | NULL
3  | 鈴木一郎   | 080-9876-5432
```

この場合、佐藤花子の電話番号は「0」や「空文字」なのではなく、**電話番号の値が存在しない**ことを表しています。

---

## 7.2 NULLと0・空文字の違い

`NULL` は、`0` や空文字（`''`）とは異なります。

| 値      | 意味            |
| ------ | ------------- |
| `NULL` | 値が存在しない、または不明 |
| `0`    | 数値の0          |
| `''`   | 文字列が空         |

例えば、以下はそれぞれ異なるデータです。

```sql
0
```

```sql
''
```

```sql
NULL
```

そのため、`NULL` を通常の値と同じように扱わないよう注意が必要です。

---

## 7.3 NULLを検索する

`NULL` のデータを検索するときは、`=` ではなく **`IS NULL`** を使用します。

以下のように記述します。

```sql
SELECT *
FROM employees
WHERE phone IS NULL;
```

これにより、電話番号が登録されていない社員を取得できます。

反対に、`NULL` ではないデータを検索する場合は `IS NOT NULL` を使用します。

```sql
SELECT *
FROM employees
WHERE phone IS NOT NULL;
```

---

## 7.4 NULLに「=」を使用しない

`NULL` を検索するときに、以下のように記述してはいけません。

```sql
SELECT *
FROM employees
WHERE phone = NULL;
```

`NULL` は通常の値とは異なるため、`=` を使用して比較することはできません。

正しくは以下のように記述します。

```sql
SELECT *
FROM employees
WHERE phone IS NULL;
```

NULLではないことを確認する場合は、

```sql
SELECT *
FROM employees
WHERE phone IS NOT NULL;
```

とします。

---

## 7.5 NULLを含む計算

`NULL` を含む値で計算を行うと、結果が `NULL` になる場合があります。

例えば、以下のデータがあるとします。

| name | salary | bonus |
| ---- | -----: | ----: |
| 山田太郎 | 300000 | 50000 |
| 佐藤花子 | 300000 |  NULL |

給与と賞与を合計するとします。

```sql
SELECT
    name,
    salary + bonus AS total_salary
FROM employees;
```

山田太郎の場合は、

```text
300000 + 50000 = 350000
```

となります。

一方、佐藤花子の場合は、

```text
300000 + NULL = NULL
```

となります。

賞与が登録されていない場合は0として計算したい、という場合には `COALESCE` などを使用します。

---

## 7.6 COALESCE

**`COALESCE`** は、NULLの値を別の値に置き換えるときに使用します。

基本的な構文は以下のとおりです。

```sql
COALESCE(値, NULLの場合の値)
```

例えば、NULLを0として扱う場合は以下のように記述します。

```sql
SELECT
    name,
    salary,
    COALESCE(bonus, 0) AS bonus
FROM employees;
```

これにより、`bonus` が `NULL` の場合は `0` が返されます。

給与と賞与を合計する場合にも使用できます。

```sql
SELECT
    name,
    salary + COALESCE(bonus, 0) AS total_salary
FROM employees;
```

この場合、賞与がNULLの社員についても、賞与を0として合計できます。

---

## 7.7 COALESCEで複数の候補を指定する

`COALESCE` には複数の値を指定できます。

```sql
COALESCE(値1, 値2, 値3)
```

左から順番に確認し、最初にNULLではない値を返します。

例えば、

```sql
SELECT
    COALESCE(phone, email, '連絡先なし') AS contact
FROM employees;
```

とした場合、

1. `phone` がNULLではなければ `phone`
2. `phone` がNULLなら `email`
3. `phone` と `email` の両方がNULLなら `'連絡先なし'`

という順番で値が選択されます。

---

## 7.8 NULLと集計関数

集計関数を使用するときも、NULLの扱いには注意が必要です。

例えば、以下のようなデータがあるとします。

| name | score |
| ---- | ----: |
| 山田   |    80 |
| 佐藤   |    90 |
| 鈴木   |  NULL |

このデータに対して、

```sql
SELECT AVG(score)
FROM students;
```

を実行すると、NULLを除外して平均値が計算されます。

つまり、

```text
(80 + 90) ÷ 2 = 85
```

となります。

`NULL` は「0点」ではないため、

```text
(80 + 90 + 0) ÷ 3
```

とはなりません。

この違いを理解しておくことが重要です。

---

## 7.9 COUNTとNULL

`COUNT` でもNULLの扱いが異なります。

`COUNT(*)` は、テーブルの行数を数えます。

```sql
SELECT COUNT(*)
FROM students;
```

一方、`COUNT(column)` は、指定したカラムがNULLではない行を数えます。

```sql
SELECT COUNT(score)
FROM students;
```

例えば、

| id | name | score |
| -- | ---- | ----: |
| 1  | 山田   |    80 |
| 2  | 佐藤   |    90 |
| 3  | 鈴木   |  NULL |

の場合、

```sql
COUNT(*)
```

の結果は、

```text
3
```

です。

一方、

```sql
COUNT(score)
```

の結果は、

```text
2
```

になります。

これは `score` がNULLの行はカウントされないためです。

---

## 7.10 NULLとWHERE

`WHERE` で条件を指定するときも、NULLの扱いに注意が必要です。

例えば、以下の条件を指定した場合、

```sql
SELECT *
FROM employees
WHERE bonus > 50000;
```

`bonus` がNULLのデータは条件に一致しません。

これは、

```text
NULL > 50000
```

を「FALSE」と単純に判断しているというより、NULLを含む比較結果が**不明（UNKNOWN）** となり、`WHERE` の条件には含まれないためです。

そのため、NULLのデータも含めたい場合は、明示的に条件を指定する必要があります。

```sql
SELECT *
FROM employees
WHERE bonus > 50000
   OR bonus IS NULL;
```

---

## 7.11 NULLとORDER BY

`ORDER BY` で並べ替える場合、NULLの位置はデータベース製品によって動作が異なる場合があります。

例えば、

```sql
SELECT *
FROM employees
ORDER BY bonus DESC;
```

とした場合、NULLがどの位置に表示されるかは、使用しているデータベースによって異なることがあります。

NULLの位置を明確にしたい場合は、CASE式などを組み合わせて並び順を指定する方法があります。

```sql
SELECT *
FROM employees
ORDER BY
    CASE
        WHEN bonus IS NULL THEN 1
        ELSE 0
    END,
    bonus DESC;
```

このSQLでは、NULLではないデータを先に並べ、その後にNULLのデータを並べています。

---

## 7.12 NULLを別の値として表示する

データベース上ではNULLのままにしておきたいものの、画面や帳票では分かりやすい文字列を表示したい場合があります。

例えば、電話番号がNULLの場合に「未登録」と表示する場合は、以下のように記述できます。

```sql
SELECT
    name,
    COALESCE(phone, '未登録') AS phone
FROM employees;
```

データそのものを変更するのではなく、**SELECTした結果だけを分かりやすい表示に変更しています。**

---

## 7.13 NULLを扱うときの実践例

例えば、社員の給与情報から「基本給＋賞与」を計算し、賞与が未登録の場合は0として扱いたいとします。

```sql
SELECT
    name,
    salary,
    COALESCE(bonus, 0) AS bonus,
    salary + COALESCE(bonus, 0) AS total_salary
FROM employees;
```

このSQLでは、

* 社員名を取得する
* 基本給を取得する
* NULLの賞与を0として表示する
* 基本給と賞与を合計する

という処理を行っています。

---

## 7.14 NULLを扱うときの注意点

NULLを扱う際は、以下の点に注意します。

* NULLは0とは異なる
* NULLは空文字とは異なる
* NULLの検索には `IS NULL` を使用する
* NULLではないことの確認には `IS NOT NULL` を使用する
* NULLを含む計算結果はNULLになる場合がある
* `COALESCE` を使用してNULLを別の値に置き換えられる
* `COUNT(*)` と `COUNT(column)` ではNULLの扱いが異なる
* データベース製品によってNULLの扱いが異なる場合がある

特に、

```sql
WHERE column = NULL
```

ではなく、

```sql
WHERE column IS NULL
```

とすることは重要なポイントです。

---

## 7.15 まとめ

* `NULL` は値が存在しない、または不明であることを表す
* `NULL` は `0` や空文字とは異なる
* NULLの検索には `IS NULL` を使用する
* NULLではないデータの検索には `IS NOT NULL` を使用する
* `COALESCE` を使用するとNULLを別の値に置き換えられる
* 集計関数ではNULLが無視される場合がある
* `COUNT(*)` と `COUNT(column)` ではNULLの扱いが異なる
* NULLを含む計算では結果がNULLになる場合がある
* NULLを扱うときは、データベース製品による違いにも注意する

NULLは、実際のデータベースを扱うと頻繁に登場します。

単純なSQLでは意識する機会が少ないものの、**実際の業務データを扱う場合にはNULLを正しく理解しておくことが重要です。**
