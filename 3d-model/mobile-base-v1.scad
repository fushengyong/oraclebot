include <MCAD/nuts_and_bolts.scad>;
include <power_box.scad>;
include <extrusion_profile_20x20_v-slot.scad>;
include <accessories_2020.scad>

$fn=50;

//Material
sheetW_b = 3.7;   //MDF Sheet

//General Parameters
gap = 5;
tolerance=0.1;

//Robot Mobile Base 
mobileR = 300/2;
mobileH = 60;
mobileW = 300;

//Caster
caster_ht = 34;
caster_hole_R = 35;

//Powered Wheels
maxWheelR = 120/2;
wheelR = 108/2; //approx as the tyres are threaded
wheelW = 20;

motorR = 34/2;
shaftL = 22.5; //length of shaft inside wheel
motorL = 25+51+shaftL;


motorDist = 30;
motorCentreOffset = -70;
motorPos = 51 + motorDist/2;

casterCenterOffset = 70;

/* not used currently 
N = 8;
support_R = 120;
theta=360/N;
L_dash = 2*support_R*sin(theta/2)*0.7;
v_notch = L_dash/2;
*/

battery_size = [ [136,110,28 ], [137,162,28] ]; 
battery_used = 1;

//motor_mount
mount_size = [30,55,40];
mount_thk = 5; //thickness to mount screws
motor_ht = 5; //height of the motor above the base of the mount

motorCenterHt = sheetW_b+motorR+motor_ht;
robotMidHt = maxWheelR+motorCenterHt;
botElecHt = 100;
robotTopHt = robotMidHt + botElecHt;

casterTopHt = motorCenterHt-wheelR+caster_ht;
vslot_dist = 100;
vslot_ht = 1000;
vslot_pos=[[vslot_dist/2,motorCentreOffset-mount_size.y+10],[-vslot_dist/2,motorCentreOffset-mount_size.y+10]];

//Left Motor Mount
//motor_mount("l");

//Right Motor Mount
//motor_mount("r");

//Vertical Support
//vertical_support();

//caster mount
//caster_mount();

//Robot base projection ( for base cutting purposes )
//projection() robot_bottom();

//Robot top projection ( for base cutting purposes )
//projection() mobile_top();

//2020 support
//support_2020();

robot_base();

/************************* SHAPE ***********************/
module robot_base() {
    robot_bottom();
    
    translate([0,motorCentreOffset,motorCenterHt]) {
        translate([motorPos,0,0]) motor("r");
        translate([motorPos,0,0]) motor_mount("r",true);
        translate([-shaftL,0,0]) powered_wheel("r");
        translate([-motorPos,0,0]) motor("l");
        translate([-motorPos,0,0]) motor_mount("l",true);
        translate([shaftL,0,0]) powered_wheel("l");
    }
    
    translate([0,casterCenterOffset, casterTopHt]) 
    {
        caster_wheel();
        caster_mount(true);
    }
    
    translate([0,motorCentreOffset-mount_size.y,0]) vertical_support(robotMidHt, true);
    translate([-0.7*mobileR*sin(60),0.7*mobileR*cos(60),0]) rotate([0,0,45]) vertical_support(robotMidHt, true);
    translate([0.7*mobileR*sin(60),0.7*mobileR*cos(60),0]) rotate([0,0,-45]) vertical_support(robotMidHt, true);
    
    translate([0,-8,sheetW_b]) power_box(true,sheetW_b);
    translate([0,-8,sheetW_b+45]) power_box_top(battery_size[battery_used].x);
    translate([0,0,sheetW_b+45+2]) battery();
    
    for( i =[ 0 : len(vslot_pos)-1 ] )
    {
        translate([vslot_pos[i].x,vslot_pos[i].y,sheetW_b]) 
        {
            extrusion_profile_20x20_v_slot(size=20, height=vslot_ht);
            translate([0,0,-sheetW_b]) boltHole(5);
        }
    }
    
    
    translate([0,0,robotMidHt]) mobile_mid();
    
    translate([0,0,robotMidHt+sheetW_b]) for( i =[ 0 : len(vslot_pos) - 1] )
    {
        translate([vslot_pos[i].x,vslot_pos[i].y,0]) 
        {
            support_2020(true, sheetW_b);
        }
    }
    
