use <MCAD/boxes.scad>
$fa = 1;
$fs = 0.4;

touch = 0.001;

module mount_pillar(inner=2.5, thickness=2, height=5, filet_r=1.5) {
    // Pillar
    translate([0,0,height/2])
    difference() {
        cylinder(r=(inner/2 + thickness), h = height, center = true);
        cylinder(r = inner/2, h = height + touch, center = true);
    }

    // Filet
    translate([0,0,filet_r])
    rotate_extrude(angle=360, convexity = 2) {
        translate([(inner/2 + thickness + filet_r - 0.001),0,0])
        rotate(180)
        difference() {
            square(filet_r);    
            circle(filet_r);
        }
    }
}

module pi_zero_case() {



}

pi_zero_case();

//mount_pillar();

// Mounting holes
mh_dist_x = 58;
mh_dist_y = 23;
mh_dia = 2.75;
