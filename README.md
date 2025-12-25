# App_db数据库使用说明 (v2.0)

## 概述

App_db v2.0 是一个典型的大型 Web 应用数据库示例，模拟了电商系统的业务模型，采用多 Schema 架构设计。包含电商核心（mall）、审计日志（audit）、地理位置（gis）三大模块，支持 PostGIS 空间数据处理。

## 数据统计

### 整体统计
- **用户数量**：10万
- **地址数量**：约40万
- **商品数量**：73个
- **订单数量**：10万
- **订单项数量**：约17.5万
- **支付记录**：5万
- **评论数量**：5万
- **数据库编码**：UTF8
- **Schema 数量**：3个

### Schema 统计

| Schema | 说明 | 表数量 | 视图数量 | 函数数量 | 存储过程数量 |
|--------|------|--------|----------|----------|------------|
| mall | 电商核心 | 10 | 2 | 5 | 0 |
| audit | 审计日志 | 3 | 0 | 0 | 0 |
| gis | 地理位置 | 4 | 0 | 2 | 4 |
| **总计** | - | **17** | **2** | **7** | **4** |

### 数据统计

| Schema | 统计项 | 数量 |
|--------|--------|------|
| MALL | 用户数量 | 100,000 |
| MALL | 地址数量 | 400,184 |
| MALL | 商品数量 | 73 |
| MALL | 订单数量 | 100,000 |
| MALL | 订单项数量 | 175,391 |
| MALL | 支付数量 | 50,000 |
| MALL | 评论数量 | 50,000 |
| AUDIT | 审计日志数量 | 1,000 |
| AUDIT | 登录日志数量 | 5,000 |
| AUDIT | 数据变更历史数量 | 2,000 |
| GIS | 门店位置数量 | 50 |
| GIS | 配送区域数量 | 10 |
| GIS | 物流轨迹数量 | 100 |
| GIS | 热点区域数量 | 20 |

## 文件说明

### app_db_schema_v2.sql
数据库结构定义脚本（v2.0），包含：
- 3个 Schema
- 17个表
- 10个序列
- 32个索引（包含PostGIS空间索引）
- 11个外键约束
- 5个触发器
- 2个视图
- 7个函数
- 4个存储过程

### app_db_data_v2.sql
示例数据插入脚本（v2.0），包含：
- MALL Schema: 10万用户、40万地址、73商品、10万订单、17.5万订单项、5万支付、5万评论
- AUDIT Schema: 1000审计日志、5000登录日志、2000数据变更历史
- GIS Schema: 50门店位置、10配送区域、100物流轨迹、20热点区域

### app_db_user_grant.sql
业务账号创建和授权脚本（v2.0），包含：
- 创建 app_user_rw 读写账号（适合应用服务）
- 创建 app_user_ro 只读账号（适合报表查询、数据分析）
- 授予 mall、audit、gis 三个 Schema 的相应权限
- 授予函数和存储过程执行权限
- 配置默认权限（适用于未来新建的表）

## 安装步骤

### 前置条件

1. PostgreSQL 12.0 或更高版本
2. 已安装 PostGIS 扩展
3. 如果使用 CentOS/RHEL 系统，请先安装 PostGIS：
   ```bash
   sudo yum install postgis
   ```

### 创建业务账号

使用 postgres 超级用户创建业务账号并授权：

```bash
psql -U postgres -d app_db -f app_db_user_grant.sql
```

脚本将创建两个不同权限级别的业务账号：

| 账号名 | 密码 | 权限级别 | 适用场景 |
|--------|------|---------|---------|
| app_user_rw | AppUserRw@2025 | 读写权限 | 应用服务、业务操作 |
| app_user_ro | AppUserRo@2025 | 只读权限 | 报表查询、数据分析 |

**权限说明：**
- **app_user_rw**：拥有 mall Schema 的 SELECT/INSERT/UPDATE/DELETE 权限，audit 和 gis Schema 的 SELECT 权限
- **app_user_ro**：仅拥有所有 Schema 的 SELECT 权限，无法执行 INSERT/UPDATE/DELETE 操作

### 快速创建和授权（独立 SQL 语句）

如果需要手动创建账号和授权，可以直接在 psql 中执行以下 SQL 语句：

