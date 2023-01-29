//===================================
//date:2023/1/9
//function:generate sparse matrix and store by csc format
//email:1025220674@qq.com
//vivado2018.3
//===================================
module mat_csc #(
    CHAOS_OVLD_W = 32,                          //random variable bit width
    SUBCAR_NUM   = 16,                          //number of subcarrier 
    OFDM_SYM_NUM = 16                           //number of ofdm symbol 
) (
    input                                       clk,
    input                                       rst_n,

    input       [CHAOS_OVLD_W       -1: 0]      rand_x1,
    input       [CHAOS_OVLD_W       -1: 0]      rand_x2,
    input       [CHAOS_OVLD_W       -1: 0]      rand_x3,
    input       [CHAOS_OVLD_W       -1: 0]      rand_z1,
    input       [CHAOS_OVLD_W       -1: 0]      rand_z2,
    input                                       rand_vld,
    output                                      rand_rdy


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
    wire                    [31     :0]         theta;
    wire                    [31     :0]         theta1;
    wire                    [31     :0]         theta2;
    wire                    [31     :0]         z0;
    wire                    [31     :0]         z1;
    wire                                        rand_shake;
    //float1
//========================================    
//output
//========================================

    assign  rand_rdy    =   ;

//========================================2
//theta、theta1、theta2、z1、z2
//=========================================

    always @(*) begin
        theta   <=  ((rand_x1>>16)*360);//16位代表0-1的范围
        theta1  <=  (rand_x2>>16)*360;
        theta2  <=  (rand_x3>>16)*360;
        z0      <=  (rand_z1>>16)*360;
        z1      <=  (rand_z2>>16)*360;
        rand_shake  <=  rand_vld&rand_rdy;
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
   wire                                             s_vld;
   wire                                             s_rdy;          //被矩阵生成模块约束    
   wire                 [31     : 0]                s12_ival;
   wire                 [31     : 0]                s12_rval;
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
    .rand_shake(rand_shake),            u//vld信号
    .rdy_i(s_rdy),
    // .vld_o(s_vld),           //输出vld
    .i_signal_o(a1_ival),       //输出虚部信号
    .r_signal_o(a1_rval)        //输出实部信号
    );

//-------------------------------------
// generate matrix
//-------------------------------------
    
    csc_stor inst_ #(
        MAT_RANK(MAT_RANK)
    ) (
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
        .val_vld(s_vld)

    );
    //---------------------------------------浮点乘法器
    // assign rand_rdy = ;
    // //float 3 delay
    // floating_point_0 inst_theta (
    // .aclk(clk),                                  // input wire aclk
    // .aresetn(rst_n),                            // input wire aresetn
    // .s_axis_a_tvalid(1),            // input wire s_axis_a_tvalid
    // .s_axis_a_tready(),            // output wire s_axis_a_tready
    // .s_axis_a_tdata(theta),              // input wire [31 : 0] s_axis_a_tdata
    // .s_axis_b_tvalid(rst_n),            // input wire s_axis_b_tvalid
    // .s_axis_b_tready(),            // output wire s_axis_b_tready
    // .s_axis_b_tdata(aa),              // input wire [31 : 0] s_axis_b_tdata
    // .m_axis_result_tvalid(),  // output wire m_axis_result_tvalid
    // .m_axis_result_tready(1),  // input wire m_axis_result_tready
    // .m_axis_result_tdata()    // output wire [31 : 0] m_axis_result_tdata
    // );

    // floating_point_0 inst_theta1 (
    // .aclk(clk),                                  // input wire aclk
    // .aresetn(rst_n),                            // input wire aresetn
    // .s_axis_a_tvalid(1),            // input wire s_axis_a_tvalid
    // .s_axis_a_tready(),            // output wire s_axis_a_tready
    // .s_axis_a_tdata('h427D3333),              // input wire [31 : 0] s_axis_a_tdata
    // .s_axis_b_tvalid(rst_n),            // input wire s_axis_b_tvalid
    // .s_axis_b_tready(),            // output wire s_axis_b_tready
    // .s_axis_b_tdata(aa),              // input wire [31 : 0] s_axis_b_tdata
    // .m_axis_result_tvalid(),  // output wire m_axis_result_tvalid
    // .m_axis_result_tready(1),  // input wire m_axis_result_tready
    // .m_axis_result_tdata()    // output wire [31 : 0] m_axis_result_tdata
    // );

    // floating_point_0 inst_theta2 (
    // .aclk(clk),                                  // input wire aclk
    // .aresetn(rst_n),                            // input wire aresetn
    // .s_axis_a_tvalid(1),            // input wire s_axis_a_tvalid
    // .s_axis_a_tready(),            // output wire s_axis_a_tready
    // .s_axis_a_tdata('h427D3333),              // input wire [31 : 0] s_axis_a_tdata
    // .s_axis_b_tvalid(rst_n),            // input wire s_axis_b_tvalid
    // .s_axis_b_tready(),            // output wire s_axis_b_tready
    // .s_axis_b_tdata(aa),              // input wire [31 : 0] s_axis_b_tdata
    // .m_axis_result_tvalid(),  // output wire m_axis_result_tvalid
    // .m_axis_result_tready(1),  // input wire m_axis_result_tready
    // .m_axis_result_tdata()    // output wire [31 : 0] m_axis_result_tdata
    // );




endmodule