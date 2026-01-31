// ============================================
// NuiBone - スピーカーマウント
// ============================================
// 20-28mm小型スピーカー用マウント
// 胴体フレームに取り付け可能
// ============================================

include <config.scad>

// --- スピーカー寸法 ---
// 一般的な小型スピーカーサイズ
speaker_dia = 23;        // スピーカー直径 (mm) - 20-28mm対応
speaker_depth = 5;       // スピーカー厚み (mm)
speaker_flange = 2;      // フランジ幅 (mm)

// --- SDカードモジュール寸法 ---
sd_module_width = 24;    // SDカードモジュール幅 (mm)
sd_module_length = 32;   // SDカードモジュール長さ (mm)
sd_module_height = 3;    // SDカードモジュール厚み (mm)

// --- I2S DAC (MAX98357A) 寸法 ---
dac_width = 17;          // DACモジュール幅 (mm)
dac_length = 21;         // DACモジュール長さ (mm)
dac_height = 3;          // DACモジュール厚み (mm)

// --- スピーカーマウント（胴体取付型）---
module speaker_mount() {
    difference() {
        union() {
            // マウントベース
            cylinder(h=speaker_depth + 3, d=speaker_dia + 6);

            // 取付フランジ
            translate([0, 0, speaker_depth + 1])
                cube([speaker_dia + 10, 8, 4], center=true);
        }

        // スピーカー穴
        translate([0, 0, 2])
            cylinder(h=speaker_depth + 3, d=speaker_dia + tolerance);

        // スピーカーフランジ受け
        translate([0, 0, -1])
            cylinder(h=3, d=speaker_dia + speaker_flange*2 + tolerance);

        // 音穴（複数の小穴）
        for (a = [0:45:315]) {
            rotate([0, 0, a])
                translate([speaker_dia/4, 0, -1])
                    cylinder(h=4, d=3);
        }
        // 中央の音穴
        translate([0, 0, -1])
            cylinder(h=4, d=5);

        // 取付穴
        for (x = [-(speaker_dia/2 + 3), (speaker_dia/2 + 3)]) {
            translate([x, 0, speaker_depth + 1])
                cylinder(h=6, d=3, center=true);
        }
    }
}

// --- スピーカーマウント（背面取付型）---
// 15cm版用：背中に外付け
module speaker_mount_back() {
    mount_thick = 3;

    difference() {
        union() {
            // ベースプレート
            hull() {
                translate([-speaker_dia/2 - 3, -speaker_dia/2 - 3, 0])
                    cylinder(h=mount_thick, r=3);
                translate([speaker_dia/2 + 3, -speaker_dia/2 - 3, 0])
                    cylinder(h=mount_thick, r=3);
                translate([-speaker_dia/2 - 3, speaker_dia/2 + 3, 0])
                    cylinder(h=mount_thick, r=3);
                translate([speaker_dia/2 + 3, speaker_dia/2 + 3, 0])
                    cylinder(h=mount_thick, r=3);
            }

            // スピーカーホルダーリング
            translate([0, 0, mount_thick])
                difference() {
                    cylinder(h=speaker_depth, d=speaker_dia + 4);
                    translate([0, 0, -1])
                        cylinder(h=speaker_depth + 2, d=speaker_dia + tolerance);
                }

            // クリップ（スピーカー固定用）
            for (a = [0, 120, 240]) {
                rotate([0, 0, a])
                    translate([speaker_dia/2 + 1, 0, mount_thick])
                        speaker_clip();
            }
        }

        // 音穴パターン
        for (a = [0:30:330]) {
            rotate([0, 0, a])
                translate([speaker_dia/4, 0, -1])
                    cylinder(h=mount_thick + 2, d=2.5);
        }
        translate([0, 0, -1])
            cylinder(h=mount_thick + 2, d=4);

        // 取付穴（ぬいぐるみへの縫い付け用）
        for (pos = [
            [-speaker_dia/2 - 1, -speaker_dia/2 - 1],
            [speaker_dia/2 + 1, -speaker_dia/2 - 1],
            [-speaker_dia/2 - 1, speaker_dia/2 + 1],
            [speaker_dia/2 + 1, speaker_dia/2 + 1]
        ]) {
            translate([pos[0], pos[1], -1])
                cylinder(h=mount_thick + 2, d=2);
        }
    }
}

// --- スピーカークリップ ---
module speaker_clip() {
    hull() {
        cube([2, 4, speaker_depth - 1]);
        translate([0, 1, speaker_depth - 1])
            cube([2, 2, 1]);
    }
    // 内向きの爪
    translate([-1, 1, speaker_depth - 2])
        cube([1, 2, 2]);
}

