 
include <../Shared Libraries/common_params_and_modules.scad>;
include <../Shared Libraries/component_shared_modules.scad>;
include <../Shared Libraries/component_esp32c3.scad>;
include <../Shared Libraries/component_ddc612sa.scad>;
include <../Shared Libraries/component_a4988.scad>;
include <../Shared Libraries/component_stepper_nema17.scad>;
include <../Shared Libraries/component_heatset_m3x5x5.scad>;

$fn = 144;
//esp32c3();

screw_type_selftap = 0; //M3 x 8mm countersunk self-tapping screw
screw_type_heatset = 1; //M3 x 5mm (len) x 5mm (OD) heatset insert and pan-head screw

base_screw_type = screw_type_selftap;
lid_screw_type = screw_type_heatset;

lid_screw_len = (lid_screw_type==screw_type_selftap?8:0)+(lid_screw_type==screw_type_heatset?10:0);
lid_screw_eng_len = (lid_screw_type==screw_type_selftap?lid_screw_len*0.75:0)+(lid_screw_type==screw_type_heatset?heatset_hgt-1:0);

base_screw_len = (base_screw_type==screw_type_selftap?8:0)+(base_screw_type==screw_type_heatset?10:0);
base_screw_eng_len = (base_screw_type==screw_type_selftap?base_screw_len*0.75:0)-(base_screw_type==screw_type_heatset?heatset_hgt-1:0);


stepper_flange_screw_len = 8;
stepper_flange_screw_eng_len = stepper_flange_screw_len-stepper_flange_hgt;

//wall_thk = 2*(w6+3+clr_close);
screw_trans = xyz_to_trans([1,1,0]*100/2+[1,1,0]*(w6+3+clr_close));
wall_thk = (w6+3+clr_close)+(1.25+w6+clr_close+w6);
//echo(wall_thk);

slope_angle = 30;
hgt1 = 10;
hgt2 = hgt1+100*tan(slope_angle);

step_h0 = hgt1;
step_h1 = hgt2;
step_l = 100;
round_r0 = 2.5;
round_r1 = 2.5;
t1_hyp = sqrt(pow(step_h1-step_h0-round_r0-round_r1,2)+pow(step_l,2));
t1_theta = atan2(step_l,(step_h1-step_h0-round_r0-round_r1));
t2_theta = acos((round_r0+round_r1)/t1_hyp);
theta = 180 - (t1_theta + t2_theta);
slope_angle_true = theta;
//echo(t1_theta + t2_theta);

outer_crn_trans = xyz_to_trans([1,1,0]*100/2+[1,1,0]*wall_thk);

lip_hgt = 1.6;
    
lid_hgt1 = /*lid_base_thk +*/ 8;
lid_hgt2 = lid_hgt1 + hgt2 - hgt1;

base_hgt = 38;
base_thk0 = 0.8;
base_thk1 = base_thk0+2;

base_screw_trans = screw_trans-outset_xxyy_to_trans(0,0,1,1)*(2*(3+clr_close)+w6);
base_screw_boss_fillet1_trans = xyz_to_trans(screw_trans[0]*ident_xyz_x-[3+clr_close+w6+2,0,0]+outer_crn_trans[0]*ident_xyz_y-[0,w6+2,0]);
base_screw_boss_fillet2_trans = xyz_to_trans(outer_crn_trans[0]*ident_xyz_x-[w6+2,0,0]+screw_trans[0]*ident_xyz_y-[0,(2*(3+clr_close)+w6)+3+clr_close+w6+2,0]);

base_feet_trans = xyz_to_trans(
    [1,0,0]*(100/2+wall_thk)
    +[0,1,0]*(100/2+(w6+3+clr_close)-(2*(3+clr_close)+w6))
    -[0,1,0]*(3+clr_close)
    -[1,1,0]*w6
    -[1,1,0]*(3.8/2+clr_tight+w6)
    -[1,1,0]*(2*bev_m)
    );

stepper_plate_screw_trans = stepper_screw_trans+outset_to_trans(3+clr_close+w6+clr_loose)+xyz_to_trans([1,-1,0]*(1.25+w6));

picking_spool_r = 55;
picking_spool_h = 9+1-2*clr_loose;
picking_hole_r = 14/2+2*clr_loose;
picking_hole_trans = list_y_to_vec([-1,1]*(picking_spool_r-w6-picking_hole_r));


picking_spool_standby_offset = 2*asin(picking_hole_r/abs(picking_hole_trans[0][1]));

standby_offset = 2*asin(picking_hole_r/abs(picking_hole_trans[0][1]));
steps_per_rotation = 200*16;

echo("+++");
echo("Stepper commands");
echo("---");
echo(str("Rot to chute, Rot to standby"));
echo(str("Angle: ",str((180-standby_offset)," deg"),", ",str((standby_offset)," deg")));
for(i=[0:4]) {
    echo(str("x",pow(2,i),": ",str(round((180-standby_offset)/360*200*pow(2,i))," steps"),", ",str(round(standby_offset/360*200*pow(2,i))," steps")));
}

echo(steps_per_rotation/2);

echo(standby_offset);
echo(round((180-standby_offset)/360*steps_per_rotation));
echo(round(standby_offset/360*steps_per_rotation));

echo("+++");

chute_r = picking_hole_r+1;
chute_x = -(abs(stepper_screw_trans[0][0])+(3+clr_close+w6)+clr_loose+w6+chute_r);
chute_y = 100/2+wall_thk-w6-chute_r;


module align_to_diag() translate([0,0,hgt1+(hgt2-hgt1)/2]) rotate([slope_angle_true,0,0]) children();

electronics_holder_loc = [0,1,0]*(100/2+wall_thk-w6-clr_loose)-esp32c3_pcb_dim/2*ident_xyz_y;
electronics_holder_wid = max(esp32c3_pcb_dim[0],ddc612sa_pcb_dim[1]);
electronics_holder_crn_trans = 
    [[1],[1],[1],[1]]*[electronics_holder_loc]+(
        xyz_to_trans(esp32c3_pcb_dim/2)
        //+outset_xxyy_to_trans(1,1,0,0)*(ddc612sa_pcb_dim[1]-esp32c3_pcb_dim[0])/2
        +outset_xxyy_to_trans(0,0,1,0)*(4+4+ddc612sa_pcb_dim[0])
        +outset_xxyy_to_trans(0,0,1,0)*(4+a4988_pcb_dim[0])
    )*ident_xyz_y+xyz_to_trans([1,0,0]*electronics_holder_wid/2);
    
electronics_holder_hgt = 4+3;

electronics_holder_hgt1 = electronics_holder_hgt;
electronics_holder_hgt2 = electronics_holder_hgt1+2;
electronics_holder1_crn_trans = electronics_holder_crn_trans-outset_xxyy_to_trans(0,0,0,1)*(esp32c3_pcb_dim[1]+4+4);
electronics_holder2_crn_trans = electronics_holder_crn_trans-outset_xxyy_to_trans(0,0,1,0)*(4+4+ddc612sa_pcb_dim[0]+4+a4988_pcb_dim[0]);

electronics_holder_screw_trans = concat(
    list_x_to_vec([-1,1]*(electronics_holder_wid/2+4+(3+clr_close)))+list_y_to_vec([1,1]*(electronics_holder_crn_trans[0][1]-(clr_loose+(3+clr_close+w6)))),
    [electronics_holder_crn_trans[2]*ident_xyz_y-[0,1,0]*(4+(3+clr_close))],
);

