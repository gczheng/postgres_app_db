/*
 * PostgreSQL DBA Architecture Playbook
 * Copyright (c) 2026, gczheng
 * License: PostgreSQL License / MIT
 */

-- =====================================================
-- app_db 业务账号创建和授权脚本 (v3.1.0)
-- 数据库名称: app_db
-- 版本: v3.1.0
-- 用途：为 app_db 数据库创建不同权限级别的业务账号
-- 执行方式：psql -U postgres -d app_db -f app_db_user_grants.sql
-- 创建日期：2026-04-17
-- 修订日期: 2026-06-09
-- 重构说明：按照实战案例规范，采用基于角色的权限管理方式。移除了文件名版本后缀。
-- =====================================================
-- [postgres] (超级管理员 - 封存/慎用)
--      |
--      +-- [role_global_owner] (业务所有权权限组 - DDL操作, NOLOGIN)
--      |         ^                   ^                  ^
--      |         |                   |                  |
--      |  [role_global_dba]    [svc_deploy_owner]    [svc_sqlplat_owner]
--      |         ^               (流水线账号)        (SQL平台账号)
--      |         |
--      |   [pers_dba_owner]
--      |    (个人账号)
--      |
--      +-- [role_global_rw] (全局读写权限组 - 跨库DML)
--      |         ^
--      |         +-------+-------+ (继承底层业务读写组)
--      |
--      +-- [role_mall_rw] (核心读写角色 - 只有DML)
--      |         ^
--      |         |
--      |    [svc_mall_rw] (核心应用账号)
--      |
--      +-- [role_audit_rw] (审计写角色 - 只有INSERT)
--      |         ^
--      |         |
--      |    [svc_audit_rw] (审计账号)
--      |
--      +-- [role_gis_rw] (GIS读写角色)
--      |         ^
--      |         |
--      |    [svc_gis_rw] (GIS账号)
--      |
--      +-- [role_global_ro] (只读角色 - 只有SELECT)
--                ^
--                |
--           [svc_bi_ro] (报表账号)
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
-- 1. 业务所有者权限组(Schema/Object Owner Role)
-- 用途: 用于拥有 DDL 操作权限，但不直接登录
-- =====================================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'role_global_owner') THEN
        CREATE ROLE role_global_owner WITH NOLOGIN;
        COMMENT ON ROLE role_global_owner IS '全局业务所有者权限组，拥有所有核心 Schema 和表的所有权，允许执行 DDL 操作';
        RAISE NOTICE '业务所有者角色 role_global_owner 已创建';
    ELSE
        COMMENT ON ROLE role_global_owner IS '全局业务所有者权限组，拥有所有核心 Schema 和表的所有权，允许执行 DDL 操作';
        RAISE NOTICE '业务所有者角色 role_global_owner 已存在，跳过创建';
    END IF;
END $$;

-- 1.2 DBA 管理权限组(DBA Role Group)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'role_global_dba') THEN
        CREATE ROLE role_global_dba WITH NOLOGIN;
        COMMENT ON ROLE role_global_dba IS '全局DBA管理组，继承所有者权限';
        GRANT role_global_owner TO role_global_dba;
        RAISE NOTICE 'DBA角色组 role_global_dba 已创建并继承 owner 权限';
    ELSE
        COMMENT ON ROLE role_global_dba IS '全局DBA管理组，继承所有者权限';
        GRANT role_global_owner TO role_global_dba;
        RAISE NOTICE 'DBA角色组 role_global_dba 已存在';
    END IF;
END $$;

-- 确保 Schema 存在并指定所有者
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_namespace WHERE nspname = 'mall') THEN
        EXECUTE 'CREATE SCHEMA mall AUTHORIZATION role_global_owner';
        RAISE NOTICE 'Mall Schema 已创建并指定所有者';
    ELSE
        EXECUTE 'ALTER SCHEMA mall OWNER TO role_global_owner';
        RAISE NOTICE 'Mall Schema 所有者已更新为 role_global_owner';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_namespace WHERE nspname = 'audit') THEN
        EXECUTE 'CREATE SCHEMA audit AUTHORIZATION role_global_owner';
        RAISE NOTICE 'Audit Schema 已创建并指定所有者';
    ELSE
        EXECUTE 'ALTER SCHEMA audit OWNER TO role_global_owner';
        RAISE NOTICE 'Audit Schema 所有者已更新为 role_global_owner';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_namespace WHERE nspname = 'gis') THEN
        EXECUTE 'CREATE SCHEMA gis AUTHORIZATION role_global_owner';
        RAISE NOTICE 'GIS Schema 已创建并指定所有者';
    ELSE
        EXECUTE 'ALTER SCHEMA gis OWNER TO role_global_owner';
        RAISE NOTICE 'GIS Schema 所有者已更新为 role_global_owner';
    END IF;
