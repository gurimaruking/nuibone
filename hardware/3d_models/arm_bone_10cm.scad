// ============================================
// NuiBone - 10cm版 腕ボーン
// ============================================
// マイクロサーボ用の小型腕
// ============================================

include <config_10cm.scad>

// --- 腕ボーン（マイクロサーボ版）---
module arm_bone_10cm() {
    difference() {
        union() {
            // サーボ軸接続部
            cylinder(h=2.5, d=servo_shaft_dia + 2);

            // 上腕
            hull() {
                cylinder(h=2, d=servo_shaft_dia + 2);
                translate([0, 0, -arm_length/2])
                    cube([arm_width, arm_thickness, 2], center=true);
            }

            // 前腕
            hull() {
                translate([0, 0, -arm_length/2])
                    cube([arm_width, arm_thickness, 2], center=true);
                translate([0, 0, -arm_length + 2])
                    sphere(d=arm_width);
            }
        }

        // サーボ軸穴（Dカット）
        difference() {
            translate([0, 0, -1])
                cylinder(h=4, d=servo_shaft_dia + tolerance);
            translate([servo_shaft_dia/2 - 0.3, 0, 0])
                cube([1, servo_shaft_dia, 5], center=true);
        }

        // 固定ネジ穴
        translate([0, 0, 1.5])
            rotate([90, 0, 0])
                cylinder(h=8, d=1.2, center=true);
    }
}

// --- 腕ボーン（振動モーター版）---
// モーターなしの装飾用腕
module arm_bone_10cm_passive() {
    // 肩ジョイント
    sphere(d=4);

    // 腕本体
    hull() {
        sphere(d=4);
        translate([0, 0, -arm_length + 3])
            sphere(d=arm_width);
    }

    // 手先
    translate([0, 0, -arm_length + 2])
        sphere(d=arm_width + 0.5);
}

// --- ワイヤー駆動版（オプション）---
// サーボから離れた位置にワイヤーで動かす
module arm_bone_10cm_wire() {
    difference() {
        union() {
            // 肩ピボット
            sphere(d=5);

            // 腕本体
            hull() {
                translate([0, 0, -2])
                    sphere(d=4);
                translate([0, 0, -arm_length + 2])
                    sphere(d=arm_width);
            }
        }

        // ピボット穴
        rotate([90, 0, 0])
            cylinder(h=8, d=1.5, center=true);

        // ワイヤー穴
        translate([0, 0, -arm_length/3])
            rotate([90, 0, 0])
                cylinder(h=6, d=1, center=true);
    }
}

// --- 印刷用パーツ展開 ---
module arm_parts_10cm_for_print() {
    // 左腕
    translate([0, 0, arm_length])
        rotate([180, 0, 0])
            arm_bone_10cm();

    // 右腕（ミラー）
    translate([15, 0, arm_length])
        rotate([180, 0, 0])
            mirror([1, 0, 0])
                arm_bone_10cm();

    // パッシブ腕（振動モーター版用）
    translate([30, 0, arm_length])
        rotate([180, 0, 0])
            arm_bone_10cm_passive();

    translate([40, 0, arm_length])
        rotate([180, 0, 0])
            arm_bone_10cm_passive();
}

// --- メイン出力 ---
arm_bone_10cm();

// 印刷用（コメントアウトで切替）
// arm_parts_10cm_for_print();