electronics_esp32c3_loc = electronics_holder_loc;
electronics_ddc612_loc = electronics_esp32c3_loc-(esp32c3_pcb_dim/2+[0,4+4,0]+ddc612sa_pcb_dim/2*rotation_matrix(-90))*ident_xyz_y;
electronics_a4988_loc = electronics_ddc612_loc-(ddc612sa_pcb_dim/2*rotation_matrix(-90)+[0,4,0]+a4988_pcb_dim/2*rotation_matrix(-90))*ident_xyz_y;

//printables parts
!/* make 'Reward Dispenser A.stl' */ base();
*/* make 'Reward Dispenser B.stl' */ rotate([0,180,0]) electronics_holder_top();
*/* make 'Reward Dispenser C.stl' */ body();
*/* make 'Reward Dispenser D.stl' */ rotate([0,180,0]) stepper_mount_plate();
*/* make 'Reward Dispenser E.stl' */ picking_spool();
*/* make 'Reward Dispenser F.stl' */ lid(true);

//blurg
!union() {
    intersection() {
        picking_spool();
        cylinder_bev(picking_spool_r+clr_free-2*clr_loose,picking_spool_h,2*bev_m,bev_m,$fn=$fn*2);
    }
    difference() {
        cylinder_bev(picking_spool_r+clr_free-2*clr_loose,picking_spool_h,2*bev_m,bev_m,$fn=$fn*2);
        cylinder_bev_co_through(picking_spool_r+clr_free-2*clr_loose-w4,picking_spool_h,bev_m,bev_m,0,$fn=$fn*2);
    }
}

*!intersection() {
    lid(true);
    translate([0,0,lid_hgt2-25]) cylinder_bev(5,25+lip_hgt,bev_m,bev_m,outer_crn_trans-outset_to_trans(5)-outset_xxyy_to_trans(0,0,1,0)*(2*(100/2+wall_thk)-50));
}

//clearance test
*/* make 'Reward Dispenser test clearance.stl' */ difference() {
    hull() {
        cylinder_bev(picking_hole_r+w6,picking_spool_h+0.8,bev_m,bev_m);
        cylinder_bev(chute_r+w6,picking_spool_h+0.8,bev_m,bev_m,[[picking_hole_r+w6+chute_r,0,0]]);
    }
    cylinder_bev_co_blind_downwards(picking_hole_r,picking_spool_h,bev_m,bev_m,0,[[0,0,picking_spool_h+0.8]]);
    cylinder_bev_co_through(chute_r,picking_spool_h+0.8,bev_m,bev_m,0,[[picking_hole_r+w6+chute_r,0,0]]);
}  

//test piece for electronics component fit
*/* make 'Reward Dispenser test elec_fit.stl' */ rotate([0,0,180]) intersection() {
    base();
    cylinder_bev(5,min(20,base_hgt),bev_m,bev_m,electronics_holder_crn_trans+outset_xxyy_to_trans(1,1,1,1)*9);
}

//test piece for LED strip fit
*/* make 'Reward Dispenser test led_fit.stl' */ rotate([0,0,180]) intersection() {
    base();
    cylinder_bev(clr_close+w6,min(25,base_hgt),bev_m,bev_m,xy1xy2_to_trans(list_x_to_vec([-1,1]*(1000/60*3/2))-list_y_to_vec([1,1]*(100/2+wall_thk-2*(chute_r+w6)-2-clr_loose-2)+[0,2-clr_close+w6])));
}

//assembled
*union() {
    rotate([0,0,180]) base();
    
    translate([0,0,base_hgt]) {
        body();
        translate([0,0,hgt1]) lid();
    }
}

//assembled internal parts
union() {
    *rotate([0,0,180]) translate([0,0,electronics_holder_hgt1]) electronics_holder_top();
    translate([0,0,base_hgt]) align_to_diag() {
        translate(-[0,0,picking_spool_h]) picking_spool();
        
        *translate([0,0,-picking_spool_h-clr_loose]) {
            stepper_mount_plate();
        
            translate([0,0,-16-stepper_hgt]) cylinder_bev(2,stepper_hgt,bev_m,bev_m,stepper_crn_trans-outset_to_trans(2));
        }
    }
}

module cross_section(enable=true) intersection() {
    if(enable) translate(-[0,1,0]/2*200-[0,0,10]) cube([1,1,1]*200);
    children();
}

//cross sections
union() {
    *cross_section() rotate([0,0,180]) base();
    
    translate([0,0,base_hgt]) {
        *cross_section() body();
        translate([0,0,hgt1]) cross_section() lid();
    }
}

//negative parts for fit checking
*union() {
    intersection() {
        rotate([0,0,180]) {
            base_cutout();
            rotate([0,0,180]) base_tray(false,true,false);
        }
        cylinder_bev(5,base_hgt,bev_m,bev_m,outer_crn_trans-outset_to_trans(5));
    }
    translate([0,0,base_hgt]) {
        intersection() {
            body_cutout();
            cylinder_bev(5,hgt2,bev_m,bev_m,outer_crn_trans-outset_to_trans(5));
        }
        
        translate([0,0,hgt1]+[0,0,1]*lid_hgt2) rotate([180,0,0]) lid_cutout();
    }
}


    
module picking_spool() difference() {
    cylinder_bev(picking_spool_r,picking_spool_h,bev_m,bev_m,$fn=$fn*2);
    
    //hole to allow access to the stepper plate screws
    translate([1,0,0]*(sqrt(pow(stepper_plate_screw_trans[0][0],2)+pow(stepper_plate_screw_trans[0][1],2)))) cylinder_bev_co_through(3,picking_spool_h,bev_m,bev_m,clr_close);
    
    //cutouts to pick up candy pieces and deliver them to the chute
    for(it=picking_hole_trans) cylinder_bev_co_through(picking_hole_r,picking_spool_h,bev_m,bev_m,0,[it]);
    
    //ramps to make picking up easier
    for(it=picking_hole_trans) for(i_ext=[0:1/($fn/4):1-1/($fn/4)]) {
        bev_rad = 5;
        
        hull() for(i_int=[i_ext,i_ext+1/($fn/4)]) {
            ia = -(bev_rad-bev_rad*sin(i_int*90))/(pi*2*abs(it[1]))*360;
            ih = bev_rad-bev_rad*cos(i_int*90);
            
            rotate([0,0,ia]) translate(it+[0,0,picking_spool_h]) cylinder_bev_co_blind_downwards(picking_hole_r,ih+bev_m,0,0,0);
        }
        hull() for(i_int=[i_ext,i_ext+1/($fn/4)]) {
            ia = -(bev_rad-bev_rad*sin(i_int*90))/(pi*2*abs(it[1]))*360;
            
            rotate([0,0,ia]) translate(it+[0,0,picking_spool_h]) cylinder_bev_co_blind_downwards(picking_hole_r,bev_m,0,bev_m,0);
        }
    }
    
    //alignment mark for standby position
    translate([0,0,picking_spool_h]) cylinder_bev_co_blind_downwards(w1,bev_m,0,bev_m,0,list_y_to_vec([1,1]*(picking_spool_r-w6)-[10,0])*rotation_matrix(-standby_offset+45));
    
    //cutout for screws to attach stepper flange
    for(it=stepper_flange_screw_trans) cylinder_bev_co_blind_upwards(1.25,stepper_flange_screw_eng_len+1,bev_m,0.5,0,[it]);
    
    //clearance for stepper shaft
    cylinder_bev_co_blind_upwards(stepper_shaft_r,-16+stepper_shaft_hgt+1,bev_m,bev_m,clr_free);
}


module stepper_mount_plate() rotate([180,0,0]) difference() {
    stepper_screw_len = 10;
    stepper_screw_head_ext = stepper_screw_len-(stepper_screw_eng_dep-1);
    
    stepper_dep = 16;
    
    union() {
        cylinder_bev(3+clr_close+w4,4,bev_m,bev_m,stepper_plate_screw_trans);
        