    translate([-vslot_dist/2,vslot_pos[0].y,vslot_ht/2]) parallel_linker(vslot_dist);
    
    translate([-vslot_dist/2,vslot_pos[0].y,vslot_ht+sheetW_b]) rotate([180,0,0]) parallel_linker(vslot_dist,true);
    
    
    
    //translate([0,-(motorCentreOffset-mount_size.y),robotMidHt]) vertical_support(botElecHt,true);
    
    //translate([0,0,robotTopHt]) mobile_top();
    
    
    
    
    
    
    
    //translate([-30,20,robotTopHt+20]) import("tx2.stl");
    //translate([0,0,1000]) import("kinect-360.stl");
 
    //Floor
    //translate([0,0,motorCenterHt-wheelR]) circle(r = 2*mobileR);
}

module robot_bottom() {
    difference()
    {
        mobile_bottom();
        translate([0,motorCentreOffset,motorCenterHt]) 
        {
            translate([motorPos,0,0]) motor("r");
            translate([motorPos,0,0]) motor_mount("r",true);
            translate([-shaftL,0,-motorCenterHt]) powered_wheel_gap("r");
            translate([-motorPos,0,0]) motor("l");
            translate([-motorPos,0,0]) motor_mount("l",true);
            translate([shaftL,0,-(sheetW_b+motorR+motor_ht)]) powered_wheel_gap("l");
        }
        translate([0,casterCenterOffset, 0]) cylinder(r=caster_hole_R,h=10);
        translate([0,casterCenterOffset, casterTopHt]) 
        {
            caster_mount(true);
        }
        translate([0,-8,sheetW_b]) power_box(true,sheetW_b);
        translate([-160/2-20,0,-5]) cylinder(r= 3/2, h = 10);
        translate([-160/2-20,15,-5]) cylinder(r= 3/2, h = 10);
        
        translate([0,motorCentreOffset-mount_size.y,0]) vertical_support(robotMidHt,true);
        translate([-0.7*mobileR*sin(60),0.7*mobileR*cos(60),0]) rotate([0,0,45]) vertical_support(robotMidHt,true);
        translate([0.7*mobileR*sin(60),0.7*mobileR*cos(60),0]) rotate([0,0,-45]) vertical_support(robotMidHt,true);
        
        for( i =[ 0 : len(vslot_pos)-1 ] )
        {
            translate([vslot_pos[i].x,vslot_pos[i].y,sheetW_b]) 
            {
                translate([0,0,-sheetW_b]) boltHole(5);
            }
        }
    }
}

module mobile_bottom() {
        color("brown") linear_extrude(height = sheetW_b) base_shape();
}

module mobile_mid() {
    color("brown") difference()
    {
        linear_extrude(height = sheetW_b) base_shape();
        translate([0,motorCentreOffset-mount_size.y,0]) vertical_support(robotMidHt,true);
        translate([-0.7*mobileR*sin(60),0.7*mobileR*cos(60),0]) rotate([0,0,45]) vertical_support(robotMidHt,true);
        translate([0.7*mobileR*sin(60),0.7*mobileR*cos(60),0]) rotate([0,0,-45]) vertical_support(robotMidHt,true);
        
        translate([0,-(motorCentreOffset-mount_size.y),0]) vertical_support(botElecHt,true);
        
        for( i =[ 0 : len(vslot_pos)-1 ] )
        {
            translate([vslot_pos[i].x,vslot_pos[i].y,sheetW_b]) 
            {
                cube([20,20,20], center = true);
                support_2020(true, sheetW_b);
            }
        }
    }
}

module mobile_top() {
    color("brown") difference()
    {
        linear_extrude(height = sheetW_b) base_shape();
        
        translate([0,-(motorCentreOffset-mount_size.y),0]) vertical_support(botElecHt,true);
        
        for( i =[ 0 : len(vslot_pos)-1 ] )
        {
            translate([vslot_pos[i].x,vslot_pos[i].y,sheetW_b]) 
            {
                cube([20,20,20], center = true);
            }
        }
    }
}

module base_shape()
{
    intersection()
    {
        square([mobileW, 2*mobileR], center=true);
        circle(r=mobileR);
    }
}

