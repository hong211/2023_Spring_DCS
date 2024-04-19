module Seq(
    clk,rst_n,in_valid,
    in_data,out_valid,out_data
);
input clk,rst_n,in_valid;
input [3:0]in_data;
output logic out_valid , out_data;
logic [3:0] a,b,c;
logic [2:0]valid;
always_ff @(posedge clk , negedge rst_n) begin
    if(!rst_n)begin
        a<=4'b0;
        b<=4'b0;
        c<=4'b0;
	    valid <=3'b0;
	 end 
    else begin
        a<=in_data;
        b<=a;
        c<=b;
		valid[2]<=in_valid;
		valid[1]<=valid[2];
		valid[0]<=valid[1];
    end
end

always_comb begin
    if(!valid[0]||!valid[2])begin
        out_data=0;
        out_valid=0;
    end
    else if((c>b && b>a)||(a>b && b>c))begin
        out_data = 1;
        out_valid =1;
    end
    else begin
        out_data=0;
        out_valid=1;
    end
end
endmodule