        //translate([0,0,4]) cylinder_bev_stud(3+clr_close+w6,-4+20,bev_m,bev_m,stepper_screw_trans);
        for(it=stepper_screw_trans) translate([0,0,4]) cylinder_bev_stud(3+clr_close+w6,-4+stepper_dep,bev_m,bev_m,[it]);
    }
    
    //cylinder_bev_co_through(stepper_flange_r,20,bev_m,bev_m,clr_loose);
    cylinder_bev_co_through(stepper_flange_r,4,bev_m,bev_m,clr_loose);
    
    
    /*intersection() {
        rotate([90,0,0]) cylinder_bev_co_through(2,abs(stepper_screw_trans[0][1])+(3+clr_close+w6)+bev_m,0,bev_m+bev_m,0,xy1xy2_to_trans(list_x_to_vec([-1,1]*5)+list_y_to_vec([4,50]))-outset_to_trans(2));
        
        translate([0,0,4]) cylinder_bev(3+clr_close+w6,50,0,0,stepper_plate_screw_trans);
    }
    
    translate([0,0,20]) cylinder_bev_co_blind_downwards(2,bev_m,0,bev_m,0,xy1xy2_to_trans(list_x_to_vec([-1,1]*5)-list_y_to_vec([0,50]))-outset_to_trans(2));
    
    hull() for(ib=[0,bev_m]) intersection() {
        rotate([90,0,0]) cylinder_bev_co_through(2+ib,abs(stepper_screw_trans[0][1])+(3+clr_close+w6)+bev_m,0,bev_m+bev_m,0,xy1xy2_to_trans(list_x_to_vec([-1,1]*5)+list_y_to_vec([4,50]))-outset_to_trans(2));
        
        cylinder_bev_co_through(stepper_flange_r+(bev_m-ib),20,0,0,clr_loose);
    }*/
    
    for(it=stepper_plate_screw_trans) cylinder_bev_co_through(1.5,4,3-1.5,bev_m,clr_close,[it]);
    
    for(it=stepper_screw_trans) translate(it) {
        cylinder_bev_co_through(1.5,stepper_dep,3-1.5,bev_m,clr_close);
        cylinder_bev_co_blind_upwards(3,stepper_dep-stepper_screw_head_ext,bev_m,0,clr_close);
        cylinder_bev_co_blind_upwards(0,stepper_dep-stepper_screw_head_ext+0.2,bev_m,0,clr_close,xyz_to_trans([sqrt(pow(3,2)-pow(1.5,2)),1.5,0]));
        cylinder_bev_co_blind_upwards(0,stepper_dep-stepper_screw_head_ext+0.4,bev_m,0,clr_close,xyz_to_trans([1,1,0]*1.5));
    }
}

module electronics_holder_top() difference() {
    holder_thk1 = 4;
    holder_thk2 = holder_thk1+(electronics_holder_hgt2-electronics_holder_hgt1);
    holder_z1 = electronics_holder_hgt2-electronics_holder_hgt1;
    holder_z2 = 0;

    union() {
        translate([0,0,holder_z1]) cylinder_bev(4,holder_thk1,bev_m,bev_m,electronics_holder_crn_trans-outset_xxyy_to_trans(0,0,0,1)*(4+clr_loose));
        
        cylinder_bev(4,holder_thk2,bev_m,bev_m,electronics_holder1_crn_trans);
        
        
        //screw bosses
        for(it=electronics_holder_screw_trans) translate([0,0,(it==electronics_holder_screw_trans[2]?holder_z2:holder_z1)]) cylinder_bev(3+clr_close+w6,(it==electronics_holder_screw_trans[2]?holder_thk2:holder_thk1),bev_m,bev_m,concat(
            [it],
            (it[1]==electronics_holder_screw_trans[0][1]?[it+[-sign(it[0]),0,0]*10]:[]),
            (it==electronics_holder_screw_trans[2]?[it+[0,10,0]]:[])
        ));
    }

    translate(electronics_esp32c3_loc+[0,0,holder_z1]) {
        esp32c3(electronics_holder_hgt,holder_thk1);
        
        for(pin_header_i=[0:len(esp32c3_pin_loc)-1]) {
            clr_z = 0.4;
            component_co_upwards(4,4,[[1],[1],[1],[1]]*[esp32c3_pin_loc[pin_header_i]]+xyz_to_trans([1,1,0]*2.54/2));
        }
    }
    translate(electronics_ddc612_loc) rotate([0,0,90]) {
        ddc612sa(electronics_holder_hgt,holder_thk2);
        
        for(pin_header_i=[0:len(ddc612sa_pin_loc)-1]) {
            clr_z = 0.4;
            component_co_upwards(holder_thk2,holder_thk2,[[1],[1],[1],[1]]*[ddc612sa_pin_loc[pin_header_i]]+xyz_to_trans([1,1,0]*2.54/2));
        }
    }
    translate(electronics_a4988_loc) rotate([0,0,90]) {
        translate([0,0,0.01]) rotate([0,180,0]) {
            a4988(holder_thk2,electronics_holder_hgt);
            
            for(pin_header_i=[0:len(a4988_pin_loc)-1]) {
                clr_z = 0.4;
                component_co_downwards(holder_thk2,holder_thk2,[[1],[1],[1],[1]]*[a4988_pin_loc[pin_header_i]]+xyz_to_trans([1,1,0]*2.54/2));
            }
        }
    }
    
    for(it=electronics_holder_screw_trans) {
        translate([0,0,(it==electronics_holder_screw_trans[2]?holder_z2:holder_z1)]) cylinder_bev_co_through(1.5,holder_thk1,bev_m,3-1.5,clr_close,[it]);
        if(it==electronics_holder_screw_trans[2]) translate([0,0,holder_thk2]) cylinder_bev_co_blind_downwards(3,holder_thk2-holder_thk1,0,bev_m,clr_close,[it]);
    }
}

module base() difference() {
    union() {
        difference() {
            cylinder_bev(5,base_hgt,bev_m,bev_m,outer_crn_trans-outset_to_trans(5));
            translate([0,0,base_hgt]) cylinder_bev_co_blind_downwards(5-w6,base_hgt-base_thk1,bev_m,bev_m,0,outer_crn_trans-outset_to_trans(5));
            
            translate([0,0,base_thk1]) cylinder_bev_co_blind_downwards(5,base_thk1-base_thk0,bev_m,bev_m,0,outer_crn_trans-outset_xxyy_to_trans(1,1,0,0)*(2*(w6+3+clr_close)-w6)-outset_to_trans(5+w6+2*bev_m+2));
        }
        intersection() {
            difference() {
                union() {
                    for(it=base_screw_trans) translate([0,0,base_thk1]) cylinder_bev_stud(3+clr_close+w6,base_hgt-base_thk1,bev_m,bev_m,xy1xy2_to_trans([it,it+[sign(it[0]),sign(it[1])]*50]));
                    
                    for(it=concat(base_screw_boss_fillet1_trans,base_screw_boss_fillet2_trans)) cylinder_bev_stud(0.01,base_hgt,0,0,xy1xy2_to_trans([it,it+[sign(it[0]),sign(it[1])]*50]));
                }
                
                for(it=concat(base_screw_boss_fillet1_trans,base_screw_boss_fillet2_trans)) translate([0,0,base_hgt]) cylinder_bev_co_blind_downwards(2,base_hgt-base_thk1,bev_m,bev_m,0,[it]);
            }
            cylinder_bev(5,base_hgt,bev_m,bev_m,outer_crn_trans-outset_to_trans(5));
        }
        
