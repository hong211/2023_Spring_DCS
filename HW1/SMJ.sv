module SMJ(
    // Input signals
    hand_n0,
    hand_n1,
    hand_n2,
    hand_n3,
    hand_n4,
    // Output signals
    out_data
);
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input [5:0] hand_n0;
input [5:0] hand_n1;
input [5:0] hand_n2;
input [5:0] hand_n3;
input [5:0] hand_n4;
output logic[1:0] out_data;
logic tempx[5:0];
//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
always @( * )
begin
    tempx[0]=0;
    tempx[1]=0;
    tempx[2]=0;
    tempx[3]=0;
    tempx[4]=0;
    tempx[5]=0;
	if((hand_n0==hand_n1)&&(hand_n1==hand_n2)&&(hand_n2==hand_n3)&&(hand_n4==hand_n3))
        begin
            tempx[5]=1;
        end
	else
	  begin
        	if(hand_n0[5:4]==2'b00)begin
                tempx[0] = (hand_n0[3:0]>4'b0110)? 1:0;
		      end
          else begin
                tempx[0] = (hand_n0[3:0]>4'b1000)? 1:0;
           end
            if(hand_n1[5:4]==2'b00)begin
                tempx[1] = (hand_n1[3:0]>4'b0110)? 1:0;
		      end
          else begin
                tempx[1] = (hand_n1[3:0]>4'b1000)? 1:0;
           end
            if(hand_n2[5:4]==2'b00)begin
                tempx[2] = (hand_n2[3:0]>4'b0110)? 1:0;
		      end
          else begin
                tempx[2] = (hand_n2[3:0]>4'b1000)? 1:0;
           end
            if(hand_n3[5:4]==2'b00)begin
                tempx[3] = (hand_n3[3:0]>4'b0110)? 1:0;
		      end
          else begin
                tempx[3] = (hand_n3[3:0]>4'b1000)? 1:0;
           end
           if(hand_n4[5:4]==2'b00)begin
                tempx[4] = (hand_n4[3:0]>4'b0110)? 1:0;
		      end
          else begin
                tempx[4] = (hand_n4[3:0]>4'b1000)? 1:0;
           end
	end
    end

logic [5:0] o1;
logic [5:0] o2;
logic [5:0] o3;
logic [5:0] o4;
logic [5:0] o5;

sort_temp s1(.in1(hand_n0),
            .in2(hand_n1),
            .in3(hand_n2),
            .in4(hand_n3),
            .in5(hand_n4),
            .out1(o1),
            .out2(o2),
            .out3(o3),
            .out4(o4),
            .out5(o5));

always @( * )
    begin
      if ((tempx[0]||tempx[1]||tempx[2]||tempx[3]||tempx[4]||tempx[5])==1)
      begin
        out_data = 2'b01;
      end
      else
      begin
        if((o1==o2)&&(o2==o3) && (o4==o5))
          out_data = 2'b11 ;
        else if((o1==o2) && (o3==o4)&&(o4==o5))
          out_data = 2'b11 ;
        else if((o1==o2)&&((o3+2)==(o4+1)&&(o4+1)==(o5))&&o3[5:4]!=2'b00)
          out_data = 2'b10;
        else if((o2==o3)&&((o1+2)==(o4+1)&&(o4+1)==(o5))&&o1[5:4]!=2'b00)
          out_data = 2'b10;
        else if((o3==o4)&&((o1+2)==(o2+1)&&(o2+1)==(o5))&&o1[5:4]!=2'b00)
          out_data = 2'b10;
        else if((o4==o5)&&((o1+2)==(o2+1)&&(o2+1)==(o3))&&o1[5:4]!=2'b00)
          out_data = 2'b10;
        else 
          out_data = 2'b00;
      end
    end
//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------


endmodule

module sort_temp(in1,in2,in3,in4,in5,
            out1,out2,out3,out4,out5);
    input [5:0]in1;
    input [5:0]in2;
    input [5:0]in3;
    input [5:0]in4;
    input [5:0]in5;
    output logic[5:0]out1;
    output logic[5:0]out2;
    output logic[5:0]out3;
    output logic[5:0]out4;
    output logic[5:0]out5;
    
    logic [5:0]temp[20];
    assign {temp[0],temp[1]}=(in1<in2)?{in1,in2}:{in2,in1};
    assign {temp[2],temp[3]}=(in3<in4)?{in3,in4}:{in4,in3};
    assign {temp[4],temp[5]}=(temp[1]<temp[2])?{temp[1],temp[2]}:{temp[2],temp[1]};
    assign {temp[6],temp[7]}=(temp[3]<in5)?{temp[3],in5}:{in5,temp[3]};
    assign {temp[8],temp[9]}=(temp[0]<temp[4])?{temp[0],temp[4]}:{temp[4],temp[0]};
    assign {temp[10],temp[11]}=(temp[5]<temp[6])?{temp[5],temp[6]}:{temp[6],temp[5]};
    assign {temp[12],temp[13]}=(temp[9]<temp[10])?{temp[9],temp[10]}:{temp[10],temp[9]};
    assign {temp[14],temp[15]}=(temp[11]<temp[7])?{temp[11],temp[7]}:{temp[7],temp[11]};
    assign {temp[16],temp[17]}=(temp[8]<temp[12])?{temp[8],temp[12]}:{temp[12],temp[8]};
    assign {temp[18],temp[19]}=(temp[13]<temp[14])?{temp[13],temp[14]}:{temp[14],temp[13]};
    assign {out1,out2,out3,out4,out5}={temp[16],temp[17],temp[18],temp[19],temp[15]};   
endmodule

