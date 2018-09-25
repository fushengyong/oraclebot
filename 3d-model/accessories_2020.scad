include <MCAD/boxes.scad>;
include <MCAD/nuts_and_bolts.scad>;

//support_2020(false, 0);

module support_2020( with_mounting_holes, thk ) {
    
    nut_base = 2;
    outer_size = [40,40,METRIC_NUT_THICKNESS[4]+nut_base];
    inner_size = [30,30,30];
    outerR = 10;

    threshold_2020 = 0.5;
    
    notch_size = [2.2,5.5,19];
    mid_gap = 8;
    
    translate([0,0,inner_size.z/2]) difference()
    {
        union()
        {
            roundedBox(inner_size, 3, true);
            translate([0,0,outer_size.z/2-inner_size.z/2]) hull()
            {
                roundedBox(outer_size, 5, true);
                translate([outer_size.x/2,0,-outer_size.z/2]) cylinder(r = outerR, h = outer_size.z);
                translate([-outer_size.x/2,0,-outer_size.z/2]) cylinder(r = outerR, h = outer_size.z);
            }
        }
        //2020 profile
        cube([20 + threshold_2020,20 + threshold_2020, inner_size.z], true);
        //M5 holes for 2020 profile
        translate([-inner_size.x,0,inner_size.z/2 - (notch_size.z)/2 ]) rotate([0,90,0]) cylinder(r=5/2, h = 2*inner_size.x);
        translate([0,inner_size.y,inner_size.z/2 - (notch_size.z)/2 ]) rotate([90,0,0]) cylinder(r=5/2, h = 2*inner_size.y);
        //M4 holes for base
        translate([-outer_size.x/2,0,-inner_size.z/2+nut_base]) nutHole(4);
        translate([outer_size.x/2,0,-inner_size.z/2+nut_base]) nutHole(4);
        
        //M4 holes
        translate([0,0,-thk]) translate([outer_size.x/2,0,-inner_size.z/2]) boltHole(4, MM, METRIC_NUT_THICKNESS[4]+nut_base+5);
        translate([0,0,-thk]) translate([-outer_size.x/2,0,-inner_size.z/2]) boltHole(4, MM, METRIC_NUT_THICKNESS[4]+nut_base+5);
    }
    
    offset_ht = inner_size.z-notch_size.z;
    translate([0,0,offset_ht])
    {
        translate([-(20 + threshold_2020)/2,0,0]) inside_notch_2020(notch_size, mid_gap, inner_size.z-notch_size.z);
        translate([0,-(20 + threshold_2020)/2,0]) rotate([0,0,90]) inside_notch_2020(notch_size, mid_gap, inner_size.z-notch_size.z);
        translate([0,(20 + threshold_2020)/2,0]) rotate([0,0,-90]) inside_notch_2020(notch_size, mid_gap, inner_size.z-notch_size.z);
        translate([(20 + threshold_2020)/2,0,0]) rotate([0,0,-180]) inside_notch_2020(notch_size, mid_gap, inner_size.z-notch_size.z);
    }
    
    if(with_mounting_holes )
    {
        translate([0,0,-thk]) translate([outer_size.x/2,0,0]) boltHole(4, MM, METRIC_NUT_THICKNESS[4]+nut_base+5);
        translate([0,0,-thk]) translate([-outer_size.x/2,0,0]) boltHole(4, MM, METRIC_NUT_THICKNESS[4]+nut_base+5);
    }
}

module inside_notch_2020(notch_size, mid_gap, offset_ht=0) 
{
    translate([0,-notch_size.y/2,0]) 
    {
        difference()
        {
            cube(notch_size);
            translate([-(tan(45)*mid_gap)/2,0,notch_size.z/2]) rotate([0,45,0]) cube([50,50,50]);
        }
        translate([0,0,-offset_ht]) cube([notch_size.x, notch_size.y, offset_ht]);
    }
}
    