```sql
-- =====================================================
-- 创建 app_user_rw 读写账号
-- =====================================================

-- 1. 创建用户
CREATE USER app_user_rw WITH PASSWORD 'AppUserRw@2025';

-- 2. 授予连接数据库权限
GRANT CONNECT ON DATABASE app_db TO app_user_rw;

-- 3. 授予 Schema 使用权限
GRANT USAGE ON SCHEMA mall TO app_user_rw;
GRANT USAGE ON SCHEMA audit TO app_user_rw;
GRANT USAGE ON SCHEMA gis TO app_user_rw;

-- 4. 授予表权限（mall 读写，audit/gis 只读）
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA mall TO app_user_rw;
GRANT SELECT ON ALL TABLES IN SCHEMA audit TO app_user_rw;
GRANT SELECT ON ALL TABLES IN SCHEMA gis TO app_user_rw;

-- 5. 授予默认权限（适用于未来新建的表）
ALTER DEFAULT PRIVILEGES IN SCHEMA mall GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app_user_rw;
ALTER DEFAULT PRIVILEGES IN SCHEMA audit GRANT SELECT ON TABLES TO app_user_rw;
ALTER DEFAULT PRIVILEGES IN SCHEMA gis GRANT SELECT ON TABLES TO app_user_rw;

-- 6. 授予序列权限
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA mall TO app_user_rw;
ALTER DEFAULT PRIVILEGES IN SCHEMA mall GRANT USAGE, SELECT ON SEQUENCES TO app_user_rw;

-- 7. 授予函数执行权限
GRANT EXECUTE ON FUNCTION public.generate_uuid() TO app_user_rw;
GRANT EXECUTE ON FUNCTION public.calculate_distance(FLOAT, FLOAT, FLOAT, FLOAT) TO app_user_rw;
GRANT EXECUTE ON FUNCTION public.is_point_in_zone(FLOAT, FLOAT, INTEGER) TO app_user_rw;
GRANT EXECUTE ON FUNCTION public.get_user_total_spent(INTEGER) TO app_user_rw;
GRANT EXECUTE ON FUNCTION public.get_product_avg_rating(INTEGER) TO app_user_rw;

-- 8. 授予存储过程执行权限
GRANT EXECUTE ON PROCEDURE public.clean_expired_orders(INTEGER) TO app_user_rw;
GRANT EXECUTE ON PROCEDURE public.batch_update_stock(INTEGER[], INTEGER[]) TO app_user_rw;
GRANT EXECUTE ON PROCEDURE public.generate_monthly_sales_report(INTEGER, INTEGER) TO app_user_rw;
GRANT EXECUTE ON PROCEDURE public.bulk_import_users(INTEGER) TO app_user_rw;

-- 9. 授予视图查询权限
GRANT SELECT ON ALL TABLES IN SCHEMA public TO app_user_rw;

-- =====================================================
-- 创建 app_user_ro 只读账号
-- =====================================================

-- 1. 创建用户
CREATE USER app_user_ro WITH PASSWORD 'AppUserRo@2025';

-- 2. 授予连接数据库权限
GRANT CONNECT ON DATABASE app_db TO app_user_ro;

-- 3. 授予 Schema 使用权限
GRANT USAGE ON SCHEMA mall TO app_user_ro;
GRANT USAGE ON SCHEMA audit TO app_user_ro;
GRANT USAGE ON SCHEMA gis TO app_user_ro;

-- 4. 授予表权限（只读）
GRANT SELECT ON ALL TABLES IN SCHEMA mall TO app_user_ro;
GRANT SELECT ON ALL TABLES IN SCHEMA audit TO app_user_ro;
GRANT SELECT ON ALL TABLES IN SCHEMA gis TO app_user_ro;

-- 5. 授予默认权限（适用于未来新建的表）
ALTER DEFAULT PRIVILEGES IN SCHEMA mall GRANT SELECT ON TABLES TO app_user_ro;
ALTER DEFAULT PRIVILEGES IN SCHEMA audit GRANT SELECT ON TABLES TO app_user_ro;
ALTER DEFAULT PRIVILEGES IN SCHEMA gis GRANT SELECT ON TABLES TO app_user_ro;

-- 6. 授予序列使用权限
GRANT USAGE ON ALL SEQUENCES IN SCHEMA mall TO app_user_ro;
ALTER DEFAULT PRIVILEGES IN SCHEMA mall GRANT USAGE ON SEQUENCES TO app_user_ro;

-- 7. 授予查询相关函数执行权限
GRANT EXECUTE ON FUNCTION public.calculate_distance(FLOAT, FLOAT, FLOAT, FLOAT) TO app_user_ro;
GRANT EXECUTE ON FUNCTION public.is_point_in_zone(FLOAT, FLOAT, INTEGER) TO app_user_ro;
GRANT EXECUTE ON FUNCTION public.get_user_total_spent(INTEGER) TO app_user_ro;
GRANT EXECUTE ON FUNCTION public.get_product_avg_rating(INTEGER) TO app_user_ro;

-- 8. 授予视图查询权限
GRANT SELECT ON ALL TABLES IN SCHEMA public TO app_user_ro;

-- =====================================================
-- 验证账号创建
-- =====================================================

-- 查看创建的用户
SELECT rolname, rolcreater, rolcanlogin 
FROM pg_roles 
WHERE rolname IN ('app_user_rw', 'app_user_ro');

-- 查看连接权限
SELECT * FROM pg_database_acl WHERE grantee = 'app_user_rw';
SELECT * FROM pg_database_acl WHERE grantee = 'app_user_ro';

-- 查看表权限
SELECT table_schema, table_name, privilege_type, grantee
FROM information_schema.table_privileges 
WHERE grantee IN ('app_user_rw', 'app_user_ro')
ORDER BY grantee, table_schema, table_name;
```

