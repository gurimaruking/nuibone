// ============================================
// NuiBone 10cm版 - 完成図
// ============================================
// 全部品（骨格・電子部品・配線）を配置した完成図
// ============================================

$fn = 32;

// ============================================
// 部品寸法（実測ベース）
// ============================================

// --- ぬいぐるみ内部利用可能空間 ---
internal_body_width = 23;    // 胴体幅 (mm)
internal_body_depth = 13;    // 胴体厚み (mm)
internal_body_height = 29;   // 胴体高さ (mm)

// --- Seeed XIAO ESP32C3 ---
xiao_w = 17.5;
xiao_h = 21.0;
xiao_d = 4.0;

// --- LiPo電池 (100mAh 1S) ---
lipo_w = 15;
lipo_h = 20;
lipo_d = 4;

// --- 振動モーター (コイン型) ---
vib_dia = 8;
vib_h = 3;

// --- MAX98357A DAC (超小型版) ---
dac_w = 14;
dac_h = 17;
dac_d = 3;

// --- スピーカー (15mm薄型) ---
speaker_dia = 15;
speaker_h = 4;

// --- 磁石 ---
magnet_dia = 3;
magnet_h = 1.5;

// --- 骨格寸法 ---
bone_thick = 1.5;
spine_width = 3;

// ============================================
// 色設定
// ============================================
color_bone = [0.95, 0.95, 0.9];       // 骨格（白）
color_pcb = [0.1, 0.4, 0.1];          // 基板（緑）
color_battery = [0.2, 0.2, 0.8];      // 電池（青）
color_motor = [0.6, 0.4, 0.2];        // モーター（茶）
color_speaker = [0.2, 0.2, 0.2];      // スピーカー（黒）
color_wire_pwr = [1, 0, 0];           // 電源線（赤）
color_wire_gnd = [0.1, 0.1, 0.1];     // GND線（黒）
color_wire_sig = [1, 0.5, 0];         // 信号線（橙）
color_magnet = [0.7, 0.7, 0.75];      // 磁石（銀）

// ============================================
// 部品モジュール
// ============================================

// XIAO ESP32C3
module xiao_esp32c3() {
    color(color_pcb) {
        // 基板
        cube([xiao_w, xiao_d, xiao_h], center=true);

        // USBコネクタ
        translate([0, -xiao_d/2 - 1, xiao_h/2 - 3])
            color([0.7, 0.7, 0.7])
                cube([9, 3, 3], center=true);

        // チップ
        translate([0, xiao_d/2 - 1, 0])
            color([0.2, 0.2, 0.2])
                cube([6, 1, 6], center=true);
    }
}

// LiPo電池
module lipo_battery() {
    color(color_battery) {
        cube([lipo_w, lipo_d, lipo_h], center=true);

        // 端子
        translate([0, lipo_d/2, lipo_h/2 - 2])
            color([1, 1, 1])
                cube([8, 2, 3], center=true);
    }
}

// 振動モーター
module vibration_motor() {
    color(color_motor) {
        cylinder(h=vib_h, d=vib_dia, center=true);

        // リード線
        translate([0, vib_dia/4, vib_h/2])
            color(color_wire_pwr)
                cylinder(h=5, d=0.5);
        translate([0, -vib_dia/4, vib_h/2])
            color(color_wire_gnd)
                cylinder(h=5, d=0.5);
    }
}

// MAX98357A DAC
module dac_module() {
    color(color_pcb) {
        cube([dac_w, dac_d, dac_h], center=true);

        // ICチップ
        translate([0, 0, dac_d/2])
            color([0.1, 0.1, 0.1])
                cube([5, 5, 1], center=true);

        // 端子台
        translate([0, dac_h/2 - 2, dac_d/2])
            color([0.8, 0.8, 0.8])
                cube([10, 3, 2], center=true);
    }
}

// スピーカー
module speaker_15mm() {
    color(color_speaker) {
        // 本体
        cylinder(h=speaker_h, d=speaker_dia, center=true);

        // コーン
        translate([0, 0, speaker_h/2 - 0.5])
            color([0.4, 0.4, 0.4])
                cylinder(h=1, d=speaker_dia - 3, center=true);

        // 端子
        for (x = [-3, 3]) {
            translate([x, speaker_dia/2 - 2, 0])
                color([0.8, 0.7, 0.3])
                    cube([1, 2, 1], center=true);
        }
    }
}

// ネオジム磁石
module magnet() {
    color(color_magnet)
        cylinder(h=magnet_h, d=magnet_dia, center=true);
}

// ============================================
// 骨格モジュール
// ============================================

