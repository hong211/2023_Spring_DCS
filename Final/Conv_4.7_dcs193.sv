module Conv(
	// Input signals
	clk,
	rst_n,
	filter_valid,
	image_valid,
	filter_size,
	image_size,
	pad_mode,
	act_mode,
	in_data,
	// Output signals
	out_valid,
	out_data
);
input clk, rst_n, image_valid, filter_valid, filter_size, pad_mode, act_mode;
input [3:0] image_size;
input signed [7:0] in_data;
output logic out_valid;
output logic signed [15:0] out_data;

logic [2:0]cnt_y_comb,cnt_y_reg,cnt_x_comb,cnt_x_reg;
logic filter_size_comb,filter_size_reg,pad_mode_comb,pad_mode_reg,act_mode_comb,act_mode_reg;
logic [2:0]image_size_comb,image_size_reg;
logic signed [7:0]filter_comb[0:4][0:4],filter_reg[0:4][0:4];
logic signed [7:0] image_comb[0:6][0:11],image_reg[0:6][0:11];

logic [2:0]filter;
logic signed [15:0] out_data_comb;
logic compute_valid_comb,compute_valid_reg;
logic [3:0]row_comb,row_reg;

logic signed [15:0] store_comb[0:4][0:4],store_reg[0:4][0:4];
logic [2:0]cnt_xx_comb,cnt_xx_reg;
logic signed [20:0] conv_comb,conv_reg;
logic signed [20:0] fil_comb,fil_reg;
logic valid2,valid3,valid4;

assign filter=(filter_size_reg)?4:2;
always_ff @( posedge clk, negedge rst_n ) begin
	if(!rst_n)begin
		filter_size_reg<=0;
		pad_mode_reg<=0;
		act_mode_reg<=0;
		image_size_reg<=0;
		for(int i=0;i<5;i++)begin
			for(int j=0;j<5;j++)begin
				filter_reg[i][j]<=0;
			end
		end
		for(int i=0;i<7;i++)begin
			for(int j=0;j<12;j++)begin
				image_reg[i][j]<=0;
			end
		end
		for(int i=0;i<5;i++)begin
			for(int j=0;j<5;j++)begin
				store_reg[i][j]<=0;
			end
		end
	end
	else begin
		filter_size_reg<=filter_size_comb;
		pad_mode_reg<=pad_mode_comb;
		act_mode_reg<=act_mode_comb;
		image_size_reg<=image_size_comb;
		filter_reg<=filter_comb;
		image_reg<=image_comb;
		store_reg<=store_comb;
	end
end
always_ff @( posedge clk, negedge rst_n ) begin
	if(!rst_n)begin
		cnt_x_reg<=0;
		cnt_y_reg<=0;
		cnt_xx_reg<=0;
		compute_valid_reg<=0;
		fil_reg<=0;
		conv_reg<=0;
		row_reg<=0;
	end
	else begin
		cnt_x_reg<=cnt_x_comb;
		cnt_y_reg<=cnt_y_comb;
		cnt_xx_reg<=cnt_xx_comb;
		compute_valid_reg<=compute_valid_comb;
		fil_reg<=fil_comb;
		conv_reg<=conv_comb;
		row_reg<=row_comb;
	end
end

always_ff @( posedge clk, negedge rst_n ) begin
	if(!rst_n)begin
		valid2<=0;
		valid3<=0;
		valid4<=0;
	end
	else begin
		valid2<=compute_valid_reg;
		valid3<=valid2;
		valid4<=valid3;
	end
end
assign out_valid=valid4;
always_comb begin
	if(!valid4)begin
		out_data=0;
	end
	else if(fil_reg>32767)begin
		out_data=32767;
	end
	else if(fil_reg<-32768)begin
		out_data=-32768;
	end
	else begin
		out_data=fil_reg;
	end

	if(valid2)begin
		conv_comb=store_reg[0][0]+store_reg[0][1]+store_reg[0][2]+store_reg[0][3]+store_reg[0][4]+
				store_reg[1][0]+store_reg[1][1]+store_reg[1][2]+store_reg[1][3]+store_reg[1][4]+
				store_reg[2][0]+store_reg[2][1]+store_reg[2][2]+store_reg[2][3]+store_reg[2][4]+
				store_reg[3][0]+store_reg[3][1]+store_reg[3][2]+store_reg[3][3]+store_reg[3][4]+
				store_reg[4][0]+store_reg[4][1]+store_reg[4][2]+store_reg[4][3]+store_reg[4][4];
	end
	else begin
		conv_comb=0;
	end
	if(conv_reg>0)begin
		fil_comb=conv_reg;
	end
	else begin
		fil_comb=(act_mode_reg==0)?0:(conv_reg/10);
		
	end
	
end

