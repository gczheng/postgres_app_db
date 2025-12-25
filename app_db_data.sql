-- =====================================================
-- App_db数据库数据插入脚本
-- 数据库名称: app_db
-- 字符集: UTF8
-- 版本: v1.1.0
-- 创建日期: 2025-12-25
-- 说明: 包含约10万用户数据
-- =====================================================

-- =====================================================
-- 设置脚本执行参数
-- =====================================================
SET client_encoding = 'UTF8';
SET timezone = 'UTC';

-- =====================================================
-- 插入分类数据
-- =====================================================
INSERT INTO categories (category_id, name, description, parent_category_id, sort_order, is_active, created_at) VALUES
(1, '电子产品', '各类电子数码产品', NULL, 1, true, '2024-01-01 00:00:00'),
(2, '手机通讯', '智能手机、配件等', 1, 1, true, '2024-01-01 00:00:00'),
(3, '电脑办公', '笔记本电脑、台式机等', 1, 2, true, '2024-01-01 00:00:00'),
(4, '家用电器', '各类家用电器', NULL, 2, true, '2024-01-01 00:00:00'),
(5, '厨房电器', '烹饪、厨房小家电', 4, 1, true, '2024-01-01 00:00:00'),
(6, '生活电器', '洗衣机、冰箱等', 4, 2, true, '2024-01-01 00:00:00'),
(7, '服装鞋包', '服装、鞋类、箱包', NULL, 3, true, '2024-01-01 00:00:00'),
(8, '男装', '男士服装', 7, 1, true, '2024-01-01 00:00:00'),
(9, '女装', '女士服装', 7, 2, true, '2024-01-01 00:00:00'),
(10, '鞋靴', '各类鞋靴', 7, 3, true, '2024-01-01 00:00:00'),
(11, '箱包皮具', '背包、手提包等', 7, 4, true, '2024-01-01 00:00:00'),
(12, '美妆个护', '化妆品、个护用品', NULL, 4, true, '2024-01-01 00:00:00'),
(13, '面部护肤', '面部护理产品', 12, 1, true, '2024-01-01 00:00:00'),
(14, '彩妆香水', '彩妆、香水', 12, 2, true, '2024-01-01 00:00:00'),
(15, '身体护理', '沐浴、身体护理', 12, 3, true, '2024-01-01 00:00:00'),
(16, '母婴用品', '母婴护理用品', NULL, 5, true, '2024-01-01 00:00:00'),
(17, '奶粉辅食', '奶粉、辅食', 16, 1, true, '2024-01-01 00:00:00'),
(18, '尿裤湿巾', '尿裤、湿巾', 16, 2, true, '2024-01-01 00:00:00'),
(19, '童装童鞋', '儿童服装、鞋类', 16, 3, true, '2024-01-01 00:00:00'),
(20, '食品饮料', '食品、饮料', NULL, 6, true, '2024-01-01 00:00:00'),
(21, '休闲零食', '各类零食', 20, 1, true, '2024-01-01 00:00:00'),
(22, '酒水茶饮', '酒类、饮料、茶饮', 20, 2, true, '2024-01-01 00:00:00'),
(23, '生鲜水果', '水果、生鲜', 20, 3, true, '2024-01-01 00:00:00'),
(24, '家居家装', '家具、家装', NULL, 7, true, '2024-01-01 00:00:00'),
(25, '卧室家具', '床、衣柜等', 24, 1, true, '2024-01-01 00:00:00'),
(26, '客厅家具', '沙发、茶几等', 24, 2, true, '2024-01-01 00:00:00'),
(27, '厨房卫浴', '厨房、卫浴用品', 24, 3, true, '2024-01-01 00:00:00'),
(28, '运动户外', '运动、户外装备', NULL, 8, true, '2024-01-01 00:00:00'),
(29, '运动鞋服', '运动服装、鞋类', 28, 1, true, '2024-01-01 00:00:00'),
(30, '户外装备', '户外运动装备', 28, 2, true, '2024-01-01 00:00:00'),
(31, '健身器材', '健身器材', 28, 3, true, '2024-01-01 00:00:00'),
(32, '图书音像', '图书、音像制品', NULL, 9, true, '2024-01-01 00:00:00'),
(33, '文学小说', '文学、小说', 32, 1, true, '2024-01-01 00:00:00'),
(34, '经管励志', '经济管理、励志', 32, 2, true, '2024-01-01 00:00:00'),
(35, '教育音像', '教育、音像', 32, 3, true, '2024-01-01 00:00:00');

