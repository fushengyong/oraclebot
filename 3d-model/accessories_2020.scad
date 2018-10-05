include <MCAD/boxes.scad>;
include <MCAD/nuts_and_bolts.scad>;

//support_2020(true, 3);

//parallel_linker(100);

module parallel_linker(link_distance, with_top)
{
    supp_size = [30,30,20];
    thk = 2;
    y_thk = (supp_size.y-20)/2;
    union()
    {
        translate([link_distance,0,0])  wrap_2020( supp_size, 10, 3 );
        rotate([0,0,180]) wrap_2020( supp_size, 10, 3 );
        translate([5/2,-supp_size.y/2,0])  cube([link_distance-5, y_thk, supp_size.z]);
        translate([5/2,supp_size.y/2-y_thk,0])  cube([link_distance-5, y_thk, supp_size.z]);
        if(with_top)
        {
            difference()
            {
                translate([(link_distance)/2,0,-5/2]) roundedBox([ link_distance+supp_size.x, supp_size.y, 5],3,true);
                cylinder(r=5/2,h=10);
                translate([link_distance,0,0]) cylinder(r=5/2,h=10);
            }
        }
    }
}

module support_2020( with_mounting_holes, thk ) {
    
    nut_base = 2;
    outer_size = [40,40,METRIC_NUT_THICKNESS[4]+nut_base];
    inner_size = [30,30,30];
    outerR = 10;

    threshold_2020 = 0.5;
    
    notch_size = [2.2,5.5,19];
    mid_gap = 8;
    
    difference()
    {
        union()
        {
            //roundedBox(inner_size, 3, true);
            wrap_2020( inner_size, outerR, 4);
            translate([0,0,outer_size.z/2])
            difference()
            {
                hull()
                {
                    roundedBox(outer_size, 5, true);
                    translate([outer_size.x/2,0,-outer_size.z/2]) cylinder(r = outerR, h = outer_size.z);
                    translate([-outer_size.x/2,0,-outer_size.z/2]) cylinder(r = outerR, h = outer_size.z);
                }
                //2020 profile
                cube([20 + threshold_2020,20 + threshold_2020, inner_size.z], true);
            }
        }
        
        //M4 holes for base
        translate([-outer_size.x/2,0,-inner_size.z/2+nut_base]) nutHole(4);
        translate([outer_size.x/2,0,-inner_size.z/2+nut_base]) nutHole(4);
        
        //M4 holes
        translate([0,0,-thk]) translate([outer_size.x/2,0,-inner_size.z/2]) boltHole(4, MM, METRIC_NUT_THICKNESS[4]+nut_base+5);
        translate([0,0,-thk]) translate([-outer_size.x/2,0,-inner_size.z/2]) boltHole(4, MM, METRIC_NUT_THICKNESS[4]+nut_base+5);
    }
    
    if(with_mounting_holes )
    {
        translate([0,0,-thk]) translate([outer_size.x/2,0,0]) boltHole(4, MM, METRIC_NUT_THICKNESS[4]+nut_base+5);
        translate([0,0,-thk]) translate([-outer_size.x/2,0,0]) boltHole(4, MM, METRIC_NUT_THICKNESS[4]+nut_base+5);
    }
}

module wrap_2020( inner_size, outerR, num_sides = 4 )
{
    difference()
    {
        _wrap_2020(inner_size, outerR);
        if( num_sides == 3 )
        {
            translate([-inner_size.x - 5,-inner_size.y/2,0]) cube(inner_size);
        }
        if( num_sides == 2 )
        {
            translate([-inner_size.x+5,-5,0]) cube(inner_size);
        }
        if( num_sides == 1 )
        {
            translate([-inner_size.x + 5,-inner_size.y/2,0]) cube(inner_size);
        }
    }
}

module _wrap_2020(inner_size, outerR)
{

    threshold_2020 = 0.5;
    notch_size = [2.2,5.5,19];
    mid_gap = 8;
    
    translate([0,0,inner_size.z/2]) difference()
    {
        union()
        {
            roundedBox(inner_size, 3, true);
        }
        //2020 profile
        cube([20 + threshold_2020,20 + threshold_2020, inner_size.z], true);
        //M5 holes for 2020 profile
        translate([-inner_size.x,0,inner_size.z/2 - (notch_size.z)/2 ]) rotate([0,90,0]) cylinder(r=5/2, h = 2*inner_size.x);
        translate([0,inner_size.y,inner_size.z/2 - (notch_size.z)/2 ]) rotate([90,0,0]) cylinder(r=5/2, h = 2*inner_size.y);
    }
    
    offset_ht = inner_size.z-notch_size.z;
    translate([0,0,offset_ht])
    {
        translate([-(20 + threshold_2020)/2,0,0]) inside_notch_2020(notch_size, mid_gap, inner_size.z-notch_size.z);
        translate([0,-(20 + threshold_2020)/2,0]) rotate([0,0,90]) inside_notch_2020(notch_size, mid_gap, inner_size.z-notch_size.z);
        translate([0,(20 + threshold_2020)/2,0]) rotate([0,0,-90]) inside_notch_2020(notch_size, mid_gap, inner_size.z-notch_size.z);
        translate([(20 + threshold_2020)/2,0,0]) rotate([0,0,-180]) inside_notch_2020(notch_size, mid_gap, inner_size.z-notch_size.z);
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
    