END $$;


ALTER TABLE mall.users OWNER TO role_global_owner;
ALTER TABLE mall.addresses OWNER TO role_global_owner;
ALTER TABLE mall.product_images OWNER TO role_global_owner;
ALTER TABLE mall.user_profiles OWNER TO role_global_owner;
ALTER TABLE mall.products OWNER TO role_global_owner;
ALTER TABLE mall.categories OWNER TO role_global_owner;
ALTER TABLE mall.orders OWNER TO role_global_owner;
ALTER TABLE mall.order_items OWNER TO role_global_owner;
ALTER TABLE mall.order_status_history OWNER TO role_global_owner;
ALTER TABLE mall.payments OWNER TO role_global_owner;
ALTER TABLE mall.reviews OWNER TO role_global_owner;
ALTER INDEX mall.users_pkey OWNER TO role_global_owner;
ALTER INDEX mall.users_username_key OWNER TO role_global_owner;
ALTER INDEX mall.users_email_key OWNER TO role_global_owner;
ALTER INDEX mall.idx_users_email OWNER TO role_global_owner;
ALTER INDEX mall.idx_users_username OWNER TO role_global_owner;
ALTER INDEX mall.idx_users_is_active OWNER TO role_global_owner;
ALTER VIEW mall.order_summary OWNER TO role_global_owner;
ALTER VIEW mall.product_summary OWNER TO role_global_owner;

ALTER FUNCTION mall.update_updated_at_column() OWNER TO role_global_owner;
ALTER FUNCTION mall.get_product_avg_rating(product_id_param integer) OWNER TO role_global_owner;
ALTER PROCEDURE mall.clean_expired_orders(IN days_old integer) OWNER TO role_global_owner;
ALTER PROCEDURE mall.batch_update_stock(IN product_ids_param integer[], IN quantities_param integer[]) OWNER TO role_global_owner;
ALTER PROCEDURE mall.generate_monthly_sales_report(IN year_param integer, IN month_param integer) OWNER TO role_global_owner;
ALTER PROCEDURE mall.bulk_import_users(IN user_count integer) OWNER TO role_global_owner;
ALTER FUNCTION mall.get_user_total_spent(user_id_param integer) OWNER TO role_global_owner;

-- audit schema
ALTER TABLE audit.audit_logs OWNER TO role_global_owner;
ALTER TABLE audit.login_logs OWNER TO role_global_owner;
ALTER TABLE audit.data_change_history OWNER TO role_global_owner;

-- gis schema
ALTER TABLE gis.store_locations OWNER TO role_global_owner;
ALTER TABLE gis.delivery_zones OWNER TO role_global_owner;
ALTER TABLE gis.logistics_tracks OWNER TO role_global_owner;
ALTER TABLE gis.hotspot_areas OWNER TO role_global_owner;
ALTER FUNCTION gis.calculate_distance(FLOAT, FLOAT, FLOAT, FLOAT) OWNER TO role_global_owner;
ALTER FUNCTION gis.is_point_in_zone(FLOAT, FLOAT, INTEGER) OWNER TO role_global_owner;

-- public schema
ALTER FUNCTION public.generate_uuid() OWNER TO role_global_owner;



-- =====================================================
-- 2. 角色(Role)创建
-- 用途: 基于角色的权限管理，方便权限批量分配
-- =====================================================

-- 2.1 读写角色 (仅 DML 权限)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'role_mall_rw') THEN
        CREATE ROLE role_mall_rw WITH NOLOGIN;
        COMMENT ON ROLE role_mall_rw IS '商城核心读写权限组，拥有 mall Schema 的 DML 操作权限';
        RAISE NOTICE '读写角色 role_mall_rw 已创建';
    ELSE
        COMMENT ON ROLE role_mall_rw IS '商城核心读写权限组，拥有 mall Schema 的 DML 操作权限';
        RAISE NOTICE '读写角色 role_mall_rw 已存在，跳过创建';
    END IF;
END $$;