        difference() {
            cylinder_bev(5,base_thk1,bev_m,bev_m,outer_crn_trans-outset_to_trans(5));
            
            //triangular grid cutout 
            trigrid_r = 1;
            
            trigrid_co_z = base_thk1;
            trigrid_co_h = base_thk1-base_thk0;
            trigrid_hh = 20;
            trigrid_wh = trigrid_hh*tan(30);
            trigrid_ext = round(100/2*1.5/(2*trigrid_wh));
            
            for(ix=[-trigrid_ext:trigrid_ext]) for(iy=[-trigrid_ext:trigrid_ext]) translate([ix*2*trigrid_wh,iy*2*trigrid_hh,0]) {
                mirror([0,(floor(abs(ix)/2)*2==abs(ix)?0:1),0]) mirror([0,(floor(abs(iy)/2)*2==abs(iy)?0:1),0]) {
                    //cutout each triangle in the grid
                    translate([0,2*trigrid_wh/tan(60)-trigrid_hh,trigrid_co_z]) {
                        cylinder_bev_co_blind_downwards(trigrid_r,trigrid_co_h,bev_m,bev_m,0,points_reg_polygon_point(3)*(2*trigrid_wh/cos(30)-(w6/2+trigrid_r)/sin(30)));
                    }
                }
            }
        }
        
        //boss for LED strip
        rotate([0,0,180]) intersection() {
            difference() {
                base_led(true,false,false);
                base_led(false,true,false);
            }
            cylinder_bev(5,base_hgt,0,0,outer_crn_trans-outset_to_trans(5)-outset_xxyy_to_trans(0,0,0,1)*(2*chute_r+w6));
        }
        
        //boss for electronics
        intersection() {
            translate([0,0,base_thk0]) {
                cylinder_bev_stud(4,electronics_holder_hgt-base_thk0,bev_m,bev_m,electronics_holder_crn_trans);
                cylinder_bev_stud(4,electronics_holder_hgt2-base_thk0,bev_m,bev_m,electronics_holder2_crn_trans-outset_xxyy_to_trans(0,0,1,0)*clr_loose);
                
                //screw bosses
                for(it=electronics_holder_screw_trans) cylinder_bev_stud(3+clr_close+w6,(it==electronics_holder_screw_trans[2]?electronics_holder_hgt1:electronics_holder_hgt2)-base_thk0,bev_m,bev_m,concat(
                    [it],
                    (it[1]==electronics_holder_screw_trans[0][1]?xy1xy2_to_trans([it,it+[-sign(it[0]),1,0]*10]):[]),
                    (it==electronics_holder_screw_trans[2]?[it+[0,10,0]]:[])
                ));
            }
                
            cylinder_bev(5,base_hgt,bev_m,bev_m,outer_crn_trans-outset_to_trans(5));
        }
        
        //outlet tray to align with chute
        rotate([0,0,180]) difference() {
            base_tray(true,false,false);
            base_tray(false,true,false);
        }
        
        //positive ardound the clearance that we need for the stepper where it protrudes into the tray
        stepper_bottom_corner = (-[0,0,(picking_spool_h+clr_loose)+16]-[0,-abs(stepper_crn_trans[0][1])-clr_loose,stepper_hgt+clr_loose])*rotation_matrix_x(-slope_angle_true)+[0,0,hgt1+(hgt2-hgt1)/2];
        
        protrusion_y = (abs(stepper_bottom_corner[1])-(100/2+wall_thk-2*(chute_r+w6))) - (stepper_bottom_corner[2]>0 ? stepper_bottom_corner[2]/tan(slope_angle_true) : 0);
        protrusion_z = (stepper_bottom_corner[2]>0 ? 0 : stepper_bottom_corner[2]);
        
        if(protrusion_y>0) rotate([0,0,180]) intersection() {
            step_h0=w6;
            step_h1=w6+protrusion_y;
            step_l=abs(chute_x)-(abs(stepper_crn_trans[0][0])+clr_loose-1);
            round_r0=chute_r;
            round_r1=1.5;
            
            step_angle_max = 52.5;
            step_angle = round_step_angle(step_h0,step_h1,step_l,round_r0,round_r1);
            step_scale_z = (step_angle>step_angle_max ? tan(step_angle)/tan(step_angle_max) : 1);
            echo(step_angle);
            echo(step_scale_z);
            
            translate(-[0,0,-base_hgt-protrusion_z]) scale([1,1,step_scale_z]) translate([0,0,-base_hgt-protrusion_z]) {
                translate([0,100/2+wall_thk-2*(chute_r+w6),0]) rotate([-90,0,0]) {
                    round_step_area(step_h0,step_h1,0,step_l,round_r0,round_r1,xy1xy2_to_trans(list_x_to_vec([-1,1]*(abs(stepper_crn_trans[0][0])+clr_loose-1))-list_y_to_vec([1,1]*base_hgt+[0,protrusion_z])));
                }
            }
            translate([0,100/2+wall_thk-2*(chute_r+w6),0]) {
                for(ixm=[0,1]) mirror([ixm,0,0]) {
                    translate([abs(stepper_crn_trans[0][0])+clr_loose-1,0,0]) rotate([0,0,90]) round_step_3d_center_h1(step_h0,step_h1,step_l,round_r0,round_r1,base_hgt,bev_m,bev_m);
                }
                cylinder_bev(round_r1,base_hgt,bev_m,bev_m,xy1xy2_to_trans(list_x_to_vec([-1,1]*(abs(stepper_crn_trans[0][0])+clr_loose-1))+list_y_to_vec([step_h0+round_r1-w6,(step_h1-step_h0)-round_r1+w6])));
            }
            translate([0,100/2+wall_thk-(chute_r+w6),0]) {
                cylinder_bev(chute_r+w6,base_hgt,bev_m,bev_m,list_x_to_vec([-1,1]*chute_x));
            }
        }
        
        //bosses for feet
        intersection() {
            for(it=base_feet_trans) translate([0,0,base_thk0]) cylinder_bev_stud(3.8/2+clr_tight+w6,-base_thk0+2,bev_m,bev_m,xy1xy2_to_trans([it,it+[sign(it[0]),sign(it[1])]*50]));
            cylinder_bev(5,base_hgt,bev_m,bev_m,outer_crn_trans-outset_to_trans(5));
        }
    }
    
    base_cutout();
}

module base_cutout() {
    intersection() {
        union() {
            translate(electronics_esp32c3_loc+[0,0,electronics_holder_hgt2]) {
                esp32c3(electronics_holder_hgt,4);
                    
                for(pin_header_i=[0:len(esp32c3_pin_loc)-1]) {
                    clr_z = 0.4;
                    component_co_downwards(3+clr_z,electronics_holder_hgt,[[1],[1],[1],[1]]*[esp32c3_pin_loc[pin_header_i]]+xyz_to_trans([1,1,0]*2.54/2));
                }
            }
            translate(electronics_ddc612_loc+[0,0,electronics_holder_hgt1]) rotate([0,0,90]) {
                ddc612sa(electronics_holder_hgt,4);
                    
                for(pin_header_i=[0:len(ddc612sa_pin_loc)-1]) {
                    clr_z = 0.4;
                    component_co_downwards(3+clr_z,electronics_holder_hgt,[[1],[1],[1],[1]]*[ddc612sa_pin_loc[pin_header_i]]+xyz_to_trans([1,1,0]*2.54/2));
                }
            }
            translate(electronics_a4988_loc+[0,0,electronics_holder_hgt1]) rotate([0,0,90]) {
                translate([0,0,0.01]) rotate([0,180,0]) {
                    a4988(4,electronics_holder_hgt);
                    
                    for(pin_header_i=[0:len(a4988_pin_loc)-1]) {
                        clr_z = 0.4;
                        component_co_upwards(3-a4988_pcb_dim[2]+clr_z,electronics_holder_hgt,[[1],[1],[1],[1]]*[a4988_pin_loc[pin_header_i]]+xyz_to_trans([1,1,0]*2.54/2));
                    }
                }
            }
            
            for(it=electronics_holder_screw_trans) translate([0,0,(it==electronics_holder_screw_trans[2]?electronics_holder_hgt1:electronics_holder_hgt2)]) cylinder_bev_co_blind_downwards(1.25,8-4,0.5,bev_m,0,[it]);
        }
        cylinder_bev(5,electronics_holder_hgt2,0,0,xy1xy2_to_trans(list_x_to_vec([-1,1]*50/2)+list_y_to_vec([-100,100/2+wall_thk-w6]))-outset_to_trans(5));
    }
    translate(electronics_esp32c3_loc+[0,0,electronics_holder_hgt2]) esp32c3_usbc_wall_co(clr_loose,w6,w6-w4);
    
