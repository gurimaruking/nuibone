// ============================================
// NuiBone - フルアセンブリ
// ============================================
// 全パーツを組み合わせた完成形プレビュー
// ============================================

include <config.scad>

use <body_frame.scad>
use <arm_bone.scad>
use <breathing.scad>
use <foot.scad>

// --- フルアセンブリ ---
module full_assembly() {
    // 胴体フレーム
    color(color_bone)
        body_frame();

    // 左腕
    color(color_bone)
        translate([-body_width/2 - 5, 0, body_height - shoulder_offset])
            rotate([0, -90, 0])
                arm_bone();

    // 右腕
    color(color_bone)
        translate([body_width/2 + 5, 0, body_height - shoulder_offset])
            rotate([0, 90, 0])
                arm_bone();

    // 呼吸機構
    color(color_bone)
        translate([0, body_depth/4, body_height/2 - 5 + sg90_height/2 + 2])
            breathing_assembly();

    // 左足
    color(color_bone)
        translate([-body_width/4, -body_depth/2 + bone_thickness, -5])
            rotate([0, 0, 0])
                foot_assembly();

    // 右足
    color(color_bone)
        translate([body_width/4, -body_depth/2 + bone_thickness, -5])
            rotate([0, 0, 0])
                foot_assembly();

    // サーボ（プレビュー用）
    preview_servos();
}

// --- サーボプレビュー ---
module preview_servos() {
    // 左肩サーボ
    color(color_servo, 0.5)
        translate([-body_width/2 - sg90_width/2 - 3, 0, body_height - shoulder_offset])
            cube([sg90_width, sg90_depth, sg90_height], center=true);

    // 右肩サーボ
    color(color_servo, 0.5)
        translate([body_width/2 + sg90_width/2 + 3, 0, body_height - shoulder_offset])
            cube([sg90_width, sg90_depth, sg90_height], center=true);

    // 呼吸サーボ
    color(color_servo, 0.5)
        translate([0, body_depth/4, body_height/2 - 5])
            cube([sg90_width, sg90_depth, sg90_height], center=true);
}

// --- ぬいぐるみサイズ参考 ---
module nui_outline() {
    color([1, 0.8, 0.8], 0.2) {
        // 頭
        translate([0, 0, body_height + 20])
            sphere(d=40);

        // 胴体
        translate([0, 0, body_height/2])
            scale([1, 0.6, 1])
                sphere(d=50);
    }
}

// --- 寸法確認用 ---
module dimension_check() {
    echo("=== NuiBone Dimensions ===");
    echo(str("Total height (approx): ", body_height + leg_length + foot_height, " mm"));
    echo(str("Body width: ", body_width, " mm"));
    echo(str("Body depth: ", body_depth, " mm"));
    echo(str("Arm span: ", body_width + arm_length * 2 + 10, " mm"));
}

// --- メイン出力 ---
full_assembly();

// ぬいぐるみ外形参考（コメントアウトで表示）
// nui_outline();

// 寸法確認
dimension_check();
