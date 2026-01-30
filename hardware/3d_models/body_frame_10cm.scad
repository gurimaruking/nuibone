// ============================================
// NuiBone - 10cm版 胴体フレーム
// ============================================
// 10cmぬいぐるみ用のコンパクトな骨格
// マイクロサーボまたは振動モーター対応
// ============================================

include <config_10cm.scad>

// --- 胴体フレーム本体 ---
module body_frame_10cm() {
    difference() {
        union() {
            // メインフレーム（背骨）
            main_spine_10cm();

            // 肩マウント部（マイクロサーボ用）
            translate([0, 0, body_height - shoulder_offset])
                shoulder_mounts_10cm();

            // 呼吸機構マウント
            translate([0, 0, body_height/2 - 3])
                breathing_mount_10cm();

            // 腰部（足接続部）
            hip_section_10cm();
        }

        // 配線穴
        wiring_channels_10cm();
    }
}

// --- メインスパイン（背骨）10cm版 ---
module main_spine_10cm() {
    // 中央の背骨
    translate([-bone_width/2, -body_depth/2, 0])
        cube([bone_width, bone_thickness, body_height]);

    // 上部横バー
    translate([-body_width/2, -body_depth/2, body_height - bone_thickness])
        cube([body_width, bone_thickness, bone_thickness]);

    // 下部横バー
    translate([-body_width/2, -body_depth/2, 0])
        cube([body_width, bone_thickness, bone_thickness]);

    // リブ（補強）
    translate([-body_width/3, -body_depth/2, body_height/2])
        cube([body_width*2/3, bone_thickness, bone_thickness]);
}

// --- 肩マウント（マイクロサーボ用）---
module shoulder_mounts_10cm() {
    // 左肩
    translate([-body_width/2, 0, 0])
        micro_servo_mount();

    // 右肩
    translate([body_width/2, 0, 0])
        mirror([1, 0, 0])
            micro_servo_mount();
}

// --- マイクロサーボマウント ---
module micro_servo_mount() {
    difference() {
        // マウントベース
        translate([-servo_width/2 - 2, -servo_depth/2 - 1, -servo_height/2])
            cube([servo_width + 4, servo_depth + 2, servo_height]);

        // サーボ本体穴
        translate([-servo_width/2, -servo_depth/2, -servo_height/2 - 1])
            cube([servo_width + tolerance, servo_depth + tolerance, servo_height + 2]);

        // 出力軸穴
        translate([-servo_width/2 - 5, 0, 0])
            rotate([0, 90, 0])
                cylinder(h=10, d=servo_shaft_dia + 2);

        // 配線穴
        translate([servo_width/2 - 2, 0, -servo_height/2 - 2])
            cylinder(h=servo_height + 4, d=3);
    }
}

// --- 呼吸機構マウント（10cm版）---
module breathing_mount_10cm() {
    // 振動モーターまたはSMAワイヤー用のシンプルなマウント
    translate([0, body_depth/4, 0]) {
        difference() {
            union() {
                // マウントベース
                cube([vibration_motor_dia + 4, vibration_motor_len + 2, 8], center=true);

                // 背骨への接続
                translate([0, -vibration_motor_len/2 - 3, 0])
                    cube([bone_width + 2, 6, 8], center=true);
            }

            // モーター穴
            rotate([90, 0, 0])
                cylinder(h=vibration_motor_len + 4, d=vibration_motor_dia + tolerance, center=true);
        }
    }
}

// --- 腰部（10cm版）---
module hip_section_10cm() {
    // 腰ベース
    hull() {
        translate([-body_width/2 + 3, -body_depth/2, 0])
            cube([body_width - 6, bone_thickness, bone_thickness]);

        translate([-body_width/3, -body_depth/2, -4])
            cube([body_width*2/3, bone_thickness, bone_thickness]);
    }

    // 足接続ポイント
    for (x = [-body_width/4, body_width/4]) {
        translate([x, -body_depth/2, -4]) {
            difference() {
                cylinder(h=6, d=5);
                translate([0, 0, -1])
                    cylinder(h=8, d=2);  // 接続穴
            }
        }
    }
}

// --- 配線チャンネル ---
module wiring_channels_10cm() {
    // 背骨に沿った配線溝
    translate([-1, -body_depth/2 + bone_thickness, 3])
        cube([2, 2, body_height - 6]);
}

// --- ESP32マウント用穴（外付け）---
module esp32_mount_holes_10cm() {
    // 背面にXIAOまたはESP32-C3を外付け
    translate([0, -body_depth/2 - 5, body_height/2]) {
        for (pos = [[-8, 0, -8], [8, 0, -8], [-8, 0, 8], [8, 0, 8]]) {
            translate(pos)
                rotate([90, 0, 0])
                    cylinder(h=6, d=1.5, center=true);
        }
    }
}

// --- 振動モーター版フレーム ---
// サーボなしの簡易版
module body_frame_10cm_vibration() {
    difference() {
        union() {
            main_spine_10cm();

            // 振動モーターマウント（胸部）
            translate([0, body_depth/4, body_height - 12])
                vibration_motor_holder();

            // 振動モーターマウント（左腕）
            translate([-body_width/2, 0, body_height - shoulder_offset])
                rotate([0, -90, 0])
                    vibration_motor_holder();

            // 振動モーターマウント（右腕）
            translate([body_width/2, 0, body_height - shoulder_offset])
                rotate([0, 90, 0])
                    vibration_motor_holder();

            hip_section_10cm();
        }

        wiring_channels_10cm();
    }
}

// --- 振動モーターホルダー ---
module vibration_motor_holder() {
    difference() {
        cylinder(h=vibration_motor_len + 2, d=vibration_motor_dia + 3);
        translate([0, 0, -1])
            cylinder(h=vibration_motor_len + 4, d=vibration_motor_dia + tolerance);
        // スリット（挿入用）
        translate([0, vibration_motor_dia/2 + 1, vibration_motor_len/2])
            cube([1.5, 3, vibration_motor_len + 4], center=true);
    }
}

// --- メイン出力 ---
body_frame_10cm();

// 振動モーター版（コメントアウトで切替）
// translate([50, 0, 0]) body_frame_10cm_vibration();
