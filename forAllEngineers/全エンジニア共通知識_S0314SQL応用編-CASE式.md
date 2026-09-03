# 5. CASE式

## 5.1 CASE式とは

**`CASE` 式**は、条件によって返す値を変更するときに使用します。

プログラミングにおける `if` 文に近い働きをします。

例えば、社員の年齢によって「若手」「中堅」「ベテラン」のように分類したい場合、`CASE` 式を使用できます。

```sql
SELECT
    name,
    age,
    CASE
        WHEN age < 30 THEN '若手'
        WHEN age < 40 THEN '中堅'
        ELSE 'ベテラン'
    END AS age_category
FROM employees;
```

このSQLでは、年齢に応じて `age_category` という列を作成しています。

例えば、以下のような結果になります。

| name | age | age_category |
| ---- | --: | ------------ |
| 山田太郎 |  25 | 若手           |
| 佐藤花子 |  35 | 中堅           |
| 鈴木一郎 |  45 | ベテラン         |

---

## 5.2 CASE式の基本構文

`CASE` 式は、基本的に以下の形式で記述します。

```sql
CASE
    WHEN 条件1 THEN 結果1
    WHEN 条件2 THEN 結果2
    ELSE その他の場合の結果
END
```

それぞれの役割は以下のとおりです。

| 要素     | 説明                     |
| ------ | ---------------------- |
| `CASE` | CASE式の開始               |
| `WHEN` | 条件を指定する                |
| `THEN` | 条件に一致した場合に返す値を指定する     |
| `ELSE` | どの条件にも一致しなかった場合の値を指定する |
| `END`  | CASE式の終了               |

---

## 5.3 条件は上から順番に判定される

複数の `WHEN` を記述した場合、条件は上から順番に判定されます。

```sql
SELECT
    name,
    age,
    CASE
        WHEN age < 20 THEN '10代以下'
        WHEN age < 30 THEN '20代'
        WHEN age < 40 THEN '30代'
        ELSE '40代以上'
    END AS age_category
FROM employees;
```

例えば、年齢が25歳の場合、

```text
age < 20
  ↓
該当しない

age < 30
  ↓
該当する → 「20代」
```

となります。

条件に一致した時点で、その後の `WHEN` は判定されません。

そのため、**条件を書く順番には注意が必要です。**

---

## 5.4 ELSEについて

`ELSE` は、どの `WHEN` の条件にも一致しなかった場合に返す値を指定します。

```sql
SELECT
    name,
    age,
    CASE
        WHEN age < 20 THEN '未成年'
        ELSE '成人'
    END AS age_category
FROM employees;
```

`ELSE` を省略することもできます。

```sql
SELECT
    name,
    age,
    CASE
        WHEN age < 20 THEN '未成年'
    END AS age_category
FROM employees;
```

`ELSE` を指定せず、どの条件にも一致しなかった場合は `NULL` が返されます。

特別な理由がない場合は、**想定外の値が発生したときの結果を明確にするために `ELSE` を指定する**ことをおすすめします。

---

## 5.5 CASE式で文字列を変換する

CASE式は、データの値を別の値に変換するときにも使用できます。

例えば、部署コードを部署名に変換する場合を考えます。

```sql
SELECT
    name,
    department_id,
    CASE
        WHEN department_id = 1 THEN '営業部'
        WHEN department_id = 2 THEN '開発部'
        WHEN department_id = 3 THEN '総務部'
        ELSE 'その他'
    END AS department_name
FROM employees;
```

データベースに保存されている値を、そのまま表示するのではなく、分かりやすい値に変換できます。

---

## 5.6 CASE式と集計関数

`CASE` 式は、`SUM` や `COUNT` などの集計関数と組み合わせることもできます。

例えば、社員の男女別人数を集計する場合は、以下のように記述できます。

```sql
SELECT
    COUNT(CASE WHEN gender = '男性' THEN 1 END) AS male_count,
    COUNT(CASE WHEN gender = '女性' THEN 1 END) AS female_count
FROM employees;
```

