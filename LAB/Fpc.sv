module Fpc(
// input signals
clk,
rst_n,
in_valid,
in_a,
in_b,
mode,
// output signals
out_valid,
out
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk, rst_n, in_valid, mode;
input [15:0] in_a, in_b;
output logic out_valid;
output logic [15:0] out;

logic out_valid_temp;
logic [15:0]out_temp3 ;
logic [15:0] a,b,a_reg,b_reg;
logic [7:0] ax,bx;

logic  [8:0]ay,by;
logic  [9:0]sum , sum_temp;

logic [15:0]mux,mux_temp;
logic [5:0]shift;
logic signed[7:0]shift_mux,shift_sum;
logic [15:0]out_temp;
//---------------------------------------------------------------------
//   Your design                       
//---------------------------------------------------------------------
typedef enum logic[1:0] {IDLE , ADDIT , MUX ,OUT  } state;
state curr,next;

always_ff @( posedge clk,negedge rst_n ) begin 
    if(!rst_n)begin
        curr<=IDLE;
        a<=0;
        b<=0;
        out_valid<=0;
        out<=0;
    end
    else begin
        curr<=next;
        a<=a_reg;
        b<=b_reg;
        out_valid<=out_valid_temp;
        out<=out_temp3;
    end
end

always_comb begin

    out_valid_temp=0;
    out_temp3=0;
    shift_mux=0;
    ax=0;
    bx=0;
    ay=0;
    by=0;
    sum=0;
    sum_temp=0;
    mux=0;
    
    
    next=IDLE;
    shift_sum=0;
    case (curr)
        IDLE:begin
            if(in_valid)begin
                if(mode==1)
                next=MUX;
                else
                next=ADDIT;
                if(in_a[14:0]>in_b[14:0] )begin
                    a_reg=in_a;
                    b_reg=in_b;
                end
                else begin
                    a_reg=in_b;
                    b_reg=in_a;
                end
            end
            else begin
                a_reg=0;
                b_reg=0;
            end
            // if(in_a[14:0]>in_b[14:0] )begin
            //     a_reg=in_a;
            //     b_reg=in_b;
            // end
            // else begin
            //     a_reg=in_b;
            //     b_reg=in_a;
            // end
            
        end
        ADDIT:begin
            a_reg=a;
            b_reg=b;
            ax={1'b1,a[6:0]};
            shift=(a[14:7]-b[14:7]);
            bx=(({1'b1,b[6:0]})>>shift);
            if(a[15]==1)begin
                ay={1'b1,~ax+1};
            end
            else begin
                ay={1'b0,ax};
            end
            if(b[15]==1)begin
                by={1'b1,~bx+1};
            end
            else begin
                by={1'b0,bx};
            end
            sum=ay+by;
            
           
            if(a[15]==1)begin
                sum_temp={1'b0,(~sum+1)};
                
            end
            else begin
                sum_temp={sum[8],sum};
                
            end

             casez(sum_temp[8:0])
                9'b000000000:shift_sum=-8;
                9'b1????????:shift_sum=1;
                9'b01???????:shift_sum=0;
                9'b001??????:shift_sum=-1;
                9'b0001?????:shift_sum=-2;
                9'b00001????:shift_sum=-3;
                9'b000001???:shift_sum=-4;
                9'b0000001??:shift_sum=-5;
                9'b00000001?:shift_sum=-6;
                9'b000000001:shift_sum=-7;
                default:shift_sum=4'hx;
            endcase 
            if(shift_sum>=0)begin
                out_temp3[6:0]=(sum_temp[7:0])>>shift_sum;
            end
            else begin
                out_temp3[6:0]=(sum_temp[7:0])<<(-shift_sum);
            end
            out_temp3[14:7]=a[14:7]+shift_sum;
            out_temp3[15]=a[15];
           
            //out_temp3=out_temp;
            out_valid_temp=1;
            next=OUT;
        end
        MUX:begin
            ax={1'b1,a[6:0]};
            bx={1'b1,b[6:0]};
            a_reg=a;
            b_reg=b;
            
            mux=ax*bx;
            
            
           casez(mux[15:0])
        
                16'b1???????????????:begin shift_mux=1;out_temp3[6:0]=mux[14:8];end
                16'b01??????????????:begin shift_mux=0;out_temp3[6:0]=mux[13:7];end
                16'b001?????????????:begin shift_mux=-1;out_temp3[6:0]=mux[12:6];end
                16'b0001????????????:begin shift_mux=-2;out_temp3[6:0]=mux[11:5];end
                16'b00001???????????:out_temp3[6:0]=mux[10:4];
                16'b000001??????????:out_temp3[6:0]=mux[9:3];
                16'b0000001?????????:out_temp3[6:0]=mux[8:2];
                16'b00000001????????:out_temp3[6:0]=mux[7:1];
                16'b000000001???????:out_temp3[6:0]=mux[6:0];
                16'b0000000001??????:out_temp3[6:0]={mux[5:0],1'b0};
                16'b00000000001?????:out_temp3[6:0]={mux[4:0],2'b0};
                16'b000000000001????:out_temp3[6:0]={mux[3:0],3'b0};
                16'b0000000000001???:out_temp3[6:0]={mux[2:0],4'b0};
                16'b00000000000001??:out_temp3[6:0]={mux[1:0],5'b0};
                16'b000000000000001?:out_temp3[6:0]={mux[0],6'b0};
                16'b0000000000000001:out_temp3[6:0]=0 ;
                default:out_temp3=0;
            endcase
            out_temp3[15]=((~a[15]&&b[15])||(a[15]&&~b[15]));
            out_temp3[14:7]=a[14:7]+b[14:7]-127+shift_mux;
            /*if(shift_mux>=0)begin
                out_temp[6:0]={mux_temp[14],mux_temp[13:8]>>shift_mux};
            end
            else begin
                out_temp[6:0]={mux_temp[14],mux_temp[13:8]<<(-shift_mux)};
            end*/
            //out_temp3=out_temp;
            out_valid_temp=1;
            next=IDLE;
        end
    // OUT:begin
    //     a_reg=0;
    //     b_reg=0;
    //     out_temp3=0;
    //     out_valid_temp=0;

    //     next=IDLE;
    // end
    default:begin
        a_reg=0;
        b_reg=0;
    end
    endcase
end/*
always_comb begin 
    casez(mux[15:8])
        8'b00000000:shift_mux=-7;
        8'b1???????:shift_mux=1;
        8'b01??????:shift_mux=0;
        8'b001?????:shift_mux=-1;
        8'b0001????:shift_mux=-2;
        8'b00001???:shift_mux=-3;
        8'b000001??:shift_mux=-4;
        8'b0000001?:shift_mux=-5;
        8'b00000001:shift_mux=-6;
        default:shift_mux=4'hx;
    endcase 
end*/
/*always_comb begin 
    casez(sum_temp[8:0])
        9'b000000000:shift_sum=-8;
        9'b1????????:shift_sum=1;
        9'b01???????:shift_sum=0;
        9'b001??????:shift_sum=-1;
        9'b0001?????:shift_sum=-2;
        9'b00001????:shift_sum=-3;
        9'b000001???:shift_sum=-4;
        9'b0000001??:shift_sum=-5;
        9'b00000001?:shift_sum=-6;
        9'b000000001:shift_sum=-7;
        default:shift_sum=4'hx;
    endcase 
end*/

endmodule