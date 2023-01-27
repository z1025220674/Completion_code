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
    reg                     [31     :0]         theta_r;
    reg                     [31     :0]         theta1_r;
    reg                     [31     :0]         theta2_r;
    reg                     [31     :0]         z1_r;
    reg                     [31     :0]         z2_r;
    reg                                         rand_shake_r;
    wire                    [31     :0]         theta;
    wire                    [31     :0]         theta1;
    wire                    [31     :0]         theta2;
    wire                    [31     :0]         z1;
    wire                    [31     :0]         z2;
    wire                                        rand_shake;
    //float1
    

//========================================2
//theta、theta1、theta2、z1、z2
//=========================================

    always @(*) begin
        theta   <=  ((rand_x1>>16)*360);//16位代表0-1的范围
        theta1  <=  (rand_x2>>16)*360;
        theta2  <=  (rand_x3>>16)*360;
        z1      <=  (rand_z1>>16)*360;
        z2      <=  (rand_z2>>16)*360;
        rand_shake  <=  rand_vld&rand_rdy;
    end
    always @(posedge clk or negedge rst_n) begin//syn cordic_angle
        if(!rst_n)begin
            rand_shake_r    <=  'b0;
        end
        else begin
            rand_shake_r    <=  rand_shake;
        end
    end
//========================================2
//cordic mod
//=========================================
   
//-------------------------------------
//csc format 
//-------------------------------------



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