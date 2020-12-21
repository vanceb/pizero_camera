$fa = 1;
$fs = 0.4;

touch = 0.001;      // Small margin to avoid "touching faces"

// Base legs
base_leg_l = 80;    // Length of the base legs
base_leg_w = 15;    // Width of the base legs
base_leg_h = 3;     // Height or thickness
base_leg_r = 5;     // Rounded corner radius

// Pillar
pillar_dia = 20;    // Diameter of the pillar
pillar_h = 50;      // Height of the pillar before the dome is added

mount_space = 15;   // How much space to give for the arm to drop below 90 deg
mount_dia = 3.5;    // Diameter of the mounting hole

filet_r = 5;        // Filet radius for the bottom of the pillar

// Arm
arm_l = 30;         // Length of the arm
arm_fix_w = 4;      // 
arm_plate_w = 70;   // Width of the mounting plate
arm_plate_d = 35;   // Depth of the mounting plate
arm_plate_th = 2;   // Thickness of the mounting plate
arm_plate_r=5;      // Radius of corner rounding

screw_dia = 3;      // Diameter of the screw used to fix the arm to the stand

// Clip
clip_w = 5;
clip_th = 2;
case_w = 40;
case_th = 14;
tolerance = 0.5;

module pillar(h, dia, filet_r, mount_space, mount_dia) {

    difference() {
        union() {
            // Column
            linear_extrude(height=h) {
                circle(r=dia/2);
            }
            // Spherical top
            translate([0, 0, h]) {
                sphere(r=dia/2);
            }
            // Filet
            translate([0,0,filet_r])
            rotate_extrude(angle=360, convexity = 2) {
                translate([(dia/2 + filet_r - 0.001),0,0])
                rotate(180)
                difference() {
                    square(filet_r);    
                    circle(filet_r);
                }
            }
        }
        union () {
            // Cut outs at top of pillar
            // Halve the sphere
            translate([dia/2, 0, h - mount_space]) {
                linear_extrude(height=(dia/2 + mount_space)) {
                    square([dia, dia], center=true);
                }
            }
            // Mount Hole
            translate([touch, 0, h]) {
                rotate([0, -90, 0]) {
                    linear_extrude(h - dia) {
                        circle(r=mount_dia/2);
                    }
                }
            }
        }
    }
}

module stand (h, dia, leg_l, leg_w, leg_h, leg_r, mount_space, mount_hole_dia) {
    // Base
    linear_extrude(height=leg_h) {            
        offset(r=leg_r) {
            rotate([0, 0, 45]) {
                square([leg_l, leg_w], center=true);
            }
            rotate([0, 0, -45]) {
                square([leg_l, leg_w], center=true);
            }
        }
    }
    // Pillar
    translate([0, 0, leg_h - touch]) { 
        pillar(h, dia, leg_r, mount_space, mount_hole_dia);
    }
}

module arm (l, dia, mount_space, mount_th, screw_dia, plate_w, plate_h, plate_th, plate_r) {
    difference() {
        pillar(l, dia, filet_r, mount_space, screw_dia);    
        // set mount screw face
        translate([-mount_th - dia/2, 0, l - mount_space]) {
            linear_extrude(height=(dia/2 + mount_space)) {
                square([dia, dia], center=true);
            }
        }
    }
    // Mount Plate
    translate([0, 0, -plate_th + touch]) {
        linear_extrude(height=plate_th) {
            offset(plate_r) {
                square([plate_w - plate_r, plate_h - plate_r], center=true);
            }
        }
    }
}

module clip(clip_w, clip_th, case_w, case_th, mount_th, tolerance) {
    difference() {
        cube([case_w + 2 * clip_th, case_th + mount_th + 2 * clip_th, clip_w], center=true);
        cube([case_w + tolerance, case_th + mount_th + tolerance, clip_w + touch], center=true);
    }
}
//stand(pillar_h, pillar_dia, base_leg_l, base_leg_w, base_leg_h, base_leg_r, mount_space, mount_dia);
//arm(arm_l, pillar_dia, mount_space, arm_fix_w, screw_dia, arm_plate_w, arm_plate_d, arm_plate_th, arm_plate_r );
clip(clip_w, clip_th, case_w, case_th, arm_plate_th, tolerance);