-- =====================================================
-- 插入商品数据 (73个商品)
-- =====================================================
INSERT INTO products (product_id, category_id, name, description, price, stock_quantity, is_active, created_at) VALUES
-- 电子产品
(1, 2, 'iPhone 15 Pro Max 256GB', '苹果最新旗舰手机，A17 Pro芯片', 9999.00, 100, true, '2024-01-01 00:00:00'),
(2, 2, '华为Mate 60 Pro 512GB', '华为高端智能手机，卫星通信', 6999.00, 150, true, '2024-01-01 00:00:00'),
(3, 2, '小米14 Ultra', '徕卡光学镜头，骁龙8 Gen3', 5999.00, 200, true, '2024-01-01 00:00:00'),
(4, 2, 'OPPO Find X7 Ultra', '哈苏影像系统，超薄设计', 5499.00, 120, true, '2024-01-01 00:00:00'),
(5, 2, 'vivo X100 Pro', '蔡司影像系统，天玑9300', 4999.00, 180, true, '2024-01-01 00:00:00'),
(6, 3, 'MacBook Pro 14英寸', 'M3芯片，16GB内存，512GB存储', 14999.00, 50, true, '2024-01-01 00:00:00'),
(7, 3, 'MacBook Air 13英寸', 'M2芯片，8GB内存，256GB存储', 8999.00, 80, true, '2024-01-01 00:00:00'),
(8, 3, 'ThinkPad X1 Carbon', '英特尔i7，16GB内存，1TB存储', 12999.00, 60, true, '2024-01-01 00:00:00'),
(9, 3, '戴尔XPS 15', '英特尔i9，32GB内存，1TB存储', 15999.00, 40, true, '2024-01-01 00:00:00'),
(10, 3, '华硕ROG游戏本', 'RTX4060，32GB内存，1TB存储', 11999.00, 70, true, '2024-01-01 00:00:00'),
-- 家用电器
(11, 5, '美的电饭煲4L', '智能电饭煲，多功能菜单', 399.00, 300, true, '2024-01-01 00:00:00'),
(12, 5, '格兰仕微波炉', '20L机械微波炉', 299.00, 250, true, '2024-01-01 00:00:00'),
(13, 5, '九阳豆浆机', '全自动豆浆机', 499.00, 200, true, '2024-01-01 00:00:00'),
(14, 6, '海尔洗衣机10kg', '滚筒洗衣机，变频电机', 2999.00, 100, true, '2024-01-01 00:00:00'),
(15, 6, '美的冰箱520L', '对开门冰箱，风冷无霜', 4999.00, 80, true, '2024-01-01 00:00:00'),
(16, 6, '格力空调1.5匹', '变频空调，一级能效', 3999.00, 150, true, '2024-01-01 00:00:00'),
(17, 6, '海信电视65英寸', '4K智能电视，HDR', 4999.00, 120, true, '2024-01-01 00:00:00'),
-- 服装鞋包
(18, 8, '优衣库男款T恤', '纯棉T恤，多色可选', 99.00, 500, true, '2024-01-01 00:00:00'),
(19, 8, '耐克运动裤', '休闲运动裤，舒适透气', 299.00, 300, true, '2024-01-01 00:00:00'),
(20, 8, '阿迪达斯运动鞋', '运动跑鞋，缓震科技', 599.00, 200, true, '2024-01-01 00:00:00'),
(21, 9, 'ZARA女装连衣裙', '时尚连衣裙，多款式', 399.00, 250, true, '2024-01-01 00:00:00'),
(22, 9, 'ONLY女款毛衣', '针织毛衣，保暖舒适', 299.00, 180, true, '2024-01-01 00:00:00'),
(23, 9, '热风女款外套', '时尚外套，多色可选', 499.00, 220, true, '2024-01-01 00:00:00'),
(24, 10, '匡威帆布鞋', '经典帆布鞋，百搭款', 399.00, 350, true, '2024-01-01 00:00:00'),
(25, 10, 'New Balance跑鞋', '复古跑鞋，舒适百搭', 699.00, 280, true, '2024-01-01 00:00:00'),
(26, 10, '斯凯奇休闲鞋', '休闲鞋，轻盈舒适', 499.00, 320, true, '2024-01-01 00:00:00'),
(27, 11, '小米双肩包', '多功能双肩包，防水', 199.00, 400, true, '2024-01-01 00:00:00'),
(28, 11, '新秀丽商务包', '商务双肩包，大容量', 699.00, 150, true, '2024-01-01 00:00:00'),
(29, 11, '蔻驰手提包', '时尚手提包，真皮材质', 2999.00, 80, true, '2024-01-01 00:00:00'),
-- 美妆个护
(30, 13, '兰蔻小黑瓶', '精华液，修护肌肤', 1299.00, 200, true, '2024-01-01 00:00:00'),
(31, 13, '雅诗兰黛小棕瓶', '精华液，抗老修护', 1399.00, 180, true, '2024-01-01 00:00:00'),
(32, 13, 'SK-II神仙水', '精华水，肌底修护', 1599.00, 160, true, '2024-01-01 00:00:00'),
(33, 14, 'Dior迪奥口红', '口红999经典色', 380.00, 500, true, '2024-01-01 00:00:00'),
(34, 14, '雅诗兰黛口红', '口红420色号', 350.00, 450, true, '2024-01-01 00:00:00'),
(35, 14, 'Chanel香奈儿香水', '经典香水5号', 1299.00, 120, true, '2024-01-01 00:00:00'),
(36, 15, '欧舒丹沐浴油', '沐浴油，保湿滋润', 299.00, 250, true, '2024-01-01 00:00:00'),
(37, 15, '资生堂身体乳', '身体乳，滋润嫩肤', 199.00, 300, true, '2024-01-01 00:00:00'),
-- 母婴用品
(38, 17, '惠氏启赋奶粉', '婴儿配方奶粉，3段', 398.00, 200, true, '2024-01-01 00:00:00'),
(39, 17, '美赞臣蓝臻奶粉', '婴儿配方奶粉，3段', 368.00, 180, true, '2024-01-01 00:00:00'),
(40, 18, '好奇纸尿裤', '纸尿裤，超大号', 299.00, 400, true, '2024-01-01 00:00:00'),
(41, 18, '帮宝适纸尿裤', '纸尿裤，超大号', 279.00, 350, true, '2024-01-01 00:00:00'),
(42, 18, '大王纸尿裤', '纸尿裤，超大号', 259.00, 320, true, '2024-01-01 00:00:00'),
(43, 19, '巴拉巴拉童装', '儿童套装，多色可选', 299.00, 250, true, '2024-01-01 00:00:00'),
(44, 19, '安踏儿童运动鞋', '儿童运动鞋，舒适防滑', 399.00, 200, true, '2024-01-01 00:00:00'),
-- 食品饮料
(45, 21, '三只松鼠坚果', '混合坚果礼盒，500g', 99.00, 500, true, '2024-01-01 00:00:00'),
(46, 21, '良品铺子零食', '零食组合装，1000g', 129.00, 450, true, '2024-01-01 00:00:00'),
(47, 21, '百草味薯片', '薯片大礼包，800g', 79.00, 600, true, '2024-01-01 00:00:00'),
(48, 22, '贵州茅台53度', '飞天茅台，500ml', 2999.00, 50, true, '2024-01-01 00:00:00'),
(49, 22, '五粮液52度', '五粮液，500ml', 1399.00, 80, true, '2024-01-01 00:00:00'),
(50, 22, '可口可乐24罐', '可口可乐，330ml*24', 59.00, 800, true, '2024-01-01 00:00:00'),
-- 家居家装
(51, 25, '慕思床垫1.8米', '乳胶床垫，独立弹簧', 5999.00, 60, true, '2024-01-01 00:00:00'),
(52, 25, '喜临门床垫', '弹簧床垫，舒适护脊', 3999.00, 80, true, '2024-01-01 00:00:00'),
(53, 25, '宜家衣柜', '四门衣柜，大容量', 2999.00, 100, true, '2024-01-01 00:00:00'),
(54, 26, '芝华仕沙发', '三人位沙发，可躺', 5999.00, 70, true, '2024-01-01 00:00:00'),
(55, 26, '顾家家居沙发', '布艺沙发，三人位', 4999.00, 90, true, '2024-01-01 00:00:00'),
(56, 27, '箭牌马桶', '智能马桶，全自动', 1999.00, 150, true, '2024-01-01 00:00:00'),
(57, 27, 'TOTO马桶', '智能马桶，全自动', 2999.00, 100, true, '2024-01-01 00:00:00'),
-- 运动户外
(58, 29, '耐克运动鞋', '跑鞋，轻便透气', 699.00, 220, true, '2024-01-01 00:00:00'),
(59, 29, '李宁运动鞋', '篮球鞋，缓震耐磨', 599.00, 180, true, '2024-01-01 00:00:00'),
(60, 29, '安德玛运动衣', '运动上衣，速干透气', 299.00, 250, true, '2024-01-01 00:00:00'),
(61, 30, '迪卡侬登山包', '登山背包，60L', 699.00, 150, true, '2024-01-01 00:00:00'),
(62, 30, '探路者帐篷', '双人帐篷，防水防雨', 499.00, 200, true, '2024-01-01 00:00:00'),
(63, 30, '牧高笛睡袋', '睡袋，羽绒保暖', 399.00, 180, true, '2024-01-01 00:00:00'),
(64, 31, '健身拉力器', '拉力器，居家健身', 199.00, 400, true, '2024-01-01 00:00:00'),
(65, 31, '动感单车', '健身车，居家骑行', 2999.00, 80, true, '2024-01-01 00:00:00'),
-- 图书音像
(66, 33, '活着（余华）', '当代文学经典', 45.00, 300, true, '2024-01-01 00:00:00'),
(67, 33, '三体全集', '科幻小说经典', 158.00, 200, true, '2024-01-01 00:00:00'),
(68, 33, '百年孤独', '世界文学经典', 68.00, 180, true, '2024-01-01 00:00:00'),
(69, 34, '穷查理宝典', '投资理财经典', 88.00, 250, true, '2024-01-01 00:00:00'),
(70, 34, '原则（瑞·达利欧）', '管理类畅销书', 128.00, 200, true, '2024-01-01 00:00:00'),
(71, 34, '人类简史', '历史类畅销书', 68.00, 220, true, '2024-01-01 00:00:00'),
(72, 35, '英语四级词汇', '英语学习资料', 35.00, 500, true, '2024-01-01 00:00:00'),
(73, 35, '考研数学', '考研资料', 88.00, 300, true, '2024-01-01 00:00:00');

