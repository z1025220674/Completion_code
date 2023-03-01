`timescale 1ns / 1ps
//===================================
//date:2023/1/9
//function:generate sparse matrix and store by csc format
//email:1025220674@qq.com
//vivado2018.3
//===================================
module mat_top #(
    CHAOS_OVLD_W = 32,                          //random variable bit width
    SUBCAR_NUM   = 16,                          //number of subcarrier 
    OFDM_SYM_NUM = 16                           //number of ofdm symbol 
) (
    input                                       clk,
    input                                       rst_n,


    input       [32                 -1: 0]      src_i,
    input       [32                 -1: 0]      src_r,
    input       [32                 -1: 0]      src_vld,
    output      [32                 -1: 0]      src_rdy,
    input       [CHAOS_OVLD_W       -1: 0]      rand_x1,
    input       [CHAOS_OVLD_W       -1: 0]      rand_x2,
    input       [CHAOS_OVLD_W       -1: 0]      rand_x3,
    input       [CHAOS_OVLD_W       -1: 0]      rand_z1,
    input       [CHAOS_OVLD_W       -1: 0]      rand_z2,
    input                                       rand_vld,
    output                                      rand_rdy            //闲时*请求上级输入参数，


);
//=========================================
//local param 
//=========================================
localparam  MAT_RANK = OFDM_SYM_NUM*SUBCAR_NUM;//1 slot 

//=========================================
//declare variable
//=========================================
    // reg                     [31     :0]         theta_r;
    // reg                     [31     :0]         theta1_r;
    // reg                     [31     :0]         theta2_r;
    // reg                     [31     :0]         z1_r;
    // reg                     [31     :0]         z2_r;
    // reg                                         rand_shake_r;
    reg                                                     rand_rdy_r;

    reg     [31                        : 0]                 theta;
    reg     [31                        : 0]                 theta1;
    reg     [31                        : 0]                 theta2;
    reg     [31                        : 0]                 z0;
    reg     [31                        : 0]                 z1;
    reg                                                     rand_shake;

    wire                                                    s_vld;
    wire                                                    s_rdy;          //被矩阵生成模块约束    
    wire    [31                        : 0]                 s12_ival;
    wire    [31                        : 0]                 s12_rval;

    wire    [$clog2(MAT_RANK)<<2     -1: 0]                 Scol_index;
    wire    [31                        : 0]                 S_val_i0;
    wire    [31                        : 0]                 S_val_r0;
    wire    [31                        : 0]                 S_val_i1;
    wire    [31                        : 0]                 S_val_r1;
    wire    [31                        : 0]                 S_val_i2;
    wire    [31                        : 0]                 S_val_r2;
    wire    [31                        : 0]                 S_val_i3;
    wire    [31                        : 0]                 S_val_r3;
    wire                                                    S_vld_o;
    wire                                                    S_rdy_o;
    assign  S_rdy_o =   1;
    //float1
//========================================    
//output
//========================================

    assign  rand_rdy    =   rand_rdy_r;

    always @(posedge clk or negedge rst_n) begin        //闲时请求上级输入，拉高条件：表明当前空闲
        if (!rst_n) begin                               //拉低条件（输入握手后，最后矩阵乘输出握手后）：表明正忙,输入握手拉高，
            rand_rdy_r  <=  'b0;    
        end 
        else begin
            rand_rdy_r  <=  'b1;
        end
    end
//========================================2
//theta、theta1、theta2、z1、z2
//=========================================

    always @(*) begin
        theta   =  ((rand_x1>>16)*360);//16位代表0-1的范围
        theta1  =  (rand_x2>>16)*360;
        theta2  =  (rand_x3>>16)*360;
        z0      =  (rand_z1>>16)*MAT_RANK;
        z1      =  (rand_z2>>16)*MAT_RANK;
        rand_shake =  rand_vld&rand_rdy;
    end
    // always @(posedge clk or negedge rst_n) begin//syn cordic_angle
    //     if(!rst_n)begin
    //         rand_shake_r    <=  'b0;
    //     end
    //     else begin
    //         rand_shake_r    <=  rand_shake;
    //     end
    // end
//========================================2
//s1 and s2 sequence
//=========================================
   cordic_mod inst_s(
    .clk(clk),
    .rst_n(rst_n),
    .theta(theta),              //输入随机序列生成theta
    .rand_shake(rand_shake),    //vld信号
    .rdy_i(s_rdy),
    .vld_o(s_vld),              //输出vld
    .i_signal_o(s12_ival),      //输出虚部信号  放大16倍
    .r_signal_o(s12_rval)       //输出实部信号
    );
    //s1,s2俩个序列，本模块输出俩序列的非零值（0和N/2处的非零值）
    //只有s2的N/2是实部和虚部乘（-1）
//-------------------------------------
// a0
//-------------------------------------
   wire                 [31     : 0]                a0_ival;
   wire                 [31     : 0]                a0_rval;
    cordic_mod isnt_a0(
    .clk(clk),
    .rst_n(rst_n),
    .theta(theta1),             //输入随机序列生成theta
    .rand_shake(rand_shake),    //vld信号
    .rdy_i(s_rdy),
    // .vld_o(s_vld),           //输出vld
    .i_signal_o(a0_ival),       //输出虚部信号
    .r_signal_o(a0_rval)        //输出实部信号
    );

//-------------------------------------
// a1
//-------------------------------------
   wire                 [31     : 0]                a1_ival;
   wire                 [31     : 0]                a1_rval;
    cordic_mod isnt_a1(
    .clk(clk),
    .rst_n(rst_n),
    .theta(theta2),             //输入随机序列生成theta
    .rand_shake(rand_shake),            //vld信号
    .rdy_i(s_rdy),
    // .vld_o(s_vld),           //输出vld
    .i_signal_o(a1_ival),       //输出虚部信号
    .r_signal_o(a1_rval)        //输出实部信号
    );

//-------------------------------------
// generate matrix
//-------------------------------------
    
    csc_stor  #(
        .MAT_RANK(MAT_RANK)
    ) inst_matrix_gern(
        .clk(clk),
        .rst_n(rst_n),
        //输入参数
        .z0(z0),
        .z1(z1),
        .s_val_i(s12_ival),
        .s_val_r(s12_rval),
        .a0_val_i(a0_ival),
        .a0_val_r(a0_rval),
        .a1_val_i(a1_ival),
        .a1_val_r(a1_rval),
        .val_vld(s_vld),
        .val_rdy(s_rdy),                //闲时*向上级模块请求输入参数的信号
        .Scol_index(Scol_index),                  //矩阵首行非零元素位置，后续n行，则各非零元素整体向右移n个
        .S_val_i0(S_val_i0),                    //第一个非零元素，非零元素最少2个，最多四个
        .S_val_r0(S_val_r0),
        .S_val_i1(S_val_i1),
        .S_val_r1(S_val_r1),
        .S_val_i2(S_val_i2),
        .S_val_r2(S_val_r2),
        .S_val_i3(S_val_i3),
        .S_val_r3(S_val_r3),
        .S_vld_o(S_vld_o),
        .S_rdy_o(S_rdy_o)
    );
//================================
// matrix multi
//================================

mat_multi #(
    .MAT_RANK(MAT_RANK)
) utu_mult(
    .clk(clk),
    .rst_n(rst_n),

    .src_i(src_i),
    .src_r(src_r),
    .src_vld(),
    .src_rdy(src_rdy),
    .Scol_index(Scol_index),
    .S_val_i0(S_val_i0),
    .S_val_r0(S_val_r0),
    .S_val_i1(S_val_i1),
    .S_val_r1(S_val_r1),
    .S_val_i2(S_val_i2),
    .S_val_r2(S_val_r2),
    .S_val_i3(S_val_i3),
    .S_val_r3(S_val_r3),
    .S_vld_o(S_vld_o),
    .S_rdy_o(S_rdy_o)
);


endmodule