### 方法一：使用 psql 命令行

#### 1. 导入数据库结构
```bash
psql -U postgres -f app_db_schema_v2.sql
```

#### 2. 导入示例数据
```bash
psql -U postgres -d app_db -f app_db_data_v2.sql
```

#### 3. 创建业务账号并授权
```bash
psql -U postgres -d app_db -f app_db_user_grant.sql
```

### 方法二：使用 pgAdmin 图形化工具

#### 1. 导入结构脚本
- 打开 pgAdmin
- 连接到 PostgreSQL 服务器
- 点击 `Tools` → `Query Tool`
- 点击 `Open File` 按钮，选择 `app_db_schema_v2.sql`
- 点击 `Execute`（闪电图标）执行脚本
- 等待执行完成，检查 `Messages` 面板

#### 2. 导入数据脚本
- 在 Query Tool 中点击 `Open File`
- 选择并打开 `app_db_data_v2.sql` 文件
- 点击 `Execute` 按钮执行脚本
- 等待执行完成（可能需要几分钟）

#### 3. 创建业务账号并授权
- 在 Query Tool 中点击 `Open File`
- 选择并打开 `app_db_user_grant.sql` 文件
- 点击 `Execute` 按钮执行脚本
- 查看执行结果中的账号信息和权限说明

## 验证安装

### 查看 Schema
```sql
\dn
```

预期结果：
```
      List of schemas
  Name  |  Owner   
--------+----------
 audit  | postgres
 gis    | postgres
 mall   | postgres
 public | postgres
 topology| postgres
```

### 查看所有表（按 Schema）
```sql
\dt mall.*
\dt audit.*
\dt gis.*
```

预期结果：
```
MALL Schema (10张表):
- users
- addresses
- user_profiles
- categories
- products
- product_images
- orders
- order_items
- order_status_history
- payments
- reviews

AUDIT Schema (3张表):
- audit_logs
- login_logs
- data_change_history

GIS Schema (4张表):
- store_locations
- delivery_zones
- logistics_tracks
- hotspot_areas
```

### 测试业务账号连接

**1. 测试 app_user_rw（读写账号）**

```bash
# 使用 app_user_rw 连接测试
psql -h localhost -U app_user_rw -d app_db
# 密码: AppUserRw@2025
```

**2. 测试 app_user_ro（只读账号）**

```bash
# 使用 app_user_ro 连接测试
psql -h localhost -U app_user_ro -d app_db
# 密码: AppUserRo@2025
```

**使用 pgAdmin 连接：**

| 配置项 | app_user_rw | app_user_ro |
|--------|-------------|-------------|
| 主机名 | localhost | localhost |
| 端口 | 5432 | 5432 |
| 数据库 | app_db | app_db |
| 用户名 | app_user_rw | app_user_ro |
| 密码 | AppUserRw@2025 | AppUserRo@2025 |

### 验证 app_user 权限

**验证 app_user_rw 权限：**

