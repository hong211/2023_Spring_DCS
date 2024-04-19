module SS(
// input signals
    clk,
    rst_n,
    in_valid,
    matrix,
    matrix_size,
// output signals
    out_valid,
    out_value
);
//================================================================
//   INPUT AND OUTPUT DECLARATION                         
//================================================================
input               clk, rst_n, in_valid;
input        [15:0] matrix;
input               matrix_size;

output logic        out_valid;
output logic [39:0] out_value;

logic [15:0]matrix_comb[0:3][0:6];
logic matrix_size_comb;
logic [40:0]a_comb[0:3][0:2];
logic [40:0]a_ff[0:3][0:2];
logic [15:0]matrix_ff[0:3][0:6];
logic matrix_size_ff;
logic [15:0]matrix_temp;
logic in_valid_comb;
logic matrix_size_temp;
typedef enum logic[1:0] {IDLE ,COMPUTE , OUTPUT  } state;
logic target;
state curr, next;
logic out_valid_comb;
logic [40:0]out_value_comb;
logic [40:0]y_comb[0:9][0:3];
logic [40:0]y_ff[0:9][0:3];
logic [15:0]weight_ff[0:3][0:3];
logic [15:0]weight_comb[0:3][0:3];
logic [6:0]cnt,cnt_comb;
always_ff @( posedge clk , negedge rst_n ) begin
    if(!rst_n)begin
        curr<=IDLE;
        in_valid_comb<=0;
        matrix_size_temp<=0;
        matrix_temp<=0;
    end
    else begin
        curr<=next;
        in_valid_comb<=in_valid;
        matrix_size_temp<=matrix_size;
        matrix_temp<=matrix;
    end
end
always_ff @( posedge clk , negedge rst_n ) begin
    if(!rst_n)begin
        out_valid<=0;
        out_value<=0;
    end
    else begin
        out_valid<=out_valid_comb;
        out_value<=out_value_comb;
    end
end
always_ff @( posedge clk , negedge rst_n ) begin
    if(!rst_n)begin
        cnt<=0;
        for(int i=0;i<=9;i=i+1)begin
            for(int j=0;j<4;j=j+1)begin
                y_ff[i][j]<=0;
            end
        end
        for(int i=0;i<4;i=i+1)begin
            for(int j=0;j<4;j=j+1)begin
                weight_ff[i][j]<=0;
            end
        end
        for(int i=0;i<4;i=i+1)begin
            for(int j=0;j<3;j=j+1)begin
                a_ff[i][j]<=0;
            end
        end
        for(int i=0;i<4;i=i+1)begin
            for(int j=0;j<7;j=j+1)begin
                matrix_ff[i][j]<=0;
            end
        end
    end
    else begin
        cnt<=cnt_comb;
        matrix_size_ff<=matrix_size_comb;
        weight_ff<=weight_comb;
        matrix_ff<=matrix_comb;
        y_ff<=y_comb;
        a_ff<=a_comb;
    end