-- =====================================================
-- 插入商品图片数据
-- =====================================================
INSERT INTO product_images (product_id, image_url, alt_text, sort_order, is_primary, created_at) VALUES
(1, 'https://example.com/images/iphone15.jpg', 'iPhone 15 Pro Max', 1, true, '2024-01-01 00:00:00'),
(2, 'https://example.com/images/mate60.jpg', '华为Mate 60 Pro', 1, true, '2024-01-01 00:00:00'),
(3, 'https://example.com/images/mi14.jpg', '小米14 Ultra', 1, true, '2024-01-01 00:00:00'),
(6, 'https://example.com/images/macbook.jpg', 'MacBook Pro', 1, true, '2024-01-01 00:00:00'),
(7, 'https://example.com/images/macbookair.jpg', 'MacBook Air', 1, true, '2024-01-01 00:00:00');

-- 为其他商品随机生成图片
INSERT INTO product_images (product_id, image_url, alt_text, sort_order, is_primary, created_at)
SELECT
    p.product_id,
    'https://example.com/images/product' || p.product_id || '.jpg' AS image_url,
    p.name AS alt_text,
    1 AS sort_order,
    true AS is_primary,
    p.created_at AS created_at
FROM products p
WHERE p.product_id > 73
  AND NOT EXISTS (
      SELECT 1 FROM product_images pi WHERE pi.product_id = p.product_id
  );