// --- SDカードモジュールマウント ---
module sd_card_mount() {
    mount_thick = 2;

    difference() {
        union() {
            // ベース
            cube([sd_module_width + 4, sd_module_length + 4, mount_thick]);

            // 側面ガイド
            translate([0, 0, mount_thick]) {
                cube([2, sd_module_length + 4, sd_module_height + 1]);
                translate([sd_module_width + 2, 0, 0])
                    cube([2, sd_module_length + 4, sd_module_height + 1]);
            }

            // 前面ストッパー
            translate([0, 0, mount_thick])
                cube([sd_module_width + 4, 2, sd_module_height + 1]);
        }

        // モジュール空間
        translate([2, 2, -1])
            cube([sd_module_width + tolerance, sd_module_length + 2, mount_thick + sd_module_height + 3]);

        // 配線穴
        translate([sd_module_width/2 + 2, sd_module_length + 2, -1])
            cube([10, 4, mount_thick + 2], center=true);

        // 取付穴
        for (pos = [[3, 3], [sd_module_width + 1, 3]]) {
            translate([pos[0], pos[1], -1])
                cylinder(h=mount_thick + 2, d=2);
        }
    }
}

// --- DAC (MAX98357A) マウント ---
module dac_mount() {
    mount_thick = 2;

    difference() {
        union() {
            // ベース
            cube([dac_width + 4, dac_length + 4, mount_thick]);

            // 側面ガイド
            translate([0, 0, mount_thick]) {
                cube([2, dac_length + 4, dac_height + 1]);
                translate([dac_width + 2, 0, 0])
                    cube([2, dac_length + 4, dac_height + 1]);
            }
        }

        // モジュール空間
        translate([2, 2, -1])
            cube([dac_width + tolerance, dac_length + 2, mount_thick + dac_height + 3]);

        // 配線穴（両端）
        translate([dac_width/2 + 2, 1, -1])
            cube([8, 4, mount_thick + 2], center=true);
        translate([dac_width/2 + 2, dac_length + 3, -1])
            cube([8, 4, mount_thick + 2], center=true);

        // 取付穴
        for (pos = [[3, 3], [dac_width + 1, 3]]) {
            translate([pos[0], pos[1], -1])
                cylinder(h=mount_thick + 2, d=2);
        }
    }
}

// --- オーディオモジュール統合マウント ---
// スピーカー + DAC を一体化
module audio_module_mount() {
    // スピーカーマウント
    speaker_mount_back();

    // DACマウント（スピーカー横に配置）
    translate([speaker_dia/2 + 5, -dac_length/2, 0])
        dac_mount();
}

// --- 10cm版スピーカーマウント ---
// より小型の15mmスピーカー用
module speaker_mount_10cm() {
    speaker_dia_10cm = 15;
    speaker_depth_10cm = 4;
    mount_thick = 2;

    difference() {
        union() {
            // 薄型ベース
            cylinder(h=mount_thick, d=speaker_dia_10cm + 5);

            // スピーカーリング
            translate([0, 0, mount_thick])
                difference() {
                    cylinder(h=speaker_depth_10cm, d=speaker_dia_10cm + 3);
                    translate([0, 0, -1])
                        cylinder(h=speaker_depth_10cm + 2, d=speaker_dia_10cm + tolerance);
                }
        }

        // 音穴
        for (a = [0:60:300]) {
            rotate([0, 0, a])
                translate([speaker_dia_10cm/4, 0, -1])
                    cylinder(h=mount_thick + 2, d=2);
        }
        translate([0, 0, -1])
            cylinder(h=mount_thick + 2, d=3);

        // 縫い付け穴
        for (a = [45, 135, 225, 315]) {
            rotate([0, 0, a])
                translate([speaker_dia_10cm/2 + 1.5, 0, -1])
                    cylinder(h=mount_thick + 2, d=1.5);
        }
    }
}

// --- 印刷用パーツ展開 ---
module audio_parts_for_print() {
    // スピーカーマウント（背面型）
    speaker_mount_back();

    // DACマウント
    translate([speaker_dia + 15, 0, 0])
        dac_mount();

    // SDカードマウント
    translate([speaker_dia + 15, dac_length + 10, 0])
        sd_card_mount();

    // 10cm版スピーカーマウント
    translate([0, speaker_dia + 15, 0])
        speaker_mount_10cm();
}

// --- メイン出力 ---
speaker_mount_back();

// 印刷用（コメントアウトで切替）
// audio_parts_for_print();

// オーディオモジュール統合版
// translate([60, 0, 0]) audio_module_mount();
