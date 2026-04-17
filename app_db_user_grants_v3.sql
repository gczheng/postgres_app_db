-- =====================================================
-- app_db 业务账号创建和授权脚本 v3.0
-- 用途：为 app_db 数据库创建不同权限级别的业务账号
-- 执行方式：psql -U postgres -d app_db -f app_db_user_grants_v3.sql
-- 创建日期：2026-04-17
-- 重构说明：按照实战案例规范，采用基于角色的权限管理方式
-- =====================================================
-- [postgres] (超级管理员 - 封存/慎用)
--      |
--      +-- [mall_owner] (业务所有者 - DDL操作)
--      |         ^
--      |         | (GRANT mall_owner TO dbadmin)
--      |         |
--      |    [dbadmin] (个人账号)
--      |
--      +-- [read_write_role] (读写角色 - 只有DML)
--      |         ^
--      |         |
--      |    [app_user_rw] (应用程序账号)
--      |
--      +-- [read_only_role] (只读角色 - 只有SELECT)
--                ^
--                |
--           [app_user_ro] (报表账号)
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
-- =====================================================

-- =====================================================
-- 1. 业务所有者(Schema/Object Owner)
-- 用途: 用于执行 DDL 操作(建表、修改表结构、创建索引)
-- =====================================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mall_owner') THEN
        CREATE ROLE mall_owner WITH LOGIN PASSWORD 'MallOwner@2026';
        RAISE NOTICE '业务所有者角色 mall_owner 已创建';
    ELSE
        RAISE NOTICE '业务所有者角色 mall_owner 已存在，跳过创建';
    END IF;
END $$;

-- 确保 Schema 存在并指定所有者
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_namespace WHERE nspname = 'mall') THEN
        EXECUTE 'CREATE SCHEMA mall AUTHORIZATION mall_owner';
        RAISE NOTICE 'Mall Schema 已创建并指定所有者';
    ELSE
        EXECUTE 'ALTER SCHEMA mall OWNER TO mall_owner';
        RAISE NOTICE 'Mall Schema 所有者已更新为 mall_owner';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_namespace WHERE nspname = 'audit') THEN
        EXECUTE 'CREATE SCHEMA audit AUTHORIZATION mall_owner';
        RAISE NOTICE 'Audit Schema 已创建并指定所有者';
    ELSE
        EXECUTE 'ALTER SCHEMA audit OWNER TO mall_owner';
        RAISE NOTICE 'Audit Schema 所有者已更新为 mall_owner';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_namespace WHERE nspname = 'gis') THEN
        EXECUTE 'CREATE SCHEMA gis AUTHORIZATION mall_owner';
        RAISE NOTICE 'GIS Schema 已创建并指定所有者';
    ELSE
        EXECUTE 'ALTER SCHEMA gis OWNER TO mall_owner';
        RAISE NOTICE 'GIS Schema 所有者已更新为 mall_owner';
    END IF;
END $$;

-- =====================================================
-- 2. 角色(Role)创建
-- 用途: 基于角色的权限管理，方便权限批量分配
-- =====================================================

-- 2.1 读写角色 (仅 DML 权限)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'read_write_role') THEN
        CREATE ROLE read_write_role;
        RAISE NOTICE '读写角色 read_write_role 已创建';
    ELSE
        RAISE NOTICE '读写角色 read_write_role 已存在，跳过创建';
    END IF;
END $$;

-- 2.2 只读角色
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'read_only_role') THEN
        CREATE ROLE read_only_role;
        RAISE NOTICE '只读角色 read_only_role 已创建';
    ELSE
        RAISE NOTICE '只读角色 read_only_role 已存在，跳过创建';
    END IF;
END $$;

-- =====================================================
-- 3. 角色权限分配
-- =====================================================