always_comb begin
	cnt_x_comb=0;
	cnt_y_comb=0;
	cnt_xx_comb=0;
	filter_size_comb=filter_size_reg;
	image_size_comb=image_size_reg;
	image_comb=image_reg;
	pad_mode_comb=pad_mode_reg;
	act_mode_comb=act_mode_reg;
	filter_comb=filter_reg;
	compute_valid_comb=compute_valid_reg;
	store_comb=store_reg;
	row_comb=row_reg;
	
	if(cnt_xx_reg==image_size_reg && cnt_xx_reg>0)begin
		for(int i=1;i<7;i++)begin
			for(int j=0;j<12;j++)begin
				image_comb[i-1][j]=image_reg[i][j];
			end
		end
		row_comb=row_reg+1;
	end
	if(filter_valid && cnt_x_reg==0 && cnt_y_reg==0 )begin
		for(int i=0;i<5;i++)begin
			for(int j=0;j<5;j++)begin
				filter_comb[i][j]=0;
			end
		end
		filter_size_comb=filter_size;
		image_size_comb=image_size-1;
		pad_mode_comb=pad_mode;
		act_mode_comb=act_mode;
		filter_comb[0][0]=in_data;
		cnt_x_comb=1;
	end
	else if(filter_valid)begin
		if(cnt_x_reg < filter)begin
			cnt_x_comb=cnt_x_reg+1;
		end
		else begin
			cnt_x_comb=0;
		end

		if(cnt_x_reg < filter)begin
			cnt_y_comb=cnt_y_reg;
		end
		else if(cnt_x_reg == filter && cnt_y_reg!= filter)begin
			cnt_y_comb=cnt_y_reg+1;
		end
		else begin
			cnt_y_comb=0;
		end
		filter_comb[cnt_y_reg][cnt_x_reg]=in_data;
	end
	else if(image_valid)begin
		if(cnt_x_reg==0 && cnt_y_reg==0)begin
			for(int i=0;i<7;i++)begin
				for(int j=0;j<12;j++)begin
					image_comb[i][j]=0;
				end
			end
			for(int i=0;i<5;i++)begin
				for(int j=0;j<5;j++)begin
					store_comb[i][j]=0;
				end
			end
		end
	
		cnt_x_comb=(cnt_x_reg < image_size_reg)?cnt_x_reg+1:0;
		cnt_y_comb=(cnt_x_reg < image_size_reg)?cnt_y_reg:cnt_y_reg+1;
		if(!filter_size_reg)begin
			image_comb[cnt_y_reg-row_comb+1][cnt_x_reg+1]=in_data;
			if(cnt_x_reg==1 &&cnt_y_reg==1)begin
				compute_valid_comb=1;
			end
			
			if(pad_mode_reg)begin
				if(cnt_x_reg==0 && cnt_y_reg==0)begin
					image_comb[0][0]=in_data;
				end 
				else if(cnt_x_reg==0 && cnt_y_reg==image_size_reg)begin
					image_comb[image_size_reg-row_comb+2][0]=in_data;

				end 
				else if(cnt_x_reg==image_size_reg && cnt_y_reg==0)begin
					case (image_size_reg)
						2:image_comb[0][4]=in_data;
						3:image_comb[0][5]=in_data;
						4:image_comb[0][6]=in_data;
						5:image_comb[0][7]=in_data;
						6:image_comb[0][8]=in_data;
						7:image_comb[0][9]=in_data;
					endcase
				end 
				else if(cnt_x_reg==image_size_reg && cnt_y_reg==image_size_reg)begin
					image_comb[image_size_reg-row_comb+2][image_size_reg+2]=in_data;
	
				end 

				if(cnt_x_reg==0)begin
					image_comb[cnt_y_reg+1-row_comb][0]=in_data;
				end
				if(cnt_y_reg==0)begin
					image_comb[0][cnt_x_reg+1]=in_data;
				end
				if(cnt_x_reg==image_size_reg)begin
					image_comb[cnt_y_reg+1-row_comb][image_size_reg+2]=in_data;
				end
				if(cnt_y_reg==image_size_reg)begin
					image_comb[image_size_reg-row_comb+2][cnt_x_reg+1]=in_data;
				end
				
			end
		end
		else begin
			image_comb[cnt_y_reg+2-row_comb][cnt_x_reg+2]=in_data;
			if(cnt_x_reg==2&&cnt_y_reg==2)begin
				compute_valid_comb=1;
			end
			
			if(pad_mode_reg)begin
				if(cnt_x_reg==0 && cnt_y_reg==0)begin
					image_comb[0][0]=in_data;
					image_comb[0][1]=in_data;
					image_comb[1][0]=in_data;
					image_comb[1][1]=in_data;
				end 
				else if(cnt_x_reg==0 && cnt_y_reg==image_size_reg)begin
					 image_comb[image_size_reg-row_comb+3][0]=in_data;
					 image_comb[image_size_reg-row_comb+3][1]=in_data;
					 image_comb[image_size_reg-row_comb+4][0]=in_data;
					 image_comb[image_size_reg-row_comb+4][1]=in_data;

				end 
				else if(cnt_x_reg==image_size_reg && cnt_y_reg==0)begin

					case (image_size_reg)
						2:begin
							image_comb[0][5]=in_data;
							image_comb[1][5]=in_data;
							image_comb[0][6]=in_data;
							image_comb[1][6]=in_data;
						end
						3:begin
							image_comb[0][6]=in_data;
							image_comb[1][6]=in_data;
							image_comb[0][7]=in_data;
							image_comb[1][7]=in_data;
						end
						4:begin
							image_comb[0][7]=in_data;
							image_comb[1][7]=in_data;
							image_comb[0][8]=in_data;
							image_comb[1][8]=in_data;
						end
						5:begin
							image_comb[0][8]=in_data;
							image_comb[1][8]=in_data;
							image_comb[0][9]=in_data;
							image_comb[1][9]=in_data;
						end
						6:begin
							image_comb[0][9]=in_data;
							image_comb[1][9]=in_data;
							image_comb[0][10]=in_data;
							image_comb[1][10]=in_data;
						end
						7:begin
							image_comb[0][10]=in_data;
							image_comb[1][10]=in_data;
							image_comb[0][11]=in_data;
							image_comb[1][11]=in_data;
						end
					endcase
					
				end 
				else if(cnt_x_reg==image_size_reg && cnt_y_reg==image_size_reg)begin
					image_comb[image_size_reg-row_comb+3][image_size_reg+3]=in_data;
					image_comb[image_size_reg-row_comb+3][image_size_reg+4]=in_data;
					image_comb[image_size_reg-row_comb+4][image_size_reg+3]=in_data;
					image_comb[image_size_reg-row_comb+4][image_size_reg+4]=in_data;
				end 

				if(cnt_x_reg==0)begin
					image_comb[cnt_y_reg+2-row_comb][0]=in_data;
					image_comb[cnt_y_reg+2-row_comb][1]=in_data;
				end
				if(cnt_y_reg==0)begin
					image_comb[0][cnt_x_reg+2]=in_data;
					image_comb[1][cnt_x_reg+2]=in_data;
				end
				if(cnt_x_reg==image_size_reg)begin
					image_comb[cnt_y_reg+2-row_comb][image_size_reg+3]=in_data;
					image_comb[cnt_y_reg+2-row_comb][image_size_reg+4]=in_data;
				end
				if(cnt_y_reg==image_size_reg)begin
					image_comb[image_size_reg-row_comb+3][cnt_x_reg+2]=in_data;
					image_comb[image_size_reg-row_comb+4][cnt_x_reg+2]=in_data;
				end
			end
		end
	end
	
	if(compute_valid_reg)begin
		cnt_xx_comb=(cnt_xx_reg < image_size_reg)?cnt_xx_reg+1:0;
		
			if(row_reg ==image_size_reg && cnt_xx_reg == image_size_reg)begin
				compute_valid_comb=0;
				row_comb=0;
			end
			
			store_comb[0][0]=image_reg[0][cnt_xx_reg]*filter_reg[0][0];
			store_comb[0][1]=image_reg[0][1+cnt_xx_reg]*filter_reg[0][1];
			store_comb[0][2]=image_reg[0][2+cnt_xx_reg]*filter_reg[0][2];
			store_comb[0][3]=image_reg[0][3+cnt_xx_reg]*filter_reg[0][3];
			store_comb[0][4]=image_reg[0][4+cnt_xx_reg]*filter_reg[0][4];
			store_comb[1][0]=image_reg[1][cnt_xx_reg]*filter_reg[1][0];
			store_comb[1][1]=image_reg[1][1+cnt_xx_reg]*filter_reg[1][1];
			store_comb[1][2]=image_reg[1][2+cnt_xx_reg]*filter_reg[1][2];
			store_comb[1][3]=image_reg[1][3+cnt_xx_reg]*filter_reg[1][3];
			store_comb[1][4]=image_reg[1][4+cnt_xx_reg]*filter_reg[1][4];
			store_comb[2][0]=image_reg[2][cnt_xx_reg]*filter_reg[2][0];
			store_comb[2][1]=image_reg[2][1+cnt_xx_reg]*filter_reg[2][1];
			store_comb[2][2]=image_reg[2][2+cnt_xx_reg]*filter_reg[2][2];
			store_comb[2][3]=image_reg[2][3+cnt_xx_reg]*filter_reg[2][3];
			store_comb[2][4]=image_reg[2][4+cnt_xx_reg]*filter_reg[2][4];
			store_comb[3][0]=image_reg[3][cnt_xx_reg]*filter_reg[3][0];
			store_comb[3][1]=image_reg[3][1+cnt_xx_reg]*filter_reg[3][1];
			store_comb[3][2]=image_reg[3][2+cnt_xx_reg]*filter_reg[3][2];
			store_comb[3][3]=image_reg[3][3+cnt_xx_reg]*filter_reg[3][3];
			store_comb[3][4]=image_reg[3][4+cnt_xx_reg]*filter_reg[3][4];
			store_comb[4][0]=image_reg[4][cnt_xx_reg]*filter_reg[4][0];
			store_comb[4][1]=image_reg[4][1+cnt_xx_reg]*filter_reg[4][1];
			store_comb[4][2]=image_reg[4][2+cnt_xx_reg]*filter_reg[4][2];
			store_comb[4][3]=image_reg[4][3+cnt_xx_reg]*filter_reg[4][3];
			store_comb[4][4]=image_reg[4][4+cnt_xx_reg]*filter_reg[4][4];
	end
end
endmodule
