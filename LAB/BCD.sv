module BCD(
  // Input signals
	in_bin,
  // Output signals
	out_hundred,
	out_ten,
	out_unit
);
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
//Input Ports
input [8:0] in_bin;

//output Ports
output logic [2:0]out_hundred;
output logic [3:0]out_ten;
output logic [3:0]out_unit;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
assign out_hundred[2:0]=in_bin[8:0]/100;
assign out_ten[3:0]=(in_bin[8:0]-100*out_hundred[2:0])/10;
assign out_unit[3:0]=in_bin[8:0]%10;
//---------------------------------------------------------------------
//   Your DESIGN                        
//---------------------------------------------------------------------


endmodule