-- =====================================================
-- 插入用户数据（10万用户）
-- =====================================================
-- 使用批量插入提高效率
DO $$
DECLARE
    i INTEGER;
    batch_size INTEGER := 1000;
    total_users INTEGER := 100000;
    first_name_list TEXT[] := ARRAY['张', '李', '王', '刘', '陈', '杨', '赵', '黄', '周', '吴'];
    last_name_list TEXT[] := ARRAY['伟', '芳', '娜', '秀英', '敏', '静', '丽', '强', '磊', '洋'];
    phone_prefixes TEXT[] := ARRAY['138', '139', '150', '151', '152', '185', '186', '187', '188', '189'];
BEGIN
    FOR batch_start IN 0..(total_users/batch_size)-1 LOOP
        INSERT INTO users (username, email, password_hash, first_name, last_name, phone, is_active, created_at, updated_at)
        SELECT
            'user' || (batch_start * batch_size + generate_series)::text AS username,
            'user' || (batch_start * batch_size + generate_series)::text || '@example.com' AS email,
            'hashed_password_' || (random() * 1000000)::int::text AS password_hash,
            first_name_list[(random() * 9)::int + 1] AS first_name,
            last_name_list[(random() * 9)::int + 1] AS last_name,
            phone_prefixes[(random() * 9)::int + 1] || lpad((random() * 100000000)::int::text, 8, '0') AS phone,
            true AS is_active,
            '2024-01-01 00:00:00'::timestamp + (random() * 365)::int * INTERVAL '1 day' AS created_at,
            '2024-01-01 00:00:00'::timestamp + (random() * 365)::int * INTERVAL '1 day' AS updated_at
        FROM generate_series(1, batch_size);

        -- 每10000条提交一次
        IF (batch_start + 1) % 10 = 0 THEN
            RAISE NOTICE '已插入 % 条用户数据', (batch_start + 1) * batch_size;
        END IF;
    END LOOP;
