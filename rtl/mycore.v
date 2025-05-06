module mycore
(
	input         clk,
	input         reset,
	
	input         pal,
	input         scandouble,

	output reg    ce_pix,

	output reg    HBlank,
	output reg    HSync,
	output reg    VBlank,
	output reg    VSync,

	output  [7:0] r,
	output  [7:0] g,
	output  [7:0] b
);

reg   [9:0] hc;
reg   [9:0] vc;
reg   [9:0] vvc;

always @(posedge clk) begin
	if(scandouble) ce_pix <= 1;
		else ce_pix <= ~ce_pix;

	if(reset) begin
		hc <= 0;
		vc <= 0;
	end
	else if(ce_pix) begin
		if(hc == 637) begin
			hc <= 0;
			if(vc == (pal ? (scandouble ? 623 : 311) : (scandouble ? 523 : 261))) begin 
				vc <= 0;
				vvc <= vvc + 9'd6;
			end else begin
				vc <= vc + 1'd1;
			end
		end else begin
			hc <= hc + 1'd1;
		end
	end
end

always @(posedge clk) begin
	if (hc == 529) HBlank <= 1;
		else if (hc == 0) HBlank <= 0;

	if (hc == 544) begin
		HSync <= 1;

		if(pal) begin
			if(vc == (scandouble ? 609 : 304)) VSync <= 1;
				else if (vc == (scandouble ? 617 : 308)) VSync <= 0;

			if(vc == (scandouble ? 601 : 300)) VBlank <= 1;
				else if (vc == 0) VBlank <= 0;
		end
		else begin
			if(vc == (scandouble ? 490 : 245)) VSync <= 1;
				else if (vc == (scandouble ? 496 : 248)) VSync <= 0;

			if(vc == (scandouble ? 480 : 240)) VBlank <= 1;
				else if (vc == 0) VBlank <= 0;
		end
	end
	
	if (hc == 590) HSync <= 0;
end

// Rainbow bar generation
// Divide screen into 8 vertical bars
wire [2:0] bar_index = hc[9:7]; // Using 3 bits to divide into 8 sections

// Generate colorful rainbow pattern
assign r = (!HBlank && !VBlank) ? (bar_index == 0 || bar_index == 1 || bar_index == 7) ? 8'hFF : 
           (bar_index == 2 || bar_index == 6) ? 8'h80 : 8'h00 : 8'h00;
           
assign g = (!HBlank && !VBlank) ? (bar_index == 2 || bar_index == 3 || bar_index == 4) ? 8'hFF : 
           (bar_index == 1 || bar_index == 5) ? 8'h80 : 8'h00 : 8'h00;
           
assign b = (!HBlank && !VBlank) ? (bar_index == 4 || bar_index == 5 || bar_index == 6) ? 8'hFF : 
           (bar_index == 3 || bar_index == 7) ? 8'h80 : 8'h00 : 8'h00;

endmodule