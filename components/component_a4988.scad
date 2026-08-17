/*
 * A4988 stepper motor driver
 */
 
//include <../Shared Libraries/common_params_and_modules.scad>;
//include <../Shared Libraries/component_shared_modules.scad>;
//$fn = 144;
//a4988();
//a4988_placeholder();

a4988_pcb_dim = [15.5,20.2,1.6];
a4988_crn_rad = 0;
a4988_screw_loc = [];
a4988_pin_loc = concat(
    [for(ixm=[-1,1])for(ip=[0:8-1])-[ixm*(6-1),8-1,0]/2*2.54+[0,0,0]+[0,ip,0]*2.54],
);
a4988_top_component_trans = [
    xyz_to_trans(a4988_pcb_dim/2)-outset_xxyy_to_trans(2.4,2.4,0.6,0.9),
    //heatsink
    [[1],[1],[1],[1]]*[[0,a4988_pcb_dim[1]/2-9,0]]+xyz_to_trans([12,12,0]/2),
];
a4988_top_component_z = [
    2,
    6,
];

module a4988(btm_plate_thk=4,top_plate_thk=4) {
    //pcb cutout
    component_pcb_co(a4988_pcb_dim);
    
    component_top_component_co(a4988_top_component_trans,a4988_top_component_z,top_plate_thk);
}

module a4988_upside_down(btm_plate_thk=4,top_plate_thk=4) {
    //pcb cutout
    component_pcb_co(a4988_pcb_dim);
    
    echo(a4988_top_component_trans);
    
    a4988_top_component_trans_flip = [for(i=[0:len(a4988_top_component_trans)-1])a4988_top_component_trans[i]*[[-1,0,0],[0,1,0],[0,0,1]]];
    
    component_btm_component_co(a4988_top_component_trans_flip,a4988_top_component_z,btm_plate_thk);
}

module a4988_trimpotwindow(btm_plate_thk=4,top_plate_thk=4) {
    window_loc = [
        a4988_pcb_dim/2*ident_xyz_xy+[-8,-5.2,0],
    ];
    
    for(window_i=[0:len(window_loc)-1]) component_co_upwards(top_plate_thk,top_plate_thk,[[1],[1],[1],[1]]*[window_loc[window_i]]+xyz_to_trans([4,5,0]/2));
}


module a4988_placeholder() {
    component_placeholder(a4988_pcb_dim,a4988_crn_rad,a4988_screw_loc,[],a4988_top_component_trans,a4988_top_component_z);
    
    translate([0,0,-a4988_pcb_dim[2]]) rotate([0,180,0]) component_placeholder(a4988_pcb_dim,a4988_crn_rad,a4988_screw_loc,a4988_pin_loc,[],[]);
}
