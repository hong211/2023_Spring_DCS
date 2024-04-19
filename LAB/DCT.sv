module DCT(
	// Input signals
	clk,
	rst_n,
	in_valid,
	in_data,
	// Output signals
	out_valid,
	out_data
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input        clk, rst_n, in_valid;
input signed [7:0]in_data;
output logic out_valid;
output logic signed[9:0]out_data;

//---------------------------------------------------------------------
//   REG AND WIRE DECLARATION                         
//---------------------------------------------------------------------

logic signed [7:0]dctmtx[0:3][0:3];



//---------------------------------------------------------------------
//   YOUR DESI-----
          
//---------      -----------------------------------------------------------
assign dctmtx[0][0] = 8'b01000000;
assign dctmtx[0][1] = 8'b01000000;
assign dctmtx[0][2] = 8'b01000000;
assign dctmtx[0][3] = 8'b01000000;
assign dctmtx[1][0] = 8'b01010011;
assign dctmtx[1][1] = 8'b00100010;
assign dctmtx[1][2] = 8'b11011110;
assign dctmtx[1][3] = 8'b10101101;
assign dctmtx[2][0] = 8'b01000000;
assign dctmtx[2][1] = 8'b11000000;
assign dctmtx[2][2] = 8'b11000000;
assign dctmtx[2][3] = 8'b01000000;
assign dctmtx[3][0] = 8'b00100010;
assign dctmtx[3][1] = 8'b10101101;
assign dctmtx[3][2] = 8'b01010011;
assign dctmtx[3][3] = 8'b11011110;

logic [10:0] input_cnt ,input_cnt_reg;
logic signed[8:0]inbuffer[0:3][0:3];
logic signed [8:0]inbuffer_reg[0:3][0:3];
logic signed[9:0]outbuffer[0:3][0:3];
logic signed[9:0]outbuffer_reg[0:3][0:3];
logic signed[9:0]out[0:3][0:3];
logic signed[9:0]out_reg[0:3][0:3];
typedef enum logic[1:0] { IDLE , PIPE1,PIPE2 , OUTPUT } state;
state curr, next;
always_ff @( posedge clk , negedge rst_n ) begin
    if(!rst_n)begin
        curr<=IDLE;
        input_cnt<=0;
        /*inbuffer<=0;
        outbuffer<=0;*/
    end
    else begin
        curr<=next;
        input_cnt<=input_cnt_reg;
        inbuffer<=inbuffer_reg;
        outbuffer<=outbuffer_reg;
        out<=out_reg;
    end
end

always_comb begin
	 input_cnt_reg=0;
        out_data=0;
        out_valid=0;
        inbuffer_reg=inbuffer;
        outbuffer_reg=outbuffer;
        out_reg=out;
    case(curr)
        OUTPUT:begin
            if(input_cnt<=15)begin
                out_valid=1;
                out_data=out[input_cnt[3:2]][input_cnt[1:0]];
                input_cnt_reg=input_cnt+1;
                next=OUTPUT;
            end 
            else next = IDLE;
        end
       
        IDLE:begin
            
            if(in_valid)begin
                inbuffer_reg[input_cnt[3:2]][input_cnt[1:0]]=in_data;
                input_cnt_reg=input_cnt+1;
                next=IDLE;
                if(input_cnt==15)begin
                    next=PIPE1;
                    input_cnt_reg=0;
                end
            end
            else
                next = IDLE;
        end    
        PIPE1:begin
            input_cnt_reg=input_cnt+1;
             next=PIPE1;
            if(input_cnt<=15)begin
                outbuffer_reg[input_cnt[3:2]][input_cnt[1:0]]=(
                dctmtx[input_cnt[3:2]][0]*inbuffer[0][input_cnt[1:0]]+
                dctmtx[input_cnt[3:2]][1]*inbuffer[1][input_cnt[1:0]]+
                dctmtx[input_cnt[3:2]][2]*inbuffer[2][input_cnt[1:0]]+
                dctmtx[input_cnt[3:2]][3]*inbuffer[3][input_cnt[1:0]])/128;
               if(input_cnt==15)begin
                    next=PIPE2;
                    input_cnt_reg=0;
                end
            end
            
           
            
        end
        PIPE2:begin
            input_cnt_reg=input_cnt+1;
             next=PIPE2;
        if(input_cnt<=15)begin
                out_reg[input_cnt[3:2]][input_cnt[1:0]]=(
                dctmtx[input_cnt[1:0]][0]*outbuffer_reg[input_cnt[3:2]][0]+
                dctmtx[input_cnt[1:0]][1]*outbuffer_reg[input_cnt[3:2]][1]+
                dctmtx[input_cnt[1:0]][2]*outbuffer_reg[input_cnt[3:2]][2]+
                dctmtx[input_cnt[1:0]][3]*outbuffer_reg[input_cnt[3:2]][3])/128;

                if(input_cnt==15)begin
                    next=OUTPUT;
                    input_cnt_reg=0;
                end
            end
        end
       
        default:begin
            next=curr;
        end
    endcase
    
end

endmodule