// メイン骨格（10cm版）
module bone_frame_10cm() {
    color(color_bone) {
        // 背骨
        translate([0, -internal_body_depth/2 + bone_thick/2, internal_body_height/2])
            cube([spine_width, bone_thick, internal_body_height - 4], center=true);

        // 上部横バー（肩）
        translate([0, -internal_body_depth/2 + bone_thick/2, internal_body_height - 2])
            cube([internal_body_width - 2, bone_thick, bone_thick], center=true);

        // 中部横バー
        translate([0, -internal_body_depth/2 + bone_thick/2, internal_body_height/2])
            cube([internal_body_width - 4, bone_thick, bone_thick], center=true);

        // 下部横バー（腰）
        translate([0, -internal_body_depth/2 + bone_thick/2, 3])
            cube([internal_body_width - 2, bone_thick, bone_thick], center=true);

        // 左肩ジョイント
        translate([-internal_body_width/2 + 2, 0, internal_body_height - 5])
            sphere(d=4);

        // 右肩ジョイント
        translate([internal_body_width/2 - 2, 0, internal_body_height - 5])
            sphere(d=4);

        // 左腕骨
        translate([-internal_body_width/2 - 8, 0, internal_body_height - 5])
            rotate([0, 90, 0])
                cylinder(h=12, d=2, center=true);

        // 右腕骨
        translate([internal_body_width/2 + 8, 0, internal_body_height - 5])
            rotate([0, 90, 0])
                cylinder(h=12, d=2, center=true);

        // 左脚ジョイント
        translate([-6, -internal_body_depth/2 + bone_thick/2, 2])
            sphere(d=3);

        // 右脚ジョイント
        translate([6, -internal_body_depth/2 + bone_thick/2, 2])
            sphere(d=3);

        // 左脚骨
        translate([-6, 0, -8])
            cylinder(h=18, d=2);

        // 右脚骨
        translate([6, 0, -8])
            cylinder(h=18, d=2);

        // 左足裏
        translate([-6, 0, -10]) {
            hull() {
                translate([-3, -4, 0]) cylinder(h=2, d=3);
                translate([3, -4, 0]) cylinder(h=2, d=3);
                translate([-3, 4, 0]) cylinder(h=2, d=3);
                translate([3, 4, 0]) cylinder(h=2, d=3);
            }
        }

        // 右足裏
        translate([6, 0, -10]) {
            hull() {
                translate([-3, -4, 0]) cylinder(h=2, d=3);
                translate([3, -4, 0]) cylinder(h=2, d=3);
                translate([-3, 4, 0]) cylinder(h=2, d=3);
                translate([3, 4, 0]) cylinder(h=2, d=3);
            }
        }
    }
}

// ============================================
// 配線モジュール
// ============================================

module wiring() {
    wire_d = 0.8;

    // === 電源配線 (赤) ===
    color(color_wire_pwr) {
        // 電池→XIAO
        translate([lipo_w/2, 0, internal_body_height/2 + lipo_h/2])
            rotate([0, 0, 0])
                cylinder(h=8, d=wire_d);

        // XIAO→DAC
        translate([-xiao_w/2, 0, internal_body_height - 5])
            rotate([0, 90, 0])
                cylinder(h=6, d=wire_d);

        // XIAO→モーター（分岐）
        translate([0, 0, internal_body_height - xiao_h/2])
            sphere(d=2);  // 分岐点
    }

    // === GND配線 (黒) ===
    color(color_wire_gnd) {
        // 共通GND
        translate([lipo_w/2 + 2, 0, internal_body_height/2 + lipo_h/2])
            cylinder(h=8, d=wire_d);
    }

    // === 信号配線 (橙) ===
    color(color_wire_sig) {
        // XIAO→左腕モーター
        translate([-xiao_w/2, 0, internal_body_height - 8])
            rotate([0, 90, 0])
                cylinder(h=internal_body_width/2 + 5, d=wire_d);

        // XIAO→右腕モーター
        translate([xiao_w/2, 0, internal_body_height - 8])
            rotate([0, -90, 0])
                cylinder(h=internal_body_width/2 + 5, d=wire_d);

        // XIAO→胸モーター
        translate([0, internal_body_depth/2 - 5, internal_body_height - xiao_h])
            cylinder(h=5, d=wire_d);

        // XIAO→DAC (I2S)
        for (i = [0:2]) {
            translate([-xiao_w/2 + 3 + i*2, 0, internal_body_height - 10])
                rotate([0, 90, 0])
                    cylinder(h=5, d=wire_d);
        }

        // DAC→スピーカー
        translate([-internal_body_width/2 + dac_w + 3, internal_body_depth/2 - 5, internal_body_height/2])
            rotate([90, 0, 0])
                cylinder(h=8, d=wire_d);
    }
}