//vertical_support(true);
module vertical_support( ht, with_mounting_holes = false )
{
    
    difference()
    {
        translate([-20,0,0]) {
            cube([10,10,ht+sheetW_b]);
            translate([30,0,0]) cube([10,10,ht+sheetW_b]);
            translate([10,0,sheetW_b]) cube([20,10,ht-sheetW_b]);
        }
        translate([0,10/2,0]) boltHole(3,MM,30);
        for( i = [ 0:2 ] )
            translate([0,10/2+i*METRIC_NUT_AC_WIDTHS[3]/2,15]) rotate([0,0,90]) nutHole(3);
        translate([0,10/2,ht+sheetW_b]) rotate([0,180,0]) boltHole(3,MM,30);
        for( i = [ 0:2 ] )
            translate([0,10/2+i*METRIC_NUT_AC_WIDTHS[3]/2,ht+sheetW_b-15]) rotate([0,0,90]) nutHole(3);
    }
    if( with_mounting_holes )
    {
        translate([0,10/2,0]) boltHole(3,MM,30);
        translate([0,10/2,ht+sheetW_b]) rotate([0,180,0]) boltHole(3,MM,30);
    }
}

/************************* BATTERY ***********************/
module battery() {
    color("blue") translate([0,0,battery_size[battery_used][2]/2]) cube( battery_size[battery_used], center = true );
}

/************************* WHEELS ***********************/
//caster_mount();
module caster_mount(with_mounting_holes = false)
{
    difference()
    {
        union()
        {
            cylinder(r=caster_hole_R+10,h=10);
            translate([0,0,-casterTopHt+sheetW_b]) cylinder(r=caster_hole_R+10,h=casterTopHt-sheetW_b);
            if( with_mounting_holes )
            {
                rotate([0,0,30]) for (i = [0:3])
                {        
                    translate([xx(caster_hole_R+5,i),yy(caster_hole_R+5,i),-casterTopHt]) boltHole(3,MM,2*casterTopHt);
                }
            }
        }
        translate([0,0,-casterTopHt+sheetW_b]) cylinder(r=caster_hole_R,h=casterTopHt-sheetW_b);
        caster_wheel( true );
        if( !with_mounting_holes )
        {
            rotate([0,0,30])  for (i = [0:3])
            {        
                translate([xx(caster_hole_R+5,i),yy(caster_hole_R+5,i),-casterTopHt]) boltHole(3,MM,3*casterTopHt);
            }
        }
        rotate([0,0,30])  for (i = [0:3])
            {        
                translate([xx(caster_hole_R+5,i),yy(caster_hole_R+5,i),10-METRIC_NUT_THICKNESS[3]]) nutHole(3);
            }
        
    }
}

//caster_wheel(true);
module caster_wheel(with_mounting_holes = false)
{
    difference()
    {
        translate([0,0,-1.3/2]) cube([38+2,32+2,1.3], center = true);
        translate([30/2,24/2,-1.3]) cylinder(r=4/2,h=1.3);
        translate([-30/2,24/2,-1.3]) cylinder(r=4/2,h=1.3);
        translate([30/2,-24/2,-1.3]) cylinder(r=4/2,h=1.3);
        translate([-30/2,-24/2,-1.3]) cylinder(r=4/2,h=1.3);
    }
    translate([0,0,-9.5-1.3/2]) cylinder(r=25/2,h=9.5);
    translate([0,25.4/2+5,-caster_ht+25.4/2]) rotate([0,90,0]) cylinder(r = 25.4/2, h = 13, center = true );
    translate([-(13+5)/2,0,-10]) rotate([-45,0,0]) cube( [13+5,22,10] );
    if( with_mounting_holes )
    {
        translate([30/2,24/2,-1.3-2]) cylinder(r=4/2,h=20);
        translate([-30/2,24/2,-1.3-2]) cylinder(r=4/2,h=20);
        translate([30/2,-24/2,-1.3-2]) cylinder(r=4/2,h=20);
        translate([-30/2,-24/2,-1.3-2]) cylinder(r=4/2,h=20);
        translate([30/2,24/2,10.1-METRIC_NUT_THICKNESS[4]]) nutHole(4);
        translate([-30/2,24/2,10.1-METRIC_NUT_THICKNESS[4]]) nutHole(4);
        translate([30/2,-24/2,10.1-METRIC_NUT_THICKNESS[4]]) nutHole(4);
        translate([-30/2,-24/2,10.1-METRIC_NUT_THICKNESS[4]]) nutHole(4);
    }
}

