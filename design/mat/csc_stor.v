
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
    .val_vld(),
    .val_rdy(),
    .Scol_index(),
    .S_val_i0(),
    .S_val_r0(),
    .S_val_i1(),
    .S_val_r1(),
    .S_val_i2(),
    .S_val_r2(),
    .S_val_i3(),
    .S_val_r3(),
    .S_vld_o(),
    .S_rdy_o()
);
*/
//function：generate row vector of matrix
module csc_stor #(                                                          //1cycle
    MAT_RANK    =   256
) (
    input                                                       clk,
    input                                                       rst_n,
    input          [31                        : 0]              z0,         //z1、z0和其他数值可以用val_vld，因为z不会改变
    input          [31                        : 0]              z1,         //z1、z0和其他数值可以用val_vld，因为z不会改变
    input          [31                        : 0]              s_val_i,
    input          [31                        : 0]              s_val_r,
    input          [31                        : 0]              a0_val_i,
    input          [31                        : 0]              a0_val_r,
    input          [31                        : 0]              a1_val_i,
    input          [31                        : 0]              a1_val_r,
    input                                                       val_vld,
    output                                                      val_rdy,
    output         [($clog2(MAT_RANK)<<2)   -1: 0]              Scol_index,  //首行非零元素位置
    output         [31                        : 0]              S_val_i0,             
    output         [31                        : 0]              S_val_r0,             
    output         [31                        : 0]              S_val_i1,             
    output         [31                        : 0]              S_val_r1,             
    output         [31                        : 0]              S_val_i2,             
    output         [31                        : 0]              S_val_r2,             
    output         [31                        : 0]              S_val_i3,             
    output         [31                        : 0]              S_val_r3,             
    output                                                      S_vld_o,
    input                                                       S_rdy_o
);

//=========================================
//declare
//=========================================
    localparam  INDEX_W =   $clog2(MAT_RANK);//8
    reg                 [31             : 0]            S_val_i0_r;     //第一个非零元素
    reg                 [31             : 0]            S_val_r0_r;
    reg                 [31             : 0]            S_val_i1_r;     //第二个
    reg                 [31             : 0]            S_val_r1_r;
    reg                 [31             : 0]            S_val_i2_r;     //第三个
    reg                 [31             : 0]            S_val_r2_r; 
    reg                 [31             : 0]            S_val_i3_r;     //第四个
    reg                 [31             : 0]            S_val_r3_r;

    reg                 [(INDEX_W<<2)  -1: 0]           Scol_index_r;      //存储第一行4个非零元素列位置
    
    wire                                                val_shake;
    
    reg                                                 S_vld_o_r;

    wire                [63             : 0]            s_z0_i;
    wire                [63             : 0]            s_z0_r;
    wire                [63             : 0]            s_z1_i;
    wire                [63             : 0]            s_z1_r;
    wire                [63             : 0]            s_z0_N2_i;      //N2----N/2;N是矩阵的秩
    wire                [63             : 0]            s_z0_N2_r;
    wire                [63             : 0]            s_z1_N2_i;
    wire                [63             : 0]            s_z1_N2_r;

    assign  val_shake   =   val_rdy & val_vld;
    // assign  S_val_i0    =   S_val_i0_r;
    // assign  S_val_r0    =   S_val_r0_r;
    // assign  S_val_i1    =   S_val_i1_r;
    // assign  S_val_r1    =   S_val_r1_r;
    // assign  S_val_i2    =   S_val_i2_r;
    // assign  S_val_r2    =   S_val_r2_r;
    // assign  S_val_i3    =   S_val_i3_r;
    // assign  S_val_r3    =   S_val_r3_r;
    assign  Scol_index  =   Scol_index_r;
    // assign  S_vld_o =   S_vld_o_r;
    // assign  val_rdy =   val_rdy;

