// ============================================
// NuiBone - 10cm版 足パーツ
// ============================================
// 小型磁石と重りで直立補助
// ============================================

include <config_10cm.scad>

// --- 足アセンブリ（10cm版）---
module foot_assembly_10cm() {
    // 脚部
    leg_bone_10cm();

    // 足裏
    translate([0, 0, -leg_length])
        foot_base_10cm();
}

// --- 脚ボーン（10cm版）---
module leg_bone_10cm() {
    difference() {
        union() {
            // 股関節接続部
            cylinder(h=4, d=4);

            // 脚本体
            hull() {
                cylinder(h=2, d=4);
                translate([0, 0, -leg_length + foot_height])
                    cube([bone_width, bone_thickness, 2], center=true);
            }
        }

        // 股関節穴
        translate([0, 0, -1])
            cylinder(h=6, d=2 + tolerance);
    }
}

// --- 足裏ベース（10cm版）---
module foot_base_10cm() {
    magnet_count = 2;  // 片足あたりの磁石数

    difference() {
        union() {
            // 足裏本体（丸みを帯びた形状）
            hull() {
                translate([-foot_width/2 + 1.5, -foot_length/2 + 1.5, 0])
                    cylinder(h=foot_height, r=1.5);
                translate([foot_width/2 - 1.5, -foot_length/2 + 1.5, 0])
                    cylinder(h=foot_height, r=1.5);
                translate([-foot_width/2 + 1.5, foot_length/2 - 1.5, 0])
                    cylinder(h=foot_height, r=1.5);
                translate([foot_width/2 - 1.5, foot_length/2 - 1.5, 0])
                    cylinder(h=foot_height, r=1.5);
            }

            // 脚接続ボス
            translate([0, 0, foot_height])
                cylinder(h=2, d=bone_width + 1.5);
        }

        // 磁石穴（前後に2個）
        for (y = [-foot_length/4, foot_length/4]) {
            translate([0, y, -0.5])
                cylinder(h=magnet_height + 0.5, d=magnet_dia + tolerance);
        }

        // 重り穴（中央）
        translate([0, 0, magnet_height])
            cylinder(h=foot_height - magnet_height + 1, d=weight_hole_dia);

        // 脚接続穴
        translate([0, 0, foot_height - 1])
            cylinder(h=4, d=bone_width + tolerance);
    }
}

// --- 足裏（磁石1個版）---
// さらに小さいぬいぐるみ用
module foot_base_10cm_single_magnet() {
    difference() {
        union() {
            // 足裏本体
            cylinder(h=foot_height, d=foot_width);

            // 脚接続ボス
            translate([0, 0, foot_height])
                cylinder(h=2, d=bone_width + 1.5);
        }

        // 磁石穴（1個）
        translate([0, 0, -0.5])
            cylinder(h=magnet_height + 0.5, d=magnet_dia + tolerance);

        // 脚接続穴
        translate([0, 0, foot_height - 1])
            cylinder(h=4, d=bone_width + tolerance);
    }
}

// --- 足全体（左右セット）---
module feet_pair_10cm() {
    // 左足
    foot_assembly_10cm();

    // 右足（ミラー）
    translate([foot_width + 8, 0, 0])
        mirror([1, 0, 0])
            foot_assembly_10cm();
}

// --- 印刷用パーツ展開 ---
module foot_parts_10cm_for_print() {
    // 左脚
    translate([0, 0, leg_length])
        leg_bone_10cm();

    // 右脚
    translate([10, 0, leg_length])
        leg_bone_10cm();

    // 左足裏
    translate([20, 0, 0])
        foot_base_10cm();

    // 右足裏
    translate([32, 0, 0])
        foot_base_10cm();

    // 単一磁石版（オプション）
    translate([44, 0, 0])
        foot_base_10cm_single_magnet();

    translate([54, 0, 0])
        foot_base_10cm_single_magnet();
}

// --- メイン出力 ---
foot_assembly_10cm();

// 印刷用（コメントアウトで切替）
// foot_parts_10cm_for_print();

// 左右ペア表示
// feet_pair_10cm();
