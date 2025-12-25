# App_db数据库使用说明

## 概述

App_db是一个典型的Web应用数据库示例，模拟了电商系统的业务模型，包含用户管理、商品管理、订单管理、支付管理、评论管理等核心功能。

## 数据统计

- **用户数量**：约10万
- **商品数量**：1000+
- **分类数量**：35个
- **订单数量**：约10万
- **订单项数量**：约30万+
- **支付记录**：约5万
- **评论数量**：5万
- **数据库编码**：UTF8

## 文件说明

### app_db_schema.sql
数据库结构定义脚本，包含：
- 12个表（用户、地址、商品、订单等）
- 12个序列
- 20+个索引
- 15个外键约束
- 5个触发器
- 2个视图

### app_db_data.sql
示例数据插入脚本，包含：
- 10万用户数据
- 35个商品分类
- 1000+个商品
- 10万订单
- 30万+订单项
- 5万支付记录
- 5万商品评论
- 地址、用户资料等相关数据

## 安装步骤

### 方法一：使用psql命令行

#### 1. 连接到PostgreSQL
```bash
psql -U postgres
```

#### 2. 创建数据库
```sql
CREATE DATABASE app_db
    ENCODING 'UTF8'
    LC_COLLATE = 'en_US.UTF-8'
    LC_CTYPE = 'en_US.UTF-8';
```

#### 3. 退出PostgreSQL
```sql
\q
```

#### 4. 导入数据库结构
```bash
psql -U postgres -d app_db -f app_db_schema.sql
```

#### 5. 导入示例数据
```bash
psql -U postgres -d app_db -f app_db_data.sql
```

### 方法二：使用pgAdmin图形化工具

#### 1. 创建数据库
- 打开pgAdmin
- 右键点击`Databases` → `Create` → `Database...`
- 输入数据库名称`app_db`
- 设置编码为`UTF8`
- 点击`Save`

#### 2. 导入结构脚本
- 展开刚创建的`app_db`数据库
- 点击`Tools` → `Query Tool`
- 点击`Open File`按钮，选择`app_db_schema.sql`
- 点击`Execute`（闪电图标）执行脚本
- 等待执行完成，检查`Messages`面板

#### 3. 导入数据脚本
- 在Query Tool中点击`Open File`
- 选择并打开`app_db_data.sql`文件
- 点击`Execute`按钮执行脚本
- 等待执行完成（可能需要几分钟）

## 验证安装

### 查看所有表
```sql
\dt
```

预期结果：
```
                List of relations
 Schema |         Name          | Type  |  Owner
--------+-----------------------+-------+----------
 public | addresses             | table | postgres
 public | categories            | table | postgres
 public | order_items           | table | postgres
 public | order_status_history  | table | postgres
 public | orders               | table | postgres
 public | payments              | table | postgres
 public | product_images        | table | postgres
 public | products              | table | postgres
 public | reviews              | table | postgres
 public | user_profiles        | table | postgres
 public | users                | table | postgres
```

### 查看数据统计
```sql
SELECT '用户数量' AS 类型, COUNT(*) AS 数量 FROM users
UNION ALL
SELECT '地址数量', COUNT(*) FROM addresses
UNION ALL
SELECT '商品数量', COUNT(*) FROM products
UNION ALL
SELECT '订单数量', COUNT(*) FROM orders
UNION ALL
SELECT '订单项数量', COUNT(*) FROM order_items
UNION ALL
SELECT '支付数量', COUNT(*) FROM payments
UNION ALL
SELECT '评论数量', COUNT(*) FROM reviews
ORDER BY 数量 DESC;
```

## 数据库结构

### 核心表

| 表名 | 说明 | 记录数 |
|-----|------|--------|
| users | 用户表 | 约10万 |
| addresses | 地址表 | 约30万 |
| user_profiles | 用户资料表 | 约5万 |
| categories | 分类表 | 35 |
| products | 商品表 | 1000+ |
| product_images | 商品图片表 | 1000+ |
| orders | 订单表 | 约10万 |
| order_items | 订单项表 | 约30万 |
| order_status_history | 订单状态历史表 | 约8万 |
| payments | 支付表 | 约5万 |
| reviews | 评论表 | 5万 |

## 常见查询