    rotate([0,0,180]) base_tray(false,false,true);
    
    rotate([0,0,180]) base_led(false,false,true);
    
    //clearance for stepper
    rotate([0,0,180]) translate([0,0,base_hgt]) cutout_stepper(true);
    
    //cutouts for feet
    for(it=base_feet_trans) {
        cylinder_bev_co_through(3.8/2,2,bev_m,bev_m,clr_tight,[it]);
        translate([0,0,base_thk1]) cylinder_bev_co_blind_downwards(3.8/2+clr_tight+w6,base_thk1-2,bev_m,bev_m,0,[it,it+[-sign(it[0]),0,0]*10]);
    }
    
    for(it=screw_trans) {
        cylinder_bev_co_through(3,base_hgt,bev_m,bev_m,clr_close,[it]);
    }
                
    for(it=base_screw_trans) {
        cylinder_bev_co_through(1.5,base_hgt,0,bev_m,clr_close,[it]);
        
        if(base_screw_type==screw_type_selftap) cylinder_bev_co_blind_upwards(3,base_hgt-(base_screw_len-base_screw_eng_len),bev_m,3-1.5,clr_close,[it]);
        
        if(base_screw_type==screw_type_heatset) translate(it) {
            cylinder_bev_co_blind_upwards(3,base_hgt-(base_screw_len-base_screw_eng_len),bev_m,0,clr_close);
            
            cylinder_bev_co_blind_upwards(0,base_hgt-(base_screw_len-base_screw_eng_len)+0.2,bev_m,0,clr_close,xyz_to_trans([sqrt(pow(3,2)-pow(1.5,2)),1.5,0]));
            cylinder_bev_co_blind_upwards(0,base_hgt-(base_screw_len-base_screw_eng_len)+0.4,bev_m,0,clr_close,xyz_to_trans([1,1,0]*1.5));
        }
    }
}

module base_tray(positive=true,negative=false,wall_neg=false) {
    tray_r1 = chute_r; //same as the chute radius
    tray_r2 = 4; //radius of bevel at bottom of tray
    
    tray_z0 = 4; //bottom of tray
    tray_z1 = tray_z0+tray_r2; //start of bevel
    tray_z2 = tray_z1+w6; //bottom lip of window to outside
    tray_z3 = tray_z2+tray_r1; //end of bevel in window
        
            
    if(positive) {
        intersection() {
            translate([0,0,base_thk0]) cylinder_bev_stud(tray_r1+w6,-base_thk0+base_hgt,bev_m,bev_m,xy1xy2_to_trans(list_x_to_vec([-1,1]*chute_x)+list_y_to_vec([chute_y,100])));
            
            cylinder_bev(5,base_hgt,bev_m,bev_m,outer_crn_trans-outset_to_trans(5));
        }
    }

    if(negative) {
        translate([0,0,tray_z0]) cylinder_bev_rad(tray_r1,base_hgt-tray_z0,tray_r2,0,xy1xy2_to_trans(list_x_to_vec([-1,1]*chute_x)+list_y_to_vec([1,1]*chute_y)));
        
        //bevel against interface with body
        translate([0,0,base_hgt]) cylinder_bev_co_blind_downwards(tray_r1,bev_m,0,bev_m,0,xy1xy2_to_trans(list_x_to_vec([-1,1]*chute_x)+list_y_to_vec([1,1]*chute_y+[0,50])));
        
        //bevel on outside wall
        translate([0,100/2+wall_thk,0]) rotate([-90,0,0]) cylinder_bev_co_blind_downwards(tray_r1,tray_r1+w6,0,bev_m,0,xy1xy2_to_trans(list_x_to_vec([-1,1]*chute_x)+list_y_to_vec(-[tray_z3,base_hgt])));
    }
    
    if(wall_neg) {
        //bevel against interface with body
        translate([0,0,base_hgt]) cylinder_bev_co_blind_downwards(2,bev_m,0,bev_m,0,xy1xy2_to_trans(list_x_to_vec([-1,1]*(abs(chute_x)+tray_r1-2))+list_y_to_vec([1,1]*(100/2+wall_thk)+[-w6,0])));
        
        translate([0,100/2+wall_thk,0]) rotate([-90,0,0]) cylinder_bev_co_blind_downwards(tray_r1,w6,0,bev_m,0,xy1xy2_to_trans(list_x_to_vec([-1,1]*chute_x)+list_y_to_vec(-[tray_z3,base_hgt])));
    }
    
    if(negative||wall_neg) {
        //curved cutout
        translate([0,100/2+wall_thk,tray_z1]) rotate([0,90,0]) rotate([0,0,180]) intersection() {
            rotate_extrude(angle=90) hull() {
                for(ix=[-1,1]*chute_x) translate([tray_r1+w6,ix]) circle(r=tray_r1);
                translate([tray_r1+w6,0]-[0,1]*(abs(chute_x)+tray_r1)) square([20,0]+[0,2]*(abs(chute_x)+tray_r1));
            }
            translate(-[0,0,1]*(abs(chute_x)+tray_r1)) cube([1,1,0]*(tray_r1+w6)+[0,0,2]*(abs(chute_x)+tray_r1));
        }
    }
}


module base_led(positive=true,negative=false,wall_neg=false) {
    led_n = 3;
    
    led_strip_seg_len = 1000/60;
    led_strip_len = led_strip_seg_len*led_n;
    led_strip_wid = 10;
    
    //led_z0 = base_thk1 + 2 + led_strip_wid/2; //center of led strip
    led_z0 = 4 + 4 + chute_r; //center of led strip
    led_z1 = led_z0 + led_strip_wid/2; //top of boss
    
    led_co_h = led_z1 - led_z0 + led_strip_wid/2;
    
    
    led_strip_trans = xy1xy2_to_trans(list_x_to_vec([-1,1]*led_strip_len/2)+list_y_to_vec([1,1]*(100/2+wall_thk-2*(chute_r+w6)-2-clr_loose)-[2,0]));
    
    
            
    if(positive) {
        translate([0,0,base_thk0]) cylinder_bev_stud(clr_close+w6,-base_thk0+led_z1,bev_m,bev_m,led_strip_trans+outset_xxyy_to_trans(0,0,0,50));
    }

    if(negative) {
        translate([0,0,led_z1]) {
            //cutout for strip
            cylinder_bev_co_blind_downwards(0.01,led_co_h,0,bev_m,clr_close,led_strip_trans-outset_xxyy_to_trans(0,0,0,1.5));
        
            for(it=[for(ix=[0:led_n-1])[ix-(led_n-1)/2,0,0]*led_strip_seg_len])  translate(it) {
                //cutout for 5050leds
                cylinder_bev_co_blind_downwards(0.01,led_co_h-1.2,0,bev_m,clr_loose,led_strip_trans*ident_xyz_y+xy1xy2_to_trans(list_x_to_vec([-1,1]*5/2))-outset_xxyy_to_trans(0,0,clr_loose-clr_close,0));
            
                //cutout for resistors
                cylinder_bev_co_blind_downwards(0.01,led_co_h-3,0,bev_m,clr_loose,led_strip_trans*ident_xyz_y+xy1xy2_to_trans(list_x_to_vec([-1,1]*(led_strip_seg_len/2-3)))-outset_xxyy_to_trans(0,0,clr_loose-clr_close,2-1.4));
            }
            
            //cutout for wire
            cylinder_bev_co_blind_downwards(0.01,led_co_h-1,0,bev_m,clr_close,led_strip_trans+outset_xxyy_to_trans(-led_strip_len+3,led_strip_wid,0,2));
        }
    }
    
