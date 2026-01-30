// ============================================
// NuiBone - 足パーツ
// ============================================
// 磁石と重りを内蔵して直立を補助
// ============================================

include <config.scad>

// --- 足アセンブリ ---
module foot_assembly() {
    // 脚部
    leg_bone();

    // 足裏
    translate([0, 0, -leg_length])
        foot_base();
}

// --- 脚ボーン ---
module leg_bone() {
    difference() {
        union() {
            // 股関節接続部
            cylinder(h=5, d=6);

            // 脚本体
            hull() {
                cylinder(h=3, d=6);
                translate([0, 0, -leg_length + foot_height])
                    cube([bone_width, bone_thickness, 3], center=true);
            }
        }

        // 股関節穴
        translate([0, 0, -1])
            cylinder(h=8, d=3 + tolerance);
    }
}

// --- 足裏ベース ---
module foot_base() {
    magnet_count = 2;  // 片足あたりの磁石数

    difference() {
        union() {
            // 足裏本体
            hull() {
                translate([-foot_width/2 + 2, -foot_length/2 + 2, 0])
                    cylinder(h=foot_height, r=2);
                translate([foot_width/2 - 2, -foot_length/2 + 2, 0])
                    cylinder(h=foot_height, r=2);
                translate([-foot_width/2 + 2, foot_length/2 - 2, 0])
                    cylinder(h=foot_height, r=2);
                translate([foot_width/2 - 2, foot_length/2 - 2, 0])
                    cylinder(h=foot_height, r=2);
            }

            // 脚接続ボス
            translate([0, 0, foot_height])
                cylinder(h=3, d=bone_width + 2);
        }

        // 磁石穴（前後に2個）
        for (y = [-foot_length/4, foot_length/4]) {
            translate([0, y, -0.5])
                cylinder(h=magnet_height + 0.5, d=magnet_dia + tolerance);
        }

        // 重り穴（中央）
        translate([0, 0, magnet_height])
            cylinder(h=foot_height - magnet_height, d=weight_hole_dia);

        // 脚接続穴
        translate([0, 0, foot_height - 1])
            cylinder(h=5, d=bone_width + tolerance);
    }
}

// --- 重りキャップ ---
// 重りを入れた後に蓋をする
module weight_cap() {
    difference() {
        cylinder(h=1.5, d=weight_hole_dia + 2);
        translate([0, 0, 0.5])
            cylinder(h=1.5, d=weight_hole_dia - 1);
    }
}

// --- 磁石固定リング ---
// 磁石を押さえるリング（オプション）
module magnet_retainer() {
    difference() {
        cylinder(h=1, d=magnet_dia + 3);
        translate([0, 0, -0.5])
            cylinder(h=2, d=magnet_dia + tolerance);
    }
}

// --- 足全体（左右セット）---
module feet_pair() {
    // 左足
    foot_assembly();

    // 右足（ミラー）
    translate([foot_width + 10, 0, 0])
        mirror([1, 0, 0])
            foot_assembly();
}

// --- 印刷用パーツ展開 ---
module foot_parts_for_print() {
    // 左脚
    translate([0, 0, leg_length])
        leg_bone();

    // 右脚
    translate([15, 0, leg_length])
        leg_bone();

    // 左足裏
    translate([30, 0, 0])
        foot_base();

    // 右足裏
    translate([50, 0, 0])
        foot_base();

    // 重りキャップ × 2
    translate([70, 0, 0])
        weight_cap();
    translate([80, 0, 0])
        weight_cap();
}

// --- メイン出力 ---
foot_assembly();

// 印刷用（コメントアウトで切替）
// foot_parts_for_print();

// 左右ペア表示
// feet_pair();