```sql
-- 使用 app_user_rw 连接
psql -h localhost -U app_user_rw -d app_db

-- 验证 Schema 使用权限
SELECT * FROM information_schema.schema_privileges 
WHERE grantee = 'app_user_rw';

-- 验证表权限
SELECT table_schema, table_name, privilege_type 
FROM information_schema.table_privileges 
WHERE grantee = 'app_user_rw'
ORDER BY table_schema, table_name;

-- 测试查询权限
SELECT COUNT(*) FROM mall.users;
SELECT COUNT(*) FROM audit.audit_logs;
SELECT COUNT(*) FROM gis.store_locations;

-- 测试写入权限（仅 app_user_rw）
INSERT INTO mall.addresses (user_id, province, city, district, address, postal_code, is_default)
VALUES (1, '北京市', '北京市', '朝阳区', '测试地址', '100000', false);

-- 删除测试数据
DELETE FROM mall.addresses WHERE address = '测试地址';
```

**验证 app_user_ro 权限：**

```sql
-- 使用 app_user_ro 连接
psql -h localhost -U app_user_ro -d app_db

-- 验证 Schema 使用权限
SELECT * FROM information_schema.schema_privileges 
WHERE grantee = 'app_user_ro';

-- 验证表权限
SELECT table_schema, table_name, privilege_type 
FROM information_schema.table_privileges 
WHERE grantee = 'app_user_ro'
ORDER BY table_schema, table_name;

-- 测试查询权限
SELECT COUNT(*) FROM mall.users;
SELECT COUNT(*) FROM audit.audit_logs;
SELECT COUNT(*) FROM gis.store_locations;
```

### 业务账号权限对比

| Schema | 表 | app_user_rw | app_user_ro |
|--------|-----|-------------|-------------|
| **mall** | users | SELECT/INSERT/UPDATE/DELETE | SELECT |
| | addresses | SELECT/INSERT/UPDATE/DELETE | SELECT |
| | user_profiles | SELECT/INSERT/UPDATE/DELETE | SELECT |
| | categories | SELECT/INSERT/UPDATE/DELETE | SELECT |
| | products | SELECT/INSERT/UPDATE/DELETE | SELECT |
| | product_images | SELECT/INSERT/UPDATE/DELETE | SELECT |
| | orders | SELECT/INSERT/UPDATE/DELETE | SELECT |
| | order_items | SELECT/INSERT/UPDATE/DELETE | SELECT |
| | order_status_history | SELECT/INSERT/UPDATE/DELETE | SELECT |
| | payments | SELECT/INSERT/UPDATE/DELETE | SELECT |
| | reviews | SELECT/INSERT/UPDATE/DELETE | SELECT |
| **audit** | 所有表 | SELECT（只读） | SELECT（只读） |
| **gis** | 所有表 | SELECT（只读） | SELECT（只读） |
| **序列** | mall 序列 | USAGE/SELECT | USAGE |
| **函数** | public 函数 | EXECUTE | EXECUTE（仅查询相关） |
| **存储过程** | public 存储过程 | EXECUTE | 无 |

**权限说明：**
- **app_user_rw**：适用于应用服务层，可以进行业务数据的增删改查操作，但审计日志和地理信息只读
- **app_user_ro**：适用于报表查询、数据分析、BI 工具等只读场景，确保数据安全

### 查看数据统计
```sql
SELECT 'MALL Schema' AS Schema, '用户数量' AS 统计项, COUNT(*) AS 数量 FROM mall.users
UNION ALL
SELECT 'MALL Schema', '地址数量', COUNT(*) FROM mall.addresses
UNION ALL
SELECT 'MALL Schema', '商品数量', COUNT(*) FROM mall.products
UNION ALL
SELECT 'MALL Schema', '订单数量', COUNT(*) FROM mall.orders
UNION ALL
SELECT 'MALL Schema', '订单项数量', COUNT(*) FROM mall.order_items
UNION ALL
SELECT 'MALL Schema', '支付数量', COUNT(*) FROM mall.payments
UNION ALL
SELECT 'MALL Schema', '评论数量', COUNT(*) FROM mall.reviews
UNION ALL
SELECT 'AUDIT Schema', '审计日志数量', COUNT(*) FROM audit.audit_logs
UNION ALL
SELECT 'AUDIT Schema', '登录日志数量', COUNT(*) FROM audit.login_logs
UNION ALL
SELECT 'AUDIT Schema', '数据变更历史数量', COUNT(*) FROM audit.data_change_history
UNION ALL
SELECT 'GIS Schema', '门店位置数量', COUNT(*) FROM gis.store_locations
UNION ALL
SELECT 'GIS Schema', '配送区域数量', COUNT(*) FROM gis.delivery_zones
UNION ALL
SELECT 'GIS Schema', '物流轨迹数量', COUNT(*) FROM gis.logistics_tracks
UNION ALL
SELECT 'GIS Schema', '热点区域数量', COUNT(*) FROM gis.hotspot_areas
ORDER BY Schema, 数量 DESC;
```

