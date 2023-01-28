//功能：输入theta（角度），根据欧拉公式输出对应角度的实部和虚部
//延迟：本模块经过18+2 cycle延迟
/*
cordic_mod (
    .clk(clk),
    .rst_n(rst_n),
    .theta(),          //输入随机序列生成theta
    .rand_shake(),     //vld信号
    .rdy_i(),
    .vld_o(),          //输出vld
    .i_signal_o(),     //输出虚部信号
    .r_signal_o()      //输出实部信号
);

*/
module cordic_mod (
    input                                       clk,
    input                                       rst_n,
    input               [31     : 0]            theta,          //输入随机序列生成theta
    input                                       rand_shake,     //vld信号
    input                                       rdy_i,
    output                                      vld_o,          //输出vld ，延迟20cycle相比输入
    output              [31     : 0]            i_signal_o,     //输出虚部信号
    output              [31     : 0]            r_signal_o      //输出实部信号
);

assign  i_signal_o  =   i_signal_r;
assign  r_signal_o  =   r_signal_r;
assign  vld_o   =   vld_r;
//========================================2
//Quadrant division
//=========================================
    reg                     [7      :0]         cordic_angle;          
    reg                                         flag_sin;
    reg                                         flag_cos;
    wire                    [31     :0]         r_signal;
    wire                    [31     :0]         i_signal;
    wire                                        vld;
    always @(posedge clk or negedge rst_n) begin                //1delay
        if (!rst_n) begin
            cordic_angle    <=  'b0;
            flag_sin    <=  'd0;
            flag_cos    <=  'd0;
        end 
        else if (rand_shake) begin
            if(theta[26:16]>'d180) begin
                if (theta[26:16]>'d270) begin//4
                    cordic_angle    <=  360-theta[26:16];
                    flag_sin    <=  'd0;//-1
                    flag_cos    <=  'd1;
                end else begin//3
                    cordic_angle    <=  theta[26:16]-180;
                    flag_sin    <=  'd0;//-1
                    flag_cos    <=  'd0;
                end
            end
            else begin
                if (theta[26:16]>'d90) begin//2
                    cordic_angle    <=  180-theta[26:16];
                    flag_sin    <=  'd1;//-1
                    flag_cos    <=  'd0;
                end 
                else begin//1
                    cordic_angle    <=  theta[26:16];
                    flag_sin    <=  'd1;//-1
                    flag_cos    <=  'd1;
                end
            end    
        end
    end
 
    cordic_pe inst_theta (
    .clk(clk),
    .rst_n(rst_n),
    .angle(cordic_angle),
    .vld(rand_shake_r),
    .Sin(i_signal),
    .Cos(r_signal),
    .finished_ndg(vld)
    );

//========================================2
//输出信号修正
//=========================================
    reg                         [31     : 0]        i_signal_r;
    reg                         [31     : 0]        r_signal_r;
    wire                        [1      : 0]        flag_sc;
    reg                                             vld_r;
    wire                                            hand_shake;
    assign  hand_shake  =   vld_o&rdy_i;
    assign  flag_sc =   {flag_sin,flag_cos};
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            i_signal_r      <= 'b0;
            r_signal_r      <= 'b0;
        end 
        else if(vld)begin  //4
            case (flag_sc)
                2'b00:begin//3
                    i_signal_r  <= ~i_signal + 'b1 ;
                    r_signal_r  <= ~r_signal + 'b1 ;
                end 
                2'b01:begin//4
                    i_signal_r  <= ~i_signal + 'b1 ;
                    r_signal_r  <= r_signal ;
                end 
                2'b10:begin//2
                    i_signal_r  <= i_signal ;
                    r_signal_r  <= ~r_signal + 'b1 ;
                end 
                2'b11:begin//1
                    i_signal_r  <= i_signal ;
                    r_signal_r  <= r_signal ;
                end 
                default: begin
                    i_signal_r  <= i_signal_r ;
                    r_signal_r  <= r_signal_r ;
                end
            endcase
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            vld_r   <=  'b0;
        end 
        else if (hand_shake) begin
            vld_r   <=  'b0;
        end
        else if(vld)begin
            vld_r   <=  vld;
        end
    end

endmodule