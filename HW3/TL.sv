module TL(
  clk,
  rst_n,
  in_valid,
  car_main_s,
  car_main_lt,
  car_side_s,
  car_side_lt,
  out_valid,
  light_main,
  light_side
);
input clk, rst_n, in_valid;
input [2:0] car_main_s, car_main_lt, car_side_s, car_side_lt; 
output logic out_valid;
output logic [1:0]light_main, light_side;

logic[2:0] mstemp,mltemp,sstemp,sltemp,ms,ml,ss,sl;
logic [3:0]target;
logic [3:0]cnt,cntt;
typedef enum logic[3:0] {IDLE  ,MS , RY1 , ML , 
                          RY2, SS, RY3 , SL ,RY4  ,
                          RY5 , def} state;
state curr,next;
/*parameter IDLE = 4'b0000 ,MS=4'b0001 , RY1=4'b0010 , ML=4'b0011 , 
          RY2=4'b0101, SS=4'b0110, RY3=4'b0111 , SL=4'b1000 ,RY4 =4'b1001 ,
          RY5 =4'b0100, def=4'b1010 ;
logic [3:0]curr,next;*/
always_ff @( posedge clk,negedge rst_n ) begin
  if(!rst_n)begin
    curr<=IDLE;
    mstemp<=0;
    mltemp<=0;
    sstemp<=0;
    sltemp<=0;
    cntt<=0;
  end
  else begin
    curr<=next;
    mstemp<=ms;
    mltemp<=ml;
    sstemp<=ss;
    sltemp<=sl;
    cntt<=cnt;
  end
end

always_comb begin
  ms=mstemp;
  ml=mltemp;
  ss=sstemp;
  sl=sltemp;
  next=IDLE;
  cnt=0;
  out_valid=0;
  light_main=2;
  light_side=0;
  target=0;
  case (curr)
    IDLE:begin
      if(in_valid)begin
        ms=car_main_s;
        ml=car_main_lt;
        ss=car_side_s;
        sl=car_side_lt;
        cnt=cntt+1;
      end
      if(cntt==1)begin
        next=(ms==0&&ml==0&&ss==0&&sl==0)?def:MS;
        cnt=0;
      end
    end
    MS:begin
      if(ms>4)begin
        target=7;
      end
      else 
        target=3; 
      out_valid=1;
      cnt=cntt+1;
      if(cntt!=target)
        next=MS;
      else begin
        cnt=0;
        if(ml!=0)
          next=RY1;
        else if(ss!=0||sl!=0)
          next=RY2;
        else 
          next=def; 
      end
    end
    RY1:begin
      out_valid=1;
      cnt=cntt+1;

      light_main=cntt==0?1:0;
      if(cntt!=2)
        next=RY1;
      else begin  
        next=ML;
        cnt=0;
      end
    end
    ML:begin
      if(ml>6)begin
        target=8;
      end
      else begin
        if(ml<=3)
          target=2;
        else
          target=5;
      end

      
      
      out_valid=1;
      light_main=3;
      cnt=cntt+1;
      if(cntt!=target)
        next=ML;
      else begin
        cnt=0;
        if(ss==0&&sl==0)
          next=RY5;
        else
          next=RY2;
      end
    end
    RY5:begin
      out_valid=1;
      light_side=0;
      cnt=cntt+1;
      if(cntt==0)begin
        light_main=1;
      end
      else 
        light_main=0;

      if(cntt!=2)
        next=RY5;
      else begin  
        next=def;
        cnt=0;
      end
    end
    RY2:begin
      out_valid=1;
      light_side=0;
      cnt=cntt+1;
      if(cntt==0)begin
        light_main=1;
      end
      else 
        light_main=0;

      if(cntt!=1)
        next=RY2;
      else begin
        cnt=0;
        if(ss!=0)
          next=SS;
        else if(sl!=0)
          next=SL;
        else
          next=def;
        
      end
    end
    SS:begin
      if(ss>6)begin
        target=8;
      end
      else if(ss<=3)begin
        target=2;
      end
      else begin
        target=5;
      end
      out_valid=1;
      light_main=0;
      light_side=2;
      cnt=cntt+1;
      if(cntt!=target)
        next=SS;
      else begin
        cnt=0;
        if(sl!=0)
          next=RY3;
        else 
          next=RY4; 
      end
    end
    RY3:begin
      out_valid=1;
      light_main=0;
      cnt=cntt+1;
      if(cntt==0)begin
        light_side=1;
      end
      else 
        light_side=0;

      if(cntt!=2)
        next=RY3;
      else begin
        next=SL;
        cnt=0;
      end
    end
    SL:begin
      if(sl>6)begin
        target=7;
      end
      else if(sl<=2)begin
        target=1;
      end
      else if(sl>2&&sl<=4)begin
        target=3;
      end
      else  
        target=5;

      out_valid=1;
      light_side=3;
      light_main=0;
      cnt=cntt+1;
      if(cntt!=target)
        next=SL;
      else begin
        cnt=0;
        next=RY4;
      end
    end
    RY4:begin
      out_valid=1;
      light_main=0;
      cnt=cntt+1;
      if(cntt==0)begin
        light_side=1;
      end
      else 
        light_side=0;

      if(cntt!=2)
        next=RY4;
      else begin
        next=def;
        cnt=0;
      end
    end
    def:begin
      out_valid=1;
    end
  endcase
end

endmodule