//=========================================
//定点转换浮点
//=========================================
    floating_point_0 fix_float_0i (
    .aclk(clk),                                  // input wire aclk
    .aresetn(rst_n),                            // input wire aresetn
    .s_axis_a_tvalid(S_vld_o_r),            // input wire s_axis_a_tvalid
    .s_axis_a_tready(val_rdy),            // output wire s_axis_a_tready
    .s_axis_a_tdata(S_val_i0_r),              // input wire [31 : 0] s_axis_a_tdata
    .m_axis_result_tvalid(S_vld_o),  // output wire m_axis_result_tvalid
    .m_axis_result_tready(S_rdy_o),  // input wire m_axis_result_tready
    .m_axis_result_tdata(S_val_i0)    // output wire [31 : 0] m_axis_result_tdata
    );
    floating_point_0 fix_float_0r (
    .aclk(clk),                                  // input wire aclk
    .aresetn(rst_n),                            // input wire aresetn
    .s_axis_a_tvalid(S_vld_o_r),            // input wire s_axis_a_tvalid
    .s_axis_a_tready(),            // output wire s_axis_a_tready
    .s_axis_a_tdata(S_val_r0_r),              // input wire [31 : 0] s_axis_a_tdata
    .m_axis_result_tvalid(),  // output wire m_axis_result_tvalid
    .m_axis_result_tready(S_rdy_o),  // input wire m_axis_result_tready
    .m_axis_result_tdata(S_val_r0)    // output wire [31 : 0] m_axis_result_tdata
    );
//=========================================
    floating_point_0 fix_float_1i (
    .aclk(clk),                                  // input wire aclk
    .aresetn(rst_n),                            // input wire aresetn
    .s_axis_a_tvalid(S_vld_o_r),            // input wire s_axis_a_tvalid
    .s_axis_a_tready(),            // output wire s_axis_a_tready
    .s_axis_a_tdata(S_val_i0_r),              // input wire [31 : 0] s_axis_a_tdata
    .m_axis_result_tvalid(),  // output wire m_axis_result_tvalid
    .m_axis_result_tready(S_rdy_o),  // input wire m_axis_result_tready
    .m_axis_result_tdata(S_val_i1)    // output wire [31 : 0] m_axis_result_tdata
    );
    floating_point_0 fix_float_1r (
    .aclk(clk),                                  // input wire aclk
    .aresetn(rst_n),                            // input wire aresetn
    .s_axis_a_tvalid(S_vld_o_r),            // input wire s_axis_a_tvalid
    .s_axis_a_tready(),            // output wire s_axis_a_tready
    .s_axis_a_tdata(S_val_r0_r),              // input wire [31 : 0] s_axis_a_tdata
    .m_axis_result_tvalid(),  // output wire m_axis_result_tvalid
    .m_axis_result_tready(S_rdy_o),  // input wire m_axis_result_tready
    .m_axis_result_tdata(S_val_r1)    // output wire [31 : 0] m_axis_result_tdata
    );
//=========================================
    floating_point_0 fix_float_2i (
    .aclk(clk),                                  // input wire aclk
    .aresetn(rst_n),                            // input wire aresetn
    .s_axis_a_tvalid(S_vld_o_r),            // input wire s_axis_a_tvalid
    .s_axis_a_tready(),            // output wire s_axis_a_tready
    .s_axis_a_tdata(S_val_i0_r),              // input wire [31 : 0] s_axis_a_tdata
    .m_axis_result_tvalid(),  // output wire m_axis_result_tvalid
    .m_axis_result_tready(S_rdy_o),  // input wire m_axis_result_tready
    .m_axis_result_tdata(S_val_i2)    // output wire [31 : 0] m_axis_result_tdata
    );
    floating_point_0 fix_float_2r (
    .aclk(clk),                                  // input wire aclk
    .aresetn(rst_n),                            // input wire aresetn
    .s_axis_a_tvalid(S_vld_o_r),            // input wire s_axis_a_tvalid
    .s_axis_a_tready(),            // output wire s_axis_a_tready
    .s_axis_a_tdata(S_val_r0_r),              // input wire [31 : 0] s_axis_a_tdata
    .m_axis_result_tvalid(),  // output wire m_axis_result_tvalid
    .m_axis_result_tready(S_rdy_o),  // input wire m_axis_result_tready
    .m_axis_result_tdata(S_val_r2)    // output wire [31 : 0] m_axis_result_tdata
    );
