//===================================
//date:2022/11/23
//function:generate chaotic sequence x_{n}=4*x_{n-1}*(1<<16-x_{n-1})>>16
//email:1025220674@qq.com
//vivado2018.3
//===================================
module logistic_seq #(
    ITERATIONS      =   200,
    CHAOS_OVLD_W    =   32,
    GAIN_INDEX      =   16
) (
    input                                       clk,
    input                                       rst_n,
    input   [GAIN_INDEX   -1:       0]          chaos_x0,       //x_{0} : initial value  range(0,2^GAIN_INDEX)
    input                                       chaos_x0_vld,   //standard handshake
    output                                      chaos_x0_rdy,
    output  [CHAOS_OVLD_W -1:       0]          chaos_xout,
    output                                      chaos_xout_vld, //standard handshake
    input                                       chaos_xout_rdy
);
//===================================================================
//param
//===================================================================
    localparam  ITERATIONS_W  = $clog2(ITERATIONS);           //$clog2(9)=4,round up
    localparam  GAIN_MULT   =   1<<16;  
//===================================================================
//declare
//===================================================================
    reg     [CHAOS_OVLD_W -1:       0]          chaos_buffer;   //vld chaos seq buffer
    reg     [GAIN_INDEX   -1:       0]          xn_r;
    reg     [ITERATIONS_W -1:       0]          iter_cnt_r;     //iterations counter
    reg                                         chaos_x0_rdy_r;   
    reg                                         chaos_xout_vld_r;   
    reg                                         fmla_en_r;        //formula data input enable
    reg                                         fmla_en_r1;       //formula data output enable ;delay1

    // wire                                        fmla_en_w;
    wire                                        in_shake_w;
    wire                                        out_shake_w;
    wire                                        last_flg_w;
    assign  in_shake_w      =   chaos_x0_rdy_r & chaos_x0_vld;
    assign  out_shake_w     =   chaos_xout_vld_r & chaos_xout_rdy;    
    assign  chaos_x0_rdy    =   chaos_x0_rdy_r;
    assign  chaos_xout      =   chaos_buffer;
    assign  chaos_xout_vld  =   chaos_xout_vld_r;
//===================================================================
//handshake
//===================================================================

    always @(posedge clk ) begin
        if (!rst_n) begin
            chaos_x0_rdy_r  <=  1'b1;    
        end 
        else if(in_shake_w)begin
            chaos_x0_rdy_r  <=  1'b0;
        end
        else if(out_shake_w)begin
            chaos_x0_rdy_r  <=  1'b1;
        end
    end

    always @(posedge clk ) begin
        if (!rst_n) begin
            chaos_xout_vld_r  <=  1'b0;
        end 
        else if (out_shake_w) begin
            chaos_xout_vld_r  <=  1'b0;
        end
        else if(last_flg_w)begin
            chaos_xout_vld_r  <=  1'b1;
        end
    end
//===================================================================
//logic
//===================================================================
    always @(posedge clk ) begin//delay
        if (!rst_n) begin
            fmla_en_r1  <=  1'b0;
        end 
        else begin
            fmla_en_r1  <=  fmla_en_r;    
        end
    end
    assign  last_flg_w  =   fmla_en_r1&(~fmla_en_r);
    //1.formula
    always @(posedge clk ) begin
        if (!rst_n) begin
            xn_r  <=  'b0;
        end
        else if(in_shake_w)begin
            xn_r  <=  chaos_x0;
        end
        else if(fmla_en_r)begin
            xn_r  <=  (xn_r*(GAIN_MULT - xn_r)>>GAIN_INDEX-2);
        end
    end
    //2.iter_cnt
    always @(posedge clk ) begin
        if (!rst_n) begin
            iter_cnt_r    <=    'b0;
        end 
        else if(iter_cnt_r == ITERATIONS-1)begin//??????
            iter_cnt_r    <=    'b0;
        end
        else if(fmla_en_r)begin //start
            iter_cnt_r    <=    'b1 + iter_cnt_r;  
        end
    end
    //3.iter_work_enable
    always @(posedge clk ) begin
        if (!rst_n) begin
            fmla_en_r <=  1'b0;
        end 
        else if( iter_cnt_r==ITERATIONS-1 && fmla_en_r )begin
            fmla_en_r <=  1'b0;
        end
        else if(in_shake_w)begin //start
            fmla_en_r <=  1'b1;
        end
    end
    //4.judge
    always @(posedge clk ) begin
        if (!rst_n) begin
            chaos_buffer    <=  'b0;    
        end 
        else if(fmla_en_r1)begin
            chaos_buffer    <= xn_r[GAIN_INDEX-1] ? {chaos_buffer<<1,1'b1} : chaos_buffer<<1;
        end
    end

//=========================================
//test
//=========================================
integer fd,err,str;
always @(posedge clk) begin
    fd=$fopen("./DATA_200_in.txt", "a+"); 
    err = $ferror(fd, str);//检查是否正常打开,正常打开str，er为0
     if ( !err ) begin
           
            if(fmla_en_r1)
            $fdisplay(fd, " %d", xn_r) ;
            //$write(fd, "New data3: %h", err) ; //最后一行不换行打印
         end
    $fclose(fd);     
end
endmodule