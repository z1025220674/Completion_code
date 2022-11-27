module propm_mat_pe #(
    
) (
    input                                       clk,
    input                                       rst_n,
);
    

//==============================================
//declare
//==============================================
localparam ITERATIONS   = 200;
localparam CHAOS_OVLD_W = 32;
localparam GAIN_INDEX   = 16;  
















chaotic_seq #(
    .ITERATIONS(ITERATIONS),
    .CHAOS_OVLD_W(CHAOS_OVLD_W),
    .GAIN_INDEX(GAIN_INDEX)     //2^16         
) theta_gen(
    .clk(clk),
    .rst_n(rst_n),
    .chaos_x0(),       //x_{0} : initial value
    .chaos_x0_vld(),   //standard handshake
    .chaos_x0_rdy(),
    .chaos_xout(),
    .chaos_xout_vld(), //standard handshake
    .chaos_xout_rdy()
);

chaotic_seq #(
    .ITERATIONS(ITERATIONS),
    .CHAOS_OVLD_W(CHAOS_OVLD_W),
    .GAIN_INDEX(GAIN_INDEX)     //2^16         
) z_gen(
    .clk(clk),
    .rst_n(rst_n),
    .chaos_x0(),       //x_{0} : initial value
    .chaos_x0_vld(),   //standard handshake
    .chaos_x0_rdy(),
    .chaos_xout(),
    .chaos_xout_vld(), //standard handshake
    .chaos_xout_rdy()
);
endmodule