// ============================================
// NuiBone - 胴体フレーム
// ============================================
// メインの骨格フレーム
// サーボ3個を収納、電池ホルダーは外付け
// ============================================

include <config.scad>

// --- 胴体フレーム本体 ---
module body_frame() {
    difference() {
        union() {
            // メインフレーム（背骨）
            main_spine();

            // 肩マウント部
            translate([0, 0, body_height - shoulder_offset])
                shoulder_mounts();

            // 呼吸サーボマウント
            translate([0, 0, body_height/2 - 5])
                breathing_servo_mount();

            // 腰部（足接続部）
            translate([0, 0, 0])
                hip_section();
        }

        // サーボ配線穴
        wiring_channels();
    }
}

// --- メインスパイン（背骨）---
module main_spine() {
    // 中央の背骨
    translate([0, -body_depth/2 + bone_thickness, 0])
        cube([bone_width, bone_thickness, body_height], center=false);

    // 上部横バー（肩支持）
    translate([-body_width/2, -body_depth/2 + bone_thickness, body_height - bone_thickness])
        cube([body_width, bone_thickness, bone_thickness]);

    // 下部横バー（腰支持）
    translate([-body_width/2, -body_depth/2 + bone_thickness, 0])
        cube([body_width, bone_thickness, bone_thickness]);

    // 前面補強バー
    translate([-body_width/4, body_depth/2 - bone_thickness*2, body_height/2 - 10])
        cube([body_width/2, bone_thickness, 20]);
}

// --- 肩マウント ---
module shoulder_mounts() {
    // 左肩サーボマウント
    translate([-body_width/2 - 2, 0, 0])
        rotate([0, -90, 0])
            servo_mount_vertical();

    // 右肩サーボマウント
    translate([body_width/2 + 2, 0, 0])
        rotate([0, 90, 0])
            servo_mount_vertical();
}

// --- 縦向きサーボマウント ---
module servo_mount_vertical() {
    difference() {
        // マウントベース
        union() {
            cube([sg90_height + 4, sg90_depth + 4, sg90_width + 4], center=true);

            // 取付フランジ
            translate([0, 0, sg90_width/2 + 2])
                cube([sg90_flange_width + 4, bone_thickness*2, 4], center=true);
        }

        // サーボ本体穴
        cube([sg90_height + tolerance, sg90_depth + tolerance, sg90_width + tolerance], center=true);

        // 出力軸穴
        translate([sg90_height/2, 0, 0])
            cylinder(h=sg90_width + 10, d=sg90_shaft_dia + 2, center=true);

        // 取付穴
        for (x = [-sg90_mount_dist/2, sg90_mount_dist/2]) {
            translate([x, 0, sg90_width/2 + 2])
                cylinder(h=10, d=sg90_mount_hole, center=true);
        }

        // 配線穴
        translate([-sg90_height/2 - 5, 0, 0])
            cube([10, 5, sg90_width], center=true);
    }
}

// --- 呼吸サーボマウント ---
module breathing_servo_mount() {
    translate([0, body_depth/4, 0]) {
        difference() {
            // マウントベース
            union() {
                cube([sg90_width + 6, sg90_depth + 4, sg90_height + 4], center=true);

                // 背骨への接続部
                translate([0, -sg90_depth/2 - body_depth/4, 0])
                    cube([bone_width + 4, body_depth/2, sg90_height + 4], center=true);
            }

            // サーボ本体穴
            cube([sg90_width + tolerance, sg90_depth + tolerance, sg90_height + tolerance], center=true);

            // 出力軸穴（上向き）
            translate([0, 0, sg90_height/2])
                cylinder(h=10, d=sg90_shaft_dia + 2, center=true);

            // 配線穴
            translate([0, -sg90_depth/2 - 5, 0])
                cube([5, 10, sg90_height], center=true);
        }
    }
}

// --- 腰部 ---
module hip_section() {
    // 腰ベース
    hull() {
        translate([-body_width/2 + 5, -body_depth/2 + bone_thickness, 0])
            cube([body_width - 10, bone_thickness, bone_thickness]);

        translate([-body_width/4, -body_depth/2 + bone_thickness, -5])
            cube([body_width/2, bone_thickness, bone_thickness]);
    }

    // 足接続ポイント（左右）
    for (x = [-body_width/4, body_width/4]) {
        translate([x, -body_depth/2 + bone_thickness, -5]) {
            difference() {
                cylinder(h=8, d=8);
                translate([0, 0, -1])
                    cylinder(h=10, d=3);  // 接続穴
            }
        }
    }
}

// --- 配線チャンネル ---
module wiring_channels() {
    // 背骨に沿った配線溝
    translate([0, -body_depth/2 + bone_thickness + 2, 5])
        cube([2, 3, body_height - 10], center=false);
}

// --- ESP32マウント穴（外付け用）---
module esp32_mount_holes() {
    // 背面にESP32を外付けするための穴
    translate([0, -body_depth/2 - 5, body_height/2]) {
        for (pos = [[-10, 0, -15], [10, 0, -15], [-10, 0, 15], [10, 0, 15]]) {
            translate(pos)
                rotate([90, 0, 0])
                    cylinder(h=10, d=2, center=true);
        }
    }
}

// --- メインの出力 ---
body_frame();

// プレビュー用サーボ表示（コメントアウトで非表示）
// %translate([-body_width/2 - sg90_width/2 - 2, 0, body_height - shoulder_offset])
//     cube([sg90_width, sg90_depth, sg90_height], center=true);