また、`SUM` と組み合わせる方法もあります。

```sql
SELECT
    SUM(CASE WHEN gender = '男性' THEN 1 ELSE 0 END) AS male_count,
    SUM(CASE WHEN gender = '女性' THEN 1 ELSE 0 END) AS female_count
FROM employees;
```

このように、CASE式を使用することで、条件に一致するデータだけを集計できます。

---

## 5.7 CASE式とGROUP BY

CASE式を使用してデータを分類した後、その分類ごとに集計することもできます。

例えば、年齢層ごとの社員数を取得する場合は以下のように記述できます。

```sql
SELECT
    CASE
        WHEN age < 30 THEN '20代以下'
        WHEN age < 40 THEN '30代'
        ELSE '40代以上'
    END AS age_category,
    COUNT(*) AS employee_count
FROM employees
GROUP BY
    CASE
        WHEN age < 30 THEN '20代以下'
        WHEN age < 40 THEN '30代'
        ELSE '40代以上'
    END;
```

CASE式によって社員を年齢層に分類し、その分類ごとに人数を集計しています。

---

## 5.8 CASE式とORDER BY

CASE式を `ORDER BY` と組み合わせることで、通常の昇順・降順とは異なる順番で並べ替えることもできます。

例えば、部署を「営業部 → 開発部 → 総務部」の順番で表示したい場合は、以下のように記述できます。

```sql
SELECT *
FROM employees
ORDER BY
    CASE
        WHEN department = '営業部' THEN 1
        WHEN department = '開発部' THEN 2
        WHEN department = '総務部' THEN 3
        ELSE 4
    END;
```

このように、CASE式によって並び順を指定できます。

---

## 5.9 CASE式を使った実践例

例えば、商品の価格によって価格帯を分類し、それぞれの商品の情報を表示する場合を考えます。

```sql
SELECT
    product_name,
    price,
    CASE
        WHEN price < 1000 THEN '低価格'
        WHEN price < 10000 THEN '中価格'
        ELSE '高価格'
    END AS price_category
FROM products;
```

さらに、価格帯ごとの商品数を集計することもできます。

```sql
SELECT
    CASE
        WHEN price < 1000 THEN '低価格'
        WHEN price < 10000 THEN '中価格'
        ELSE '高価格'
    END AS price_category,
    COUNT(*) AS product_count
FROM products
GROUP BY
    CASE
        WHEN price < 1000 THEN '低価格'
        WHEN price < 10000 THEN '中価格'
        ELSE '高価格'
    END;
```

このように、CASE式は単独で使用するだけでなく、**集計や並べ替えと組み合わせることで、より実用的なSQLを記述できます。**

---

## 5.10 CASE式を使用するときの注意点

### 条件の順番に注意する

条件は上から順番に判定されるため、条件の順番によって結果が変わります。

```sql
CASE
    WHEN age >= 20 THEN '20歳以上'
    WHEN age >= 30 THEN '30歳以上'
    ELSE '20歳未満'
END
```

この場合、30歳のデータは最初の `age >= 20` に一致するため、「20歳以上」と判定されます。

「30歳以上」を判定したい場合は、条件の順番を変更する必要があります。

```sql
CASE
    WHEN age >= 30 THEN '30歳以上'
    WHEN age >= 20 THEN '20歳以上'
    ELSE '20歳未満'
END
```

---

## 5.11 まとめ

* `CASE` 式は条件によって返す値を変更するときに使用する
* `WHEN` で条件を指定し、`THEN` で結果を指定する
* `ELSE` でどの条件にも一致しなかった場合の結果を指定できる
* 条件は上から順番に判定される
* `SELECT` だけでなく、`GROUP BY` や `ORDER BY` でも使用できる
* 集計関数と組み合わせて条件付きの集計ができる
* 条件の順番によって結果が変わるため注意が必要

CASE式を使うことで、データを条件に応じて分類・変換できるようになります。

特に、**「データを取得するだけでなく、取得したデータを分かりやすい形に加工する」** という場面で役立つ構文です。
