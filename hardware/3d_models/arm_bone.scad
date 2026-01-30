// ============================================
// NuiBone - 腕ボーン
// ============================================
// サーボホーンに接続する腕の骨
// 左右共通（ミラーして使用）
// ============================================

include <config.scad>

// --- 腕ボーン ---
module arm_bone() {
    difference() {
        union() {
            // サーボホーン接続部（肩側）
            servo_horn_connector();

            // 上腕部
            translate([0, 0, 0])
                upper_arm();

            // 前腕部
            translate([0, 0, -arm_length + 5])
                forearm();
        }

        // 軽量化穴
        lightening_holes();
    }
}

// --- サーボホーン接続部 ---
module servo_horn_connector() {
    // SG90の付属ホーンに接続する部分
    horn_hole_dia = 2;      // ホーン取付穴
    horn_center_dia = 7;    // ホーン中心部直径

    difference() {
        // 接続ベース
        hull() {
            cylinder(h=arm_thickness, d=horn_center_dia + 4, center=true);
            translate([0, 0, -8])
                cube([arm_width, arm_width, 1], center=true);
        }

        // ホーン中心穴
        cylinder(h=arm_thickness + 2, d=horn_center_dia + tolerance, center=true);

        // ホーン固定穴（ネジ用）
        for (a = [0, 90, 180, 270]) {
            rotate([0, 0, a])
                translate([horn_center_dia/2 + 1.5, 0, 0])
                    cylinder(h=arm_thickness + 2, d=horn_hole_dia, center=true);
        }
    }

    // ホーンをクランプするリング
    difference() {
        cylinder(h=arm_thickness + 1, d=horn_center_dia + 2, center=true);
        cylinder(h=arm_thickness + 3, d=horn_center_dia + tolerance, center=true);

        // スリット（弾性確保）
        translate([0, horn_center_dia/2, 0])
            cube([1, 3, arm_thickness + 3], center=true);
    }
}

// --- 上腕部 ---
module upper_arm() {
    hull() {
        translate([0, 0, -3])
            cube([arm_width, arm_thickness, 1], center=true);
        translate([0, 0, -arm_length/2])
            cube([arm_width + 1, arm_thickness, 1], center=true);
    }
}

// --- 前腕部 ---
module forearm() {
    hull() {
        cube([arm_width + 1, arm_thickness, 1], center=true);
        translate([0, 0, -arm_length/2 + 5])
            sphere(d=arm_width);
    }

    // 手先の丸み
    translate([0, 0, -arm_length/2 + 3])
        sphere(d=arm_width + 1);
}

// --- 軽量化穴 ---
module lightening_holes() {
    // 上腕の軽量化
    for (z = [-10, -20]) {
        translate([0, 0, z])
            rotate([90, 0, 0])
                cylinder(h=arm_thickness + 2, d=2, center=true);
    }
}

// --- 腕ボーン（サーボホーン一体型）---
// サーボに直接取り付けるバージョン
module arm_bone_direct() {
    difference() {
        union() {
            // サーボ軸接続部
            cylinder(h=3, d=sg90_shaft_dia + 2);

            // 腕本体
            translate([0, 0, 0])
                hull() {
                    cylinder(h=3, d=8);
                    translate([0, 0, -arm_length])
                        sphere(d=arm_width);
                }
        }

        // サーボ軸穴（Dカット対応）
        difference() {
            cylinder(h=5, d=sg90_shaft_dia + tolerance, center=true);
            translate([sg90_shaft_dia/2, 0, 0])
                cube([1, sg90_shaft_dia, 6], center=true);
        }

        // 固定ネジ穴
        translate([0, 0, 1.5])
            rotate([90, 0, 0])
                cylinder(h=10, d=2, center=true);
    }
}

// --- メイン出力 ---
arm_bone();

// 直接取付バージョン（コメントアウトで切替）
// translate([20, 0, 0]) arm_bone_direct();