END $$;

-- =====================================================
-- 插入地址数据（每个用户2-5个地址）
-- =====================================================
DO $$
DECLARE
    user_record RECORD;
    address_count INTEGER;
    addr_idx INTEGER;
    phone_prefixes TEXT[] := ARRAY['138', '139', '150', '151', '152', '185', '186', '187', '188', '189'];
BEGIN
    FOR user_record IN SELECT user_id, first_name, last_name, phone, created_at, updated_at FROM users LOOP
        address_count := (random() * 4)::int + 2;

        INSERT INTO addresses (user_id, recipient_name, phone, province, city, district, street_address, postal_code, is_default, created_at)
        SELECT
            user_record.user_id,
            COALESCE(user_record.first_name, '') || COALESCE(user_record.last_name, '') AS recipient_name,
            COALESCE(user_record.phone,
                phone_prefixes[(random() * 9)::int + 1] || lpad((random() * 100000000)::int::text, 8, '0')
            ) AS phone,
            CASE (random() * 9)::int
                WHEN 0 THEN '北京市'
                WHEN 1 THEN '上海市'
                WHEN 2 THEN '广东省'
                WHEN 3 THEN '浙江省'
                WHEN 4 THEN '四川省'
                WHEN 5 THEN '湖北省'
                WHEN 6 THEN '陕西省'
                WHEN 7 THEN '江苏省'
                ELSE '重庆市'
            END AS province,
            CASE (random() * 9)::int
                WHEN 0 THEN '北京市'
                WHEN 1 THEN '上海市'
                WHEN 2 THEN '广州市'
                WHEN 3 THEN '深圳市'
                WHEN 4 THEN '杭州市'
                WHEN 5 THEN '成都市'
                WHEN 6 THEN '武汉市'
                WHEN 7 THEN '西安市'
                WHEN 8 THEN '南京市'
                ELSE '重庆市'
            END AS city,
            CASE (random() * 9)::int
                WHEN 0 THEN '朝阳区'
                WHEN 1 THEN '海淀区'
                WHEN 2 THEN '浦东新区'
                WHEN 3 THEN '黄浦区'
                WHEN 4 THEN '天河区'
                WHEN 5 THEN '越秀区'
                WHEN 6 THEN '福田区'
                WHEN 7 THEN '南山区'
                WHEN 8 THEN '西湖区'
                ELSE '滨江区'
            END AS district,
            CASE (random() * 9)::int
                WHEN 0 THEN '人民路'
                WHEN 1 THEN '建设路'
                WHEN 2 THEN '解放路'
                WHEN 3 THEN '中山路'
                WHEN 4 THEN '和平路'
                WHEN 5 THEN '胜利路'
                WHEN 6 THEN '友谊路'
                WHEN 7 THEN '光明路'
                WHEN 8 THEN '幸福路'
                ELSE '团结路'
            END || (random() * 999)::int::text AS street_address,
            lpad((random() * 999999)::int::text, 6, '0') AS postal_code,
            (generate_series = 1) AS is_default,
            user_record.created_at + (random() * 365)::int * INTERVAL '1 day' AS created_at
        FROM generate_series(1, address_count);
    END LOOP;
