module Counter(
	// Input signals
	clk,
	rst_n,
	// Output signals
	clk2
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
	input        clk, rst_n;
	output logic clk2;
	logic [1:0]temp,next;
	always_ff@(posedge clk, negedge rst_n)begin
		if(!rst_n)
			temp<=1;
		else
			temp<=next;       
	end
	always_comb begin
		case(temp)
			2'b00 ,2'b01,2'b10: next = temp+1;
			2'b11:next = 2'b00;
		endcase
	end
	assign clk2=temp[1];
endmodule