-- 3.1 读写角色权限
-- 授予 Schema 使用权限
GRANT USAGE ON SCHEMA mall TO read_write_role;
GRANT USAGE ON SCHEMA audit TO read_write_role;
GRANT USAGE ON SCHEMA gis TO read_write_role;

-- 授予表权限（mall 读写，audit/gis 只读）
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA mall TO read_write_role;
GRANT SELECT ON ALL TABLES IN SCHEMA audit TO read_write_role;
GRANT SELECT ON ALL TABLES IN SCHEMA gis TO read_write_role;

-- 授予默认权限（适用于未来新建的表）
ALTER DEFAULT PRIVILEGES FOR ROLE mall_owner IN SCHEMA mall GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO read_write_role;
ALTER DEFAULT PRIVILEGES FOR ROLE mall_owner IN SCHEMA audit GRANT SELECT ON TABLES TO read_write_role;
ALTER DEFAULT PRIVILEGES FOR ROLE mall_owner IN SCHEMA gis GRANT SELECT ON TABLES TO read_write_role;

-- 授予序列权限
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA mall TO read_write_role;
ALTER DEFAULT PRIVILEGES FOR ROLE mall_owner IN SCHEMA mall GRANT USAGE, SELECT ON SEQUENCES TO read_write_role;

-- 授予函数执行权限
GRANT EXECUTE ON FUNCTION mall.get_user_total_spent(INTEGER) TO read_write_role;
GRANT EXECUTE ON FUNCTION mall.get_product_avg_rating(INTEGER) TO read_write_role;
GRANT EXECUTE ON FUNCTION gis.calculate_distance(FLOAT, FLOAT, FLOAT, FLOAT) TO read_write_role;
GRANT EXECUTE ON FUNCTION gis.is_point_in_zone(FLOAT, FLOAT, INTEGER) TO read_write_role;
GRANT EXECUTE ON FUNCTION public.generate_uuid() TO read_write_role;

-- 授予存储过程执行权限
GRANT EXECUTE ON PROCEDURE mall.clean_expired_orders(INTEGER) TO read_write_role;
GRANT EXECUTE ON PROCEDURE mall.batch_update_stock(INTEGER[], INTEGER[]) TO read_write_role;
GRANT EXECUTE ON PROCEDURE mall.generate_monthly_sales_report(INTEGER, INTEGER) TO read_write_role;
GRANT EXECUTE ON PROCEDURE mall.bulk_import_users(INTEGER) TO read_write_role;

-- 3.2 只读角色权限
-- 授予 Schema 使用权限
GRANT USAGE ON SCHEMA mall TO read_only_role;
GRANT USAGE ON SCHEMA audit TO read_only_role;
GRANT USAGE ON SCHEMA gis TO read_only_role;

-- 授予表权限（只读）
GRANT SELECT ON ALL TABLES IN SCHEMA mall TO read_only_role;
GRANT SELECT ON ALL TABLES IN SCHEMA audit TO read_only_role;
GRANT SELECT ON ALL TABLES IN SCHEMA gis TO read_only_role;

-- 授予默认权限（适用于未来新建的表）
ALTER DEFAULT PRIVILEGES FOR ROLE mall_owner IN SCHEMA mall GRANT SELECT ON TABLES TO read_only_role;
ALTER DEFAULT PRIVILEGES FOR ROLE mall_owner IN SCHEMA audit GRANT SELECT ON TABLES TO read_only_role;
ALTER DEFAULT PRIVILEGES FOR ROLE mall_owner IN SCHEMA gis GRANT SELECT ON TABLES TO read_only_role;

-- 授予序列使用权限
GRANT USAGE ON ALL SEQUENCES IN SCHEMA mall TO read_only_role;
ALTER DEFAULT PRIVILEGES FOR ROLE mall_owner IN SCHEMA mall GRANT USAGE ON SEQUENCES TO read_only_role;

