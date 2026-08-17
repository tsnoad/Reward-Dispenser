/*
 * ESP32-C3 Supermini MCU
 */
 
//include <../Homeassistant Case/common_params_and_modules.scad>;
//include <../Shared Libraries/component_shared_modules.scad>;
//include <../Shared Libraries/component_esp32c3.scad>;
//$fn = 144;
//esp32c3();

esp32c3_pcb_dim = [17.8,22.7,1.0];
esp32c3_crn_rad = 0;
esp32c3_screw_loc = [];
esp32c3_pin_loc = concat(
    [for(ixm=[-1,1])for(ip=[0:8-1])-[ixm*(7-1),8-1,0]/2*2.54+[0,(3.3-1.6)/2,0]+[0,ip,0]*2.54],
);

esp32c3_button_loc = [];

//[for(ix=[-1,1])for(ip=[0:7])[ix*(7/2-0.5)*2.54,(3.3-1.6)/2+(-(8/2-0.5)+ip)*2.54,0]],
    

esp32c3_top_component_trans = [
    xyz_to_trans(esp32c3_pcb_dim/2)-outset_xxyy_to_trans(2.4,2.4,3.1,0),
    xyz_to_trans(esp32c3_pcb_dim/2)-outset_xxyy_to_trans(5.8,5.8,0.4,0),
];
esp32c3_top_component_z = [
    2,
    1,
];


module esp32c3(btm_plate_thk=4,top_plate_thk=4,pcb_dim=esp32c3_pcb_dim) {
   
    //pcb cutout
    component_pcb_co(esp32c3_pcb_dim);
    
    component_top_component_co(esp32c3_top_component_trans,esp32c3_top_component_z,top_plate_thk);
    
    
    //usb c cutout
    usbc_crn_trans = xy1xy2_to_trans(list_x_to_vec([-1,1]*9/2)+list_y_to_vec([0,-3.2]));

    translate([0,esp32c3_pcb_dim[1]/2-10,0]) rotate([-90,0,0]) {
        cylinder_oh_bev(1+clr_component,10+1.4+clr_component,bev_m,bev_m,usbc_crn_trans-outset_to_trans(1));
        cylinder_oh_bev(1+clr_component,10+clr_pcb,bev_m,bev_m,usbc_crn_trans-outset_to_trans(1),180,true,0);
    }
    
    /*//top component cutouts
    for(cutout_i=[0:len(top_component_trans)-1]) cylinder_bev_co_blind_upwards(0,top_component_z[cutout_i],bev_m,0,clr_loose,top_component_trans[cutout_i]);
    
    //bottom component cutouts
    if(len(btm_component_trans)>0) for(cutout_i=[0:len(btm_component_trans)-1]) component_co_downwards(pcb_dim[2]+btm_component_z[cutout_i],btm_plate_thk,btm_component_trans[cutout_i]);
    
    //usb c cutout
    //translate([0,esp32c3_pcb_dim[1]/2-10,0]) rotate([-90,0,0]) cylinder_oh_bev(clr_loose,10+1.4+clr_loose,0,bev_m,xy1xy2_to_trans(list_x_to_vec([-1,1]*9/2)+list_y_to_vec([0,-3.2/2])));
    for(izm=[0,1]) intersection() {
        mirror([0,0,izm]) translate(-[200,200,0]/2+[0,0,-0.01]) cube([200,200,50]);
        union() {
            translate([0,esp32c3_pcb_dim[1]/2-10,3.2/2]) rotate([-90,0,0]) cylinder_bev(1+clr_loose,1.4+clr_loose+10,bev_m,bev_m,xyz_to_trans([9,3.2,0]/2)-outset_to_trans(1)+outset_xxyy_to_trans(0,0,izm!=0?1:0,izm==0?1:0)*10);
            
            translate([0,esp32c3_pcb_dim[1]/2+4-(4-w6-clr_loose),3.2/2]) rotate([-90,0,0]) cylinder_bev_co_blind_downwards(1,w6+clr_loose,bev_m,bev_m,clr_loose,xyz_to_trans([9,3.2,0]/2)-outset_to_trans(1)+outset_xxyy_to_trans(0,0,izm!=0?1:0,izm==0?1:0)*10);
            
            translate([0,esp32c3_pcb_dim[1]/2+4,3.2/2]) rotate([-90,0,0]) cylinder_bev_co_blind_downwards(1+2,(4-w6-clr_loose),0,(4-w6-clr_loose),clr_loose,xyz_to_trans([9,3.2,0]/2)-outset_to_trans(1)+outset_xxyy_to_trans(0,0,izm!=0?1:0,izm==0?1:0)*10);
        }
    }
    
    pin_header_trans = concat(
        [for(ix=[-1,1])for(ip=[0:7])[ix*(7/2-0.5)*2.54,(3.3-1.6)/2+(-(8/2-0.5)+ip)*2.54,0]],
    );
    
    pin_header_crn_trans = concat(
        [for(ix=[-1,1])for(ip=[0:7])xyz_to_trans([1,1,0]*2.54/2)+outset_xxyy_to_trans(ix>0?1:0,ix<0?1:0,0,0)*2.54],
    );
    
    for(pin_header_i=[0:len(pin_header_trans)-1]) component_co_downwards(btm_plate_thk,btm_plate_thk,[[1],[1],[1],[1]]*[pin_header_trans[pin_header_i]]+pin_header_crn_trans[pin_header_i]);
    
    for(pin_header_i=[0:len(pin_header_trans)-1]) component_co_upwards(1,top_plate_thk,[[1],[1],[1],[1]]*[pin_header_trans[pin_header_i]]+pin_header_crn_trans[pin_header_i]);*/
}

