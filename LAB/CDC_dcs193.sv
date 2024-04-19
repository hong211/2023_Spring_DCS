`include "synchronizer.v"
module CDC (
    clk_1,
    clk_2,
    rst_n,
    in_valid,
    in_a,
    in_b,
    mode,
    out_valid,
    out
);
input clk_1,clk_2,rst_n,in_valid,mode;
input [3:0]in_a,in_b;
output logic out_valid;
output logic [7:0]out;

logic [3:0]ina_reg,inb_reg ,ina ,inb; 
logic mode_comb , mode_reg;
typedef enum logic[1:0] {IDLE , COMPUTE ,OUT  } state;
state curr ,next;

logic in1 , in_reg , in3 ,in3_reg;

logic out_valid_temp;
logic [7:0]out_temp;

assign in1 = in_valid ^ in_reg;
always_ff @( posedge clk_1 , negedge rst_n ) begin : first_stage
    if(!rst_n)begin
        in_reg<=0;
    end
    else begin
        in_reg<=in1;
    end
end

synchronizer second_stage(.clk(clk_2),.rst_n(rst_n),.D(in_reg),.Q(in3));

always_ff @( posedge clk_2,negedge rst_n ) begin : third_stage
    if(!rst_n)begin
        in3_reg<=0;
    end
    else begin
        in3_reg<=in3;
    end
end

assign CDC_res = in3 ^ in3_reg;

always_ff @( posedge clk_1 , negedge rst_n ) begin : input_data
    if(!rst_n)begin
        ina_reg<=0;
        inb_reg<=0;
        mode_reg<=0;
    end
    else begin
        ina_reg<=ina;
        inb_reg<=inb;
        mode_reg<=mode_comb;
    end
end

always_comb begin : in
    if(in_valid)begin
        ina=in_a;
        inb=in_b;
        mode_comb=mode;
    end
    else begin
        ina=ina_reg;
        inb=inb_reg;
        mode_comb=mode_reg;
    end
end

always_ff @( posedge clk_2 , negedge rst_n ) begin : FSM
    if(!rst_n)begin
        curr<=IDLE;
    end
    else begin
        curr<=next;
    end
end

always_comb begin : FSM_comb
    case (curr)
        IDLE:begin
            out_valid_temp=0;
            out_temp=0;
            if(CDC_res)begin
                next=COMPUTE;
            end
            else 
                next = IDLE;
        end
        COMPUTE:begin
            out_temp=mode_reg ? ina_reg*inb_reg : ina_reg+inb_reg;
            out_valid_temp=1;
            next=OUT;
        end
        OUT: begin
            out_valid_temp=0;
            out_temp=0;
            next = IDLE;
        end
        default: begin
            out_valid_temp=0;
            out_temp=0;
            next = IDLE;
        end
    endcase
end
always_ff @( posedge clk_2 , negedge rst_n ) begin : OUT_PUT
    if(!rst_n)begin
        out_valid<=0;
        out<=0;
    end
    else begin
        out_valid<=out_valid_temp;
        out<=out_temp;
    end
end
endmodule