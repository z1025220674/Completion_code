
/*
csc_stor inst_ #(
    MAT_RANK()
) (
    .clk,
    .rst_n,

    .z1(),
    .z2(),
    .s_val_i(),
    .s_val_r(),
    .a0_val_i(),
    .a0_val_r(),
    .a1_val_i(),
    .a1_val_r(),
    .val_vld()

);
*/
//function：generate row vector of matrix
module csc_stor #(
    MAT_RANK    =   256
) (
    input                                       clk,
    input                                       rst_n,

    input               [31     : 0]            z1,         //z1、z2和其他数值可以用val_vld，因为z不会改变
    input               [31     : 0]            z2,         //z1、z2和其他数值可以用val_vld，因为z不会改变
    input               [31     : 0]            s_val_i,
    input               [31     : 0]            s_val_r,
    input               [31     : 0]            a0_val_i,
    input               [31     : 0]            a0_val_r,
    input               [31     : 0]            a1_val_i,
    input               [31     : 0]            a1_val_r,
    input                                       val_vld

);
    
//=========================================
//
//=========================================




//=========================================
//
//=========================================


//=========================================
//
//=========================================


    
endmodule