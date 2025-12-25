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

## 安装步骤

### 前置条件

1. PostgreSQL 12.0 或更高版本
2. 已安装 PostGIS 扩展
3. 如果使用 CentOS/RHEL 系统，请先安装 PostGIS：
   ```bash
   sudo yum install postgis
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