-- 2.2 只读角色
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'role_global_ro') THEN
        CREATE ROLE role_global_ro WITH NOLOGIN;
        COMMENT ON ROLE role_global_ro IS '全局只读权限组，拥有所有 Schema 的 SELECT 权限';
        RAISE NOTICE '只读角色 role_global_ro 已创建';
    ELSE
        COMMENT ON ROLE role_global_ro IS '全局只读权限组，拥有所有 Schema 的 SELECT 权限';
        RAISE NOTICE '只读角色 role_global_ro 已存在，跳过创建';
    END IF;
END $$;

-- 2.3 审计读写角色 (仅针对 audit schema 的 INSERT)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'role_audit_rw') THEN
        CREATE ROLE role_audit_rw WITH NOLOGIN;
        COMMENT ON ROLE role_audit_rw IS '审计日志追加权限组，拥有 audit Schema 的 INSERT/SELECT 权限，无删改权';
        RAISE NOTICE '审计读写角色 role_audit_rw 已创建';
    ELSE
        COMMENT ON ROLE role_audit_rw IS '审计日志追加权限组，拥有 audit Schema 的 INSERT/SELECT 权限，无删改权';
        RAISE NOTICE '审计读写角色 role_audit_rw 已存在，跳过创建';
    END IF;
END $$;

-- 2.4 GIS读写角色
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'role_gis_rw') THEN
        CREATE ROLE role_gis_rw WITH NOLOGIN;
        COMMENT ON ROLE role_gis_rw IS 'GIS轨迹读写权限组，拥有 gis Schema 的完整 DML 权限';
        RAISE NOTICE 'GIS读写角色 role_gis_rw 已创建';
    ELSE
        COMMENT ON ROLE role_gis_rw IS 'GIS轨迹读写权限组，拥有 gis Schema 的完整 DML 权限';
        RAISE NOTICE 'GIS读写角色 role_gis_rw 已存在，跳过创建';
    END IF;
END $$;

-- 2.5 全局读写角色
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'role_global_rw') THEN
        CREATE ROLE role_global_rw WITH NOLOGIN;
        COMMENT ON ROLE role_global_rw IS '全局读写权限组，拥有所有 Schema 的完整 DML 操作权限';
        RAISE NOTICE '全局读写角色 role_global_rw 已创建';
    ELSE
        COMMENT ON ROLE role_global_rw IS '全局读写权限组，拥有所有 Schema 的完整 DML 操作权限';
        RAISE NOTICE '全局读写角色 role_global_rw 已存在，跳过创建';
    END IF;
END $$;

-- =====================================================
-- 3. 角色权限分配
-- =====================================================

-- 3.1 读写角色权限
-- 授予 Schema 使用权限
GRANT USAGE ON SCHEMA mall TO role_mall_rw;
GRANT USAGE ON SCHEMA audit TO role_mall_rw;
GRANT USAGE ON SCHEMA gis TO role_mall_rw;

-- 授予表权限（mall 读写，audit/gis 只读）
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA mall TO role_mall_rw;
GRANT SELECT ON ALL TABLES IN SCHEMA audit TO role_mall_rw;
GRANT SELECT ON ALL TABLES IN SCHEMA gis TO role_mall_rw;

-- 授予默认权限（适用于未来新建的表）
-- [!TIP] “一劳永逸”配置：ALTER DEFAULT PRIVILEGES 仅对目标角色（此处为 role_global_owner）亲自建表生效。
-- 我们在下方已通过 `ALTER ROLE svc_deploy_owner SET role = 'role_global_owner';` 完成了底层强制绑定，
-- 自动化流水线建表时将自动触发此处的默认权限分发，无需手工干预。
ALTER DEFAULT PRIVILEGES FOR ROLE role_global_owner IN SCHEMA mall GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO role_mall_rw;
ALTER DEFAULT PRIVILEGES FOR ROLE role_global_owner IN SCHEMA audit GRANT SELECT ON TABLES TO role_mall_rw;
ALTER DEFAULT PRIVILEGES FOR ROLE role_global_owner IN SCHEMA gis GRANT SELECT ON TABLES TO role_mall_rw;

-- 授予序列权限
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA mall TO role_mall_rw;
ALTER DEFAULT PRIVILEGES FOR ROLE role_global_owner IN SCHEMA mall GRANT USAGE, SELECT ON SEQUENCES TO role_mall_rw;