// ============================================
// 完成アセンブリ
// ============================================

module complete_assembly_10cm() {
    // === 骨格 ===
    bone_frame_10cm();

    // === XIAO ESP32C3 (背面上部) ===
    translate([0, -internal_body_depth/2 + xiao_d/2 + 1, internal_body_height - xiao_h/2 - 2])
        rotate([90, 0, 0])
            rotate([0, 0, 90])
                xiao_esp32c3();

    // === LiPo電池 (背面中央) ===
    translate([0, -internal_body_depth/2 + lipo_d/2 + 1, internal_body_height/2])
        lipo_battery();

    // === 振動モーター x 3 ===
    // 左腕
    translate([-internal_body_width/2 - 5, 0, internal_body_height - 5])
        rotate([0, 90, 0])
            vibration_motor();

    // 右腕
    translate([internal_body_width/2 + 5, 0, internal_body_height - 5])
        rotate([0, -90, 0])
            vibration_motor();

    // 胸（呼吸）
    translate([0, internal_body_depth/2 - vib_h/2 - 1, internal_body_height/2 - 5])
        rotate([90, 0, 0])
            vibration_motor();

    // === DAC (左側) ===
    translate([-internal_body_width/2 + dac_w/2 + 1, 0, internal_body_height/2 - 3])
        rotate([90, 0, 0])
            dac_module();

    // === スピーカー (胸部前面) ===
    translate([0, internal_body_depth/2 - speaker_h/2, internal_body_height/2 + 3])
        rotate([90, 0, 0])
            speaker_15mm();

    // === 磁石 (足裏) ===
    translate([-6, -2, -10 - magnet_h/2])
        magnet();
    translate([-6, 2, -10 - magnet_h/2])
        magnet();
    translate([6, -2, -10 - magnet_h/2])
        magnet();
    translate([6, 2, -10 - magnet_h/2])
        magnet();

    // === 配線 ===
    wiring();
}

// ============================================
// ぬいぐるみ外形（参考）
// ============================================

module nui_silhouette() {
    color([1, 0.85, 0.75], 0.15) {
        // 頭
        translate([0, 0, internal_body_height + 20])
            sphere(d=45);

        // 胴体
        translate([0, 0, internal_body_height/2])
            resize([35, 25, 35])
                sphere(d=10);

        // 腕
        for (x = [-1, 1]) {
            translate([x * 25, 0, internal_body_height - 5])
                rotate([0, 90 * x, 0])
                    cylinder(h=20, d=12, center=true);
        }

        // 脚
        for (x = [-8, 8]) {
            translate([x, 0, -12])
                cylinder(h=25, d=14, center=true);
        }
    }
}

// ============================================
// 断面図
// ============================================

module cross_section() {
    difference() {
        complete_assembly_10cm();

        // Y方向でカット
        translate([0, 50, 0])
            cube([100, 100, 200], center=true);
    }
}

// ============================================
// 寸法情報
// ============================================

module dimension_info() {
    echo("========================================");
    echo("NuiBone 10cm版 完成図 - 部品リスト");
    echo("========================================");
    echo("【電子部品】");
    echo(str("  Seeed XIAO ESP32C3: ", xiao_w, "x", xiao_h, "x", xiao_d, "mm"));
    echo(str("  LiPo電池 100mAh: ", lipo_w, "x", lipo_h, "x", lipo_d, "mm"));
    echo(str("  振動モーター: φ", vib_dia, "x", vib_h, "mm x 3個"));
    echo(str("  MAX98357A DAC: ", dac_w, "x", dac_h, "x", dac_d, "mm"));
    echo(str("  スピーカー: φ", speaker_dia, "x", speaker_h, "mm"));
    echo(str("  磁石: φ", magnet_dia, "x", magnet_h, "mm x 4個"));
    echo("");
    echo("【内部空間】");
    echo(str("  利用可能: ", internal_body_width, "x", internal_body_depth, "x", internal_body_height, "mm"));
    echo(str("  体積: 約", internal_body_width * internal_body_depth * internal_body_height / 1000, "cm³"));
    echo("========================================");
}

// ============================================
// メイン出力
// ============================================

// 完成アセンブリ
complete_assembly_10cm();

// ぬいぐるみ外形（参考表示）
nui_silhouette();

// 寸法情報
dimension_info();

// 断面図（コメントアウトで切替）
// cross_section();
