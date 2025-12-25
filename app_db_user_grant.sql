-- =====================================================
-- app_db 业务账号创建和授权脚本 v2.0
-- 用途：为 app_db 数据库创建不同权限级别的业务账号
-- 执行方式：psql -U postgres -d app_db -f app_db_user_grant.sql
-- 创建日期：2025-12-25
-- =====================================================

-- =====================================================
-- 表结构说明：
-- Mall Schema (10表): users, addresses, user_profiles, categories, products,
--                    product_images, orders, order_items, order_status_history,
--                    payments, reviews
-- Audit Schema (3表): audit_logs, login_logs, data_change_history
-- GIS Schema (4表): store_locations, delivery_zones, logistics_tracks, hotspot_areas
-- 视图 (mall schema): order_summary, product_summary
--
-- 函数分布：
--    - Mall Schema: get_user_total_spent(), get_product_avg_rating()
--    - GIS Schema: calculate_distance(), is_point_in_zone()
--    - Public Schema: generate_uuid()
--
-- 存储过程分布：
--    - Mall Schema: clean_expired_orders(), batch_update_stock(),
--                 generate_monthly_sales_report(), bulk_import_users()
--
-- =====================================================
-- 账号说明：
-- 1. app_user_rw: 读写账号，适合应用服务使用
--    - Mall Schema: SELECT/INSERT/UPDATE/DELETE (10表 + 2视图)
--    - Audit Schema: SELECT (3表)
--    - GIS Schema: SELECT (4表)
--    - 函数执行权限: Mall(2), GIS(2), Public(1)
--    - 存储过程执行权限: Mall(4)
--    - 序列: USAGE/SELECT (mall schema 10个序列)
--
-- 2. app_user_ro: 只读账号，适合报表查询、数据分析使用
--    - Mall Schema: SELECT (10表 + 2视图)
--    - Audit Schema: SELECT (3表)
--    - GIS Schema: SELECT (4表)
--    - 查询函数执行权限: Mall(2), GIS(2)
--    - 序列: USAGE (mall schema)
--    - 无存储过程执行权限
-- =====================================================

-- =====================================================
-- 1. 创建 app_user_rw 读写账号
-- =====================================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'app_user_rw') THEN
        CREATE USER app_user_rw WITH PASSWORD 'AppUserRw@2025';
        RAISE NOTICE '用户 app_user_rw 已创建';
    ELSE
        RAISE NOTICE '用户 app_user_rw 已存在，跳过创建';
    END IF;
END $$;

-- 授予连接数据库权限
GRANT CONNECT ON DATABASE app_db TO app_user_rw;

-- 授予 Schema 使用权限
GRANT USAGE ON SCHEMA mall TO app_user_rw;
GRANT USAGE ON SCHEMA audit TO app_user_rw;
GRANT USAGE ON SCHEMA gis TO app_user_rw;

-- 授予表权限（mall 读写，audit/gis 只读）
-- Mall Schema (10表): users, addresses, user_profiles, categories, products,
--                    product_images, orders, order_items, order_status_history,
--                    payments, reviews
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA mall TO app_user_rw;

-- Audit Schema (3表): audit_logs, login_logs, data_change_history
GRANT SELECT ON ALL TABLES IN SCHEMA audit TO app_user_rw;

-- GIS Schema (4表): store_locations, delivery_zones, logistics_tracks, hotspot_areas
GRANT SELECT ON ALL TABLES IN SCHEMA gis TO app_user_rw;

-- 授予视图权限（mall schema 包含 2 个视图：order_summary, product_summary）
-- 注意：视图通过 ALL TABLES 语句已自动包含 SELECT 权限

-- 授予默认权限（适用于未来新建的表）
ALTER DEFAULT PRIVILEGES IN SCHEMA mall GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app_user_rw;
ALTER DEFAULT PRIVILEGES IN SCHEMA audit GRANT SELECT ON TABLES TO app_user_rw;
ALTER DEFAULT PRIVILEGES IN SCHEMA gis GRANT SELECT ON TABLES TO app_user_rw;

-- 授予序列权限（mall schema 有 10 个序列）
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA mall TO app_user_rw;
ALTER DEFAULT PRIVILEGES IN SCHEMA mall GRANT USAGE, SELECT ON SEQUENCES TO app_user_rw;

-- 授予函数执行权限（mall、gis、public schema）
-- Mall Schema 函数
GRANT EXECUTE ON FUNCTION mall.get_user_total_spent(INTEGER) TO app_user_rw;
GRANT EXECUTE ON FUNCTION mall.get_product_avg_rating(INTEGER) TO app_user_rw;
-- GIS Schema 函数
GRANT EXECUTE ON FUNCTION gis.calculate_distance(FLOAT, FLOAT, FLOAT, FLOAT) TO app_user_rw;
GRANT EXECUTE ON FUNCTION gis.is_point_in_zone(FLOAT, FLOAT, INTEGER) TO app_user_rw;
-- Public Schema 通用函数
GRANT EXECUTE ON FUNCTION public.generate_uuid() TO app_user_rw;