-- 授予函数执行权限
GRANT EXECUTE ON FUNCTION mall.get_user_total_spent(INTEGER) TO role_mall_rw;
GRANT EXECUTE ON FUNCTION mall.get_product_avg_rating(INTEGER) TO role_mall_rw;
GRANT EXECUTE ON FUNCTION gis.calculate_distance(FLOAT, FLOAT, FLOAT, FLOAT) TO role_mall_rw;
GRANT EXECUTE ON FUNCTION gis.is_point_in_zone(FLOAT, FLOAT, INTEGER) TO role_mall_rw;
GRANT EXECUTE ON FUNCTION public.generate_uuid() TO role_mall_rw;

-- 授予存储过程执行权限
GRANT EXECUTE ON PROCEDURE mall.clean_expired_orders(INTEGER) TO role_mall_rw;
GRANT EXECUTE ON PROCEDURE mall.batch_update_stock(INTEGER[], INTEGER[]) TO role_mall_rw;
GRANT EXECUTE ON PROCEDURE mall.generate_monthly_sales_report(INTEGER, INTEGER) TO role_mall_rw;
GRANT EXECUTE ON PROCEDURE mall.bulk_import_users(INTEGER) TO role_mall_rw;

-- 3.2 只读角色权限
-- 授予 Schema 使用权限
GRANT USAGE ON SCHEMA mall TO role_global_ro;
GRANT USAGE ON SCHEMA audit TO role_global_ro;
GRANT USAGE ON SCHEMA gis TO role_global_ro;

-- 授予表权限（只读）
GRANT SELECT ON ALL TABLES IN SCHEMA mall TO role_global_ro;
GRANT SELECT ON ALL TABLES IN SCHEMA audit TO role_global_ro;
GRANT SELECT ON ALL TABLES IN SCHEMA gis TO role_global_ro;

-- 授予默认权限（适用于未来新建的表）
ALTER DEFAULT PRIVILEGES FOR ROLE role_global_owner IN SCHEMA mall GRANT SELECT ON TABLES TO role_global_ro;
ALTER DEFAULT PRIVILEGES FOR ROLE role_global_owner IN SCHEMA audit GRANT SELECT ON TABLES TO role_global_ro;
ALTER DEFAULT PRIVILEGES FOR ROLE role_global_owner IN SCHEMA gis GRANT SELECT ON TABLES TO role_global_ro;

-- 授予序列使用权限
GRANT USAGE ON ALL SEQUENCES IN SCHEMA mall TO role_global_ro;
ALTER DEFAULT PRIVILEGES FOR ROLE role_global_owner IN SCHEMA mall GRANT USAGE ON SEQUENCES TO role_global_ro;

-- 授予查询相关函数执行权限
GRANT EXECUTE ON FUNCTION mall.get_user_total_spent(INTEGER) TO role_global_ro;
GRANT EXECUTE ON FUNCTION mall.get_product_avg_rating(INTEGER) TO role_global_ro;
GRANT EXECUTE ON FUNCTION gis.calculate_distance(FLOAT, FLOAT, FLOAT, FLOAT) TO role_global_ro;
GRANT EXECUTE ON FUNCTION gis.is_point_in_zone(FLOAT, FLOAT, INTEGER) TO role_global_ro;

-- 3.3 审计读写角色权限 (role_audit_rw)
GRANT USAGE ON SCHEMA audit TO role_audit_rw;
GRANT USAGE ON SCHEMA mall TO role_audit_rw;

GRANT SELECT, INSERT ON ALL TABLES IN SCHEMA audit TO role_audit_rw;
GRANT SELECT ON ALL TABLES IN SCHEMA mall TO role_audit_rw;

ALTER DEFAULT PRIVILEGES FOR ROLE role_global_owner IN SCHEMA audit GRANT SELECT, INSERT ON TABLES TO role_audit_rw;
ALTER DEFAULT PRIVILEGES FOR ROLE role_global_owner IN SCHEMA mall GRANT SELECT ON TABLES TO role_audit_rw;

GRANT USAGE ON ALL SEQUENCES IN SCHEMA audit TO role_audit_rw;
ALTER DEFAULT PRIVILEGES FOR ROLE role_global_owner IN SCHEMA audit GRANT USAGE ON SEQUENCES TO role_audit_rw;

