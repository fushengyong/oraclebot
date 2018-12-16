include <MCAD/triangles.scad>;

//U_clip_top( [5,5,5], 100, 10, 10, true );

U_clip_top( [5,5,5], 100, 10, 100, false );

//_clip( [5,5,5], false );

//_pin( 20, 40, 10 );

module U_clip_top(pins_size, pin_dist, clip_length, clip_ht, with_mounting_holes = false)
{
    thk = pins_size.y;
    clip_x_thk = pins_size.x/2;
    
    _clip( pins_size, pin_dist, with_mounting_holes );
    
    translate([pin_dist/2,-thk/2,-clip_length]) cube([clip_x_thk, thk, clip_length]);
    translate([-pin_dist/2-clip_x_thk,-thk/2,-clip_length]) cube([clip_x_thk, thk, clip_length]);
    
    translate([-pin_dist/2-clip_x_thk,-thk/2,-clip_length]) cube([clip_x_thk*2+pin_dist, thk, thk]);
    
    translate([-pin_dist/2-clip_x_thk,-thk/2,-clip_length]) cube([clip_x_thk*2+pin_dist, thk+clip_ht, thk]);
    
    
}

module _clip( pins_size, pin_dist, with_mounting_holes = false)
{
    
    translate([pin_dist/2, 0, 0]) _pin( pins_size.x, pins_size.z, pins_size.y, with_mounting_holes );
    
    translate([-pin_dist/2, 0, 0]) rotate([0,0,180]) _pin( pins_size.x, pins_size.z, pins_size.y, with_mounting_holes );
}

module _pin( pin_base, pin_ht, thk, with_mounting_holes = false )
{
    hole_bottom_size = 5;
    if( with_mounting_holes == true )
    {
        translate([-pin_base/2,-thk/2, -hole_bottom_size]) cube([pin_base, thk, pin_ht + hole_bottom_size ]);
    }
    else
    {
        translate([0,thk/2,0]) rotate([90,0,0]) triangle(pin_ht, pin_base,thk);
    }
}