
module mat_multi #(
    MAT_RANK    =   256
) (
    input                                                           clk,
    input                                                           rst_n,

    input            [$clog2(MAT_RANK)<<2     -1: 0]                Scol_index,
    input            [31                        : 0]                S_val_i0,
    input            [31                        : 0]                S_val_r0,
    input            [31                        : 0]                S_val_i1,
    input            [31                        : 0]                S_val_r1,
    input            [31                        : 0]                S_val_i2,
    input            [31                        : 0]                S_val_r2,
    input            [31                        : 0]                S_val_i3,
    input            [31                        : 0]                S_val_r3,
    input                                                           S_vld_o,
    output                                                          S_rdy_o
);
    
endmodule