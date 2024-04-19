module Sort(
    // Input signals
	in_num0,
	in_num1,
	in_num2,
	in_num3,
	in_num4,
    // Output signals
	out_num
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input  [5:0] in_num0, in_num1, in_num2, in_num3, in_num4;
output logic [5:0] out_num;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
logic [5:0]temp[20];
    assign {temp[0],temp[1]}=(in_num0<in_num1)?{in_num0,in_num1}:{in_num1,in_num0};
    assign {temp[2],temp[3]}=(in_num2<in_num3)?{in_num2,in_num3}:{in_num3,in_num2};
    assign {temp[4],temp[5]}=(temp[1]<temp[2])?{temp[1],temp[2]}:{temp[2],temp[1]};
    assign {temp[6],temp[7]}=(temp[3]<in_num4)?{temp[3],in_num4}:{in_num4,temp[3]};
    assign {temp[8],temp[9]}=(temp[0]<temp[4])?{temp[0],temp[4]}:{temp[4],temp[0]};
    assign {temp[10],temp[11]}=(temp[5]<temp[6])?{temp[5],temp[6]}:{temp[6],temp[5]};
    assign {temp[12],temp[13]}=(temp[9]<temp[10])?{temp[9],temp[10]}:{temp[10],temp[9]};
    assign {temp[14],temp[15]}=(temp[11]<temp[7])?{temp[11],temp[7]}:{temp[7],temp[11]};
    assign {temp[16],temp[17]}=(temp[8]<temp[12])?{temp[8],temp[12]}:{temp[12],temp[8]};
    assign {temp[18],temp[19]}=(temp[13]<temp[14])?{temp[13],temp[14]}:{temp[14],temp[13]};

    assign out_num= temp[18];

//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------

endmodule