### 1. 查询用户统计
```sql
SELECT
    COUNT(*) AS 总用户数,
    COUNT(CASE WHEN is_active = true THEN 1 END) AS 活跃用户数,
    COUNT(CASE WHEN created_at > CURRENT_DATE - INTERVAL '30 days' THEN 1 END) AS 近30天注册用户
FROM users;
```

### 2. 查询商品统计
```sql
SELECT
    c.name AS 分类名称,
    COUNT(p.product_id) AS 商品数量,
    AVG(p.price) AS 平均价格,
    SUM(p.stock_quantity) AS 总库存
FROM categories c
LEFT JOIN products p ON c.category_id = p.category_id
WHERE c.is_active = true
GROUP BY c.category_id, c.name
ORDER BY 商品数量 DESC;
```

### 3. 查询订单统计
```sql
SELECT
    status AS 订单状态,
    COUNT(*) AS 订单数量,
    SUM(total_amount) AS 总金额,
    AVG(total_amount) AS 平均金额
FROM orders
GROUP BY status
ORDER BY 订单数量 DESC;
```

### 4. 查询销售排行榜
```sql
SELECT
    p.product_id AS 商品ID,
    p.name AS 商品名称,
    c.name AS 分类名称,
    SUM(oi.quantity) AS 销售数量,
    SUM(oi.subtotal) AS 销售金额
FROM order_items oi
INNER JOIN products p ON oi.product_id = p.product_id
INNER JOIN categories c ON p.category_id = c.category_id
GROUP BY p.product_id, p.name, c.name
ORDER BY 销售金额 DESC
LIMIT 20;
```

### 5. 查询用户消费排行
```sql
SELECT
    u.username AS 用户名,
    u.email AS 邮箱,
    COUNT(DISTINCT o.order_id) AS 订单数量,
    SUM(o.total_amount) AS 总消费金额,
    MAX(o.created_at) AS 最后下单时间
FROM users u
INNER JOIN orders o ON u.user_id = o.user_id
GROUP BY u.user_id, u.username, u.email
ORDER BY 总消费金额 DESC
LIMIT 10;
```

## 性能优化建议

### 1. 分析表大小
```sql
SELECT
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS 大小,
    pg_total_relation_size(schemaname||'.'||tablename) AS 大小字节
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```

### 2. 更新统计信息
```sql
ANALYZE;
VACUUM ANALYZE;
```

### 3. 查看索引使用情况
```sql
SELECT
    schemaname,
    tablename,
    indexname,
    idx_scan AS 扫描次数,
    idx_tup_read AS 读取行数
FROM pg_stat_user_indexes
ORDER BY idx_scan DESC;
```

## 清理数据

### 清理所有数据（谨慎使用）
```sql
TRUNCATE TABLE order_status_history CASCADE;
TRUNCATE TABLE payments CASCADE;
TRUNCATE TABLE reviews CASCADE;
TRUNCATE TABLE order_items CASCADE;
TRUNCATE TABLE orders CASCADE;
TRUNCATE TABLE product_images CASCADE;
TRUNCATE TABLE products CASCADE;
TRUNCATE TABLE user_profiles CASCADE;
TRUNCATE TABLE addresses CASCADE;
TRUNCATE TABLE users CASCADE;
TRUNCATE TABLE categories CASCADE;
```

### 删除数据库
```bash
psql -U postgres -c "DROP DATABASE app_db;"
```

## 常见问题

### 1. 插入数据时出现编码错误
**问题**：ERROR: character with byte sequence 0x...

**解决方案**：
```bash
export PGCLIENTENCODING=UTF8
psql -U postgres -d app_db -f app_db_data.sql
```

### 2. 内存不足
**问题**：插入大量数据时内存不足

**解决方案**：
```bash
psql -U postgres -d app_db -v client_min_messages=warning -f app_db_data.sql
```

### 3. 执行时间过长
**问题**：数据插入脚本执行时间过长

**解决方案**：
- 在执行前关闭自动提交（autocommit off）
- 使用批量插入而非单条插入
- 增加maintenance_work_mem参数
```sql
SET maintenance_work_mem = '256MB';
```

## 版本信息

- **版本号**：v1.0.0
- **创建日期**：2025-12-25
- **PostgreSQL版本**：建议使用12.0或更高版本

## 联系方式

如有问题，请参考文档或提交Issue。

---

**文档结束**