## Schema 详细说明

### MALL Schema - 电商核心

**功能**：包含所有电商相关的表、视图、函数和触发器

**核心表**：

| 表名 | 说明 | 记录数 |
|-----|------|--------|
| users | 用户表 | 100,000 |
| addresses | 地址表 | 400,184 |
| user_profiles | 用户资料表 | 50,000 |
| categories | 分类表 | 35 |
| products | 商品表 | 73 |
| product_images | 商品图片表 | 73 |
| orders | 订单表 | 100,000 |
| order_items | 订单项表 | 175,391 |
| order_status_history | 订单状态历史表 | 约80,000 |
| payments | 支付表 | 50,000 |
| reviews | 评论表 | 50,000 |

**视图**：
- `mall.order_summary`：订单汇总视图
- `mall.product_summary`：商品汇总视图

**使用示例**：
```sql
-- 查询用户
SELECT * FROM mall.users LIMIT 10;

-- 查询商品汇总
SELECT * FROM mall.product_summary LIMIT 10;

-- 查询订单汇总
SELECT * FROM mall.order_summary LIMIT 10;
```

### AUDIT Schema - 审计日志

**功能**：用于记录数据库操作日志和审计信息，支持数据追踪和安全审计

**核心表**：

| 表名 | 说明 | 记录数 |
|-----|------|--------|
| audit_logs | 审计日志表 | 1,000 |
| login_logs | 用户登录日志表 | 5,000 |
| data_change_history | 数据变更历史表 | 2,000 |

**使用示例**：
```sql
-- 查询最近的审计日志
SELECT * FROM audit.audit_logs 
ORDER BY operation_time DESC 
LIMIT 10;

-- 查询用户登录记录
SELECT * FROM audit.login_logs 
WHERE user_id = 1 
ORDER BY login_time DESC;

-- 查询数据变更历史
SELECT * FROM audit.data_change_history 
WHERE table_name = 'mall.users' 
ORDER BY change_time DESC;
```

### GIS Schema - 地理位置

**功能**：包含 PostGIS 扩展和地理位置相关表，支持空间查询和地理计算

**核心表**：

| 表名 | 说明 | 记录数 |
|-----|------|--------|
| store_locations | 门店位置表 | 50 |
| delivery_zones | 配送区域表 | 10 |
| logistics_tracks | 物流轨迹表 | 100 |
| hotspot_areas | 热点区域表 | 20 |

**PostGIS 功能**：
- 空间索引（GIST 索引）
- 空间查询支持
- 地理计算功能

**使用示例**：
```sql
-- 查询门店位置（带坐标）
SELECT store_name, address, ST_AsText(geometry) AS coordinates 
FROM gis.store_locations 
WHERE is_active = true;

-- 查询附近的门店（半径5公里）
SELECT store_name, address, 
       ST_Distance(geometry, ST_MakePoint(116.4, 39.9)::geography) / 1000 AS distance_km
FROM gis.store_locations
WHERE ST_DWithin(geometry, ST_MakePoint(116.4, 39.9)::geography, 5000)
ORDER BY distance_km;

-- 使用自定义函数计算两点距离
SELECT calculate_distance(39.9, 116.4, 31.2, 121.5) AS distance_km;

-- 判断点是否在配送区域内
SELECT is_point_in_zone(39.9, 116.4, 1) AS in_zone;
```

## 常见查询

### 1. 查询用户统计（MALL）
```sql
SELECT
    COUNT(*) AS 总用户数,
    COUNT(CASE WHEN is_active = true THEN 1 END) AS 活跃用户数,
    COUNT(CASE WHEN created_at > CURRENT_DATE - INTERVAL '30 days' THEN 1 END) AS 近30天注册用户
FROM mall.users;
```

### 2. 查询商品统计（MALL）
```sql
SELECT
    c.name AS 分类名称,
    COUNT(p.product_id) AS 商品数量,
    AVG(p.price) AS 平均价格,
    SUM(p.stock_quantity) AS 总库存
FROM mall.categories c
LEFT JOIN mall.products p ON c.category_id = p.category_id
WHERE c.is_active = true
GROUP BY c.category_id, c.name
ORDER BY 商品数量 DESC;
```