END $$;

-- =====================================================
-- 插入用户资料数据
-- =====================================================
DO $$
DECLARE
    user_record RECORD;
    gender_list CHAR(1)[] := ARRAY['男', '女'];
    user_created_at TIMESTAMP;
    user_updated_at TIMESTAMP;
BEGIN
    FOR user_record IN SELECT user_id, created_at, updated_at FROM users LIMIT 50000 LOOP
        user_created_at := user_record.created_at;
        user_updated_at := user_record.updated_at;

        INSERT INTO user_profiles (user_id, gender, birth_date, avatar_url, bio, created_at, updated_at)
        VALUES (
            user_record.user_id,
            gender_list[(random() * 1)::int + 1],
            '1990-01-01'::date + (random() * 365 * 30)::int * INTERVAL '1 day',
            'https://example.com/avatars/' || user_record.user_id || '.jpg',
            '这是用户' || user_record.user_id || '的个人简介',
            user_created_at,
            user_updated_at
        );
    END LOOP;
END $$;

-- =====================================================
-- 插入订单数据（10万订单）
-- =====================================================
DO $$
DECLARE
    i INTEGER;
    batch_size INTEGER := 1000;
    total_orders INTEGER := 100000;
    status_list VARCHAR(50)[] := ARRAY['pending', 'paid', 'shipped', 'delivered', 'cancelled', 'refunded'];
    order_date TIMESTAMP;
    user_ids INTEGER[];
    address_ids INTEGER[];
    addr_count INTEGER;
BEGIN
    -- 随机选择10000个活跃用户
    SELECT array_agg(user_id) INTO user_ids
    FROM users
    WHERE is_active = true
    ORDER BY random()
    LIMIT 10000;

    -- 获取这些用户的地址
    SELECT array_agg(address_id) INTO address_ids
    FROM addresses
    WHERE user_id = ANY(user_ids)
    ORDER BY random();

    -- 检查地址数量
    addr_count := COALESCE(array_length(address_ids, 1), 0);

    IF addr_count = 0 THEN
        RAISE NOTICE '警告：没有找到地址数据，跳过订单插入';
        RETURN;
    END IF;

    FOR batch_start IN 0..(total_orders/batch_size)-1 LOOP
        order_date := '2024-01-01 00:00:00'::timestamp + (batch_start * batch_size + random()) * INTERVAL '1 second';

        INSERT INTO orders (user_id, address_id, order_number, total_amount, status, created_at, updated_at)
        SELECT
            user_ids[(random() * 9999)::int + 1] AS user_id,
            address_ids[(random() * (addr_count - 1))::int + 1] AS address_id,
            'ORD' || TO_CHAR(order_date, 'YYYYMMDDHH24MISS') || lpad((batch_start * batch_size + generate_series)::text, 6, '0') AS order_number,
            (random() * 5000)::decimal(10,2) + 50.00 AS total_amount,
            status_list[(random() * 5)::int + 1] AS status,
            order_date AS created_at,
            order_date + INTERVAL '1 day' AS updated_at
        FROM generate_series(1, batch_size);

        -- 每10000条提交一次
        IF (batch_start + 1) % 10 = 0 THEN
            RAISE NOTICE '已插入 % 条订单数据', (batch_start + 1) * batch_size;
        END IF;
    END LOOP;