-- 3.4 GIS读写角色权限 (role_gis_rw)
GRANT USAGE ON SCHEMA gis TO role_gis_rw;
GRANT USAGE ON SCHEMA mall TO role_gis_rw;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA gis TO role_gis_rw;
GRANT SELECT ON ALL TABLES IN SCHEMA mall TO role_gis_rw;

ALTER DEFAULT PRIVILEGES FOR ROLE role_global_owner IN SCHEMA gis GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO role_gis_rw;
ALTER DEFAULT PRIVILEGES FOR ROLE role_global_owner IN SCHEMA mall GRANT SELECT ON TABLES TO role_gis_rw;

    GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA gis TO role_gis_rw;
ALTER DEFAULT PRIVILEGES FOR ROLE role_global_owner IN SCHEMA gis GRANT USAGE, SELECT ON SEQUENCES TO role_gis_rw;

-- 3.5 全局读写角色权限 (role_global_rw)
-- 通过 RBAC 继承各微服务业务域的读写/写入权限，极大地降低维护成本
GRANT role_mall_rw TO role_global_rw;
GRANT role_audit_rw TO role_global_rw;
GRANT role_gis_rw TO role_global_rw;

-- 针对 audit 库补充 UPDATE 和 DELETE 权限（因为 role_audit_rw 只有 INSERT）
GRANT UPDATE, DELETE ON ALL TABLES IN SCHEMA audit TO role_global_rw;
ALTER DEFAULT PRIVILEGES FOR ROLE role_global_owner IN SCHEMA audit GRANT UPDATE, DELETE ON TABLES TO role_global_rw;

-- =====================================================
-- 4. 应用程序账号(Application RW User)
-- 用途: 后端服务连接数据库使用的账号
-- =====================================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'svc_mall_rw') THEN
        CREATE ROLE svc_mall_rw WITH LOGIN PASSWORD 'SvcMallRw@2026';
        COMMENT ON ROLE svc_mall_rw IS '商城生产环境核心应用账号，用于后端服务执行日常 DML 操作';
        -- 将读写角色赋予应用账号
        GRANT role_mall_rw TO svc_mall_rw;
        -- 设置默认搜索路径
        ALTER USER svc_mall_rw SET search_path = mall, audit, gis, public;
        RAISE NOTICE '应用程序账号 svc_mall_rw 已创建并赋予读写权限';
    ELSE
        COMMENT ON ROLE svc_mall_rw IS '商城生产环境核心应用账号，用于后端服务执行日常 DML 操作';
        -- 确保角色已赋予
        GRANT role_mall_rw TO svc_mall_rw;
        ALTER USER svc_mall_rw SET search_path = mall, audit, gis, public;
        RAISE NOTICE '应用程序账号 svc_mall_rw 已存在，确保权限已更新';
    END IF;
END $$;

-- 授予连接数据库权限
GRANT CONNECT ON DATABASE app_db TO svc_mall_rw;

-- =====================================================
-- 4.1 审计业务账号(Audit RW User)
-- 用途: 审计服务专用的日志写入账号
-- =====================================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'svc_audit_rw') THEN
        CREATE ROLE svc_audit_rw WITH LOGIN PASSWORD 'SvcAuditRw@2026';
        COMMENT ON ROLE svc_audit_rw IS '审计微服务生产环境防篡改账号，仅具备日志追加插入权限';
        GRANT role_audit_rw TO svc_audit_rw;
        ALTER USER svc_audit_rw SET search_path = audit, mall, public;
        RAISE NOTICE '审计账号 svc_audit_rw 已创建并赋予读写权限';
    ELSE
        COMMENT ON ROLE svc_audit_rw IS '审计微服务生产环境防篡改账号，仅具备日志追加插入权限';
        GRANT role_audit_rw TO svc_audit_rw;
        ALTER USER svc_audit_rw SET search_path = audit, mall, public;
        RAISE NOTICE '审计账号 svc_audit_rw 已存在，确保权限已更新';
    END IF;
END $$;

GRANT CONNECT ON DATABASE app_db TO svc_audit_rw;

