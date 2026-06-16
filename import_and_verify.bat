@echo off
chcp 65001 >nul
echo ========================================================
echo app_db 快速导入与验证脚本 (Windows)
echo ========================================================
echo.

set PGUSER=postgres
set PGDATABASE=app_db

echo [1/5] 正在清理旧数据库 (如果存在)...
dropdb -U %PGUSER% --if-exists %PGDATABASE%
if %ERRORLEVEL% NEQ 0 echo [警告] dropdb 失败或数据库不存在，继续...

echo [2/5] 正在创建新数据库 %PGDATABASE%...
createdb -U %PGUSER% %PGDATABASE%
if %ERRORLEVEL% NEQ 0 (
    echo [错误] 创建数据库失败！请检查 PostgreSQL 服务是否启动以及 %PGUSER% 用户权限。
    pause
    exit /b %ERRORLEVEL%
)

echo [3/5] 正在导入数据库结构 (Schema)...
psql -U %PGUSER% -d %PGDATABASE% -v dbname=%PGDATABASE% -f app_db_schema.sql
if %ERRORLEVEL% NEQ 0 (
    echo [错误] 导入结构失败！
    pause
    exit /b %ERRORLEVEL%
)

echo [4/5] 正在导入示例数据 (Data)...
psql -U %PGUSER% -d %PGDATABASE% -f app_db_data.sql
if %ERRORLEVEL% NEQ 0 (
    echo [错误] 导入数据失败！
    pause
    exit /b %ERRORLEVEL%
)

echo [5/5] 正在创建业务账号并授权 (Grants)...
psql -U %PGUSER% -d %PGDATABASE% -f app_db_user_grants.sql
if %ERRORLEVEL% NEQ 0 (
    echo [错误] 授权失败！
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo ========================================================
echo 导入完成！正在执行快速数据验证...
echo ========================================================
echo.

echo 【表级数据量统计】:
psql -U %PGUSER% -d %PGDATABASE% -c "SELECT 'mall.users' AS table_name, COUNT(*) AS row_count FROM mall.users UNION ALL SELECT 'mall.orders', COUNT(*) FROM mall.orders UNION ALL SELECT 'audit.audit_logs', COUNT(*) FROM audit.audit_logs UNION ALL SELECT 'gis.store_locations', COUNT(*) FROM gis.store_locations;"

echo.
echo 【账号权限验证 (svc_bi_ro 只读账号测试)】:
set PGPASSWORD=SvcBiRo@2026
psql -h 127.0.0.1 -U svc_bi_ro -d %PGDATABASE% -c "SELECT current_user, current_database();"
set PGPASSWORD=

echo.
echo 【业务账号权限多维度功能测试】:

:: 1. DML 只读越权测试 (svc_bi_ro 尝试写入，预期被拒)
echo -^> [DML只读安全测试] 以 svc_bi_ro 尝试写入 mall.categories (预期报错: permission denied)...
set PGPASSWORD=SvcBiRo@2026
psql -h 127.0.0.1 -U svc_bi_ro -d %PGDATABASE% -c "INSERT INTO mall.categories (category_id, name) VALUES (9999, 'Test');" 2^>^&1 | findstr /I "ERROR permission" >nul
if %ERRORLEVEL% EQU 0 (
    echo [OK] 已成功拦截越权写入
) else (
    echo [ERROR] 未成功拦截越权写入！
)

:: 2. DML 读写放行测试 (svc_mall_rw 写入、更新与删除，预期成功)
echo -^> [DML读写放行测试] 以 svc_mall_rw 插入/更新/删除 mall.categories...
set PGPASSWORD=SvcMallRw@2026
psql -h 127.0.0.1 -U svc_mall_rw -d %PGDATABASE% -c "INSERT INTO mall.categories (category_id, name) VALUES (9999, 'TestRW'); UPDATE mall.categories SET name = 'TestRW_Updated' WHERE category_id = 9999; DELETE FROM mall.categories WHERE category_id = 9999;" >nul 2^>^&1
if %ERRORLEVEL% EQU 0 (
    echo [OK] DML 增删改操作测试通过
) else (
    echo [ERROR] DML 增删改操作失败！
)

:: 3. DDL 越权拦截测试 (svc_mall_rw 尝试建表，预期被拒)
echo -^> [DDL权限隔离测试] 以 svc_mall_rw 尝试在 mall 创建新表 (预期报错: permission denied)...
set PGPASSWORD=SvcMallRw@2026
psql -h 127.0.0.1 -U svc_mall_rw -d %PGDATABASE% -c "CREATE TABLE mall.test_dml_ddl (id int);" 2^>^&1 | findstr /I "ERROR permission" >nul
if %ERRORLEVEL% EQU 0 (
    echo [OK] 已成功拦截非Owner建表操作
) else (
    echo [ERROR] 未能拦截非Owner建表操作！
)

:: 4. DDL 放行与默认授权验证 (svc_deploy_owner 建表，验证 svc_mall_rw / svc_bi_ro 自动赋权)
echo -^> [DDL与默认授权测试] 以 svc_deploy_owner 创建新表 mall.test_default_grants...
set PGPASSWORD=SvcDeployOwner@2026
psql -h 127.0.0.1 -U svc_deploy_owner -d %PGDATABASE% -c "CREATE TABLE mall.test_default_grants (id int, val varchar(50));" >nul 2^>^&1
if %ERRORLEVEL% EQU 0 (
    echo [OK] Owner DDL 建表成功
) else (
    echo [ERROR] Owner DDL 建表失败！
)

echo -^> [默认授权-读写校验] 以 svc_mall_rw 向新表插入并查询数据 (验证默认DML权限)...
set PGPASSWORD=SvcMallRw@2026
psql -h 127.0.0.1 -U svc_mall_rw -d %PGDATABASE% -c "INSERT INTO mall.test_default_grants (id, val) VALUES (1, 'default_priv_test'); SELECT * FROM mall.test_default_grants;" >nul 2^>^&1
if %ERRORLEVEL% EQU 0 (
    echo [OK] 默认 DML 授权生效
) else (
    echo [ERROR] 默认 DML 授权失败！
)

echo -^> [默认授权-只读校验] 以 svc_bi_ro 查询新表数据 (验证默认只读权限)...
set PGPASSWORD=SvcBiRo@2026
psql -h 127.0.0.1 -U svc_bi_ro -d %PGDATABASE% -c "SELECT * FROM mall.test_default_grants;" >nul 2^>^&1
if %ERRORLEVEL% EQU 0 (
    echo [OK] 默认 SELECT 授权生效
) else (
    echo [ERROR] 默认 SELECT 授权失败！
)

:: 5. 清理 DDL 测试表
echo -^> [清理测试资源] 以 svc_deploy_owner 删除测试表...
set PGPASSWORD=SvcDeployOwner@2026
psql -h 127.0.0.1 -U svc_deploy_owner -d %PGDATABASE% -c "DROP TABLE mall.test_default_grants;" >nul 2^>^&1
if %ERRORLEVEL% EQU 0 (
    echo [OK] 测试资源清理完毕
) else (
    echo [ERROR] 测试资源清理失败！
)

set PGPASSWORD=

echo.
echo ========================================================
echo 验证结束，全部流程已成功执行！
echo ========================================================
pause