module esp32c3_usbc_holder_co(wall_thk=4,co_top=false) {
    //usb c cutout
    usbc_crn_trans = xy1xy2_to_trans(list_x_to_vec([-1,1]*9/2)+list_y_to_vec([0,-3.2]));

    translate([0,esp32c3_pcb_dim[1]/2+wall_thk,0]) rotate([-90,0,0]) {
        cylinder_oh_bev_co_blind_downwards(1,wall_thk,bev_m,bev_m,clr_component,usbc_crn_trans-outset_to_trans(1));
        if(co_top) cylinder_oh_bev_co_blind_downwards(1,wall_thk,bev_m,bev_m,clr_component,usbc_crn_trans-outset_to_trans(1),180,true,0);
    }
}

module esp32c3_usbc_wall_co(wall_dist=clr_loose,wall_thk=4,wall_inset=4-w6) {
    // usbc_crn_trans = xy1xy2_to_trans(list_x_to_vec([-1,1]*9/2)+list_y_to_vec([0,-3.2]));

    // //usb c cutout
    // translate([0,esp32c3_pcb_dim[1]/2+wall_dist,0]) rotate([-90,0,0]) {
    //     translate([0,0,-wall_dist]) cylinder_oh_bev_co_through(1,wall_thk-wall_inset,0,0,clr_component,usbc_crn_trans-outset_to_trans(1));
        
    //     intersection() {
    //         translate([0,0,-wall_dist]) cylinder_oh_bev_co_through(1,wall_thk-wall_inset+wall_dist,wall_dist+bev_m,bev_m,clr_component,usbc_crn_trans-outset_to_trans(1));
    //         translate(-[1,2,1]*50/2+[0,esp32c3_pcb_dim[2],0]) cube([50,50,50]);
    //     }
        
    //     translate([0,0,wall_thk]) {
    //         if(wall_inset<=2*bev_m) cylinder_bev_co_blind_downwards(2,wall_inset,wall_inset,0,clr_loose,usbc_crn_trans+outset_to_trans(12/2-3.2/2-2));
            
    //         if(wall_inset>2*bev_m) cylinder_oh_bev_co_blind_downwards(2,wall_inset,bev_m,bev_m,clr_loose,usbc_crn_trans+outset_to_trans(12/2-3.2/2-2),0,true);
    //     }
    // }

    usbc_wall_co(esp32c3_pcb_dim,wall_dist,wall_thk,wall_inset);
}

