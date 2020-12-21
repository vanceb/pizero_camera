use <MCAD/boxes.scad>
$fa = 1;
$fs = 0.4;

touch = 0.001;

// In all names:  w=x, d=y, h=z
// Overall Pi Zero dimensions - includes overhangs
piz_w = 68.5;
piz_d = 31.5;
piz_h = 5;

// Board dimensions
w = 65;
d = 30;
h = 1.5;
corner_radius = 3.5;

// Connector Dimensions
// HDMI
hdmi_w = 11;
hdmi_d = 8;
hdmi_h = 3.5;
hdmi_project = 0.5;  // How far over the edge of the board?
hdmi_x = (w / 2) - 12.4;
hdmi_y = (d - hdmi_d) / 2 + hdmi_project;
hdmi_z = ((hdmi_h + h) / 2) - touch;

// Micro USB
musb_w = 8;
musb_d = 5.6;
musb_h = 2.2;
musb_project = 1;
musb_x1 = -(41.4 - (w / 2));
musb_x2 = -(54 - (w / 2));
musb_y = (d - musb_d) / 2 + musb_project;
musb_z = ((musb_h + h) / 2) - touch;

// Micro SD holder and card
sd_w = 15.5;
sd_d = 11.8;
sd_h = 1.1;
sd_project = 2.2;
sd_x = ((w - sd_w) / 2) + sd_project;
sd_y = (d / 2) - 16.9;
sd_z = (h + sd_h) / 2 - touch;

// Camera Port
cam_w = 4.1;
cam_d = 17;
cam_h = 1.2;
cam_project = 1;
cam_x = -(((w - cam_w) / 2) + cam_project);
cam_y = 0;
cam_z = (h + cam_h) / 2 - touch;

// Mounting holes
mh_dist_x = 58;
mh_dist_y = 23;
mh_dia = 2.75;


module pi_zero() {
        // PCB
        difference() {
        // Base PCB
        color("Green")
        roundedBox(size=[w,d,h], radius=corner_radius, sidesonly=true);

        // Mounting holes
        translate([mh_dist_x / 2, mh_dist_y / 2, 0])
            cylinder(h=2*h, r=mh_dia/2, center=true);
        translate([-mh_dist_x / 2, mh_dist_y / 2, 0])
            cylinder(h=2*h, r=mh_dia/2, center=true);
        translate([mh_dist_x / 2, -mh_dist_y / 2, 0])
            cylinder(h=2*h, r=mh_dia/2, center=true);
        translate([-mh_dist_x / 2, -mh_dist_y / 2, 0])
            cylinder(h=2*h, r=mh_dia/2, center=true);
    }

    // Ports
    // HDMI
    color("Silver")
    translate([hdmi_x, hdmi_y, hdmi_z])
        cube([hdmi_w, hdmi_d, hdmi_h], center=true);

    // Micro USB
    //1
    color("Silver")
    translate([musb_x1, musb_y, musb_z])
        cube([musb_w, musb_d, musb_h], center=true);
    //2
    color("Silver")
    translate([musb_x2, musb_y, musb_z])
        cube([musb_w, musb_d, musb_h], center=true);

    // Micro SD
    color("Black")
    translate([sd_x, sd_y, sd_z])
        cube([sd_w, sd_d, sd_h], center=true);

    // Camera Port
    color("BlanchedAlmond")
    translate([cam_x, cam_y, cam_z])
        cube([cam_w, cam_d, cam_h], center=true);
}

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

