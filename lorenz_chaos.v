module lorenz_chaos #(
    ITERATIONS      =   200,
    CHAOS_OVLD_W    =   32,
    GAIN_INDEX      =   16
) (
    input                                       clk,
    input                                       rst_n,
    input   [GAIN_INDEX   -1:       0]          chaos_x0,       //x_{0} : initial value  range(0,2^GAIN_INDEX)
    input                                       chaos_x0_vld,   //standard handshake
    output                                      chaos_x0_rdy,
    output  [CHAOS_OVLD_W -1:       0]          chaos_xout,
    output                                      chaos_xout_vld, //standard handshake
    input                                       chaos_xout_rdy
);
    



    
endmodule