-- 授予存储过程执行权限（mall schema）
GRANT EXECUTE ON PROCEDURE mall.clean_expired_orders(INTEGER) TO app_user_rw;
GRANT EXECUTE ON PROCEDURE mall.batch_update_stock(INTEGER[], INTEGER[]) TO app_user_rw;
GRANT EXECUTE ON PROCEDURE mall.generate_monthly_sales_report(INTEGER, INTEGER) TO app_user_rw;
GRANT EXECUTE ON PROCEDURE mall.bulk_import_users(INTEGER) TO app_user_rw;

DO $$
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'app_user_rw 读写账号配置完成';
    RAISE NOTICE '========================================';
END $$;

-- =====================================================
-- 2. 创建 app_user_ro 只读账号
-- =====================================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'app_user_ro') THEN
        CREATE USER app_user_ro WITH PASSWORD 'AppUserRo@2025';
        RAISE NOTICE '用户 app_user_ro 已创建';
    ELSE
        RAISE NOTICE '用户 app_user_ro 已存在，跳过创建';
    END IF;
END $$;

-- 授予连接数据库权限
GRANT CONNECT ON DATABASE app_db TO app_user_ro;

-- 授予 Schema 使用权限
GRANT USAGE ON SCHEMA mall TO app_user_ro;
GRANT USAGE ON SCHEMA audit TO app_user_ro;
GRANT USAGE ON SCHEMA gis TO app_user_ro;

-- 授予表权限（只读）
-- Mall Schema (10表 + 2视图): users, addresses, user_profiles, categories, products,
--                            product_images, orders, order_items, order_status_history,
--                            payments, reviews, order_summary, product_summary
GRANT SELECT ON ALL TABLES IN SCHEMA mall TO app_user_ro;

-- Audit Schema (3表): audit_logs, login_logs, data_change_history
GRANT SELECT ON ALL TABLES IN SCHEMA audit TO app_user_ro;

-- GIS Schema (4表): store_locations, delivery_zones, logistics_tracks, hotspot_areas
GRANT SELECT ON ALL TABLES IN SCHEMA gis TO app_user_ro;

-- 授予默认权限（适用于未来新建的表）
ALTER DEFAULT PRIVILEGES IN SCHEMA mall GRANT SELECT ON TABLES TO app_user_ro;
ALTER DEFAULT PRIVILEGES IN SCHEMA audit GRANT SELECT ON TABLES TO app_user_ro;
ALTER DEFAULT PRIVILEGES IN SCHEMA gis GRANT SELECT ON TABLES TO app_user_ro;

-- 授予序列使用权限（需要序列权限以支持表查询）
GRANT USAGE ON ALL SEQUENCES IN SCHEMA mall TO app_user_ro;
ALTER DEFAULT PRIVILEGES IN SCHEMA mall GRANT USAGE ON SEQUENCES TO app_user_ro;

-- 授予查询相关函数执行权限（mall、gis schema）
-- 注意：app_user_ro 不需要 generate_uuid() (仅用于写入)
-- Mall Schema 函数
GRANT EXECUTE ON FUNCTION mall.get_user_total_spent(INTEGER) TO app_user_ro;
GRANT EXECUTE ON FUNCTION mall.get_product_avg_rating(INTEGER) TO app_user_ro;
-- GIS Schema 函数
GRANT EXECUTE ON FUNCTION gis.calculate_distance(FLOAT, FLOAT, FLOAT, FLOAT) TO app_user_ro;
GRANT EXECUTE ON FUNCTION gis.is_point_in_zone(FLOAT, FLOAT, INTEGER) TO app_user_ro;

-- 注意：app_user_ro 不授予存储过程执行权限（存储过程用于修改数据）

DO $$
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'app_user_ro 只读账号配置完成';
    RAISE NOTICE '========================================';
END $$;

-- =====================================================
-- 执行完成
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE '业务账号创建和授权完成！';
    RAISE NOTICE '========================================';
    RAISE NOTICE '账号信息：';
    RAISE NOTICE '  1. app_user_rw（读写账号）';
    RAISE NOTICE '     密码: AppUserRw@2025';
    RAISE NOTICE '     权限: SELECT/INSERT/UPDATE/DELETE';
    RAISE NOTICE '     场景: 应用服务、业务操作';
    RAISE NOTICE '';
    RAISE NOTICE '  2. app_user_ro（只读账号）';
    RAISE NOTICE '     密码: AppUserRo@2025';
    RAISE NOTICE '     权限: SELECT（只读）';
    RAISE NOTICE '     场景: 报表查询、数据分析';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Schema 权限分配：';
    RAISE NOTICE '  MALL Schema:';
    RAISE NOTICE '    app_user_rw: SELECT/INSERT/UPDATE/DELETE';
    RAISE NOTICE '    app_user_ro: SELECT（只读）';
    RAISE NOTICE '';
    RAISE NOTICE '  AUDIT Schema:';
    RAISE NOTICE '    app_user_rw: SELECT（只读）';
    RAISE NOTICE '    app_user_ro: SELECT（只读）';
    RAISE NOTICE '';
    RAISE NOTICE '  GIS Schema:';
    RAISE NOTICE '    app_user_rw: SELECT（只读）';
    RAISE NOTICE '    app_user_ro: SELECT（只读）';
    RAISE NOTICE '========================================';
END $$;
