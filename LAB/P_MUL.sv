module P_MUL(
    //Input 
    clk,
    rst_n,
    in_1,
    in_2,
	in_3,
    in_4,
	in_valid,
    //OUTPUT
    out_valid,
    out
);

//Input 
input clk;
input rst_n;
input in_valid;
input [46:0] in_1,in_2,in_3,in_4;
//OUTPUT
output logic out_valid;
output logic [95:0] out;

logic in_valid1,in_valid2,in_valid3;
logic [46:0]in_1_reg,in_2_reg,in_3_reg,in_4_reg;
logic [46:0]in1,in2,in3,in4;

logic [47:0]sum1,sum2,sum1_reg,sum2_reg;

logic [31:0]mul1,mul1_reg,mul2,mul2_reg,mul3,mul3_reg;
logic [31:0]mul4,mul4_reg,mul5,mul5_reg,mul6,mul6_reg;
logic [31:0]mul7,mul7_reg,mul8,mul8_reg,mul9,mul9_reg;

logic [95:0]out_temp;
logic out_valid_temp;
always_comb begin : input1
    if(in_valid)begin
        in1=in_1;
        in2=in_2;
        in3=in_3;
        in4=in_4;
    end
    else begin
        in1=0;
        in2=0;
        in3=0;
        in4=0;
    end
end

always_ff @( posedge clk,negedge rst_n ) begin
    if(!rst_n)begin
        in_valid1<=0;
        in_1_reg<=0;
        in_2_reg<=0;
        in_3_reg<=0;
        in_4_reg<=0;

        sum1_reg<=0;
        sum2_reg<=0;
        in_valid2<=0;

        mul1_reg<=0;
        mul2_reg<=0;
        mul3_reg<=0;
        mul4_reg<=0;
        mul5_reg<=0;
        mul6_reg<=0;
        mul7_reg<=0;
        mul8_reg<=0;
        mul8_reg<=0;

        in_valid3<=0;
    end
    else begin
        in_valid1<=in_valid;
        in_1_reg<=in1;
        in_2_reg<=in2;
        in_3_reg<=in3;
        in_4_reg<=in4;

        sum1_reg<=sum1;
        sum2_reg<=sum2;
        in_valid2<=in_valid1;

        mul1_reg<=mul1;
        mul2_reg<=mul2;
        mul3_reg<=mul3;
        mul4_reg<=mul4;
        mul5_reg<=mul5;
        mul6_reg<=mul6;
        mul7_reg<=mul7;
        mul8_reg<=mul8;
        mul9_reg<=mul9;

        in_valid3<=in_valid2;
    end
end

always_comb begin:sum
    if(in_valid1)begin
        sum1=in_1_reg+in_2_reg;
        sum2=in_3_reg+in_4_reg;
    end
    else begin
        sum1=0;
        sum2=0;
    end
end

always_comb begin:multiple
    if(in_valid2)begin
        mul1=sum1_reg[15:0]*sum2_reg[15:0];//shift0
        mul2=sum1_reg[31:16]*sum2_reg[15:0];//shift 16
        mul3=sum1_reg[47:32]*sum2_reg[15:0];//shift 32
        mul4=sum1_reg[15:0]*sum2_reg[31:16];//shift 16
        mul5=sum1_reg[31:16]*sum2_reg[31:16];//shift 32
        mul6=sum1_reg[47:32]*sum2_reg[31:16];//shift 48
        mul7=sum1_reg[15:0]*sum2_reg[47:32];//shift 32
        mul8=sum1_reg[31:16]*sum2_reg[47:32];//shift 48
        mul9=sum1_reg[47:32]*sum2_reg[47:32];//shift 64
    end
    else begin
        mul1=0;
        mul2=0;
        mul3=0;
        mul4=0;
        mul5=0;
        mul6=0;
        mul7=0;
        mul8=0;
        mul9=0;
    end
end

always_comb begin : adder
    if(in_valid3)begin
        out_temp=(mul1_reg)+(mul2_reg<<16)+(mul3_reg<<32)+
                 (mul4_reg<<16)+(mul5_reg<<32)+(mul6_reg<<48)+
                 (mul7_reg<<32)+(mul8_reg<<48)+(mul9_reg<<64);
        out_valid_temp=1;
    end
    else begin
        out_temp=0;
        out_valid_temp=0;
    end
end

always_ff @( posedge clk, negedge rst_n ) begin :output1
    if(!rst_n)begin
        out<=0;
        out_valid<=0;
    end
    else begin
        out<=out_temp;
        out_valid<=out_valid_temp;
    end
end



endmodule