module powered_wheel(side="l")
{    
    if( side == "l" )
        translate([-(wheelW + motorDist+motorL - 10),0,0]) rotate([0,90,0]) cylinder(r = wheelR, h = wheelW, center = true);
    if( side == "r" )
        translate([wheelW + motorDist+motorL - 10,0,0]) rotate([0,90,0]) cylinder(r = wheelR, h = wheelW, center = true);
}

module powered_wheel_gap(side="l")
{    
    if( side == "l" )
        translate([-motorDist-motorL-mobileR/2+5,0,0]) cube([ mobileR, 2*maxWheelR, 3*sheetW_b], center = true);
    if( side == "r" )
        translate([motorDist+motorL+mobileR/2-5,0,0]) cube([ mobileR, 2*maxWheelR, 3*sheetW_b], center = true);
}
/************************* MOTOR ***********************/
module motor(side="l", holes = false) {
    if( holes == true )
    {
        if(side == "r")
            rotate([0,90,0]) motor_with_holes();
        if(side == "l")
            rotate([180,0,0]) rotate([0,-90,0]) motor_with_holes();
    } else {
        if(side == "r")
            rotate([0,90,0]) motor_stl();
        if(side == "l")
            rotate([180,0,0]) rotate([0,-90,0]) motor_stl();
    }
    
}

