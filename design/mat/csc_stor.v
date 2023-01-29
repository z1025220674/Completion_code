
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
    input                                               clk,
    input                                               rst_n,

    input               [31             : 0]            z0,         //z1、z0和其他数值可以用val_vld，因为z不会改变
    input               [31             : 0]            z1,         //z1、z0和其他数值可以用val_vld，因为z不会改变
    input               [31             : 0]            s_val_i,
    input               [31             : 0]            s_val_r,
    input               [31             : 0]            a0_val_i,
    input               [31             : 0]            a0_val_r,
    input               [31             : 0]            a1_val_i,
    input               [31             : 0]            a1_val_r,
    input                                               val_vld,
    output                                              val_rdy

);

//=========================================
//declare
//=========================================
    localparam  INDEX_W =   $clog2(MAT_RANK);
    reg                 [31             : 0]            S_val_i0_r;     //第一个非零元素
    reg                 [31             : 0]            S_val_r0_r;
    reg                 [31             : 0]            S_val_i1_r;     //第二个
    reg                 [31             : 0]            S_val_r1_r;
    reg                 [31             : 0]            S_val_i2_r;     //第三个
    reg                 [31             : 0]            S_val_r2_r; 
    reg                 [31             : 0]            S_val_i3_r;     //第四个
    reg                 [31             : 0]            S_val_r3_r;

    reg                 [INDEX_W*4    -1: 0]            col_index;      //存储第一行4个非零元素列位置

    wire                [63             : 0]            s_z0_i;
    wire                [63             : 0]            s_z0_r;
    wire                [63             : 0]            s_z1_i;
    wire                [63             : 0]            s_z1_r;
    wire                [63             : 0]            s_z0_N2_i;      //N2----N/2;N是矩阵的秩
    wire                [63             : 0]            s_z0_N2_r;
    wire                [63             : 0]            s_z1_N2_i;
    wire                [63             : 0]            s_z1_N2_r;


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
            S_val_i0_r  <=  (s_z0_i)>>1;
            S_val_r0_r  <=  (s_z0_r)>>1;
            S_val_i1_r  <=  (s_z1_i)>>1;
            S_val_r1_r  <=  (s_z1_r)>>1;
            S_val_i2_r  <=  (s_z0_N2_i)>>1;
            S_val_r2_r  <=  (s_z0_N2_r)>>1;
            S_val_i3_r  <=  (s_z1_N2_i)>>1;
            S_val_r3_r  <=  (s_z1_N2_r)>>1;
        end
        else if(val_shake && z0==z1)begin             //特殊情况2个非零，其余4个
            S_val_i0_r  <=  (s_z0_i + s_z1_i)>>1;
            S_val_r0_r  <=  (s_z0_r + s_z1_r)>>1;
            S_val_i1_r  <=  (s_z0_N2_i + s_z1_N2_i)>>1;
            S_val_r1_r  <=  (s_z0_N2_r + s_z1_N2_r)>>1;
            S_val_i2_r  <=  32'b0;
            S_val_r2_r  <=  32'b0;
            S_val_i3_r  <=  32'b0;
            S_val_r3_r  <=  32'b0;
        end
        else if(val_shake && z0>z1)begin              
            S_val_i0_r  <=  (s_z1_i)>>1;
            S_val_r0_r  <=  (s_z1_r)>>1;
            S_val_i1_r  <=  (s_z0_i)>>1;
            S_val_r1_r  <=  (s_z0_r)>>1;
            S_val_i2_r  <=  (s_z1_N2_i)>>1;
            S_val_r2_r  <=  (s_z1_N2_r)>>1;
            S_val_i3_r  <=  (s_z0_N2_i)>>1;
            S_val_r3_r  <=  (s_z0_N2_r)>>1;
        end
    end
//=========================================
//第一行非零元素的位置
//=========================================

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            col_index   <=  'b0;
        end 
        else if(val_shake && z0<z1)begin
            col_index[0             +:INDEX_W]   <=  z0;
            col_index[(INDEX_W   )  +:INDEX_W]   <=  z1;
            col_index[(INDEX_W<<1)  +:INDEX_W]   <=  z0+(MAT_RANK>>1);
            col_index[(INDEX_W*3 )  +:INDEX_W]   <=  z1+(MAT_RANK>>1);
        end
        else if(val_shake && z0==z1)begin
            col_index[0             +:INDEX_W]   <=  z0;
            col_index[(INDEX_W   )  +:INDEX_W]   <=  z0+(MAT_RANK>>1);
            col_index[(INDEX_W<<1)  +:INDEX_W]   <=  'b0;
            col_index[(INDEX_W*3 )  +:INDEX_W]   <=  'b0;
        end
        else if(val_shake && z0>z1)begin
            col_index[0             +:INDEX_W]   <=  z1;
            col_index[(INDEX_W   )  +:INDEX_W]   <=  z0;
            col_index[(INDEX_W<<1)  +:INDEX_W]   <=  z1+(MAT_RANK>>1);
            col_index[(INDEX_W*3 )  +:INDEX_W]   <=  z0+(MAT_RANK>>1);
        end
    end


//=========================================
//
//=========================================


    
endmodule