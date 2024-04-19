module inter(
  // Input signals
  clk,
  rst_n,
  in_valid_1,
  in_valid_2,
  data_in_1,
  data_in_2,
  ready_slave1,
  ready_slave2,
  // Output signals
  valid_slave1,
  valid_slave2,
  addr_out,
  value_out,
  handshake_slave1,
  handshake_slave2
);

//---------------------------------------------------------------------
//   PORT DECLARATION
//---------------------------------------------------------------------
input clk, rst_n, in_valid_1, in_valid_2;
input [6:0] data_in_1, data_in_2; 
input ready_slave1, ready_slave2;

output logic valid_slave1, valid_slave2;
output logic [2:0] addr_out, value_out;
output logic handshake_slave1, handshake_slave2;
parameter S_idle = 'd0;
parameter S_master1 = 'd1;
parameter S_master2 = 'd2;
parameter S_handshake = 'd3;
logic [1:0]curr, next;
logic temp,temp_out,head,head_temp;
logic [2:0]addr_out_temp,value_out_temp;
logic [2:0]now,now_temp;
logic [6:0]x,xtemp;
always_ff @( posedge clk , negedge rst_n) begin
    if(!rst_n)begin
        curr <=S_idle;
        temp_out<=0;
        addr_out<=0;
        value_out<=0;
        head<=0;
        now<=0;
        x<=0;
    end
    else begin
        curr <=next;
        temp_out<=temp;
        addr_out<=addr_out_temp;
        value_out<=value_out_temp;
        head<=head_temp;
        now<=now_temp;
        x<=xtemp;
    end
end

always_comb begin
    next=S_idle;
    valid_slave1=0;
    valid_slave2=0;
    handshake_slave1=0;
    handshake_slave2=0;
    addr_out_temp=0;
    value_out_temp=0;
    head_temp=0;
    temp=0;
    now_temp=0;
    xtemp=0;
    case (curr)
        S_idle:begin
        now_temp={in_valid_1,in_valid_2};
        if(in_valid_1&&in_valid_2)
          xtemp=data_in_2;
        if(in_valid_1)begin
          next=S_master1;
          addr_out_temp=data_in_1[5:3];
          value_out_temp=data_in_1[2:0];
          head_temp=data_in_1[6];
        end
        else if(in_valid_2)begin
          next=S_master2;
          addr_out_temp=data_in_2[5:3];
          value_out_temp=data_in_2[2:0];
          head_temp=data_in_2[6];
        end
        end
        S_master1:begin
          now_temp=now;
          addr_out_temp=addr_out;
          value_out_temp=value_out;
          head_temp=head;
          next=S_master1;
          xtemp=x;
          if(head==0)
            valid_slave1=1;
          else
            valid_slave2=1;

          if(head ==0  && ready_slave1== 1)begin
            next=S_handshake;
            temp=0;
          end
          else if(head  && ready_slave2== 1)begin
            next=S_handshake;
            temp=1;
          end
        end
        S_master2:begin
          now_temp=now;
          addr_out_temp=addr_out;
          value_out_temp=value_out;
          head_temp=head;
          next=S_master2;

          if(head==0)
            valid_slave1=1;
          else
            valid_slave2=1;
          if(head ==0  && ready_slave1== 1)begin
            next=S_handshake;
            temp=0;
          end
          else if(head  && ready_slave2== 1)begin
            next=S_handshake;
            temp=1;
          end
        end
        S_handshake: begin
          if(!temp_out)
            handshake_slave1=1;
          else
            handshake_slave2=1;

          if(now==2'b11)begin
            next=S_master1;
            addr_out_temp=x[5:3];
            value_out_temp=x[2:0];
            head_temp=x[6];
          end
          else begin
            next=S_idle;
          end
          /*else if(in_valid_2)begin
            next=S_master2;
            addr_out_temp=data_in_2[5:3];
            value_out_temp=data_in_2[2:0];
            head_temp=data_in_2[6];
          end*/
        end 
    endcase
end
endmodule
