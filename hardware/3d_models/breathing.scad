// ============================================
// NuiBone - 呼吸機構
// ============================================
// サーボの回転を上下動に変換するリンク機構
// 胸部を押し上げて呼吸を表現
// ============================================

include <config.scad>

// --- 呼吸機構アセンブリ ---
module breathing_assembly() {
    // サーボホーンに取り付けるクランクアーム
    crank_arm();

    // 上下動するプッシュロッド
    translate([0, 0, crank_radius])
        push_rod();

    // 胸プレート（押し上げ部）
    translate([0, 0, crank_radius + push_rod_length])
        chest_plate();
}

// --- パラメータ ---
crank_radius = 8;        // クランク半径（ストローク = 2 × radius）
push_rod_length = 15;    // プッシュロッド長さ
push_rod_dia = 3;        // プッシュロッド直径

// --- クランクアーム ---
module crank_arm() {
    difference() {
        union() {
            // サーボ軸接続部
            cylinder(h=4, d=sg90_shaft_dia + 3);

            // クランクアーム本体
            hull() {
                cylinder(h=3, d=8);
                translate([crank_radius, 0, 0])
                    cylinder(h=3, d=6);
            }
        }

        // サーボ軸穴（Dカット）
        difference() {
            translate([0, 0, -1])
                cylinder(h=6, d=sg90_shaft_dia + tolerance);
            translate([sg90_shaft_dia/2, 0, 0])
                cube([1, sg90_shaft_dia, 8], center=true);
        }

        // クランクピン穴
        translate([crank_radius, 0, -1])
            cylinder(h=6, d=push_rod_dia + tolerance);

        // 固定ネジ穴
        translate([4, 0, 2])
            rotate([0, 90, 0])
                cylinder(h=10, d=1.5);
    }
}

// --- プッシュロッド ---
module push_rod() {
    difference() {
        union() {
            // ロッド本体
            cylinder(h=push_rod_length, d=push_rod_dia);

            // 下部（クランクピン）
            translate([0, 0, -2])
                cylinder(h=4, d=push_rod_dia - tolerance);

            // 上部（胸プレート接続）
            translate([0, 0, push_rod_length])
                sphere(d=push_rod_dia + 2);
        }
    }
}

// --- 胸プレート ---
module chest_plate() {
    plate_width = breath_plate_size;
    plate_depth = breath_plate_size * 0.8;
    plate_height = 3;

    difference() {
        union() {
            // プレート本体（丸みを帯びた形状）
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

            // プッシュロッド受け
            translate([0, 0, -5])
                cylinder(h=5, d=push_rod_dia + 4);
        }

        // プッシュロッド穴
        translate([0, 0, -6])
            cylinder(h=8, d=push_rod_dia + tolerance);

        // 軽量化穴
        for (x = [-plate_width/3, plate_width/3]) {
            for (y = [-plate_depth/3, plate_depth/3]) {
                translate([x, y, -1])
                    cylinder(h=plate_height + 2, d=4);
            }
        }
    }
}

// --- スライドガイド（オプション）---
// プッシュロッドの横ブレを防ぐ
module slide_guide() {
    guide_height = 10;

    difference() {
        cube([10, 10, guide_height], center=true);

        // ロッド穴
        cylinder(h=guide_height + 2, d=push_rod_dia + 1, center=true);

        // 取付穴
        for (x = [-3, 3]) {
            translate([x, 0, 0])
                rotate([90, 0, 0])
                    cylinder(h=12, d=2, center=true);
        }
    }
}

// --- 単品出力（印刷用）---
module breathing_parts_for_print() {
    // クランクアーム
    crank_arm();

    // プッシュロッド
    translate([20, 0, 0])
        push_rod();

    // 胸プレート
    translate([40, 0, 0])
        chest_plate();

    // スライドガイド
    translate([60, 0, 5])
        slide_guide();
}

// --- メイン出力 ---
// アセンブリ表示
breathing_assembly();

// 印刷用パーツ展開（コメントアウトで切替）
// breathing_parts_for_print();