END $$;

-- =====================================================
-- 插入订单项数据（每个订单1-5个商品）
-- =====================================================
DO $$
DECLARE
    order_record RECORD;
    item_count INTEGER;
    product_ids INTEGER[];
    selected_product_id INTEGER;
    product_count INTEGER;
BEGIN
    -- 获取所有商品ID
    SELECT array_agg(product_id) INTO product_ids
    FROM products
    WHERE is_active = true;

    product_count := COALESCE(array_length(product_ids, 1), 0);

    IF product_count = 0 THEN
        RAISE NOTICE '警告：没有找到商品数据，跳过订单项插入';
        RETURN;
    END IF;

    FOR order_record IN SELECT order_id, total_amount, created_at FROM orders LIMIT 50000 LOOP
        item_count := (random() * 5)::int + 1;

        FOR item_idx IN 1..item_count LOOP
            selected_product_id := product_ids[(random() * (product_count - 1))::int + 1];

            INSERT INTO order_items (order_id, product_id, quantity, unit_price, subtotal, created_at)
            SELECT
                order_record.order_id,
                selected_product_id,
                (random() * 5)::int + 1,
                price,
                price * ((random() * 5)::int + 1),
                order_record.created_at
            FROM products
            WHERE product_id = selected_product_id;
        END LOOP;
    END LOOP;
END $$;

-- =====================================================
-- 插入订单状态历史数据
-- =====================================================
DO $$
DECLARE
    order_record RECORD;
    history_idx INTEGER;
    history_count INTEGER;
    status_array VARCHAR(50)[];
BEGIN
    FOR order_record IN SELECT order_id, status, created_at FROM orders LIMIT 30000 LOOP
        -- 根据订单状态生成历史记录
        IF order_record.status = 'pending' THEN
            status_array := ARRAY['pending'];
            history_count := 1;
        ELSIF order_record.status = 'paid' THEN
            status_array := ARRAY['pending', 'paid'];
            history_count := 2;
        ELSIF order_record.status = 'shipped' THEN
            status_array := ARRAY['pending', 'paid', 'shipped'];
            history_count := 3;
        ELSIF order_record.status = 'delivered' THEN
            status_array := ARRAY['pending', 'paid', 'shipped', 'delivered'];
            history_count := 4;
        ELSIF order_record.status = 'cancelled' THEN
            status_array := ARRAY['pending', 'cancelled'];
            history_count := 2;
        ELSIF order_record.status = 'refunded' THEN
            status_array := ARRAY['pending', 'paid', 'refunded'];
            history_count := 3;
        ELSE
            status_array := ARRAY['pending'];
            history_count := 1;
        END IF;
        
        FOR history_idx IN 1..history_count LOOP
            INSERT INTO order_status_history (order_id, status, remark, created_at)
            VALUES (
                order_record.order_id,
                status_array[history_idx],
                '订单状态变更为 ' || status_array[history_idx],
                order_record.created_at + (history_idx - 1) * INTERVAL '1 day'
            );
        END LOOP;
    END LOOP;
END $$;

-- =====================================================
-- 插入支付数据
-- =====================================================
DO $$
DECLARE
    order_record RECORD;
    payment_method_list VARCHAR(50)[] := ARRAY['微信支付', '支付宝', '信用卡', '借记卡', '余额支付'];
