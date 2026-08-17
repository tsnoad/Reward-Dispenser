/*
 * DDC612SA 5v->12v Buck regulator module
 * https://
 */
 
//include <../Homeassistant Case/common_params_and_modules.scad>;
//$fn = 144;
//ddc612sa();

ddc612sa_pcb_dim = [16.1,24.1,1.6];
ddc612sa_crn_rad = 0;
ddc612sa_screw_loc = [];
ddc612sa_pin_loc = concat(
    //[for(ixm=[-1,1])for(ip=[0:8-1])-[ixm*(7-1),8-1,0]/2*2.54+[0,(3.3-1.6)/2,0]+[0,ip,0]*2.54],
    
    //[for(ip=[-1:1])[ip*2.54,-pcb_dim[1]/2+1.75,0]]
    
    [for(ix=[0:3-1])for(ip=[0])[-(3-1),0,0]/2*2.54+[0,-ddc612sa_pcb_dim[1]/2+1.75,0]+[ix,ip,0]*2.54],
);
ddc612sa_top_component_trans = [
        xyz_to_trans(ddc612sa_pcb_dim/2)-outset_xxyy_to_trans(0.3,0.3,3,2.6),
        xyz_to_trans(ddc612sa_pcb_dim/2)-outset_xxyy_to_trans(0.3,7.4,15.4,0.3),
];
ddc612sa_top_component_z = [
    2,
    4.8,
];

module ddc612sa(btm_plate_thk=4,top_plate_thk=4,pcb_dim=ddc612sa_pcb_dim) {
co=true;
co_screw=false;
tray_top_thk=10;
tray_thk=5;

    /*top_component_trans = [
        xyz_to_trans(pcb_dim/2)-outset_xxyy_to_trans(0.3,0.3,3,2.6),
        xyz_to_trans(pcb_dim/2)-outset_xxyy_to_trans(0.3,7.4,15.4,0.3),
    ];
    
    top_component_z = [
        2+0.4,
        4.8+0.4,
    ];
    
    btm_component_trans = [
    ];
    
    btm_component_z = [
    ];*/
    
    //pcb cutout
    component_pcb_co(pcb_dim);
    
    component_top_component_co(ddc612sa_top_component_trans,ddc612sa_top_component_z,top_plate_thk);
    
    /*//top component cutouts
    for(cutout_i=[0:len(top_component_trans)-1]) component_co_upwards(top_component_z[cutout_i],top_plate_thk,top_component_trans[cutout_i]);
    
    //bottom component cutouts
    if(len(btm_component_trans)>0) for(cutout_i=[0:len(btm_component_trans)-1]) component_co_downwards(pcb_dim[2]+btm_component_z[cutout_i],btm_plate_thk,btm_component_trans[cutout_i]);
    
    
    pin_header_trans = concat(
        [for(ip=[-1:1])[ip*2.54,-pcb_dim[1]/2+1.75,0]],
    );
    
    pin_header_crn_trans = concat(
        [for(ip=[-1:1])xyz_to_trans([1,1,0]*2.54/2)+outset_xxyy_to_trans(0,0,0,1)*2.54],
    );
    
    for(pin_header_i=[0:len(pin_header_trans)-1]) component_co_downwards(btm_plate_thk,btm_plate_thk,[[1],[1],[1],[1]]*[pin_header_trans[pin_header_i]]+pin_header_crn_trans[pin_header_i]);
    
    for(pin_header_i=[0:len(pin_header_trans)-1]) component_co_upwards(1,top_plate_thk,[[1],[1],[1],[1]]*[pin_header_trans[pin_header_i]]+pin_header_crn_trans[pin_header_i]);*/
}