//=========================================
    floating_point_0 fix_float_3i (
    .aclk(clk),                                  // input wire aclk
    .aresetn(rst_n),                            // input wire aresetn
    .s_axis_a_tvalid(S_vld_o_r),            // input wire s_axis_a_tvalid
    .s_axis_a_tready(),            // output wire s_axis_a_tready
    .s_axis_a_tdata(S_val_i3_r),              // input wire [31 : 0] s_axis_a_tdata
    .m_axis_result_tvalid(),  // output wire m_axis_result_tvalid
    .m_axis_result_tready(S_rdy_o),  // input wire m_axis_result_tready
    .m_axis_result_tdata(S_val_i3)    // output wire [31 : 0] m_axis_result_tdata
    );
    floating_point_0 fix_float_3r (
    .aclk(clk),                                  // input wire aclk
    .aresetn(rst_n),                            // input wire aresetn
    .s_axis_a_tvalid(S_vld_o_r),            // input wire s_axis_a_tvalid
    .s_axis_a_tready(),            // output wire s_axis_a_tready
    .s_axis_a_tdata(S_val_r3_r),              // input wire [31 : 0] s_axis_a_tdata
    .m_axis_result_tvalid(),  // output wire m_axis_result_tvalid
    .m_axis_result_tready(S_rdy_o),  // input wire m_axis_result_tready
    .m_axis_result_tdata(S_val_r3)    // output wire [31 : 0] m_axis_result_tdata
    );
//=========================================
//shake
//=========================================
    // always @(posedge clk or negedge rst_n) begin        //闲时*向上级模块请求输入参数的信号，拉高条件：本模块Svld_o=0,即本模块没有工作，且把输出信号完成transaction
    //     if (!rst_n) begin                               //拉低条件：本模块正在工作，Svld_o=1，还有本模块完成输入握手
    //         val_rdy_r   <=  'b1;    
    //     end 
    //     else if(val_shake || S_vld_o_r)begin
    //         val_rdy_r   <=  'b0;
    //     end
    //     else if(!S_vld_o_r)begin
    //         val_rdy_r   <=  'b1;
    //     end
    // end

    always @(posedge clk or negedge rst_n) begin        //本信号表明输出信号有效，拉高条件（正忙）：输入握手
        if (!rst_n) begin                               //拉低条件（闲）；输出握手
            S_vld_o_r   <=  'b0;
        end 
        else if(S_vld_o_r && S_rdy_o)begin
            S_vld_o_r   <=  'b0;
        end
        else if(val_shake)begin
            S_vld_o_r   <=  'b1;
        end
    end

//=========================================
//复数乘法公式
//=========================================



    
    assign s_z0_i   =   $signed(a0_val_i)*$signed(s_val_r) + $signed(a0_val_r)*$signed(s_val_i) ;
    assign s_z0_r   =   $signed(a0_val_i)*$signed(s_val_i) + $signed(a0_val_r)*$signed(s_val_r) ;
    assign s_z1_i   =   $signed(a1_val_i)*$signed(s_val_r) + $signed(a1_val_r)*$signed(s_val_i) ;
    assign s_z1_r   =   $signed(a1_val_i)*$signed(s_val_i) + $signed(a1_val_r)*$signed(s_val_r) ;
    assign s_z0_N2_i   =   s_z0_i;
    assign s_z0_N2_r   =   s_z0_r;
    assign s_z1_N2_i   =   $signed(a1_val_i)*$signed(~s_val_r + 'b1) + $signed(a1_val_r)*$signed(~s_val_i + +'b1) ;
    assign s_z1_N2_r   =   $signed(a1_val_i)*$signed(~s_val_i + 'b1) + $signed(a1_val_r)*$signed(~s_val_r + +'b1) ;