BEGIN
    FOR order_record IN SELECT order_id, total_amount, status, created_at FROM orders
                       WHERE status IN ('paid', 'shipped', 'delivered', 'refunded')
                       LIMIT 50000 LOOP

        INSERT INTO payments (order_id, payment_method, amount, status, transaction_id, created_at)
        VALUES (
            order_record.order_id,
            payment_method_list[(random() * 4)::int + 1],
            order_record.total_amount,
            CASE
                WHEN order_record.status = 'refunded' THEN 'refunded'
                ELSE 'success'
            END,
            'TXN' || TO_CHAR(order_record.created_at, 'YYYYMMDDHH24MISS') || order_record.order_id,
            order_record.created_at + INTERVAL '1 hour'
        );
    END LOOP;
END $$;

-- =====================================================
-- 插入评论数据（5万评论）
-- =====================================================
DO $$
DECLARE
    i INTEGER;
    batch_size INTEGER := 500;
    total_reviews INTEGER := 50000;
    title_list TEXT[] := ARRAY['非常好', '很满意', '物超所值', '值得购买', '质量不错', '一般般', '有点失望', '非常差'];
    content_list TEXT[] := ARRAY[
        '这个商品真的很不错，推荐购买！',
        '性价比很高，物流也快。',
        '质量和描述一致，满意。',
        '使用了一段时间，感觉很好。',
        '包装精美，送人很有面子。',
        '还可以，但不太惊艳。',
        '感觉有点贵，性价比一般。',
        '不太推荐，质量有待提升。'
    ];
BEGIN
    FOR batch_start IN 0..(total_reviews/batch_size)-1 LOOP
        INSERT INTO reviews (user_id, product_id, rating, title, content, is_verified, created_at, updated_at)
        SELECT
            (random() * 99999)::int + 1 AS user_id,
            (random() * 72)::int + 1 AS product_id,
            (random() * 4)::int + 1 AS rating,
            title_list[(random() * 7)::int + 1] AS title,
            content_list[(random() * 7)::int + 1] AS content,
            (random() > 0.5) AS is_verified,
            '2024-01-01 00:00:00'::timestamp + (random() * 365)::int * INTERVAL '1 day' AS created_at,
            '2024-01-01 00:00:00'::timestamp + (random() * 365)::int * INTERVAL '1 day' AS updated_at
        FROM generate_series(1, batch_size);

        -- 每5000条提交一次
        IF (batch_start + 1) % 10 = 0 THEN
            RAISE NOTICE '已插入 % 条评论数据', (batch_start + 1) * batch_size;
        END IF;
    END LOOP;
END $$;

-- =====================================================
-- 重置序列值
-- =====================================================
DO $$
BEGIN
    PERFORM setval('users_user_id_seq', (SELECT COALESCE(MAX(user_id), 1) FROM users));
    PERFORM setval('addresses_address_id_seq', (SELECT COALESCE(MAX(address_id), 1) FROM addresses));
    PERFORM setval('user_profiles_profile_id_seq', (SELECT COALESCE(MAX(profile_id), 1) FROM user_profiles));
    PERFORM setval('products_product_id_seq', (SELECT COALESCE(MAX(product_id), 1) FROM products));
    PERFORM setval('product_images_image_id_seq', (SELECT COALESCE(MAX(image_id), 1) FROM product_images));
    PERFORM setval('orders_order_id_seq', (SELECT COALESCE(MAX(order_id), 1) FROM orders));
    PERFORM setval('order_items_order_item_id_seq', (SELECT COALESCE(MAX(order_item_id), 1) FROM order_items));
    PERFORM setval('order_status_history_history_id_seq', (SELECT COALESCE(MAX(history_id), 1) FROM order_status_history));
    PERFORM setval('payments_payment_id_seq', (SELECT COALESCE(MAX(payment_id), 1) FROM payments));
    PERFORM setval('reviews_review_id_seq', (SELECT COALESCE(MAX(review_id), 1) FROM reviews));
END $$;

-- =====================================================
-- 数据插入完成
-- =====================================================

-- 显示统计信息
SELECT '用户数量' AS 统计项, COUNT(*) AS 数量 FROM users
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