end
always_comb begin
    matrix_size_comb=matrix_size_ff;
    weight_comb=weight_ff;
    matrix_comb=matrix_ff;
    next=IDLE;
    cnt_comb=0;
    y_comb=y_ff;
    a_comb=a_ff;
    out_valid_comb=0;
    out_value_comb=0;
    case (curr)
        OUTPUT:begin
            cnt_comb=cnt+1;
            if(matrix_size_ff == 0&& cnt<3)begin
                out_valid_comb=1;
                out_value_comb=y_ff[4-cnt][0]+y_ff[4-cnt][1];
                next=OUTPUT;
            end
            else if(matrix_size_ff==1&& cnt<7)begin
                out_valid_comb=1;
                out_value_comb=y_ff[9-cnt][0]+y_ff[9-cnt][1]+y_ff[9-cnt][2]+y_ff[9-cnt][3];
                next=OUTPUT;
            end
            else begin
                next=IDLE;
                cnt_comb=0;
            end
        end
        IDLE:begin
            if(in_valid_comb)begin
                if(cnt==0)
                    matrix_size_comb=matrix_size_temp;
                cnt_comb=cnt+1;
                if(matrix_size_ff==0)begin
                    matrix_comb[0][2]=0;
                    matrix_comb[1][0]=0;
                    case(cnt)

                    0:weight_comb[0][0]=matrix_temp;
                    1:weight_comb[0][1]=matrix_temp;
                    2:weight_comb[1][0]=matrix_temp;
                    3:weight_comb[1][1]=matrix_temp;

                    4:matrix_comb[0][0]=matrix_temp;
                    5:matrix_comb[1][1]=matrix_temp;
                    6:matrix_comb[0][1]=matrix_temp;
                    7:matrix_comb[1][2]=matrix_temp;
                    default:begin
                        cnt_comb=0;
                        next=COMPUTE;
                    end
                    endcase
                   
                end
                else begin
                    matrix_comb[0][4]=0;
                    matrix_comb[0][5]=0;
                    matrix_comb[0][6]=0;
                    matrix_comb[1][0]=0;
                    matrix_comb[1][5]=0;
                    matrix_comb[1][6]=0;

                    matrix_comb[2][0]=0;
                    matrix_comb[2][1]=0;
                    matrix_comb[2][6]=0;

                    
                    matrix_comb[3][0]=0;
                    matrix_comb[3][1]=0;
                    matrix_comb[3][2]=0;
                    case(cnt)
                    16:matrix_comb[0][0]=matrix_temp;
                    17:matrix_comb[1][1]=matrix_temp;
                    18:matrix_comb[2][2]=matrix_temp;
                    19:matrix_comb[3][3]=matrix_temp;
                    20:matrix_comb[0][1]=matrix_temp;
                    21:matrix_comb[1][2]=matrix_temp;
                    22:matrix_comb[2][3]=matrix_temp;
                    23:matrix_comb[3][4]=matrix_temp;

                    24:matrix_comb[0][2]=matrix_temp;
                    25:matrix_comb[1][3]=matrix_temp;
                    26:matrix_comb[2][4]=matrix_temp;
                    27:matrix_comb[3][5]=matrix_temp;
                    28:matrix_comb[0][3]=matrix_temp;
                    29:matrix_comb[1][4]=matrix_temp;
                    30:matrix_comb[2][5]=matrix_temp;
                    31:matrix_comb[3][6]=matrix_temp;

                    0:weight_comb[0][0]=matrix_temp;
                    1:weight_comb[0][1]=matrix_temp;
                    2:weight_comb[0][2]=matrix_temp;
                    3:weight_comb[0][3]=matrix_temp;
                    4:weight_comb[1][0]=matrix_temp;
                    5:weight_comb[1][1]=matrix_temp;
                    6:weight_comb[1][2]=matrix_temp;
                    7:weight_comb[1][3]=matrix_temp;
                    8:weight_comb[2][0]=matrix_temp;
                    9:weight_comb[2][1]=matrix_temp;
                    10:weight_comb[2][2]=matrix_temp;
                    11:weight_comb[2][3]=matrix_temp;
                    12:weight_comb[3][0]=matrix_temp;
                    13:weight_comb[3][1]=matrix_temp;
                    14:weight_comb[3][2]=matrix_temp;
                    15:weight_comb[3][3]=matrix_temp;
                    default:begin
                        cnt_comb=0;
                        next=COMPUTE;
                    end
                    endcase
                end
                
            end
            else begin
                cnt_comb=0;
                if(cnt!=0)
                    next=COMPUTE;
            end
        end 
       
        COMPUTE:begin
            cnt_comb=cnt+1;
            next=COMPUTE;
            if(matrix_size_ff==0)begin
                a_comb[0][0]=matrix_ff[0][0];
                a_comb[1][0]=matrix_ff[1][0];

                y_comb[0][0]=matrix_ff[0][0]*weight_ff[0][0];
                y_comb[1][0]=matrix_ff[1][0]*weight_ff[1][0]+y_ff[0][0];
                y_comb[2][0]=y_ff[1][0];
                y_comb[3][0]=y_ff[2][0];
                y_comb[4][0]=y_ff[3][0];

                y_comb[0][1]=a_ff[0][0]*weight_ff[0][1];
                y_comb[1][1]=a_ff[1][0]*weight_ff[1][1]+y_ff[0][1];
                y_comb[2][1]=y_ff[1][1];
                y_comb[3][1]=y_ff[2][1];
                y_comb[4][1]=y_ff[3][1];

                matrix_comb[0][0]=matrix_ff[0][1]; 
                matrix_comb[0][1]=matrix_ff[0][2];
                matrix_comb[0][2]=0;
                matrix_comb[1][0]=matrix_ff[1][1]; 
                matrix_comb[1][1]=matrix_ff[1][2];
                matrix_comb[1][2]=0;
                if(cnt==4)begin
                    next=OUTPUT;
                    cnt_comb=0;
                end
            end
            else begin
                a_comb[0][0]=matrix_ff[0][0];
                a_comb[1][0]=matrix_ff[1][0];
                a_comb[2][0]=matrix_ff[2][0];
                a_comb[3][0]=matrix_ff[3][0];

                a_comb[0][1]=a_ff[0][0];
                a_comb[1][1]=a_ff[1][0];
                a_comb[2][1]=a_ff[2][0];
                a_comb[3][1]=a_ff[3][0];

                a_comb[0][2]=a_ff[0][1];
                a_comb[1][2]=a_ff[1][1];
                a_comb[2][2]=a_ff[2][1];
                a_comb[3][2]=a_ff[3][1];


                y_comb[0][0]=matrix_ff[0][0]*weight_ff[0][0];
                y_comb[1][0]=matrix_ff[1][0]*weight_ff[1][0]+y_ff[0][0];
                y_comb[2][0]=matrix_ff[2][0]*weight_ff[2][0]+y_ff[1][0];
                y_comb[3][0]=matrix_ff[3][0]*weight_ff[3][0]+y_ff[2][0];
                y_comb[4][0]=y_ff[3][0];
                y_comb[5][0]=y_ff[4][0];
                y_comb[6][0]=y_ff[5][0];
                y_comb[7][0]=y_ff[6][0];
                y_comb[8][0]=y_ff[7][0];
                y_comb[9][0]=y_ff[8][0];
               
                y_comb[0][1]=a_ff[0][0]*weight_ff[0][1];
                y_comb[1][1]=a_ff[1][0]*weight_ff[1][1]+y_ff[0][1];
                y_comb[2][1]=a_ff[2][0]*weight_ff[2][1]+y_ff[1][1];
                y_comb[3][1]=a_ff[3][0]*weight_ff[3][1]+y_ff[2][1];
                y_comb[4][1]=y_ff[3][1];
                y_comb[5][1]=y_ff[4][1];
                y_comb[6][1]=y_ff[5][1];
                y_comb[7][1]=y_ff[6][1];
                y_comb[8][1]=y_ff[7][1];
                y_comb[9][1]=y_ff[8][1];

                y_comb[0][2]=a_ff[0][1]*weight_ff[0][2];
                y_comb[1][2]=a_ff[1][1]*weight_ff[1][2]+y_ff[0][2];
                y_comb[2][2]=a_ff[2][1]*weight_ff[2][2]+y_ff[1][2];
                y_comb[3][2]=a_ff[3][1]*weight_ff[3][2]+y_ff[2][2];
                y_comb[4][2]=y_ff[3][2];
                y_comb[5][2]=y_ff[4][2];
                y_comb[6][2]=y_ff[5][2];
                y_comb[7][2]=y_ff[6][2];
                y_comb[8][2]=y_ff[7][2];
                y_comb[9][2]=y_ff[8][2];

                y_comb[0][3]=a_ff[0][2]*weight_ff[0][3];
                y_comb[1][3]=a_ff[1][2]*weight_ff[1][3]+y_ff[0][3];
                y_comb[2][3]=a_ff[2][2]*weight_ff[2][3]+y_ff[1][3];
                y_comb[3][3]=a_ff[3][2]*weight_ff[3][3]+y_ff[2][3];
                y_comb[4][3]=y_ff[3][3];
                y_comb[5][3]=y_ff[4][3];
                y_comb[6][3]=y_ff[5][3];
                y_comb[7][3]=y_ff[6][3];
                y_comb[8][3]=y_ff[7][3];
                y_comb[9][3]=y_ff[8][3];

                matrix_comb[0][0]=matrix_ff[0][1]; 
                matrix_comb[0][1]=matrix_ff[0][2];
                matrix_comb[0][2]=matrix_ff[0][3];
                matrix_comb[0][3]=matrix_ff[0][4];
                matrix_comb[0][4]=matrix_ff[0][5];
                matrix_comb[0][5]=matrix_ff[0][6];
                matrix_comb[0][6]=0;


                matrix_comb[1][0]=matrix_ff[1][1]; 
                matrix_comb[1][1]=matrix_ff[1][2];
                matrix_comb[1][2]=matrix_ff[1][3];
                matrix_comb[1][3]=matrix_ff[1][4];
                matrix_comb[1][4]=matrix_ff[1][5];
                matrix_comb[1][5]=matrix_ff[1][6];
                matrix_comb[1][6]=0;

                matrix_comb[2][0]=matrix_ff[2][1]; 
                matrix_comb[2][1]=matrix_ff[2][2];
                matrix_comb[2][2]=matrix_ff[2][3];
                matrix_comb[2][3]=matrix_ff[2][4];
                matrix_comb[2][4]=matrix_ff[2][5];
                matrix_comb[2][5]=matrix_ff[2][6];
                matrix_comb[2][6]=0;

                matrix_comb[3][0]=matrix_ff[3][1]; 
                matrix_comb[3][1]=matrix_ff[3][2];
                matrix_comb[3][2]=matrix_ff[3][3];
                matrix_comb[3][3]=matrix_ff[3][4];
                matrix_comb[3][4]=matrix_ff[3][5];
                matrix_comb[3][5]=matrix_ff[3][6];
                matrix_comb[3][6]=0;
                if(cnt==9)begin
                    next=OUTPUT;
                    cnt_comb=0;
                end
            end
        end
        
        
    endcase
end

endmodule