-- =====================================================
-- 4.2 GIS业务账号(GIS RW User)
-- 用途: GIS/物流微服务专用的读写账号
-- =====================================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'svc_gis_rw') THEN
        CREATE ROLE svc_gis_rw WITH LOGIN PASSWORD 'SvcGisRw@2026';
        COMMENT ON ROLE svc_gis_rw IS '物流与GIS微服务生产环境账号，用于高频更新空间及轨迹数据';
        GRANT role_gis_rw TO svc_gis_rw;
        ALTER USER svc_gis_rw SET search_path = gis, mall, public;
        RAISE NOTICE 'GIS账号 svc_gis_rw 已创建并赋予读写权限';
    ELSE
        COMMENT ON ROLE svc_gis_rw IS '物流与GIS微服务生产环境账号，用于高频更新空间及轨迹数据';
        GRANT role_gis_rw TO svc_gis_rw;
        ALTER USER svc_gis_rw SET search_path = gis, mall, public;
        RAISE NOTICE 'GIS账号 svc_gis_rw 已存在，确保权限已更新';
    END IF;
END $$;

GRANT CONNECT ON DATABASE app_db TO svc_gis_rw;

-- =====================================================
-- 5. 只读账号(Read-Only / Reporting User)
-- 用途: 数据分析师、BI 报表工具、开发人员排查问题
-- =====================================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'svc_bi_ro') THEN
        CREATE ROLE svc_bi_ro WITH LOGIN PASSWORD 'SvcBiRo@2026';
        COMMENT ON ROLE svc_bi_ro IS '报表与数据分析生产环境账号，全局只读';
        -- 将只读角色赋予报表账号
        GRANT role_global_ro TO svc_bi_ro;
        -- 设置默认搜索路径
        ALTER USER svc_bi_ro SET search_path = mall, audit, gis, public;
        RAISE NOTICE '只读账号 svc_bi_ro 已创建并赋予只读权限';
    ELSE
        COMMENT ON ROLE svc_bi_ro IS '报表与数据分析生产环境账号，全局只读';
        -- 确保角色已赋予
        GRANT role_global_ro TO svc_bi_ro;
        ALTER USER svc_bi_ro SET search_path = mall, audit, gis, public;
        RAISE NOTICE '只读账号 svc_bi_ro 已存在，确保权限已更新';
    END IF;
END $$;

-- 授予连接数据库权限
GRANT CONNECT ON DATABASE app_db TO svc_bi_ro;

-- =====================================================
-- 6. 运维监控账号(Monitoring User)
-- 用途: Prometheus (pg_exporter)、Zabbix、PMM 等监控工具
-- =====================================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'svc_monitor_ro') THEN
        CREATE ROLE svc_monitor_ro WITH LOGIN PASSWORD 'SvcMonitorRo@2026';
        COMMENT ON ROLE svc_monitor_ro IS '监控系统生产环境账号，具有 pg_monitor 特权';
        -- 赋予监控特权 (PostgreSQL 10+ 推荐方式)
        GRANT pg_monitor TO svc_monitor_ro;
        RAISE NOTICE '运维监控账号 svc_monitor_ro 已创建';
    ELSE
        COMMENT ON ROLE svc_monitor_ro IS '监控系统生产环境账号，具有 pg_monitor 特权';
        RAISE NOTICE '运维监控账号 svc_monitor_ro 已存在，跳过创建';
    END IF;
END $$;

-- 授予连接数据库权限
GRANT CONNECT ON DATABASE app_db TO svc_monitor_ro;
GRANT CONNECT ON DATABASE postgres TO svc_monitor_ro;

-- =====================================================
-- 7. 复制/备份账号(Replication / Backup User)
-- 用途: 用于主从复制(Streaming Replication)或物理备份(pg_basebackup)
-- =====================================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'svc_repl_ro') THEN
        CREATE ROLE svc_repl_ro WITH LOGIN REPLICATION PASSWORD 'SvcReplRo@2026';
        COMMENT ON ROLE svc_repl_ro IS '物理备份与流复制专用生产环境账号';
        RAISE NOTICE '复制/备份账号 svc_repl_ro 已创建';
    ELSE
        COMMENT ON ROLE svc_repl_ro IS '物理备份与流复制专用生产环境账号';
        RAISE NOTICE '复制/备份账号 svc_repl_ro 已存在，跳过创建';
    END IF;
END $$;

