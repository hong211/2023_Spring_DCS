module HE(
	// Input signals
	clk,
	rst_n,
	in_valid,
	in_image,
  // Output signals
	out_valid,
	out_image
);
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input				clk,rst_n,in_valid;
input [7:0]			in_image;
output logic 		out_valid;
output logic [7:0]	out_image;

//---------------------------------------------------------------------
// PARAMETER DECLARATION
//---------------------------------------------------------------------
logic[7:0] pixel1,pixel2,pixel3,pixel4,pixel5,pixel6,pixel7,pixel8;
logic[7:0] pixel1_temp,pixel2_temp,pixel3_temp,pixel4_temp,pixel5_temp,pixel6_temp,pixel7_temp,pixel8_temp;
logic[7:0]out_image_temp ,in_image_reg  ;
logic[10:0]out1,out2,out3,out4,out5,out6,out7;
logic[10:0]out1_temp,out2_temp,out3_temp,out4_temp,out5_temp,out6_temp,out7_temp;
logic[19:0]out8 , out8_temp ,out8_temp2;
typedef enum logic[1:0] {IDLE , STORE ,OUT } state;
state curr,next;
logic[9:0]cnt,cntt;
logic out_valid_temp;
always_ff @(posedge clk,negedge rst_n ) begin
	if(!rst_n)begin
		curr<=IDLE;
		pixel1<=0;
		pixel2<=0;
		pixel3<=0;
		pixel4<=0;
		pixel5<=0;
		pixel6<=0;
		pixel7<=0;
		pixel8<=0;
		cntt<=0;
		out1<=0;
		out2<=0;
		out3<=0;
		out4<=0;
		out5<=0;
		out6<=0;
		out7<=0;
		out8<=0;
		in_image_reg<=0;
	end
	else begin
		curr<=next;
		pixel1<=pixel1_temp;
		pixel2<=pixel2_temp;
		pixel3<=pixel3_temp;
		pixel4<=pixel4_temp;
		pixel5<=pixel5_temp;
		pixel6<=pixel6_temp;
		pixel7<=pixel7_temp;
		pixel8<=pixel8_temp;
		cntt<=cnt;
		out1<=out1_temp;
		out2<=out2_temp;
		out3<=out3_temp;
		out4<=out4_temp;
		out5<=out5_temp;
		out6<=out6_temp;
		out7<=out7_temp;
		out8<=out8_temp;
		in_image_reg<=in_image;
	end	
end

always_comb begin
	pixel1_temp=pixel1;
	pixel2_temp=pixel2;
	pixel3_temp=pixel3;
	pixel4_temp=pixel4;
	pixel5_temp=pixel5;
	pixel6_temp=pixel6;
	pixel7_temp=pixel7;
	pixel8_temp=pixel8;
	out_valid=0;
	out1_temp=out1;
	out2_temp=out2;
	out3_temp=out3;
	out4_temp=out4;
	out5_temp=out5;
	out6_temp=out6;
	out7_temp=out7;
	out8_temp=out8;
	cnt=0;
	next=IDLE;
	out8_temp2=0;
	out_image=0;
	case(curr)

		IDLE:begin
			out1_temp=0;
			out2_temp=0;
			out3_temp=0;
			out4_temp=0;
			out5_temp=0;
			out6_temp=0;
			out7_temp=0;
			out8_temp=0;
			if(in_valid)begin
				pixel1_temp=in_image;
				pixel2_temp=pixel1;
				pixel3_temp=pixel2;
				pixel4_temp=pixel3;
				pixel5_temp=pixel4;
				pixel6_temp=pixel5;
				pixel7_temp=pixel6;
				pixel8_temp=pixel7;
				cnt=cntt+1;
			end
			if(cntt>6)begin
				next=STORE;
				cnt=0;
			end
		end	
		
		STORE:begin
			if(cntt<=1022 && in_valid)begin
				out1_temp=(in_image<=pixel1)?out1+1:out1;
				out2_temp=(in_image<=pixel2)?out2+1:out2;
				out3_temp=(in_image<=pixel3)?out3+1:out3;
				out4_temp=(in_image<=pixel4)?out4+1:out4;
				out5_temp=(in_image<=pixel5)?out5+1:out5;
				out6_temp=(in_image<=pixel6)?out6+1:out6;
				out7_temp=(in_image<=pixel7)?out7+1:out7;
				out8_temp=(in_image<=pixel8)?out8+1:out8;
				cnt=cntt+1;
				next=STORE;
				
			end
			else begin
				next=OUT;
				out8_temp=((in_image<=pixel8)?out8+1:out8)*937;
				cnt=0;
			end
		end


		OUT:begin
			if(cntt<=7)begin
				out_valid=1;
				out_image_temp=out8[19:12]+(((3*out8[19:12]+out8[11:0])>4093)?1:0);
				out_image=(out_image_temp!=0)?out_image_temp-1:0;
				case(cntt)
					0:begin
						
					out8_temp2=(in_image_reg<=pixel7)?out7+1:out7;
					out7_temp=(in_image_reg<=pixel6)?out6+1:out6;
					out6_temp=(in_image_reg<=pixel5)?out5+1:out5;
					out5_temp=(in_image_reg<=pixel4)?out4+1:out4;
					out4_temp=(in_image_reg<=pixel3)?out3+1:out3;
					out3_temp=(in_image_reg<=pixel2)?out2+1:out2;
					out2_temp=(in_image_reg<=pixel1)?out1+1:out1;
						
						
						
						
					end
					default:begin 
						//out8_temp=out7+(out7<<3)+(out7<<5)+(out7<<10)-(out7<<7);
						out8_temp2=out7;
						out7_temp=out6;
						out6_temp=out5;
						out5_temp=out4;
						out4_temp=out3;
						out3_temp=out2;
						out2_temp=out1;
					end
					
				endcase
				out8_temp=out8_temp2*937;
				cnt=cntt+1;
				next=OUT;
			end
			else begin
				next=IDLE;
				cnt=0;
			end
		end
	endcase

end
endmodule