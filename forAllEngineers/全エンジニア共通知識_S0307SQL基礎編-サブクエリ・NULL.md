## 7. サブクエリ・NULL

### 7.1 サブクエリとは

**サブクエリ（Subquery）** とは、SQL文の中に記述された別のSQL文のことです。

例えば、平均年齢より年齢が高いユーザーを取得する場合、以下のように記述できます。

```sql
SELECT *
FROM users
WHERE age > (
    SELECT AVG(age)
    FROM users
);
```

内側の `SELECT` で平均年齢を求め、その結果を外側のSQLで使用しています。

---

### 7.2 NULLとは

**`NULL`** は、データが存在しないことを表す特殊な値です。

例えば、メールアドレスが登録されていない場合、そのカラムが `NULL` になっていることがあります。

| id | name | email                                       |
| -- | ---- | ------------------------------------------- |
| 1  | 山田太郎 | [taro@example.com](mailto:taro@example.com) |
| 2  | 佐藤花子 | NULL                                        |

`NULL` は、0や空文字（`''`）とは異なります。

* `0` → 数値の0
* `''` → 空の文字列
* `NULL` → 値が存在しない

---

### 7.3 NULLを検索する

`NULL` を検索するときは、`=` ではなく `IS NULL` を使用します。

```sql
SELECT *
FROM users
WHERE email IS NULL;
```

NULLではないデータを取得する場合は、`IS NOT NULL` を使用します。

```sql
SELECT *
FROM users
WHERE email IS NOT NULL;
```

---

### 7.4 まとめ

* サブクエリは、SQL文の中に記述された別のSQL文
* `NULL` は値が存在しないことを表す
* `NULL` は0や空文字とは異なる
* `IS NULL` でNULLのデータを検索する
* `IS NOT NULL` でNULLではないデータを検索する

---