### 3. 查询订单统计（MALL）
```sql
SELECT
    status AS 订单状态,
    COUNT(*) AS 订单数量,
    SUM(total_amount) AS 总金额,
    AVG(total_amount) AS 平均金额
FROM mall.orders
GROUP BY status
ORDER BY 订单数量 DESC;
```

### 4. 查询销售排行榜（MALL）
```sql
SELECT
    p.product_id AS 商品ID,
    p.name AS 商品名称,
    c.name AS 分类名称,
    SUM(oi.quantity) AS 销售数量,
    SUM(oi.subtotal) AS 销售金额
FROM mall.order_items oi
INNER JOIN mall.products p ON oi.product_id = p.product_id
INNER JOIN mall.categories c ON p.category_id = c.category_id
GROUP BY p.product_id, p.name, c.name
ORDER BY 销售金额 DESC
LIMIT 20;
```

### 5. 查询用户消费排行（MALL）
```sql
SELECT
    u.username AS 用户名,
    u.email AS 邮箱,
    COUNT(DISTINCT o.order_id) AS 订单数量,
    SUM(o.total_amount) AS 总消费金额,
    MAX(o.created_at) AS 最后下单时间
FROM mall.users u
INNER JOIN mall.orders o ON u.user_id = o.user_id
GROUP BY u.user_id, u.username, u.email
ORDER BY 总消费金额 DESC
LIMIT 10;
```

### 6. 查询审计日志（AUDIT）
```sql
SELECT 
    al.*,
    u.username AS 操作用户
FROM audit.audit_logs al
LEFT JOIN mall.users u ON al.user_id = u.user_id
WHERE al.operation_time > CURRENT_TIMESTAMP - INTERVAL '7 days'
ORDER BY al.operation_time DESC
LIMIT 100;
```

### 7. 查询用户登录历史（AUDIT）
```sql
SELECT 
    ll.*,
    u.username
FROM audit.login_logs ll
INNER JOIN mall.users u ON ll.user_id = u.user_id
WHERE ll.login_time > CURRENT_TIMESTAMP - INTERVAL '30 days'
ORDER BY ll.login_time DESC;
```

### 8. 查询附近的门店（GIS）
```sql
SELECT 
    store_name,
    address,
    phone,
    business_hours,
    ST_Distance(geometry, ST_MakePoint(116.4, 39.9)::geography) / 1000 AS distance_km
FROM gis.store_locations
WHERE is_active = true
  AND ST_DWithin(geometry, ST_MakePoint(116.4, 39.9)::geography, 10000) -- 10公里范围内
ORDER BY distance_km
LIMIT 10;
```

## 函数和存储过程

### 函数

| 函数名 | 说明 | 所在 Schema |
|-------|------|------------|
| generate_uuid() | 生成UUID | public |
| calculate_distance() | 计算两点之间距离 | public |
| is_point_in_zone() | 判断点是否在区域内 | public |
| get_user_total_spent() | 获取用户总消费金额 | public |
| get_product_avg_rating() | 获取商品平均评分 | public |

**调用示例**：
```sql
-- 生成UUID
SELECT generate_uuid();

-- 计算两点距离（北京到上海）
SELECT calculate_distance(39.9, 116.4, 31.2, 121.5);

-- 判断点是否在配送区域
SELECT is_point_in_zone(39.9, 116.4, 1);

-- 获取用户总消费金额
SELECT get_user_total_spent(1);

-- 获取商品平均评分
SELECT get_product_avg_rating(10);
```

### 存储过程

| 存储过程名 | 说明 | 所在 Schema |
|-----------|------|------------|
| clean_expired_orders() | 清理过期订单 | public |
| batch_update_stock() | 批量更新商品库存 | public |
| generate_monthly_sales_report() | 生成月度销售报表 | public |
| bulk_import_users() | 批量导入用户（测试用） | public |

**调用示例**：
```sql
-- 清理30天前的过期订单
CALL clean_expired_orders(30);

-- 批量更新库存
CALL batch_update_stock(ARRAY[1,2,3], ARRAY[10,5,8]);

-- 生成2024年12月的销售报表
CALL generate_monthly_sales_report(2024, 12);

-- 批量导入100个测试用户
CALL bulk_import_users(100);
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
WHERE schemaname IN ('mall', 'audit', 'gis')
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
    relname AS 表名,
    indexrelname AS 索引名,
    idx_scan AS 扫描次数,
    idx_tup_read AS 读取行数
FROM pg_stat_user_indexes
WHERE schemaname IN ('mall', 'audit', 'gis')
ORDER BY idx_scan DESC;

```

