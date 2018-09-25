//Motor dimensions
//Cylinder : r,h,z translate
//Cone : r1,r2,h,z translate
/*
shaftL=21.8; 
motorDim = [["cylinder",33/2, 19, 0],["cone", 36.8/2,37.4/2,21.2,19]]; //r,h,z translate
shaftOffset = 0;
shaftDim = [ [ "cylinder", 13.5/2, 10, 40.2 ], [ "cylinder",6.00/2, shaftL,40.2+10 ] ]; //r,h,z translate
motorR = 37.4/2;
motorL = 19+21.2+10+shaftL;  //total length
       //Shaft Length
motorDist = 10;


cyl_motor_pair(motorDim, shaftDim, shaftOffset,motorDist);
*/
module cyl_motor_pair(motorDim, shaftDim, shaftOffset, motorDist)
{
    translate([0,0,shaftOffset])
    {
        translate([motorDist/2,0,0]) rotate([0,90,0]) rotate([0,0,180]) cyl_motor(motorDim, shaftDim, shaftOffset);
        translate([-motorDist/2,0,0]) rotate([0,-90,0]) cyl_motor(motorDim, shaftDim, shaftOffset);
    }
}

module cyl_motor( motorDim, shaftDim, shaftOffset ) {
    union() {
        for(i = [0 : len(motorDim) ])
        {
            if(motorDim[i][0] == "cylinder")
                translate([0,0,motorDim[i][3]]) cylinder( r = motorDim[i][1], h = motorDim[i][2] );
            if(motorDim[i][0] == "cone")
                translate([0,0,motorDim[i][4]]) cylinder( r1 = motorDim[i][1], r2 = motorDim[i][2], h = motorDim[i][3] );
        }
        translate([-shaftOffset,0,0]) for(i = [0 : len(shaftDim) ])
        {
            if(shaftDim[i][0] == "cylinder")
                translate([0,0,shaftDim[i][3]]) cylinder( r = shaftDim[i][1], h = shaftDim[i][2] );
            if(shaftDim[i][0] == "cone")
                translate([0,0,shaftDim[i][4]]) cylinder( r1 = shaftDim[i][1], r2 = shaftDim[i][2], h = shaftDim[i][3] );
        }
    }
}