`timescale 1ns/1ps

module lpf (
    input  wire clk,
    input  wire n_rst,
    input  wire signed [7:0] xn,
    output wire signed [7:0] yn
);

reg signed [7:0] d0, d1, d2, d3, d4;
reg signed [7:0] d5, d6, d7, d8, d9;
reg signed [7:0] d10, d11, d12, d13, d14;
reg signed [7:0] d15, d16, d17, d18;

wire signed [8:0] s0, s1, s2, s3, s4;
wire signed [8:0] s5, s6, s7, s8, s9;

wire signed [17:0] sx0, sx2, sx3, sx4;
wire signed [17:0] sx6, sx7, sx8, sx9;

wire signed [17:0] m0, m2, m3, m4;
wire signed [17:0] m6, m7, m8, m9;

reg signed [18:0] add0_0, add0_1, add0_2, add0_3;
reg signed [19:0] add1_0, add1_1;
reg signed [20:0] sum_reg;

wire signed [20:0] y_shift;
wire pos_ov;
wire neg_ov;

reg signed [7:0] yn_d1;

// delay line
always @(posedge clk or negedge n_rst) begin
    if(!n_rst) begin
        d0 <= 0; d1 <= 0; d2 <= 0; d3 <= 0; d4 <= 0;
        d5 <= 0; d6 <= 0; d7 <= 0; d8 <= 0; d9 <= 0;
        d10 <= 0; d11 <= 0; d12 <= 0; d13 <= 0; d14 <= 0;
        d15 <= 0; d16 <= 0; d17 <= 0; d18 <= 0;
    end
    else begin
        d0  <= xn;
        d1  <= d0;
        d2  <= d1;
        d3  <= d2;
        d4  <= d3;
        d5  <= d4;
        d6  <= d5;
        d7  <= d6;
        d8  <= d7;
        d9  <= d8;
        d10 <= d9;
        d11 <= d10;
        d12 <= d11;
        d13 <= d12;
        d14 <= d13;
        d15 <= d14;
        d16 <= d15;
        d17 <= d16;
        d18 <= d17;
    end
end

// symmetric pair sum
assign s0 = {d0[7], d0}   + {d18[7], d18};
assign s1 = {d1[7], d1}   + {d17[7], d17}; // coefficient 0
assign s2 = {d2[7], d2}   + {d16[7], d16};
assign s3 = {d3[7], d3}   + {d15[7], d15};
assign s4 = {d4[7], d4}   + {d14[7], d14};
assign s5 = {d5[7], d5}   + {d13[7], d13}; // coefficient 0
assign s6 = {d6[7], d6}   + {d12[7], d12};
assign s7 = {d7[7], d7}   + {d11[7], d11};
assign s8 = {d8[7], d8}   + {d10[7], d10};
assign s9 = {d9[7], d9};

// sign extension only for non-zero coefficients
assign sx0 = {{9{s0[8]}}, s0};
assign sx2 = {{9{s2[8]}}, s2};
assign sx3 = {{9{s3[8]}}, s3};
assign sx4 = {{9{s4[8]}}, s4};
assign sx6 = {{9{s6[8]}}, s6};
assign sx7 = {{9{s7[8]}}, s7};
assign sx8 = {{9{s8[8]}}, s8};
assign sx9 = {{9{s9[8]}}, s9};

// constant multiply using shift/add
// coefficients: [6, 0, -8, -14, -12, 0, 19, 41, 58, 64]
assign m0 = (sx0 <<< 2) + (sx0 <<< 1);                    // * 6
assign m2 = -(sx2 <<< 3);                                  // * -8
assign m3 = -((sx3 <<< 3) + (sx3 <<< 2) + (sx3 <<< 1));     // * -14
assign m4 = -((sx4 <<< 3) + (sx4 <<< 2));                  // * -12
assign m6 = (sx6 <<< 4) + (sx6 <<< 1) + sx6;               // * 19
assign m7 = (sx7 <<< 5) + (sx7 <<< 3) + sx7;               // * 41
assign m8 = (sx8 <<< 6) - (sx8 <<< 2) - (sx8 <<< 1);       // * 58
assign m9 = (sx9 <<< 6);                                   // * 64

// adder tree stage 0
always @(posedge clk or negedge n_rst) begin
    if(!n_rst) begin
        add0_0 <= 0;
        add0_1 <= 0;
        add0_2 <= 0;
        add0_3 <= 0;
    end
    else begin
        add0_0 <= m0 + m2;
        add0_1 <= m3 + m4;
        add0_2 <= m6 + m7;
        add0_3 <= m8 + m9;
    end
end

// adder tree stage 1
always @(posedge clk or negedge n_rst) begin
    if(!n_rst) begin
        add1_0 <= 0;
        add1_1 <= 0;
    end
    else begin
        add1_0 <= add0_0 + add0_1;
        add1_1 <= add0_2 + add0_3;
    end
end

// final sum register
always @(posedge clk or negedge n_rst) begin
    if(!n_rst)
        sum_reg <= 0;
    else
        sum_reg <= add1_0 + add1_1;
end

// scaling
assign y_shift = sum_reg >>> 8;

// cheap saturation
assign pos_ov = (~y_shift[20]) & (|y_shift[19:7]);
assign neg_ov = ( y_shift[20]) & (~(&y_shift[19:7]));

// output register
always @(posedge clk or negedge n_rst) begin
    if(!n_rst)
        yn_d1 <= 8'sd0;
    else if(pos_ov)
        yn_d1 <= 8'sd127;
    else if(neg_ov)
        yn_d1 <= -8'sd128;
    else
        yn_d1 <= y_shift[7:0];
end

assign yn = yn_d1;

endmodule