-- 授予查询相关函数执行权限
GRANT EXECUTE ON FUNCTION mall.get_user_total_spent(INTEGER) TO read_only_role;
GRANT EXECUTE ON FUNCTION mall.get_product_avg_rating(INTEGER) TO read_only_role;
GRANT EXECUTE ON FUNCTION gis.calculate_distance(FLOAT, FLOAT, FLOAT, FLOAT) TO read_only_role;
GRANT EXECUTE ON FUNCTION gis.is_point_in_zone(FLOAT, FLOAT, INTEGER) TO read_only_role;

-- =====================================================
-- 4. 应用程序账号(Application RW User)
-- 用途: 后端服务连接数据库使用的账号
-- =====================================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'app_user_rw') THEN
        CREATE USER app_user_rw WITH PASSWORD 'AppUserRw@2026';
        -- 将读写角色赋予应用账号
        GRANT read_write_role TO app_user_rw;
        -- 设置默认搜索路径
        ALTER USER app_user_rw SET search_path = mall, audit, gis, public;
        RAISE NOTICE '应用程序账号 app_user_rw 已创建并赋予读写权限';
    ELSE
        -- 确保角色已赋予
        GRANT read_write_role TO app_user_rw;
        ALTER USER app_user_rw SET search_path = mall, audit, gis, public;
        RAISE NOTICE '应用程序账号 app_user_rw 已存在，确保权限已更新';
    END IF;
END $$;

-- 授予连接数据库权限
GRANT CONNECT ON DATABASE app_db TO app_user_rw;

-- =====================================================
-- 5. 只读账号(Read-Only / Reporting User)
-- 用途: 数据分析师、BI 报表工具、开发人员排查问题
-- =====================================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'app_user_ro') THEN
        CREATE USER app_user_ro WITH PASSWORD 'AppUserRo@2026';
        -- 将只读角色赋予报表账号
        GRANT read_only_role TO app_user_ro;
        -- 设置默认搜索路径
        ALTER USER app_user_ro SET search_path = mall, audit, gis, public;
        RAISE NOTICE '只读账号 app_user_ro 已创建并赋予只读权限';
    ELSE
        -- 确保角色已赋予
        GRANT read_only_role TO app_user_ro;
        ALTER USER app_user_ro SET search_path = mall, audit, gis, public;
        RAISE NOTICE '只读账号 app_user_ro 已存在，确保权限已更新';
    END IF;
END $$;

-- 授予连接数据库权限
GRANT CONNECT ON DATABASE app_db TO app_user_ro;

-- =====================================================
-- 6. 运维监控账号(Monitoring User)
-- 用途: Prometheus (pg_exporter)、Zabbix、PMM 等监控工具
-- =====================================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'monitor_user') THEN
        CREATE USER monitor_user WITH PASSWORD 'Monitor@2026';
        -- 赋予监控特权 (PostgreSQL 10+ 推荐方式)
        GRANT pg_monitor TO monitor_user;
        RAISE NOTICE '运维监控账号 monitor_user 已创建';
    ELSE
        RAISE NOTICE '运维监控账号 monitor_user 已存在，跳过创建';
    END IF;
END $$;

-- 授予连接数据库权限
GRANT CONNECT ON DATABASE app_db TO monitor_user;
GRANT CONNECT ON DATABASE postgres TO monitor_user;

-- =====================================================
-- 7. 复制/备份账号(Replication / Backup User)
-- 用途: 用于主从复制(Streaming Replication)或物理备份(pg_basebackup)
-- =====================================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'repl_user') THEN
        CREATE USER repl_user WITH REPLICATION PASSWORD 'Repl@2026';
        RAISE NOTICE '复制/备份账号 repl_user 已创建';
    ELSE
        RAISE NOTICE '复制/备份账号 repl_user 已存在，跳过创建';
    END IF;
END $$;

