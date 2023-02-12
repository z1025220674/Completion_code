//功能：实现稀疏矩阵向量乘
//1，ram存储向量
//2. 根据输入稀疏矩阵首行非零元素
module mat_multi #(
    MAT_RANK    =   256
) (
    input                                                           clk,
    input                                                           rst_n,

    input            [31                        : 0]                src_i,
    input            [31                        : 0]                src_r,
    input                                                           src_vld,
    output                                                          src_rdy,
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
    

//==================================================
//declare
//==================================================
    reg                                                             src_rdy_r;   
//==================================================
//src_ir shake
//==================================================
    always @(posedge clk or negedge rst_n) begin  // 握手情况：单次，多次：vld连续，不连续
        if (!rst_n) begin
            src_rdy_r   <=  'b0;    
        end 
        else if()begin
            
        end
    end
//==================================================
//source ram
//==================================================
//==================================================
//source ram
//==================================================
//==================================================
//source ram
//==================================================
//==================================================
//source ram write
//==================================================

//==================================================
//source ram
//==================================================
//存储向量（子载波符号块个数*子载波数）16*16
ram_source inst_soucre_ir (
  .clka(clk),    // input wire clka
  .ena(ena),      // input wire ena
  .addra(addra),  // input wire [11 : 0] addra
  .douta(douta),  // output wire [63 : 0] douta
  .clkb(clk),    // input wire clkb
  .enb(enb),      // input wire enb
  .addrb(addrb),  // input wire [11 : 0] addrb
  .doutb(doutb)  // output wire [63 : 0] doutb
);

endmodule