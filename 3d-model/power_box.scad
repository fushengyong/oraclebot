include <MCAD/nuts_and_bolts.scad>;
include <fan_holder_v2.scad>

$fn = 50;
//power_box(true,10);

//translate([0,0,45]) power_box_top(137);
//power_box();

module power_box_top(battery_width)
{
    thr = 0.1;
    thk = 4/2;
    difference()
    {
        union()
        {
            translate([-(160+2*thk)/2,-(60+2*thk)/2,-8]) cube([160+2*thk,60+2*thk,10]);
        }
        translate([-(160+thr)/2,-(60+thr)/2,-8]) cube([160+thr,60+thr,8]);
        translate([-160/2+thk,-(60-2*thk)/2,-8]) cube([20,10,12]);
        translate([-160/2+thk,(60-2*thk)/2-10,-8]) cube([20,10,12]);
        translate([160/2,-40/2,-12]) cube([20,40,10]);
        
       translate([-(battery_width)/2-2,10,-5]) cylinder(r=3/2,h=10);
       translate([(battery_width)/2+2,10,-5]) cylinder(r=3/2,h=10);
       translate([-(battery_width)/2-2,-10,-5]) cylinder(r=3/2,h=10);
       translate([(battery_width)/2+2,-10,-5]) cylinder(r=3/2,h=10);
    }
}
module power_box( with_mounting_holes = false, base_th=0)
{
    translate([45-160/2,0,3]) difference()
    {
        translate([-45,-60/2,-3]) difference() {
            union()
            {
                cube([160,60,45]);
                translate([0,60/2,0]) cylinder(r=15, h=5);
                translate([160,60/2,0]) cylinder(r=15, h=5);
            }
            translate([2,2,5]) cube([160-4,60-4,45]);
            translate([-15/2,60/2,5-METRIC_NUT_THICKNESS[3]]) nutHole(3);
            translate([160+15/2,60/2,5-METRIC_NUT_THICKNESS[3]]) nutHole(3);
            translate([-15/2,60/2,0]) boltHole(3,MM,20);
            translate([160+15/2,60/2,0]) boltHole(3,MM,20);
            translate([10,70-10/2,30]) rotate([90,0,0]) cylinder(r = 4/2, h = 70);
            
            translate([160+10/2,(60-30)/2+1,12+1]) rotate([0,-90,0]) cube([28,28,10]);
            for( i = [ 0:5 ] )
            {
                xx = (160-20)/6;
                translate([20+xx*i,-5,10]) cube([5,70,30]);
            }
            
            for( i = [ 0:2 ] )
            {
                yy = (60-10)/3;
                translate([-5,10+yy*i,12]) cube([10,5,30]);
            }
        }
        translate([5,0,0]) boost_converter();
        translate([52,0,0]) rotate([0,0,90]) buck_converter();
        translate([75,0,0]) rotate([0,0,90]) buck_converter();
        translate([98,0,0]) rotate([0,0,90]) buck_converter();
        
       
        
        
    }
    if( with_mounting_holes )
    {
        translate([-15/2-160/2,0,-base_th]) boltHole(3,MM,20);
        translate([160/2+15/2,0,-base_th]) boltHole(3,MM,20);
    }
    
    translate([-160/2,-30,0]) translate([160,(60-30)/2,12]) rotate([0,-90,0]) fan_mount(size = 30, thick = 2 );
}

module boost_converter()
{
    pcb_dim = [65.3,36.7,1.6];
    //pcb
    translate([0,0,pcb_dim.z/2]) cube(pcb_dim, center = true);
    //height
    color("gray") translate([0,0,23/2+pcb_dim.z]) cube([pcb_dim.x, pcb_dim.y,23], center = true);
    //mount holes
    holes = [[3.3,5.08],[3.3,31.5],[61.75,5.08],[61.75,31.5]];
    translate([-pcb_dim.x/2+0.1, -pcb_dim.y/2+0.1,0]) for( i = [ 0 : len(holes) - 1 ] )
        translate([holes[i][0],holes[i][1],-10]) linear_extrude(10) nutHole(3,proj=1);
}


module buck_converter()
{
    pcb_dim = [43.7,20.8,1.6];
    //pcb
    translate([0,0,pcb_dim.z/2]) cube(pcb_dim, center = true);
    //height
    color("gray") translate([0,0,14/2+pcb_dim.z]) cube([pcb_dim.x, pcb_dim.y,14], center = true);
    //mount holes
    holes = [[6.6,17.7],[36.1,2.5]];
    translate([-pcb_dim.x/2+0.1, -pcb_dim.y/2+0.1,0])
    for( i = [ 0 : len(holes) - 1 ] )
        translate([holes[i][0],holes[i][1],-10]) linear_extrude(10) nutHole(3,proj=1);
}