    if(wall_neg) {
    }
    
    if(negative||wall_neg) {
        for(it=[for(ix=[0:led_n-1])[ix-(led_n-1)/2,0,0]*led_strip_seg_len])  translate(it) {
            //cutout for light channel
            translate([0,100/2+wall_thk-2*(chute_r+w6)-2,led_z0]) rotate([-90,0,0]) {
                cylinder_oh_bev_co_through(4/2,w2,bev_s,bev_s,0,[[0,0,0]],0,true);
                translate([0,0,w2]) cylinder_oh_bev(4/2+1,2-w2+(w6-w4),bev_s,bev_m,[[0,0,0]],0,true);
            }
        }
    }
}


module body() difference() {
    union() {
        difference() {
            union() {
                union() {
                    cylinder_bev(5,hgt1-lip_hgt,bev_m,bev_m,outer_crn_trans-outset_to_trans(5));
                    translate([0,0,hgt1-lip_hgt]) cylinder_bev_stud(5-w6-clr_close,lip_hgt,bev_m,bev_m,outer_crn_trans-outset_to_trans(5));
                }

                intersection() {
                    union() {
                        cylinder_bev(5,hgt2-lip_hgt,bev_m,bev_m,outer_crn_trans-outset_to_trans(5));
                        translate([0,0,hgt2-lip_hgt]) cylinder_bev_stud(5-w6-clr_close,lip_hgt,bev_m,bev_m,outer_crn_trans-outset_to_trans(5));
                    }
                    
                    translate(-[1,0,0]*(100/2+wall_thk)+[0,100/2,0]) cube([2,0,0]*(100/2+wall_thk)+[0,wall_thk,hgt2+lip_hgt]);
                }

                for(ixm=[0,1]) mirror([ixm,0,0]) translate(-[1,1,0]*(100+2*wall_thk)/2+[0,wall_thk,0]) intersection() {
                    translate([2*(100/2+wall_thk),0,bev_m]) rotate([0,-90,0]) {
                        round_step_3d(-bev_m+step_h0-lip_hgt,-bev_m+step_h1-lip_hgt,step_l,round_r0+lip_hgt,round_r1-lip_hgt,2*(100/2+wall_thk),bev_m,bev_m);
                    
                        translate([0,0,(w6+clr_close)]) round_step_3d(-bev_m+step_h0,-bev_m+step_h1,step_l,round_r0,round_r1,2*(100/2+wall_thk-(w6+clr_close)),bev_m,bev_m);
                        
                        translate([0,0,(w6+clr_close)-bev_m]) round_step_3d(-bev_m+step_h0-lip_hgt+bev_m+bev_m,-bev_m+step_h1-lip_hgt+bev_m+bev_m,step_l,round_r0+lip_hgt-bev_m-bev_m,round_r1-lip_hgt+bev_m+bev_m,2*(100/2+wall_thk-(w6+clr_close)+bev_m),bev_m+bev_m,bev_m+bev_m);
                    }
                    
                    cube([2*(100/2+wall_thk),100,100]);
                }
            }
            
            //cut out internal space
            intersection() {
                align_to_diag() {
                    translate([0,0,-picking_spool_h-clr_loose]+[0,0,-4]) {
                        hull() translate([0,0,-200-5]) {
                            cylinder_bev(2+clr_loose,200,0,0,stepper_crn_trans-outset_to_trans(2));
                            overhang_angle = min(45,90-5-slope_angle_true);
                            
                            translate([0,0,-100]) cylinder_bev(2+clr_loose,200,0,0,stepper_crn_trans-outset_to_trans(2)+outset_xxyy_to_trans(tan(overhang_angle),tan(overhang_angle),tan(slope_angle_true+overhang_angle),tan(-slope_angle_true+overhang_angle))*100);
                        }
                    }
                }
                cylinder_bev_co_blind_upwards(5-w6,hgt2,bev_m,bev_m,0,outer_crn_trans-outset_to_trans(5)-outset_xxyy_to_trans(1,1,0,0)*(100/2+wall_thk-abs(screw_trans[0][0])+(3+clr_close))*0);
            }
        }
        
        //positive for chute
        intersection() {
            union() {
                cylinder_bev(chute_r+w6,2,bev_m,bev_m,xy1xy2_to_trans(list_x_to_vec([-1,1]*chute_x)+list_y_to_vec([chute_y,100])));
                
                cylinder_bev(chute_r+w6,hgt1+(hgt2-hgt1)/2,bev_m,bev_m,xy1xy2_to_trans(list_x_to_vec([1,1]*chute_x+[0,20])+list_y_to_vec([chute_y,100])));
                intersection() {
                    translate([0,0,2-bev_m]) cylinder_bev_stud(chute_r+w6,hgt1+(hgt2-hgt1)/2,bev_m+bev_m,bev_m,xy1xy2_to_trans(list_x_to_vec([1,1]*chute_x+[0,20])+list_y_to_vec([chute_y,100])));
                    cylinder_bev(chute_r+w6,hgt1+(hgt2-hgt1)/2,bev_m,bev_m,xy1xy2_to_trans(list_x_to_vec([-1,1]*chute_x)+list_y_to_vec([chute_y,100])));
                }
            }
            
            cylinder_bev(5,hgt2,bev_m,bev_m,outer_crn_trans-outset_to_trans(5));
        }
        
        //positives for screw bosses
        for(it=base_screw_trans) intersection() {
            cylinder_bev(3+clr_close+w6,(it[1]<0?hgt1:hgt2-10)-lip_hgt,bev_m,bev_m,xy1xy2_to_trans([it,it+[sign(it[0]),sign(it[1]),0]*50]));
            
            cylinder_bev(5,(it[1]<0?hgt1:hgt2)-lip_hgt,bev_m,bev_m,outer_crn_trans-outset_to_trans(5));
        }
    }
    
    body_cutout();
}

module body_cutout() {
    align_to_diag() {
        cylinder_bev_co_blind_downwards(picking_spool_r,picking_spool_h+clr_loose,bev_m,bev_m,clr_free,$fn=$fn*2);
        
        
        translate([0,0,-picking_spool_h-clr_loose]) {
            //clearance for stepper plate
            cylinder_bev_co_blind_downwards(3+clr_close+w4,4,bev_m,bev_m,clr_loose,stepper_plate_screw_trans);
        
            //entry to chute and feed ramp
            cylinder_bev_co_blind_downwards(chute_r,bev_m+7.5,0,bev_m,0,[picking_hole_trans[1]]);
            for(it=[picking_hole_trans[1]]) for(i_ext=[0:1/($fn/4):1-1/($fn/4)]) {
                bev_rad = 7.5;
                
                hull() for(i_int=[i_ext,i_ext+1/($fn/4)]) {
                    ia = (bev_rad-bev_rad*sin(i_int*90))/(pi*2*abs(it[1]))*360;
                    ih = bev_rad-bev_rad*cos(i_int*90);
                    
                    rotate([0,0,ia]) translate(it) cylinder_bev_co_blind_downwards(chute_r,ih+bev_m,0,0,0);
                }
                hull() for(i_int=[i_ext,i_ext+1/($fn/4)]) {
                    ia = (bev_rad-bev_rad*sin(i_int*90))/(pi*2*abs(it[1]))*360;
                    
                    rotate([0,0,ia]) translate(it) cylinder_bev_co_blind_downwards(chute_r,bev_m,0,bev_m,0);
                }
            }
        }
    }
    