//motor("l");
//motor_mount("l", true);
module motor_mount(side="l", with_mounting_holes = false)
{
    RR = mount_size.y/2-mount_thk;
    if( side == "l" )
    {
        translate([-25,0,-(motorR+motor_ht)]) difference() 
        {   
            union() {
                translate([-mount_thk,-mount_size.y/2,0]) cube(mount_size);
                translate([60,-motorR-10/2,0]) cube([20,motorR*2+10,10]);
                if( with_mounting_holes )
                {
                    translate([-mount_thk+mount_size.x-10,mount_size.y/2-5,-sheetW_b]) boltHole(4,MM,12);
                    translate([-mount_thk+mount_size.x-10,-mount_size.y/2+5,-sheetW_b]) boltHole(4,MM,12);
                    translate( [60+20/2,-motorR-10/2+5,-sheetW_b] ) boltHole(3, MM, 15);
                    translate( [60+20/2,+motorR+10/2-5,-sheetW_b] ) boltHole(3, MM, 15);
                }
            }
            
            //nut
            translate([-mount_thk+mount_size.x-10,mount_size.y/2-5,5]) linear_extrude(height = 10) nutHole(4, proj = 1);
            translate([-mount_thk+mount_size.x-10,-mount_size.y/2+5,5]) linear_extrude(height = 10) nutHole(4, proj = 1);
            translate( [60+20/2,-motorR-10/2+5,5] ) linear_extrude(height = 10) nutHole(3, proj = 1);
            translate( [60+20/2,+motorR+10/2-5,5] ) linear_extrude(height = 10) nutHole(3, proj = 1);
            //bolt
            if( !with_mounting_holes )
            {
                translate([-mount_thk+mount_size.x-10,mount_size.y/2-5,-sheetW_b]) boltHole(4,MM,12);
                translate([-mount_thk+mount_size.x-10,-mount_size.y/2+5,-sheetW_b]) boltHole(4,MM,12);
                translate( [60+20/2,-motorR-10/2+5,-sheetW_b] ) boltHole(3, MM, 15);
                translate( [60+20/2,+motorR+10/2-5,-sheetW_b] ) boltHole(3, MM, 15);
            }
            
            //curve shape for strength
            translate([-mount_thk+mount_size.x,mount_size.y, RR+motor_ht])  rotate([90,0,0]) cylinder(r = RR, h = mount_size.y*2);
            //for zip tie
            translate([60+2,0,motorR+7.5/2+4]) rotate([0,90,0]) difference() {
                cylinder(r = motorR+7.5, h = 4);
                cylinder(r = motorR+5, h = 4);
            }
            translate([25,0,motorR+motor_ht]) motor(side, true);
            
        }
    }
    if( side == "r" )
    {
        translate([25+mount_thk,0,-(motorR+motor_ht)]) difference() 
        {
            union()
            {
                translate([-mount_size.x,-mount_size.y/2,0]) cube(mount_size);
                translate([-20-mount_thk-60,-motorR-10/2,0]) cube([20,motorR*2+10,10]);
                if( with_mounting_holes )
                {
                    translate([-mount_size.x+10,mount_size.y/2-5,-sheetW_b]) boltHole(4,MM,12);
                    translate([-mount_size.x+10,-mount_size.y/2+5,-sheetW_b]) boltHole(4,MM,12);
                    translate( [-20/2-mount_thk-60,-motorR-10/2+5,-sheetW_b] ) boltHole(3, MM, 15);
                    translate( [-20/2-mount_thk-60,motorR+10/2-5,-sheetW_b] ) boltHole(3, MM, 15);
                }
            }
            //nut
            translate([-mount_size.x+10,mount_size.y/2-5,5]) linear_extrude(height = 10) nutHole(4, proj = 1);
            translate([-mount_size.x+10,-mount_size.y/2+5,5]) linear_extrude(height = 10) nutHole(4, proj = 1);
            translate( [-20/2-mount_thk-60,-motorR-10/2+5,5] ) linear_extrude(height = 10) nutHole(3, proj = 1);
            translate( [-20/2-mount_thk-60,motorR+10/2-5,5] ) linear_extrude(height = 10) nutHole(3, proj = 1);
            //bolt
            if( !with_mounting_holes )
            {
                translate([-mount_size.x+10,mount_size.y/2-5,-sheetW_b]) boltHole(4,MM,12);
                translate([-mount_size.x+10,-mount_size.y/2+5,-sheetW_b]) boltHole(4,MM,12);
                translate( [-20/2-mount_thk-60,-motorR-10/2+5,-sheetW_b] ) boltHole(3, MM, 15);
                translate( [-20/2-mount_thk-60,motorR+10/2-5,-sheetW_b] ) boltHole(3, MM, 15);
            }
            
            //curve shape for strength
            translate([-mount_size.x,mount_size.y,RR+motor_ht])  rotate([90,0,0]) cylinder(r = RR, h = mount_size.y*2);
            
             //for zip tie
            translate([-mount_thk-60-4-2,0,motorR+7.5/2+4]) rotate([0,90,0]) difference() {
                cylinder(r = motorR+7.5, h = 4);
                cylinder(r = motorR+5, h = 4);
            }
            
            translate([-25-mount_thk,0,motorR+motor_ht]) motor(side, true);
        }
    }
}

//motor_with_holes();
//motor_stl();
module motor_with_holes()
{
    motor_hole_r = 3/2;
    motor_hole_l = 20;
    motor_hole_dist = 13;
    for (i = [0:3])
    {        
        hull()
        {
            translate([xx(motor_hole_dist-1,i),yy(motor_hole_dist-1,i),25]) cylinder(r = motor_hole_r, h = motor_hole_l);
            translate([xx(motor_hole_dist+1,i),yy(motor_hole_dist+1,i),25]) cylinder(r = motor_hole_r, h = motor_hole_l);
        }
    }
    
    translate([0,0,25]) cylinder(r = 16.2/2, h = motor_hole_l);
    
    translate([0,0,-mount_size.x+25]) linear_extrude(height=mount_size.x) motor_face();
    
    translate([0,0,-25]) cylinder(r = 30/2, h = 40);
    
    translate([0,0,-25-26.7]) cylinder(r = 33.48/2, h = 26.70);
}

module motor_stl()
{
    import("Faulhaber-encoder-motor-repaired.stl");
}

module motor_face(exact = false)
{
    if( exact )
        projection(cut = false) translate([0,0,-10]) motor_stl();
    if(!exact)
        circle(r=41/2);
}

/********************* FUNCTIONS ********************/

function xx(r, i) = r*sin(90-(360/3)*i);
function yy(r, i) = r*cos(90+(360/3)*i);