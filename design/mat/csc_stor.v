
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

    input               [31     : 0]            z0,         //z1、z0和其他数值可以用val_vld，因为z不会改变
    input               [31     : 0]            z1,         //z1、z0和其他数值可以用val_vld，因为z不会改变
    input               [31     : 0]            s_val_i,
    input               [31     : 0]            s_val_r,
    input               [31     : 0]            a0_val_i,
    input               [31     : 0]            a0_val_r,
    input               [31     : 0]            a1_val_i,
    input               [31     : 0]            a1_val_r,
    input                                       val_vld

);

//=========================================
//declare
//=========================================
    reg                 [31     : 0]            S_val_i0_r;
    reg                 [31     : 0]            S_val_r0_r;
    reg                 [31     : 0]            S_val_i1_r;
    reg                 [31     : 0]            S_val_r1_r;
    reg                 [31     : 0]            S_val_i2_r;
    reg                 [31     : 0]            S_val_r2_r;
    reg                 [31     : 0]            S_val_i3_r;
    reg                 [31     : 0]            S_val_r3_r;


//=========================================
//生成第一行向量非零元素
//=========================================


    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            S_val_i0_r  <=  32'b0;
            S_val_r0_r  <=  32'b0;
            S_val_i1_r  <=  32'b0;
            S_val_r1_r  <=  32'b0;
            S_val_i2_r  <=  32'b0;
            S_val_r2_r  <=  32'b0;
            S_val_i3_r  <=  32'b0;
            S_val_r3_r  <=  32'b0;
        end 
        else if(val_vld)begin
            S_val_i0_r  <=  ;
            S_val_r0_r  <=  32'b0;
            S_val_i1_r  <=  32'b0;
            S_val_r1_r  <=  32'b0;
            S_val_i2_r  <=  32'b0;
            S_val_r2_r  <=  32'b0;
            S_val_i3_r  <=  32'b0;
            S_val_r3_r  <=  32'b0;
        end
    end


//=========================================
//
//=========================================


//=========================================
//
//=========================================


    
endmodule