module half_case(
                inner_w=50, 
                inner_d=40, 
                inner_h=20, 
                thickness=2, 
                corner_radius=5, 
                lip_h=1, 
                inner_lip=true,
                fit_tolerance=0.1
                ) {
    
    inner_radius = corner_radius > thickness ? corner_radius - thickness : 0;
    outer_radius = inner_radius > 0 ? corner_radius : thickness;
    lip_radius   = (outer_radius + inner_radius) / 2;
    w = inner_w - inner_radius;
    d = inner_d - inner_radius;
    h = inner_lip ? inner_h - lip_h: inner_h;
    lh = inner_lip ? inner_h: inner_h + lip_h;

    // Base
    linear_extrude(height = thickness) {
        offset(r = outer_radius)
            square([w, d], center=true);
    }

    // Sides
    // Main case body
    linear_extrude(height = h) {
        difference() {
            // Outer
            offset(r = outer_radius)
                square([w, d], center=true);
            // Inner
            offset(r = inner_radius)
                square([w, d], center=true);
        }
    }
    // Lip for lid seating
    if(inner_lip) {
        linear_extrude(height = lh)
        difference() {
            offset(r = lip_radius)
                square([w, d], center=true);
            offset(r = inner_radius)
                square([w, d], center=true);
        }
    } else {
        linear_extrude(height = lh)
        difference() {
            offset(r = outer_radius)
                square([w, d], center=true);
            offset(r = lip_radius + fit_tolerance)
                square([w, d], center=true);
        }
    }
}

module pi_zero_cutout_case(
                            thickness=2,
                            clearance=2,
                            ) {
                            }

module cutout_case(
                    thickness=2, 
                    standoff_height=5, 
                    edge_clearance=2, 
                    top_clearance=4,
                    cut_clearance=1.5,
                    cable_clearance=0,          // Extra space on the side where the cables are
                    camera_cable_clearance=0,   // Extra space for the camera flexi cable
                    cut_hdmi=true,
                    cut_usb1=true,
                    cut_usb2=true,
                    cut_sd=true,
                    cable_dia=5,
                    pi_face_down=true,
                    lip_height= 1,
                    fit_tolerance = 0.1
                   ) {
    // How far to offset the case depending on cable room required, so piis still centered on the axes
    clear_x = pi_face_down ? -camera_cable_clearance/2 : camera_cable_clearance/2;
    clear_y = pi_face_down ? -cable_clearance/2 : cable_clearance/2;
    // Maximum extrude distance so we cut the case
    max_ex = w + camera_cable_clearance + 2*thickness;

    // Case
    difference() {
        // Case itself
        translate([clear_x, clear_y, 0]) {
            half_case(
                inner_w = w + camera_cable_clearance + edge_clearance, 
                inner_d = d + cable_clearance + edge_clearance, 
                inner_h = standoff_height + h + top_clearance, 
                thickness=2, 
                corner_radius=5, 
                lip_h=1, 
                inner_lip=true,
                fit_tolerance=0.1
                );      
        }
        // Cutouts
        if (cut_hdmi) {
            tx = hdmi_x;
            ty = pi_face_down ? -hdmi_y : hdmi_y;
            tz = pi_face_down ? thickness + standoff_height - hdmi_h/2 : thickness + standoff_height + h + hdmi_h/2;

            translate([tx, ty, tz])
            if(pi_face_down) {
                rotate([90,0,0])
                linear_extrude(max_ex)
                offset(r=cut_clearance)
                square([hdmi_w,hdmi_h], center=true);            
            } else {
                rotate([-90,0,0])
                linear_extrude(max_ex)
                offset(r=cut_clearance)
                square([hdmi_w,hdmi_h], center=true);            
            }
        }
        if (cut_usb1) {
            tx = musb_x1;
            ty = pi_face_down ? -musb_y : musb_y;
            tz = pi_face_down ? thickness + standoff_height - musb_h/2 : thickness + standoff_height + h + musb_h/2;

            translate([tx, ty, tz])
            if(pi_face_down) {
                rotate([90,0,0])
                linear_extrude(max_ex)
                offset(r=cut_clearance)
                square([musb_w,musb_h], center=true);            
            } else {
                rotate([-90,0,0])
                linear_extrude(max_ex)
                offset(r=cut_clearance)
                square([musb_w,musb_h], center=true);            
            }
        }
        if (cut_usb2) {
            tx = musb_x2;
            ty = pi_face_down ? -musb_y : musb_y;
            tz = pi_face_down ? thickness + standoff_height - musb_h/2 : thickness + standoff_height + h + musb_h/2;

            translate([tx, ty, tz])
            if(pi_face_down) {
                rotate([90,0,0])
                linear_extrude(max_ex)
                offset(r=cut_clearance)
                square([musb_w,musb_h], center=true);            
            } else {
                rotate([-90,0,0])
                linear_extrude(max_ex)
                offset(r=cut_clearance)
                square([musb_w,musb_h], center=true);            
            }
        }
        if (cut_sd) {
            tx = sd_x;
            ty = pi_face_down ? -sd_y : sd_y;
            tz = pi_face_down ? thickness + standoff_height - sd_h/2 : thickness + standoff_height + h + sd_h/2;

            translate([tx, ty, tz])
                rotate([-90,0,-90])
                linear_extrude(max_ex)
                offset(r=cut_clearance)
                square([sd_d,sd_h], center=true);            
        }
        // Cut a cable exit slot if configured correctly
        if (cable_dia > 0 && cable_clearance > cable_dia) {
            tx = 0;
            ty = pi_face_down ? -(d/2 + cable_clearance - cable_dia/2) : (d/2 + cable_clearance - cable_dia/2);
            tz = pi_face_down ? thickness + (standoff_height + h + top_clearance - cable_dia/2) : thickness + standoff_height + h + sd_h/2;

            translate([tx, ty, tz])
                rotate([90,0,-90])
                linear_extrude(max_ex) {
                circle(cable_dia/2);
                translate([0,cable_dia/2,0])
                square(cable_dia, center=true);
            }
        }
    }

    // Mounting pillars
    translate([w/2 - corner_radius, d/2 - corner_radius, thickness - 0.001])
        mount_pillar();
    translate([-(w/2 - corner_radius), d/2 - corner_radius, thickness - 0.001])
        mount_pillar();
    translate([w/2 - corner_radius, -(d/2 - corner_radius), thickness - 0.001])
        mount_pillar();
    translate([-(w/2 - corner_radius), -(d/2 - corner_radius), thickness - 0.001])
        mount_pillar();
}