### 4. 查看空间索引使用情况（GIS）
```sql
SELECT
    schemaname AS Schema,
    relname AS 表名,
    indexrelname AS 索引名,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes
WHERE schemaname = 'gis'
  AND indexrelname LIKE '%geometry%';
```

## 清理数据

### 清理 MALL Schema 数据（谨慎使用）
```sql
TRUNCATE TABLE mall.order_status_history CASCADE;
TRUNCATE TABLE mall.payments CASCADE;
TRUNCATE TABLE mall.reviews CASCADE;
TRUNCATE TABLE mall.order_items CASCADE;
TRUNCATE TABLE mall.orders CASCADE;
TRUNCATE TABLE mall.product_images CASCADE;
TRUNCATE TABLE mall.products CASCADE;
TRUNCATE TABLE mall.user_profiles CASCADE;
TRUNCATE TABLE mall.addresses CASCADE;
TRUNCATE TABLE mall.users CASCADE;
TRUNCATE TABLE mall.categories CASCADE;
```

### 清理 AUDIT Schema 数据
```sql
TRUNCATE TABLE audit.data_change_history CASCADE;
TRUNCATE TABLE audit.login_logs CASCADE;
TRUNCATE TABLE audit.audit_logs CASCADE;
```

### 清理 GIS Schema 数据
```sql
TRUNCATE TABLE gis.hotspot_areas CASCADE;
TRUNCATE TABLE gis.logistics_tracks CASCADE;
TRUNCATE TABLE gis.delivery_zones CASCADE;
TRUNCATE TABLE gis.store_locations CASCADE;
```

### 删除数据库
```bash
psql -U postgres -c "DROP DATABASE app_db;"
```

### 撤销业务账号权限并删除用户

**撤销 app_user_rw 权限并删除：**

```sql
-- 使用 postgres 用户执行
-- 1. 撤销所有权限
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA mall FROM app_user_rw;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA audit FROM app_user_rw;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA gis FROM app_user_rw;
REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA mall FROM app_user_rw;
REVOKE USAGE ON SCHEMA mall FROM app_user_rw;
REVOKE USAGE ON SCHEMA audit FROM app_user_rw;
REVOKE USAGE ON SCHEMA gis FROM app_user_rw;
REVOKE EXECUTE ON ALL FUNCTIONS IN SCHEMA public FROM app_user_rw;
REVOKE EXECUTE ON ALL PROCEDURES IN SCHEMA public FROM app_user_rw;
REVOKE CONNECT ON DATABASE app_db FROM app_user_rw;

-- 2. 删除用户
DROP USER app_user_rw;
```

**撤销 app_user_ro 权限并删除：**

```sql
-- 使用 postgres 用户执行
-- 1. 撤销所有权限
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA mall FROM app_user_ro;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA audit FROM app_user_ro;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA gis FROM app_user_ro;
REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA mall FROM app_user_ro;
REVOKE USAGE ON SCHEMA mall FROM app_user_ro;
REVOKE USAGE ON SCHEMA audit FROM app_user_ro;
REVOKE USAGE ON SCHEMA gis FROM app_user_ro;
REVOKE EXECUTE ON ALL FUNCTIONS IN SCHEMA public FROM app_user_ro;
REVOKE CONNECT ON DATABASE app_db FROM app_user_ro;

-- 2. 删除用户
DROP USER app_user_ro;
```

## 常见问题

### 1. PostGIS 扩展未安装
**问题**：ERROR: could not open extension control file

**解决方案**：
```bash
# CentOS/RHEL
sudo yum install postgis postgis-topology

# Ubuntu/Debian
sudo apt-get install postgresql-<version>-postgis-<version>
```

### 2. 插入数据时出现编码错误
**问题**：ERROR: character with byte sequence 0x...

**解决方案**：
```bash
export PGCLIENTENCODING=UTF8
psql -U postgres -d app_db -f app_db_data_v2.sql
```

### 3. 内存不足
**问题**：插入大量数据时内存不足

**解决方案**：
```bash
psql -U postgres -d app_db -v client_min_messages=warning -f app_db_data_v2.sql
```

