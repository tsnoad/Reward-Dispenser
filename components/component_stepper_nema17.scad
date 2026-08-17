/*
 * Nema17 x 34mm stepper
 */
 
stepper_crn_trans = xyz_to_trans([1,1,0]*42/2);
stepper_screw_trans = xyz_to_trans([1,1,0]*31/2);
stepper_screw_eng_dep = 5;
stepper_hgt = 34;
stepper_boss_r = 22/2;
stepper_boss_hgt = 2;
stepper_shaft_r = 5/2;
stepper_shaft_hgt = 20;
stepper_flange_r = 22/2;
stepper_flange_hgt = 2;
stepper_flange_screw_trans = points_reg_polygon_point(4)*16/2;
stepper_conn_clr_trans = xy1xy2_to_trans(list_x_to_vec([0,1]*(42/2+15))+list_y_to_vec([-1,1]*16/2));