module lid(
            camera_dia=6.8, 
            camera_pcb_height=3,
            thickness=2,
            standoff_height=5,
            edge_clearance=2,
            camera_cable_clearance=0,
            cable_clearance=0,
            pi_face_down=true,
            lip_height=1,
            fit_tolerance=0.3
        ) {
    // How far to offset the case depending on cable room required, so piis still centered on the axes
    clear_x = pi_face_down ? -camera_cable_clearance/2 : camera_cable_clearance/2;
    clear_y = pi_face_down ? -cable_clearance/2 : cable_clearance/2;
    // Maximum extrude distance so we cut the case
    max_ex = w + camera_cable_clearance + 2*thickness;
    // Base
    difference() {
        translate([clear_x, clear_y, 0]) {
            half_case(
                    inner_w = w + camera_cable_clearance + edge_clearance, 
                    inner_d = d + cable_clearance + edge_clearance, 
                    inner_h = camera_pcb_height,
                    thickness=2, 
                    corner_radius=5, 
                    lip_h=1, 
                    inner_lip=false,
                    fit_tolerance=0.1
            );
        }
        // Camera Lens cutout
        cylinder(r=(camera_dia + fit_tolerance)/2, h=2*max_ex, center=true);
    }
}

//half_case();
cutout_case(thickness = 2, cut_clearance=1.5, camera_cable_clearance=10, cut_hdmi=false, cut_sd=false, cut_usb1=false);
translate([0,0,20])
rotate([180,0,0])
lid(thickness=2, camera_cable_clearance=10);
translate([0,0,7 + h/2])
rotate([180,0,0])
pi_zero();