-- =====================================================
-- 8. CI/CD 自动化部署账号(Deploy Service Account)
-- 用途: 流水线执行 DDL 操作
-- =====================================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'svc_deploy_owner') THEN
        CREATE ROLE svc_deploy_owner WITH LOGIN PASSWORD 'SvcDeployOwner@2026';
        COMMENT ON ROLE svc_deploy_owner IS '生产环境 CI/CD 自动化部署账号，继承 role_global_owner 权限用于执行结构变更';
        GRANT role_global_owner TO svc_deploy_owner;
        RAISE NOTICE '部署账号 svc_deploy_owner 已创建并赋予业务所有者权限';
    ELSE
        COMMENT ON ROLE svc_deploy_owner IS '生产环境 CI/CD 自动化部署账号，继承 role_global_owner 权限用于执行结构变更';
        GRANT role_global_owner TO svc_deploy_owner;
        RAISE NOTICE '部署账号 svc_deploy_owner 已存在，确保权限已更新';
    END IF;
END $$;
-- 【黑科技：一劳永逸解决默认权限陷阱】强制绑定会话级角色
ALTER ROLE svc_deploy_owner SET role = 'role_global_owner';
GRANT CONNECT,CREATE ON DATABASE app_db TO svc_deploy_owner;

-- =====================================================
-- 8.2 SQL 审核与执行平台账号(SQL Platform Service Account)
-- 用途: Archery/Yearning 等平台执行 DDL 和 DML
-- =====================================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'svc_sqlplat_owner') THEN
        CREATE ROLE svc_sqlplat_owner WITH LOGIN PASSWORD 'SvcSqlPlatOwner@2026';
        COMMENT ON ROLE svc_sqlplat_owner IS 'SQL审核与执行平台专属账号，继承 role_global_owner 权限用于执行结构变更与数据修补';
        GRANT role_global_owner TO svc_sqlplat_owner;
        RAISE NOTICE 'SQL平台账号 svc_sqlplat_owner 已创建并赋予业务所有者权限';
    ELSE
        COMMENT ON ROLE svc_sqlplat_owner IS 'SQL审核与执行平台专属账号，继承 role_global_owner 权限用于执行结构变更与数据修补';
        GRANT role_global_owner TO svc_sqlplat_owner;
        RAISE NOTICE 'SQL平台账号 svc_sqlplat_owner 已存在，确保权限已更新';
    END IF;
END $$;
-- 【黑科技：一劳永逸解决默认权限陷阱】强制绑定会话级角色
ALTER ROLE svc_sqlplat_owner SET role = 'role_global_owner';
GRANT CONNECT,CREATE ON DATABASE app_db TO svc_sqlplat_owner;

-- =====================================================
-- 9. 个人管理账号(Personal Admin Accounts)
-- 用途: 具体的 DBA 或高级运维人员
-- =====================================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'pers_dba_owner') THEN
        CREATE ROLE pers_dba_owner WITH LOGIN PASSWORD 'PersDbaOwner@2026';
        COMMENT ON ROLE pers_dba_owner IS 'DBA Alice Smith 的个人管理账号';
        -- 赋予 DBA 管理组身份
        GRANT role_global_dba TO pers_dba_owner;
        RAISE NOTICE '个人管理账号 pers_dba_owner 已创建并赋予DBA管理组权限';
    ELSE
        COMMENT ON ROLE pers_dba_owner IS 'DBA Alice Smith 的个人管理账号';
        -- 确保权限已赋予
        GRANT role_global_dba TO pers_dba_owner;
        RAISE NOTICE '个人管理账号 pers_dba_owner 已存在，确保权限已更新';
    END IF;
END $$;

-- 授予连接数据库权限
GRANT CONNECT,CREATE ON DATABASE app_db TO pers_dba_owner;

