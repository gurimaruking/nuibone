// ============================================
// NuiBone - 10cm ぬいぐるみサイズ解析
// ============================================
// 10cmぬいの内部空間と部品サイズの検証
// ============================================

$fn = 32;

// ============================================
// 10cmぬいぐるみの典型的なサイズ
// ============================================
// 外形（縫いぐるみ外側）
nui_total_height = 100;      // 全高 100mm
nui_head_dia = 45;           // 頭直径 約45mm
nui_body_height = 35;        // 胴体高さ 約35mm
nui_body_width = 35;         // 胴体幅 約35mm
nui_body_depth = 25;         // 胴体厚み 約25mm
nui_arm_length = 25;         // 腕長さ 約25mm
nui_arm_dia = 12;            // 腕直径 約12mm
nui_leg_length = 25;         // 脚長さ 約25mm
nui_leg_dia = 14;            // 脚直径 約14mm

// 内部空間（綿を除いた利用可能スペース）
// 布厚み + 綿の余裕 = 約5-8mm マージン
margin = 6;

internal_body_width = nui_body_width - margin * 2;   // 約23mm
internal_body_depth = nui_body_depth - margin * 2;   // 約13mm
internal_body_height = nui_body_height - margin;      // 約29mm
internal_arm_dia = nui_arm_dia - margin;              // 約6mm
internal_leg_dia = nui_leg_dia - margin;              // 約8mm

// ============================================
// 部品サイズ
// ============================================

// マイクロサーボ候補
// SG51R: 約 16.2 x 6.0 x 12.0 mm (最小クラス)
sg51r_w = 6.0;
sg51r_h = 16.2;
sg51r_d = 12.0;

// 振動モーター（代替案）
// コイン型: φ8 x 3mm
vib_motor_dia = 8;
vib_motor_h = 3;

// ESP32モジュール候補
// Seeed XIAO ESP32C3: 21 x 17.5 x 4 mm
xiao_w = 17.5;
xiao_h = 21;
xiao_d = 4;

// MAX98357A DAC: 約 17 x 14 x 3 mm (小型版)
dac_w = 14;
dac_h = 17;
dac_d = 3;

// microSDカードアダプタ（超小型版）: 約 15 x 14 x 2 mm
sd_w = 14;
sd_h = 15;
sd_d = 2;

// スピーカー: φ15 x 4 mm（超薄型）
speaker_dia = 15;
speaker_h = 4;

// LiPo電池: 約 20 x 15 x 4 mm (100mAh)
lipo_w = 15;
lipo_h = 20;
lipo_d = 4;

// 磁石: φ3 x 1.5 mm
magnet_dia = 3;
magnet_h = 1.5;

// ============================================
// 可視化
// ============================================

// ぬいぐるみ外形（半透明）
module nui_outline_10cm() {
    color([1, 0.8, 0.7], 0.2) {
        // 頭
        translate([0, 0, nui_body_height + nui_head_dia/2 - 5])
            sphere(d=nui_head_dia);

        // 胴体
        translate([0, 0, nui_body_height/2])
            resize([nui_body_width, nui_body_depth, nui_body_height])
                sphere(d=10);

        // 左腕
        translate([-nui_body_width/2 - nui_arm_length/2 + 5, 0, nui_body_height - 8])
            rotate([0, 90, 0])
                cylinder(h=nui_arm_length, d=nui_arm_dia, center=true);

        // 右腕
        translate([nui_body_width/2 + nui_arm_length/2 - 5, 0, nui_body_height - 8])
            rotate([0, 90, 0])
                cylinder(h=nui_arm_length, d=nui_arm_dia, center=true);

        // 左脚
        translate([-8, 0, -nui_leg_length/2 + 3])
            cylinder(h=nui_leg_length, d=nui_leg_dia, center=true);

        // 右脚
        translate([8, 0, -nui_leg_length/2 + 3])
            cylinder(h=nui_leg_length, d=nui_leg_dia, center=true);
    }
}