### 4. 执行时间过长
**问题**：数据插入脚本执行时间过长

**解决方案**：
- 在执行前关闭自动提交（autocommit off）
- 使用批量插入而非单条插入
- 增加 maintenance_work_mem 参数
```sql
SET maintenance_work_mem = '256MB';
```

### 5. 空间查询性能慢
**问题**：GIS 相关查询执行较慢

**解决方案**：
```sql
-- 确保空间索引存在
SELECT indexname FROM pg_indexes
WHERE schemaname = 'gis' AND indexname LIKE '%geometry%';

-- 重建空间索引
REINDEX INDEX gis.idx_store_locations_geometry;

-- 更新统计信息
ANALYZE gis.store_locations;
```

### 6. 业务账号无法连接数据库
**问题**：连接失败，提示认证失败

**解决方案**：
```sql
-- 检查用户是否存在
SELECT rolname FROM pg_roles WHERE rolname IN ('app_user_rw', 'app_user_ro');

-- 如果不存在，重新创建
CREATE USER app_user_rw WITH PASSWORD 'AppUserRw@2025';
CREATE USER app_user_ro WITH PASSWORD 'AppUserRo@2025';

-- 检查 pg_hba.conf 配置
-- 确保包含以下配置：
# IPv4 local connections:
host    app_db          app_user_rw      127.0.0.1/32            md5
host    app_db          app_user_ro      127.0.0.1/32            md5
host    app_db          app_user_rw      192.168.0.0/16          md5
host    app_db          app_user_ro      192.168.0.0/16          md5

-- 修改后重启 PostgreSQL
sudo systemctl restart postgresql
```

### 7. 业务账号权限不足
**问题**：无法查询某些表或执行某些操作

**解决方案**：
```sql
-- 使用 postgres 用户重新授权
psql -U postgres -d app_db

-- 重新授予 app_user_rw 权限
GRANT USAGE ON SCHEMA mall TO app_user_rw;
GRANT USAGE ON SCHEMA audit TO app_user_rw;
GRANT USAGE ON SCHEMA gis TO app_user_rw;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA mall TO app_user_rw;
GRANT SELECT ON ALL TABLES IN SCHEMA audit TO app_user_rw;
GRANT SELECT ON ALL TABLES IN SCHEMA gis TO app_user_rw;

-- 重新授予 app_user_ro 权限
GRANT USAGE ON SCHEMA mall TO app_user_ro;
GRANT USAGE ON SCHEMA audit TO app_user_ro;
GRANT USAGE ON SCHEMA gis TO app_user_ro;
GRANT SELECT ON ALL TABLES IN SCHEMA mall TO app_user_ro;
GRANT SELECT ON ALL TABLES IN SCHEMA audit TO app_user_ro;
GRANT SELECT ON ALL TABLES IN SCHEMA gis TO app_user_ro;
```

### 8. 修改业务账号密码
**问题**：需要修改业务账号密码

**解决方案**：
```sql
-- 方法一：使用 postgres 用户修改
ALTER USER app_user_rw WITH PASSWORD 'NewPasswordRw@2025';
ALTER USER app_user_ro WITH PASSWORD 'NewPasswordRo@2025';

-- 方法二：使用 psql 命令行
psql -U postgres -c "ALTER USER app_user_rw WITH PASSWORD 'NewPasswordRw@2025';"
psql -U postgres -c "ALTER USER app_user_ro WITH PASSWORD 'NewPasswordRo@2025';"
```

## 版本对比

### v1.0 vs v2.0

| 特性 | v1.0 | v2.0 |
|-----|-------|------|
| Schema 数量 | 1 (public) | 3 (mall, audit, gis) |
| 表数量 | 10 | 17 |
| 索引类型 | 普通 | 普通 + PostGIS 空间索引 |
| 视图数量 | 2 | 2 |
| 函数数量 | 0 | 7 |
| 存储过程数量 | 0 | 4 |
| 触发器数量 | 5 | 5 |
| 地理位置 | 无 | 有（PostGIS 支持）|
| 审计日志 | 无 | 有（3张表） |
| 空间查询 | 不支持 | 支持（GIST 索引） |

## 版本信息

- **版本号**：v2.0.0
- **创建日期**：2025-12-25
- **PostgreSQL版本**：建议使用 12.0 或更高版本
- **PostGIS版本**：建议使用 3.0 或更高版本

## 技术支持

如有问题，请参考文档或提交 Issue。

---

**文档结束**