-- =====================================================
-- 8. 个人管理账号(Personal Admin Accounts)
-- 用途: 具体的 DBA 或高级运维人员
-- =====================================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'dbadmin') THEN
        CREATE USER dbadmin WITH PASSWORD 'DbAdmin@2026';
        -- 赋予业务 Owner 身份(推荐,可管理业务对象)
        GRANT mall_owner TO dbadmin;
        RAISE NOTICE '个人管理账号 dbadmin 已创建并赋予业务所有者权限';
    ELSE
        -- 确保权限已赋予
        GRANT mall_owner TO dbadmin;
        RAISE NOTICE '个人管理账号 dbadmin 已存在，确保权限已更新';
    END IF;
END $$;

-- 授予连接数据库权限
GRANT CONNECT ON DATABASE app_db TO dbadmin;

-- =====================================================
-- 执行完成
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE '业务账号创建和授权完成！';
    RAISE NOTICE '========================================';
    RAISE NOTICE '账号信息：';
    RAISE NOTICE '  1. mall_owner（业务所有者）';
    RAISE NOTICE '     密码: MallOwner@2026';
    RAISE NOTICE '     权限: 拥有 Schema 所有权，可执行 DDL 操作';
    RAISE NOTICE '     场景: 数据库结构管理、发布变更';
    RAISE NOTICE '';
    RAISE NOTICE '  2. app_user_rw（应用程序账号）';
    RAISE NOTICE '     密码: AppUserRw@2026';
    RAISE NOTICE '     权限: SELECT/INSERT/UPDATE/DELETE';
    RAISE NOTICE '     场景: 应用服务、业务操作';
    RAISE NOTICE '';
    RAISE NOTICE '  3. app_user_ro（只读账号）';
    RAISE NOTICE '     密码: AppUserRo@2026';
    RAISE NOTICE '     权限: SELECT（只读）';
    RAISE NOTICE '     场景: 报表查询、数据分析';
    RAISE NOTICE '';
    RAISE NOTICE '  4. monitor_user（运维监控账号）';
    RAISE NOTICE '     密码: Monitor@2026';
    RAISE NOTICE '     权限: pg_monitor';
    RAISE NOTICE '     场景: 监控工具连接';
    RAISE NOTICE '';
    RAISE NOTICE '  5. repl_user（复制/备份账号）';
    RAISE NOTICE '     密码: Repl@2026';
    RAISE NOTICE '     权限: REPLICATION';
    RAISE NOTICE '     场景: 主从复制、物理备份';
    RAISE NOTICE '';
    RAISE NOTICE '  6. dbadmin（个人管理账号）';
    RAISE NOTICE '     密码: DbAdmin@2026';
    RAISE NOTICE '     权限: 继承 mall_owner 权限';
    RAISE NOTICE '     场景: DBA 日常管理';
    RAISE NOTICE '========================================';
    RAISE NOTICE '权限层级结构：';
    RAISE NOTICE '  [postgres] (超级管理员 - 封存/慎用)';
    RAISE NOTICE '       |';
    RAISE NOTICE '       +-- [mall_owner] (业务所有者 - DDL操作)';
    RAISE NOTICE '       |         ^';
    RAISE NOTICE '       |         | (GRANT mall_owner TO dbadmin)';
    RAISE NOTICE '       |         |';
    RAISE NOTICE '       |    [dbadmin] (个人账号)';
    RAISE NOTICE '       |';
    RAISE NOTICE '       +-- [read_write_role] (读写角色 - 只有DML)';
    RAISE NOTICE '       |         ^';
    RAISE NOTICE '       |         |';
    RAISE NOTICE '       |    [app_user_rw] (应用程序账号)';
    RAISE NOTICE '       |';
    RAISE NOTICE '       +-- [read_only_role] (只读角色 - 只有SELECT)';
    RAISE NOTICE '                 ^';
    RAISE NOTICE '                 |';
    RAISE NOTICE '            [app_user_ro] (报表账号)';
    RAISE NOTICE '========================================';
END $$;