// 内部利用可能空間
module internal_space() {
    color([0, 1, 0], 0.1) {
        translate([0, 0, nui_body_height/2])
            cube([internal_body_width, internal_body_depth, internal_body_height], center=true);
    }
}

// 部品配置案
module components_layout() {
    // === 胴体内部品 ===

    // XIAO ESP32C3 (背面上部)
    color([0, 0.5, 0])
        translate([0, -internal_body_depth/2 + xiao_d/2 + 1, nui_body_height - xiao_h/2 - 3])
            cube([xiao_w, xiao_d, xiao_h], center=true);

    // LiPo電池 (背面中央)
    color([1, 0.5, 0])
        translate([0, -internal_body_depth/2 + lipo_d/2 + 1, nui_body_height/2])
            cube([lipo_w, lipo_d, lipo_h], center=true);

    // スピーカー (胸部前面)
    color([0.3, 0.3, 0.3])
        translate([0, internal_body_depth/2 - speaker_h/2, nui_body_height/2 + 3])
            rotate([90, 0, 0])
                cylinder(h=speaker_h, d=speaker_dia, center=true);

    // DAC (電池横)
    color([0.5, 0, 0.5])
        translate([-internal_body_width/2 + dac_w/2 + 1, 0, nui_body_height/2 - 5])
            cube([dac_w, dac_d, dac_h], center=true);

    // SDカード (電池横)
    color([0, 0, 1])
        translate([internal_body_width/2 - sd_w/2 - 1, 0, nui_body_height/2 - 5])
            cube([sd_w, sd_d, sd_h], center=true);

    // === 振動モーター版（サーボ代替）===

    // 左腕モーター
    color([1, 0, 0])
        translate([-nui_body_width/2 + 2, 0, nui_body_height - 8])
            rotate([0, 90, 0])
                cylinder(h=vib_motor_h, d=vib_motor_dia, center=true);

    // 右腕モーター
    color([1, 0, 0])
        translate([nui_body_width/2 - 2, 0, nui_body_height - 8])
            rotate([0, 90, 0])
                cylinder(h=vib_motor_h, d=vib_motor_dia, center=true);

    // 胸モーター（呼吸用）
    color([1, 0, 0])
        translate([0, internal_body_depth/2 - 5, nui_body_height/2 - 8])
            cylinder(h=vib_motor_h, d=vib_motor_dia, center=true);

    // === 足の磁石 ===
    for (x = [-8, 8]) {
        color([0.7, 0.7, 0.7])
            translate([x, 0, -nui_leg_length + 2])
                cylinder(h=magnet_h, d=magnet_dia, center=true);
    }
}

// ============================================
// サイズチェック結果
// ============================================
module size_check() {
    echo("========================================");
    echo("10cm ぬいぐるみ 内部空間解析");
    echo("========================================");
    echo(str("胴体内部空間: ", internal_body_width, " x ", internal_body_depth, " x ", internal_body_height, " mm"));
    echo(str("  → 約 ", internal_body_width * internal_body_depth * internal_body_height / 1000, " cm³"));
    echo("");
    echo("【結論】");
    echo("- SG90 (12.2mm幅) は入らない → SG51R or 振動モーター必須");
    echo("- 単3電池 (φ14.5 x 50mm) は入らない → LiPo電池必須");
    echo("- 標準SDカードモジュール (24x32mm) は入らない → microSD直付け or 超小型版");
    echo("- ESP32-DevKit は入らない → XIAO ESP32C3 推奨");
    echo("");
    echo("【推奨構成】");
    echo("- マイコン: Seeed XIAO ESP32C3 (21x17.5x4mm)");
    echo("- 電源: LiPo 1S 100-150mAh (20x15x4mm)");
    echo("- 動力: 振動モーター φ8x3mm x 3個");
    echo("- オーディオ: MAX98357A小型版 + φ15mmスピーカー");
    echo("- 音声データ: XIAO内蔵フラッシュ or SPI Flash");
    echo("========================================");
}

// ============================================
// メイン表示
// ============================================
nui_outline_10cm();
internal_space();
components_layout();
size_check();
