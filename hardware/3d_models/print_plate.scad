// ============================================
// NuiBone - 印刷用プレート
// ============================================
// 全パーツを印刷しやすい向きに配置
// ============================================

include <config.scad>

use <body_frame.scad>
use <arm_bone.scad>
use <breathing.scad>
use <foot.scad>

// --- 印刷プレート ---
module print_plate() {

    // === 胴体フレーム ===
    translate([0, 0, 0])
        body_frame();

    // === 腕 × 2 ===
    // 左腕
    translate([60, 0, arm_length])
        rotate([180, 0, 0])
            arm_bone();

    // 右腕（ミラー）
    translate([80, 0, arm_length])
        rotate([180, 0, 0])
            mirror([1, 0, 0])
                arm_bone();

    // === 呼吸機構 ===
    // クランクアーム
    translate([60, 30, 0])
        crank_arm();

    // プッシュロッド
    translate([80, 30, 0])
        push_rod();

    // 胸プレート
    translate([70, 55, 0])
        chest_plate();

    // === 脚 × 2 ===
    translate([100, 0, leg_length])
        leg_bone();

    translate([115, 0, leg_length])
        leg_bone();

    // === 足裏 × 2 ===
    translate([100, 30, 0])
        foot_base();

    translate([120, 30, 0])
        foot_base();
}

// --- 呼吸部品（別モジュール参照用）---
module crank_arm() {
    crank_radius = 8;
    push_rod_dia = 3;

    difference() {
        union() {
            cylinder(h=4, d=sg90_shaft_dia + 3);
            hull() {
                cylinder(h=3, d=8);
                translate([crank_radius, 0, 0])
                    cylinder(h=3, d=6);
            }
        }
        difference() {
            translate([0, 0, -1])
                cylinder(h=6, d=sg90_shaft_dia + tolerance);
            translate([sg90_shaft_dia/2, 0, 0])
                cube([1, sg90_shaft_dia, 8], center=true);
        }
        translate([crank_radius, 0, -1])
            cylinder(h=6, d=push_rod_dia + tolerance);
    }
}

module push_rod() {
    push_rod_length = 15;
    push_rod_dia = 3;

    union() {
        cylinder(h=push_rod_length, d=push_rod_dia);
        translate([0, 0, -2])
            cylinder(h=4, d=push_rod_dia - tolerance);
        translate([0, 0, push_rod_length])
            sphere(d=push_rod_dia + 2);
    }
}

module chest_plate() {
    plate_width = breath_plate_size;
    plate_depth = breath_plate_size * 0.8;
    plate_height = 3;
    push_rod_dia = 3;

    difference() {
        union() {
            hull() {
                translate([-plate_width/2, -plate_depth/2, 0])
                    cylinder(h=plate_height, r=3);
                translate([plate_width/2, -plate_depth/2, 0])
                    cylinder(h=plate_height, r=3);
                translate([-plate_width/2, plate_depth/2, 0])
                    cylinder(h=plate_height, r=3);
                translate([plate_width/2, plate_depth/2, 0])
                    cylinder(h=plate_height, r=3);
            }
            translate([0, 0, -5])
                cylinder(h=5, d=push_rod_dia + 4);
        }
        translate([0, 0, -6])
            cylinder(h=8, d=push_rod_dia + tolerance);
        for (x = [-plate_width/3, plate_width/3]) {
            for (y = [-plate_depth/3, plate_depth/3]) {
                translate([x, y, -1])
                    cylinder(h=plate_height + 2, d=4);
            }
        }
    }
}

module leg_bone() {
    difference() {
        union() {
            cylinder(h=5, d=6);
            hull() {
                cylinder(h=3, d=6);
                translate([0, 0, -leg_length + foot_height])
                    cube([bone_width, bone_thickness, 3], center=true);
            }
        }
        translate([0, 0, -1])
            cylinder(h=8, d=3 + tolerance);
    }
}

module foot_base() {
    difference() {
        union() {
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
            translate([0, 0, foot_height])
                cylinder(h=3, d=bone_width + 2);
        }
        for (y = [-foot_length/4, foot_length/4]) {
            translate([0, y, -0.5])
                cylinder(h=magnet_height + 0.5, d=magnet_dia + tolerance);
        }
        translate([0, 0, magnet_height])
            cylinder(h=foot_height - magnet_height, d=weight_hole_dia);
        translate([0, 0, foot_height - 1])
            cylinder(h=5, d=bone_width + tolerance);
    }
}

// --- メイン出力 ---
print_plate();

// プレートサイズ表示
echo("=== Print Plate Size ===");
echo("Approximate plate size: 140mm x 70mm");
echo("Recommended: 0.2mm layer, 20% infill, supports for overhangs");