    cutout_stepper();
    
    //chute
    union() {
        chute_top_trans = (picking_hole_trans[1]-[0,0,(picking_spool_h+clr_loose)+(bev_m+7.5)])*rotation_matrix_x(-slope_angle_true)+[0,0,hgt1+(hgt2-hgt1)/2];

        chute_curve1_r = 40;
        chute_curve1_y = chute_y-chute_curve1_r;
        chute_curve1_z = chute_top_trans[2]-sqrt(pow(chute_curve1_r,2)-pow(chute_curve1_r-(chute_y-chute_top_trans[1]),2));
        
        for(i_ext=[0:1/($fn/2):1-1/($fn/2)]) hull() for(i_int=[i_ext,i_ext+1/($fn/2)]) {
            //i_x = chute_x*(sin((1-i_int)*180+90)/2+0.5);
            i_x = chute_x*(atan(sin((1-i_int)*180+90)/tan(45))/atan(sin(90)/tan(45))/2+0.5);
            i_z = (1-i_int)*chute_top_trans[2];
            iy = chute_y-chute_curve1_r+sqrt(pow(chute_curve1_r,2)-pow(max(0,i_z-chute_curve1_z),2));
        
            translate([i_x,iy,i_z]) sphere(r=chute_r);
        }
        
        translate([chute_x,chute_y,0]) cylinder_bev_co_blind_upwards(chute_r,bev_m,bev_m,0,0);
    }
    
    for(it=screw_trans) {
        cylinder_bev_co_through(1.5,(it[1]>0?hgt2:hgt1),0,bev_m,clr_close,[it]);
        
        if(lid_screw_type==screw_type_selftap) cylinder_bev_co_blind_upwards(3,(it[1]>0?hgt2:hgt1)-(lid_screw_len-lid_screw_eng_len),bev_m,3-1.5,clr_close,[it]);
        
        if(lid_screw_type==screw_type_heatset) translate(it) {
            cylinder_bev_co_blind_upwards(3,(it[1]>0?hgt2:hgt1)-(lid_screw_len-lid_screw_eng_len),bev_m,0,clr_close);
            
            cylinder_bev_co_blind_upwards(0,(it[1]>0?hgt2:hgt1)-(lid_screw_len-lid_screw_eng_len)+0.2,bev_m,0,clr_close,xyz_to_trans([sqrt(pow(3,2)-pow(1.5,2)),1.5,0]));
            cylinder_bev_co_blind_upwards(0,(it[1]>0?hgt2:hgt1)-(lid_screw_len-lid_screw_eng_len)+0.4,bev_m,0,clr_close,xyz_to_trans([1,1,0]*1.5));
        }
    }
                
    for(it=base_screw_trans) {
        if(base_screw_type==screw_type_selftap) cylinder_bev_co_blind_upwards(1.25,base_screw_eng_len,bev_m,0.5,0,[it]);
        
        if(base_screw_type==screw_type_heatset) translate(it) heatset_hole_upwards();
    }
}

module cutout_stepper(cutout_base=false,cutout_base_array=false,cutout_base_outset=0) {
    if(!cutout_base) {
        align_to_diag() {
            translate([0,0,-picking_spool_h-clr_loose]) {
                translate([0,0,-4]) {
                    //clearance for stepper
                    cylinder_bev_co_blind_downwards(2,-4+16+stepper_hgt,bev_m,bev_m,clr_loose,stepper_crn_trans-outset_to_trans(2));
                    cylinder_bev_co_blind_downwards(3+clr_close+w6,-4+16+stepper_hgt,bev_m,bev_m,clr_loose,stepper_screw_trans);
                    
                    //screws for stepper
                    for(it=stepper_plate_screw_trans) cylinder_bev_co_blind_downwards(1.25,8-4,0.5,bev_m,0,[it]);
                }
                    
                //clearance for stepper wire
                cylinder_bev_co_blind_downwards(2,16+stepper_hgt,bev_m,bev_m,clr_loose,stepper_conn_clr_trans-outset_to_trans(2));
                intersection() {
                    translate([0,0,-4+bev_m]) cylinder_bev_co_blind_downwards(2,-4+16+stepper_hgt,bev_m,bev_m+bev_m,clr_loose,stepper_conn_clr_trans-outset_to_trans(2));
                    cylinder_bev_co_blind_downwards(3+clr_close+w4,16+stepper_hgt,bev_m,bev_m,clr_loose,stepper_plate_screw_trans);
                }
            }
        }
        
    } else {
        for(i=(cutout_base_array==false?[0,1,2]:cutout_base_array)) {
            hull() for(iz=[0,50]) translate([0,0,iz]) {
                align_to_diag() translate([0,0,-picking_spool_h-clr_loose]+[0,0,-4]) {
                    //clearance for stepper
                    if(i==0) cylinder_bev_co_blind_downwards(2+cutout_base_outset,-4+16+stepper_hgt+clr_loose,bev_m,0,clr_loose,stepper_crn_trans-outset_to_trans(2));
                    
                    if(i==1) cylinder_bev_co_blind_downwards(3+clr_close+w6+cutout_base_outset,-4+16+stepper_hgt+clr_loose,bev_m,0,clr_loose,stepper_screw_trans);
                    
                    //clearance for stepper wire
                    if(i==2) cylinder_bev_co_blind_downwards(2+cutout_base_outset,-4+16+stepper_hgt+clr_loose,bev_m,bev_m,clr_loose,stepper_conn_clr_trans-outset_to_trans(2));
                }
            }
        }
        if(cutout_base_array==false) for(i=[0,1,2]) {
            hull() for(ib=[0,bev_m]) intersection() {
                cutout_stepper(true,[i],ib);
                translate([0,0,-(bev_m-ib)]) cylinder_bev(5,10,0,0,outer_crn_trans-outset_to_trans(5));
            }
            hull() for(ib=[0,bev_m]) intersection() {
                cutout_stepper(true,[i],ib);
                translate([0,0,-base_hgt]) cylinder_bev(5+(bev_m-ib),base_hgt,0,0,outer_crn_trans-outset_to_trans(5)-outset_xxyy_to_trans(0,0,0,1)*2*(chute_r+w6));
            }
        }
    }
}



module lid(print=false) translate([0,0,1]*lid_hgt2*(print?0:1)) rotate([180,0,0]*(print?0:1)) difference() {
    crn_rad = 5;
    crn_cent_trans = outer_crn_trans-outset_to_trans(crn_rad);
    
    lid_wall_thk = w6+clr_close+w6;
    lid_int_crn_trans = xyz_to_trans([1,1,0]*(100/2+wall_thk-lid_wall_thk));
    
    lid_base_thk = 0.8+2;
    
    lid_step_h0 = lid_hgt1;
    lid_step_h1 = lid_hgt2;
    
    union() {
        //cylinder_bev(5,hgt1,bev_m,bev_m,outer_crn_trans-outset_to_trans(5));
        difference() {
            cylinder_bev(5,lid_hgt1+lip_hgt,bev_m,bev_m,outer_crn_trans-outset_to_trans(5));
            translate([0,0,lid_hgt1+lip_hgt]) cylinder_bev_co_blind_downwards(5-w6,lip_hgt,bev_m,bev_m,0,outer_crn_trans-outset_to_trans(5));
            translate([0,0,lid_hgt1]) cylinder_bev_co_blind_downwards(2,lid_hgt1-lid_base_thk,bev_m,bev_m,0,lid_int_crn_trans-outset_to_trans(2));
            translate([0,0,lid_base_thk]) cylinder_bev_co_blind_downwards(5,2,bev_m,bev_m,bev_m,lid_int_crn_trans-outset_to_trans(5+5));
        }

