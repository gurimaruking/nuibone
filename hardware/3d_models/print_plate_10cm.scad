// ============================================
// NuiBone - 10cm版 印刷用プレート
// ============================================
// 全パーツを印刷しやすい向きに配置
// ============================================

include <config_10cm.scad>

use <body_frame_10cm.scad>
use <arm_bone_10cm.scad>
use <foot_10cm.scad>

// --- 印刷プレート（10cm版）---
module print_plate_10cm() {

    // === 胴体フレーム ===
    translate([0, 0, 0])
        body_frame_10cm();

    // === 腕 × 2 ===
    translate([40, 0, arm_length])
        rotate([180, 0, 0])
            arm_bone_10cm();

    translate([52, 0, arm_length])
        rotate([180, 0, 0])
            mirror([1, 0, 0])
                arm_bone_10cm();

    // === 脚 × 2 ===
    translate([40, 20, leg_length])
        leg_bone_10cm();

    translate([52, 20, leg_length])
        leg_bone_10cm();

    // === 足裏 × 2 ===
    translate([40, 35, 0])
        foot_base_10cm();

    translate([52, 35, 0])
        foot_base_10cm();
}

// --- 脚ボーン（コピー）---
module leg_bone_10cm() {
    difference() {
        union() {
            cylinder(h=4, d=4);
            hull() {
                cylinder(h=2, d=4);
                translate([0, 0, -leg_length + foot_height])
                    cube([bone_width, bone_thickness, 2], center=true);
            }
        }
        translate([0, 0, -1])
            cylinder(h=6, d=2 + tolerance);
    }
}

// --- 足裏ベース（コピー）---
module foot_base_10cm() {
    difference() {
        union() {
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
            translate([0, 0, foot_height])
                cylinder(h=2, d=bone_width + 1.5);
        }
        for (y = [-foot_length/4, foot_length/4]) {
            translate([0, y, -0.5])
                cylinder(h=magnet_height + 0.5, d=magnet_dia + tolerance);
        }
        translate([0, 0, magnet_height])
            cylinder(h=foot_height - magnet_height + 1, d=weight_hole_dia);
        translate([0, 0, foot_height - 1])
            cylinder(h=4, d=bone_width + tolerance);
    }
}

// --- メイン出力 ---
print_plate_10cm();

// プレートサイズ表示
echo("=== Print Plate Size (10cm version) ===");
echo("Approximate plate size: 70mm x 50mm");
echo("Recommended: 0.16mm layer, 25% infill");
echo("Note: Smaller parts require careful printing");
