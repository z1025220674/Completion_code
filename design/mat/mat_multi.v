//功能：实现稀疏矩阵向量乘
//1，ram存储向量
//2. 根据输入稀疏矩阵首行非零元素
module mat_multi #(
    MAT_RANK    =   256
) (
    input                                                           clk,
    input                                                           rst_n,

    input            [31                        : 0]                src_i,          //源序列输入
    input            [31                        : 0]                src_r,
    input                                                           src_vld,
    output                                                          src_rdy,        //求源序列输入
    input            [($clog2(MAT_RANK)<<2)   -1: 0]                Scol_index,
    input            [31                        : 0]                S_val_i0,       //输入的四个非零
    input            [31                        : 0]                S_val_r0,
    input            [31                        : 0]                S_val_i1,
    input            [31                        : 0]                S_val_r1,
    input            [31                        : 0]                S_val_i2,
    input            [31                        : 0]                S_val_r2,
    input            [31                        : 0]                S_val_i3,
    input            [31                        : 0]                S_val_r3,
    input                                                           S_vld_o,
    output                                                          S_rdy_o,

    output           [31                        : 0]                spmv_i,         //输出预编码后的序列
    output           [31                        : 0]                spmv_r,
    output                                                          spmv_vld,
    input                                                           spmv_rdy              
);
    

//==================================================
//declare
//==================================================
    reg                                                             src_rdy_r;   
    reg              [11                        : 0]                addra_r;
    wire                                                            ena;   
    wire             [63                        : 0]                douta;

    wire             [11                        : 0]                addrb0;     //通过列索引读取ram
    wire             [11                        : 0]                addrb1;
    wire             [11                        : 0]                addrb2;
    wire             [11                        : 0]                addrb3;
    reg              [11                        : 0]                addrb0_r;     //通过列索引读取ram
    reg              [11                        : 0]                addrb1_r;
    reg              [11                        : 0]                addrb2_r;
    reg              [11                        : 0]                addrb3_r;

    reg                                                             enb_r;  
    wire             [63                        : 0]                doutb0;
    wire             [63                        : 0]                doutb1;
    wire             [63                        : 0]                doutb2;
    wire             [63                        : 0]                doutb3;
    reg              [31                        : 0]                S_val_i0_r;
    reg              [31                        : 0]                S_val_r0_r;
    reg              [31                        : 0]                S_val_i1_r;
    reg              [31                        : 0]                S_val_r1_r;
    reg              [31                        : 0]                S_val_i2_r;
    reg              [31                        : 0]                S_val_r2_r;
    reg              [31                        : 0]                S_val_i3_r;
    reg              [31                        : 0]                S_val_r3_r;

    