        intersection() {
            //cylinder_bev(5,hgt2,bev_m,bev_m,outer_crn_trans-outset_to_trans(5));
            difference() {
                cylinder_bev(5,lid_hgt2+lip_hgt,bev_m,bev_m,outer_crn_trans-outset_to_trans(5));
                translate([0,0,lid_hgt2+lip_hgt]) cylinder_bev_co_blind_downwards(5-w6,lip_hgt,bev_m,bev_m,0,outer_crn_trans-outset_to_trans(5));
                translate([0,0,lid_hgt2]) cylinder_bev_co_blind_downwards(2,lid_hgt2-lid_base_thk,bev_m,bev_m,0,lid_int_crn_trans-outset_to_trans(2));
                translate([0,0,lid_base_thk]) cylinder_bev_co_blind_downwards(5,2,bev_m,bev_m,bev_m,lid_int_crn_trans-outset_to_trans(5+5));
            }
            
            translate(-[1,0,0]*(100/2+wall_thk)+[0,100/2,0]) cube([2,0,0]*(100/2+wall_thk)+[0,wall_thk,lid_hgt2+lip_hgt]);
        }

        for(ixm=[0,1]) mirror([ixm,0,0]) translate(-[1,1,0]*(100+2*wall_thk)/2+[0,wall_thk,0]) intersection() {
            //translate([2*(100/2+wall_thk),0,bev_m]) rotate([0,-90,0]) round_step_3d(-bev_m+step_h0,-bev_m+step_h1,step_l,round_r0,round_r1,2*(100/2+wall_thk),bev_m,bev_m);
            
            union() {
                translate([2*(100/2+wall_thk),0,bev_m]) rotate([0,-90,0]) round_step_3d(-bev_m+lid_step_h0,-bev_m+lid_step_h1,step_l,round_r0,round_r1,lid_wall_thk,bev_m,bev_m);
            
                translate([2*(100/2+wall_thk),0,bev_m]) rotate([0,-90,0]) round_step_3d(-bev_m+lid_step_h0+lip_hgt,-bev_m+lid_step_h1+lip_hgt,step_l,round_r0-lip_hgt,round_r1+lip_hgt,w6,bev_m,bev_m);
                
                translate([2*(100/2+wall_thk),0,bev_m]) rotate([0,-90,0]) round_step_3d(-bev_m+lid_step_h0+bev_m,-bev_m+lid_step_h1+bev_m,step_l,round_r0-bev_m,round_r1+bev_m,w6+bev_m,bev_m,bev_m);
            }
            
            cube([2*(100/2+wall_thk),100,100]);
        }
        
        //funnel shape
        difference() {
            union() {
                intersection() {
                    cylinder_bev(5,lid_hgt2,bev_m,bev_m,outer_crn_trans-outset_to_trans(5));
                    
                    translate(-[1,0,0]*(100/2+wall_thk)+[0,100/2,0]) cube([2,0,0]*(100/2+wall_thk)+[0,wall_thk,lid_hgt2+lip_hgt]);
                }
                intersection() {
                    translate([(100/2+wall_thk),-100/2,bev_m]) rotate([0,-90,0]) round_step_3d(-bev_m+lid_step_h0,-bev_m+lid_step_h1,step_l,round_r0,round_r1,2*(100/2+wall_thk),bev_m,bev_m);
                    translate(-[1,0,0]*(100/2+wall_thk)+[0,100/2,0]*0) cube([2,1,0]*(100/2+wall_thk)+[0,wall_thk,lid_hgt2+lip_hgt]);
                }
            }
            
            translate([0,0,-hgt1+lid_hgt1]) align_to_diag() {
                cylinder_bev_co_blind_downwards(picking_spool_r-w6,200,0,bev_m,clr_free,[[0,0,0],[-tan(60),-1,0],[tan(60),-1,0]]*200,$fn=$fn*2);
                
                translate([0,0,-5-200]) hull() {
                    cylinder_bev(picking_spool_r-w6+clr_free,200,0,0,[[0,0,0],[-tan(60),-1,0],[tan(60),-1,0]]*200,$fn=$fn*2);
                    translate([0,0,-100]) cylinder_bev(picking_spool_r-w6+clr_free+100*tan(45-slope_angle),200,0,0,[[0,0,0],[-tan(60),-1,0],[tan(60),-1,0]]*200,$fn=$fn*2);
                }
            }
        }
        
        //bosses for screw engagement
        intersection() {
            difference() {
                union() {
                    boss_r = (lid_screw_type==screw_type_selftap?1.25:0)+(lid_screw_type==screw_type_heatset?heatset_hole_r:0)+w6;
                    
                    for(it=screw_trans) if(it[1]<0) translate([0,0,lid_base_thk]) cylinder_bev_stud(boss_r,-lid_base_thk+(it[1]<0?lid_hgt1:lid_hgt2),bev_m,bev_m,xy1xy2_to_trans([it,it+[sign(it[0]),sign(it[1])]*50]));
                    
                    *for(it=concat(base_screw_boss_fillet1_trans,base_screw_boss_fillet2_trans)) cylinder_bev_stud(0.01,base_hgt,0,0,xy1xy2_to_trans([it,it+[sign(it[0]),sign(it[1])]*50]));
                }
                
                *for(it=concat(base_screw_boss_fillet1_trans,base_screw_boss_fillet2_trans)) translate([0,0,base_hgt]) cylinder_bev_co_blind_downwards(2,base_hgt-base_thk1,bev_m,bev_m,0,[it]);
            }
            cylinder_bev(5-(w6+clr_close),lid_hgt2,bev_m,bev_m,outer_crn_trans-outset_to_trans(5));
        }
        
        
        difference() {
            cylinder_bev(5,lid_base_thk,bev_m,bev_m,outer_crn_trans-outset_to_trans(5));

            //triangular grid cutout 
            trigrid_r = 1;
            
            trigrid_co_z = lid_base_thk;
            trigrid_co_h = 2;
            trigrid_hh = 20;
            trigrid_wh = trigrid_hh*tan(30);
            trigrid_ext = round(100/2*1.5/(2*trigrid_wh));
            
            for(ix=[-trigrid_ext:trigrid_ext]) for(iy=[-trigrid_ext:trigrid_ext]) translate([ix*2*trigrid_wh,iy*2*trigrid_hh,0]) {
                mirror([0,(floor(abs(ix)/2)*2==abs(ix)?0:1),0]) mirror([0,(floor(abs(iy)/2)*2==abs(iy)?0:1),0]) {
                    //cutout each triangle in the grid
                    translate([0,2*trigrid_wh/tan(60)-trigrid_hh,trigrid_co_z]) {
                        cylinder_bev_co_blind_downwards(trigrid_r,trigrid_co_h,bev_m,bev_m,0,points_reg_polygon_point(3)*(2*trigrid_wh/cos(30)-(w6/2+trigrid_r)/sin(30)));
                    }
                }
            }
        }
    }
    lid_cutout();
}

module lid_cutout() {
    for(it=screw_trans) translate([0,0,(it[1]<0?lid_hgt1:lid_hgt2)]) {
        if(lid_screw_type==screw_type_selftap) cylinder_bev_co_blind_downwards(1.25,lid_screw_eng_len,0.5,bev_m,0,[it]);
        
        if(lid_screw_type==screw_type_heatset) mirror([0,0,1]) translate(it) heatset_hole_upwards();
    }
}