-- =====================================================
-- 执行完成
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE '业务账号创建和授权完成！';
    RAISE NOTICE '========================================';
    RAISE NOTICE '账号信息：';
    RAISE NOTICE '  1. role_global_owner（业务所有者权限组 - NOLOGIN）';
    RAISE NOTICE '     密码: 无';
    RAISE NOTICE '     权限: 拥有 Schema 所有权，可执行 DDL 操作';
    RAISE NOTICE '     场景: 权限组，仅供具体的账号继承';
    RAISE NOTICE '';
    RAISE NOTICE '  2. svc_deploy_owner（自动化部署账号）';
    RAISE NOTICE '     密码: SvcDeployOwner@2026';
    RAISE NOTICE '     权限: 继承 role_global_owner 权限';
    RAISE NOTICE '     场景: 流水线执行结构变更与初始数据导入';
    RAISE NOTICE '';
    RAISE NOTICE '  3. svc_mall_rw（应用程序账号）';
    RAISE NOTICE '     密码: SvcMallRw@2026';
    RAISE NOTICE '     权限: mall 读写，audit/gis 只读';
    RAISE NOTICE '     场景: 核心电商应用服务';
    RAISE NOTICE '';
    RAISE NOTICE '  4. svc_audit_rw（审计业务账号）';
    RAISE NOTICE '     密码: SvcAuditRw@2026';
    RAISE NOTICE '     权限: audit 插入，mall 只读';
    RAISE NOTICE '     场景: 审计微服务（防篡改日志）';
    RAISE NOTICE '';
    RAISE NOTICE '  5. svc_gis_rw（GIS业务账号）';
    RAISE NOTICE '     密码: SvcGisRw@2026';
    RAISE NOTICE '     权限: gis 读写，mall 只读';
    RAISE NOTICE '     场景: 物流与地理微服务';
    RAISE NOTICE '';
    RAISE NOTICE '  6. svc_bi_ro（只读账号）';
    RAISE NOTICE '     密码: SvcBiRo@2026';
    RAISE NOTICE '     权限: 所有表 SELECT（只读）';
    RAISE NOTICE '     场景: 报表查询、数据分析';
    RAISE NOTICE '';
    RAISE NOTICE '  7. svc_monitor_ro（运维监控账号）';
    RAISE NOTICE '     密码: SvcMonitorRo@2026';
    RAISE NOTICE '     权限: pg_monitor';
    RAISE NOTICE '     场景: 监控工具连接';
    RAISE NOTICE '';
    RAISE NOTICE '  8. svc_repl_ro（复制/备份账号）';
    RAISE NOTICE '     密码: SvcReplRo@2026';
    RAISE NOTICE '     权限: REPLICATION';
    RAISE NOTICE '     场景: 主从复制、物理备份';
    RAISE NOTICE '';
    RAISE NOTICE '  9. pers_dba_owner（个人管理账号）';
    RAISE NOTICE '     密码: PersDbaOwner@2026';
    RAISE NOTICE '     权限: 继承 role_global_dba 管理组权限';
    RAISE NOTICE '     场景: DBA 日常管理';
    RAISE NOTICE '========================================';
    RAISE NOTICE '权限层级结构：';
    RAISE NOTICE '  [postgres] (超级管理员 - 封存/慎用)';
    RAISE NOTICE '       |';
    RAISE NOTICE '       +-- [role_global_owner] (业务所有权权限组 - DDL操作, NOLOGIN)';
    RAISE NOTICE '       |         ^                   ^                  ^';
    RAISE NOTICE '       |         |                   |                  |';
    RAISE NOTICE '       |  [role_global_dba]    [svc_deploy_owner]    [svc_sqlplat_owner]';
    RAISE NOTICE '       |         ^               (流水线账号)        (SQL平台账号)';
    RAISE NOTICE '       |         |';
    RAISE NOTICE '       |   [pers_dba_owner]';
    RAISE NOTICE '       |    (个人账号)';
    RAISE NOTICE '       |';
    RAISE NOTICE '       +-- [role_global_rw] (全局读写权限组 - 跨库DML)';
    RAISE NOTICE '       |         ^';
    RAISE NOTICE '       |         +-------+-------+ (继承底层业务读写组)';
    RAISE NOTICE '       |';
    RAISE NOTICE '       +-- [role_mall_rw] (核心读写角色)';
    RAISE NOTICE '       |         ^';
    RAISE NOTICE '       |         |';
    RAISE NOTICE '       |    [svc_mall_rw] (核心应用账号)';
    RAISE NOTICE '       |';
    RAISE NOTICE '       +-- [role_audit_rw] (审计写角色)';
    RAISE NOTICE '       |         ^';
    RAISE NOTICE '       |         |';
    RAISE NOTICE '       |    [svc_audit_rw] (审计账号)';
    RAISE NOTICE '       |';
    RAISE NOTICE '       +-- [role_gis_rw] (GIS读写角色)';
    RAISE NOTICE '       |         ^';
    RAISE NOTICE '       |         |';
    RAISE NOTICE '       |    [svc_gis_rw] (GIS账号)';
    RAISE NOTICE '       |';
    RAISE NOTICE '       +-- [role_global_ro] (只读角色 - 只有SELECT)';
    RAISE NOTICE '                 ^';
    RAISE NOTICE '                 |';
    RAISE NOTICE '            [svc_bi_ro] (报表账号)';
    RAISE NOTICE '========================================';
END $$;