//=========================================
//生成第一行向量非零元素
//=========================================


    always @(posedge clk or negedge rst_n) begin         //储存个非零元素
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
        else if(val_shake && z0<z1)begin              
            S_val_i0_r  <=  (s_z0_i)>>17;
            S_val_r0_r  <=  (s_z0_r)>>17;
            S_val_i1_r  <=  (s_z1_i)>>17;
            S_val_r1_r  <=  (s_z1_r)>>17;
            S_val_i2_r  <=  (s_z0_N2_i)>>17;
            S_val_r2_r  <=  (s_z0_N2_r)>>17;
            S_val_i3_r  <=  (s_z1_N2_i)>>17;
            S_val_r3_r  <=  (s_z1_N2_r)>>17;
        end
        else if(val_shake && z0==z1)begin             //特殊情况2个非零，其余4个
            S_val_i0_r  <=  (s_z0_i + s_z1_i)>>17;
            S_val_r0_r  <=  (s_z0_r + s_z1_r)>>17;
            S_val_i1_r  <=  (s_z0_N2_i + s_z1_N2_i)>>17;
            S_val_r1_r  <=  (s_z0_N2_r + s_z1_N2_r)>>17;
            S_val_i2_r  <=  32'b0;
            S_val_r2_r  <=  32'b0;
            S_val_i3_r  <=  32'b0;
            S_val_r3_r  <=  32'b0;
        end
        else if(val_shake && z0>z1)begin              
            S_val_i0_r  <=  (s_z1_i)>>17;
            S_val_r0_r  <=  (s_z1_r)>>17;
            S_val_i1_r  <=  (s_z0_i)>>17;
            S_val_r1_r  <=  (s_z0_r)>>17;
            S_val_i2_r  <=  (s_z1_N2_i)>>17;
            S_val_r2_r  <=  (s_z1_N2_r)>>17;
            S_val_i3_r  <=  (s_z0_N2_i)>>17;
            S_val_r3_r  <=  (s_z0_N2_r)>>17;
        end
    end
//=========================================
//第一行非零元素的位置
//=========================================
    wire                [INDEX_W       -1: 0]           z0_N_2;
    wire                [INDEX_W       -1: 0]           z1_N_2;
    assign z0_N_2   =   z0[16+:INDEX_W]+(MAT_RANK>>>1);
    assign z1_N_2   =   z1[16+:INDEX_W]+(MAT_RANK>>>1);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            Scol_index_r   <=  'b0;
        end 
        else if(val_shake && z0<z1)begin
            Scol_index_r[0             +:INDEX_W]   <=  z0[16+:INDEX_W];
            Scol_index_r[(INDEX_W   )  +:INDEX_W]   <=  z1[16+:INDEX_W];
            Scol_index_r[(INDEX_W<<1)  +:INDEX_W]   <=  z0_N_2;
            Scol_index_r[(INDEX_W*3 )  +:INDEX_W]   <=  z0_N_2;
        end
        else if(val_shake && z0==z1)begin
            Scol_index_r[0             +:INDEX_W]   <=  z0[16+:INDEX_W];
            Scol_index_r[(INDEX_W   )  +:INDEX_W]   <=  z0[16+:INDEX_W]+(MAT_RANK>>>1);
            Scol_index_r[(INDEX_W<<1)  +:INDEX_W]   <=  'b0;
            Scol_index_r[(INDEX_W*3 )  +:INDEX_W]   <=  'b0;
        end
        else if(val_shake && z0>z1)begin
            Scol_index_r[0             +:INDEX_W]   <=  z1[16+:INDEX_W];
            Scol_index_r[(INDEX_W   )  +:INDEX_W]   <=  z0[16+:INDEX_W];
            Scol_index_r[(INDEX_W<<1)  +:INDEX_W]   <=  z1[16+:INDEX_W]+(MAT_RANK>>>1);
            Scol_index_r[(INDEX_W*3 )  +:INDEX_W]   <=  z0[16+:INDEX_W]+(MAT_RANK>>>1);
        end
    end


//=========================================
//
//=========================================


    
endmodule