module I2S(
  // Input signals
  clk,
  rst_n,
  in_valid,
  SD,
  WS,
  // Output signals
  out_valid,
  out_left,
  out_right
);

//---------------------------------------------------------------------
//   PORT DECLARATION
//---------------------------------------------------------------------
input clk, rst_n, in_valid;
input SD, WS;

output logic        out_valid;
output logic [31:0] out_left, out_right;

parameter  idle = 2'b00 , read=2'b01 ,print=2'b10;
logic temp_ws , temp_out;
logic [31:0] temp_ ,temp_shift ;
logic [2:0] next , curr;
logic SDnow;
logic out;
always_ff @( posedge clk, negedge rst_n ) begin 
  if(!rst_n) begin
    curr <=idle;
    temp_shift<=0; 
    SDnow<=0;
    temp_ws<=0;
    temp_out<=0;
  end
  else begin
    curr<=next;
    temp_shift<=temp_;
    SDnow <= SD;
    temp_ws<=WS;
    temp_out<=out;
  end
end

always_comb begin
  out_valid=0;
  out_left=0;
  out_right=0;
  out=0;
  temp_=0;
  next = 2'b00;
  case(curr)
    print:begin
      temp_[0]=SDnow;
      out_valid=1;
      if(!temp_out)
        out_left=temp_shift;
      else if(temp_out)
        out_right=temp_shift;

      if(in_valid)
        next=read;
    end
    idle :begin
      temp_[0]=SDnow;
      if(in_valid)
        next=read;
    end
    read:begin
      temp_=temp_shift<<1;
      temp_[0]=SDnow;
      next=read;
      if(!in_valid||temp_ws!=WS)begin
        next=print; 
        out=temp_ws;
      end
    end
    
  endcase
end
endmodule