//==================================================
//ram in
//==================================================
    always @(posedge clk or negedge rst_n) begin  // 握手情况：单次，多次：vld连续，不连续;只需要看不连续符号块（256个数组一组）,
        if (!rst_n) begin
            src_rdy_r   <=  1'b1;    
        end 
        else if((addra_r==MAT_RANK-1 )&& (ena) && (src_rdy_r))begin
            src_rdy_r   <=  0;
        end
        else if(addra_r==12'b0 && enb_r )begin
            src_rdy_r   <=  1;
        end
    end

    always @(posedge clk ) begin
        if (!rst_n) begin
            addra_r   <=  32'b0;
        end 
        else if((addra_r==MAT_RANK-1 )&& (ena) && (src_rdy_r))begin
            addra_r   <=  addra_r;
        end
        else if((addra_r==0 )&& (enb_r) )begin
            addra_r   <=  0;
        end
        else if(enb_r)begin
            addra_r   <=  addra_r - 1'b1;
        end
        else if(ena)begin
            addra_r   <=  addra_r + 1'b1;
        end
    end

//==================================================
//multi
//==================================================
    wire             [31                        : 0]                ram0_i,ram0_r;
    wire             [31                        : 0]                ram1_i,ram1_r;
    wire             [31                        : 0]                ram2_i,ram2_r;
    wire             [31                        : 0]                ram3_i,ram3_r;
    wire             [31                        : 0]                mult_0i,mult_0r;
    wire             [31                        : 0]                mult_1i,mult_1r;
    wire             [31                        : 0]                mult_2i,mult_2r;
    wire             [31                        : 0]                mult_3i,mult_3r;
    reg              [31                        : 0]                mult_0i_r,mult_0r_r;
    reg              [31                        : 0]                mult_1i_r,mult_1r_r;
    reg              [31                        : 0]                mult_2i_r,mult_2r_r;
    reg              [31                        : 0]                mult_3i_r,mult_3r_r;
    
    reg              [31                        : 0]                spmv_i_r,spmv_r_r;
    
    reg                                                             b_vld_r;
    reg                                                             spmv_vld_r;
    reg                                                             mat_vld_r;
    assign  mult_0i =   $signed(S_val_i0_r)*$signed(ram0_r)+$signed(S_val_r0_r)*$signed(ram0_i);
    assign  mult_0r =   $signed(S_val_r0_r)*$signed(ram0_r)+$signed(S_val_i0_r)*$signed(ram0_i);
    assign  mult_1i =   $signed(S_val_i1_r)*$signed(ram1_r)+$signed(S_val_r1_r)*$signed(ram1_i);
    assign  mult_1r =   $signed(S_val_r1_r)*$signed(ram1_r)+$signed(S_val_i1_r)*$signed(ram1_i);
    assign  mult_2i =   $signed(S_val_i2_r)*$signed(ram2_r)+$signed(S_val_r2_r)*$signed(ram2_i);
    assign  mult_2r =   $signed(S_val_r2_r)*$signed(ram2_r)+$signed(S_val_i2_r)*$signed(ram2_i);
    assign  mult_3i =   $signed(S_val_i3_r)*$signed(ram3_r)+$signed(S_val_r3_r)*$signed(ram3_i);
    assign  mult_3r =   $signed(S_val_r3_r)*$signed(ram3_r)+$signed(S_val_i3_r)*$signed(ram3_i);
    assign  {ram0_i,ram0_r}=doutb0;
    assign  {ram1_i,ram1_r}=doutb1;
    assign  {ram2_i,ram2_r}=doutb2;
    assign  {ram3_i,ram3_r}=doutb3;
always @(posedge clk or negedge rst_n) begin                //代表矩阵行向量已经准备好       ,,/??????          
    if (!rst_n) begin
        mat_vld_r   <=  1'b0;
    end 
    // else if()begin
    //     mat_vld_r   <=  1'b0;
    // end
    else if(S_vld_o && S_rdy_o)begin
        mat_vld_r   <=  1'b1;
    end
end
always @(posedge clk or negedge rst_n) begin                //将输入的预编码矩阵行向量保存，用来做spmv
    if (!rst_n) begin
        S_val_i0_r  <=  'b0;
        S_val_r0_r  <=  'b0;
        S_val_i1_r  <=  'b0;
        S_val_r1_r  <=  'b0;
        S_val_i2_r  <=  'b0;
        S_val_r2_r  <=  'b0;
        S_val_i3_r  <=  'b0;
        S_val_r3_r  <=  'b0;    
    end 
    else if(S_vld_o && S_rdy_o)begin
        S_val_i0_r  <=  S_val_i0;
        S_val_r0_r  <=  S_val_r0;
        S_val_i1_r  <=  S_val_i1;
        S_val_r1_r  <=  S_val_r1;
        S_val_i2_r  <=  S_val_i2;
        S_val_r2_r  <=  S_val_r2;
        S_val_i3_r  <=  S_val_i3;
        S_val_r3_r  <=  S_val_r3;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        spmv_i_r    <=  'b0;
        spmv_r_r    <=  'b0;
    end 
    else begin
        spmv_i_r    <=  mult_0i_r+mult_1i_r+mult_2i_r+mult_3i_r;
        spmv_r_r    <=  mult_0r_r+mult_1r_r+mult_2r_r+mult_3r_r;    
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        spmv_vld_r  <= 1'b0;
    end 
    else begin
        spmv_vld_r  <=  b_vld_r;
    end
end
always @(posedge clk or negedge rst_n) begin                    //做SPMV，矩阵和密集向量乘
    if (!rst_n) begin
        mult_0i_r     <=  32'b0;
        mult_0r_r     <=  32'b0;
        mult_1i_r     <=  32'b0;
        mult_1r_r     <=  32'b0;
        mult_2i_r     <=  32'b0;
        mult_2r_r     <=  32'b0;
        mult_3i_r     <=  32'b0;
        mult_3r_r     <=  32'b0;
    end 
    else if(b_vld_r && mat_vld_r)begin
        mult_0i_r     <=  mult_0i>>16;
        mult_0r_r     <=  mult_0r>>16;
        mult_1i_r     <=  mult_1i>>16;
        mult_1r_r     <=  mult_1r>>16;
        mult_2i_r     <=  mult_2i>>16;
        mult_2r_r     <=  mult_2r>>16;
        mult_3i_r     <=  mult_3i>>16;
        mult_3r_r     <=  mult_3r>>16;
    end
end

//==================================================
//ram 读取
//==================================================
    assign  addrb0  =   Scol_index[0                +:$clog2(MAT_RANK)];        //做ram读取，根据列索引进行读取
    assign  addrb1  =   Scol_index[$clog2(MAT_RANK) +:$clog2(MAT_RANK)];
    assign  addrb2  =   Scol_index[($clog2(MAT_RANK)<<1) +:$clog2(MAT_RANK)];
    assign  addrb3  =   Scol_index[($clog2(MAT_RANK)*3)  +:$clog2(MAT_RANK)];
always @(posedge clk or negedge rst_n) begin                      
    if (!rst_n) begin
        addrb0_r  <=  12'b0;
        addrb1_r  <=  12'b0;
        addrb2_r  <=  12'b0;
        addrb3_r  <=  12'b0;
    end 
    else if(enb_r)begin
        addrb0_r  <=  addrb0 + 1'b1;
        addrb1_r  <=  addrb1 + 1'b1;
        addrb2_r  <=  addrb2 + 1'b1;
        addrb3_r  <=  addrb3 + 1'b1;
    end
end
always @(posedge clk or negedge rst_n) begin                    //做ram读取，doutb输出的有效信号
    if (!rst_n) begin
        b_vld_r <=  1'b0; 
    end 
    else begin
        b_vld_r <=  enb_r;
    end
end
always @(posedge clk or negedge rst_n) begin                    //做ram读取，enb_r在addra写完后进行读取
    if (!rst_n) begin
        enb_r   <=  1'b0;
    end 
    else if((addra_r==12'b0 )&& (enb_r))begin
        enb_r   <=  1'b0;
    end
    else if((addra_r==MAT_RANK-1 )&& (ena))begin
        enb_r   <=  1'b1;
    end
end

//==================================================
//source ram
//==================================================
//==================================================
//浮点转定点
//==================================================

//==================================================
//source ram
//==================================================
//存储向量（子载波符号块个数*子载波数）16*16,用于和第一个非零元素相乘

ram_source inst_soucre_ir_0 (
  .clka(clk),    // input wire clka
  .wea(ena),      // input wire ena
  .addra(addra_r),  // input wire [11 : 0] addra
  .dina(douta),  // output wire [63 : 0] douta
  .clkb(clk),    // input wire clkb
  .enb(enb_r),      // input wire enb
  .addrb(addrb0),  // input wire [11 : 0] addrb
  .doutb(doutb0)  // output wire [63 : 0] doutb
);
//==================================================
//存储向量（子载波符号块个数*子载波数）16*16,用于和第二个非零元素相乘
ram_source inst_soucre_ir_1 (
  .clka(clk),    // input wire clka
  .wea(ena),      // input wire ena
  .addra(addra_r),  // input wire [11 : 0] addra
  .dina(douta),  // output wire [63 : 0] douta
  .clkb(clk),    // input wire clkb
  .enb(enb_r),      // input wire enb
  .addrb(addrb1),  // input wire [11 : 0] addrb
  .doutb(doutb1)  // output wire [63 : 0] doutb
);
//==================================================
//存储向量（子载波符号块个数*子载波数）16*16,用于和第三个非零元素相乘
ram_source inst_soucre_ir_2 (
  .clka(clk),    // input wire clka
  .wea(ena),      // input wire ena
  .addra(addra_r),  // input wire [11 : 0] addra
  .dina(douta),  // output wire [63 : 0] douta
  .clkb(clk),    // input wire clkb
  .enb(enb_r),      // input wire enb
  .addrb(addrb2),  // input wire [11 : 0] addrb
  .doutb(doutb2)  // output wire [63 : 0] doutb
);
//==================================================
//存储向量（子载波符号块个数*子载波数）16*16,用于和第四个非零元素相乘
ram_source inst_soucre_ir_3 (
  .clka(clk),    // input wire clka
  .wea(ena),      // input wire ena
  .addra(addra_r),  // input wire [11 : 0] addra
  .dina(douta),  // output wire [63 : 0] douta
  .clkb(clk),    // input wire clkb
  .enb(enb_r),      // input wire enb
  .addrb(addrb3),  // input wire [11 : 0] addrb
  .doutb(doutb3)  // output wire [63 : 0] doutb
);
    else if(enb_r)begin
        addrb0_r  <=  (addrb0_r + 1'b1)%MAT_RANK;
        addrb1_r  <=  (addrb1_r + 1'b1)%MAT_RANK;
        addrb2_r  <=  (addrb2_r + 1'b1)%MAT_RANK;
        addrb3_r  <=  (addrb3_r + 1'b1)%MAT_RANK;
    end


    assign  spmv_i  =   spmv_i_r;
    assign  spmv_r  =   spmv_r_r;
    assign  spmv_vld=   spmv_vld_r;
    assign  S_rdy_o =   1'b1;       //请求csc矩阵的行向量输入
    assign  douta   =   {src_i,src_r};  
    assign  src_rdy =   addra_r==32'b0;
    assign  ena =src_vld;
endmodule