include <MCAD/nuts_and_bolts.scad>;
include <MCAD/triangles.scad>;

//pvc_pipe_holder(0.75*25.4, true, 3);

module pvc_pipe_holder(r, with_mounting_holes, base_thk)
{
    nut_dist = 10;
    nut_supp_r = 10;
    ht_base_supp = 5;
    ht = 30;
    
    difference()
    {
        union()
        {
            cylinder(r=r+nut_supp_r/2, h = ht);
            _pvc_pipe_holder_base(r, with_mounting_holes, base_thk, nut_dist, nut_supp_r, ht_base_supp);
            
            translate([0,0,ht_base_supp])
            {
                translate([(r+nut_supp_r/2)*cos(45), (r+nut_supp_r/2)*sin(45)]) rotate([0,0,45]) _pvc_pipe_support(ht-ht_base_supp, nut_dist-1-nut_supp_r/2, 4);
                translate([(r+nut_supp_r/2)*cos(135), (r+nut_supp_r/2)*sin(135)]) rotate([0,0,135]) _pvc_pipe_support(ht-ht_base_supp, nut_dist-1-nut_supp_r/2, 4);
                translate([(r+nut_supp_r/2)*cos(-45), (r+nut_supp_r/2)*sin(-45)]) rotate([0,0,-45]) _pvc_pipe_support(ht-ht_base_supp, nut_dist-1-nut_supp_r/2, 4);
                translate([(r+nut_supp_r/2)*cos(-135), (r+nut_supp_r/2)*sin(-135)]) rotate([0,0,-135]) _pvc_pipe_support(ht-ht_base_supp, nut_dist-1-nut_supp_r/2, 4);
            }
        }
        cylinder(r=r+0.05, h = ht);
    }
}

module _pvc_pipe_support(supp_ht, supp_base, thk)
{
    translate([0,thk/2,0]) rotate([90,0,0]) triangle(supp_ht,supp_base,thk);
}

module _pvc_pipe_holder_base(r, with_mounting_holes, base_thk, nut_dist, nut_supp_r, ht)
{
    
    difference()
    {
        hull()
        {
            translate() cylinder(r = r+nut_dist, h = ht);
            translate([-nut_dist-r,0,0]) cylinder(r = nut_supp_r, h = ht);
            translate([nut_dist+r,0,0]) cylinder(r = nut_supp_r, h = ht);
        }
        //nut holes
        translate([-nut_dist-r,0,ht-METRIC_NUT_THICKNESS[3]]) nutHole(3);
        translate([+nut_dist+r,0,ht-METRIC_NUT_THICKNESS[3]]) nutHole(3);
        //bolt_holes
        translate([-nut_dist-r,0,-base_thk]) boltHole(3,MM,1+ht+base_thk);
        translate([+nut_dist+r,0,-base_thk]) boltHole(3,MM,1+ht+base_thk);
    }
    
    if( with_mounting_holes == true )
    {
        //nut holes
        translate([-nut_dist-r,0,ht-METRIC_NUT_THICKNESS[3]]) nutHole(3);
        translate([+nut_dist+r,0,ht-METRIC_NUT_THICKNESS[3]]) nutHole(3);
        //bolt_holes
        translate([-nut_dist-r,0,-base_thk]) boltHole(3,MM,1+ht+base_thk);
        translate([+nut_dist+r,0,-base_thk]) boltHole(3,MM,1+ht+base_thk);
    }
    
}