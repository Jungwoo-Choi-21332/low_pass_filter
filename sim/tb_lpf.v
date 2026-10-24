`timescale 1ns/1ps
`define T_CLK 3

module tb_lpf;

reg clk;
reg n_rst;

reg [11:0] addr;
reg signed [7:0] xn_mem [0:2999];

reg  signed [7:0] xn;
wire signed [7:0] yn;

integer i;

// clock
initial clk = 1'b0;
always #(`T_CLK/2.0) clk = ~clk;

// input memory init
initial begin
    for(i = 0; i < 3000; i = i + 1)
        xn_mem[i] = 8'sd0;

    $readmemh("./sim/xn_data.txt", xn_mem);
end

// DUT
lpf u_lpf (
    .clk   (clk),
    .n_rst (n_rst),
    .xn    (xn),
    .yn    (yn)
);

// reset
// reset
initial begin
    n_rst = 1'b0;
    addr  = 12'd0;
    xn    = 8'sd0;

    repeat(5) @(posedge clk);

    @(negedge clk);
    #0.3;
    n_rst = 1'b1;
    xn    = xn_mem[0];
    addr  = 12'd0;
end

// input drive
always @(negedge clk or negedge n_rst) begin
    if(!n_rst) begin
        addr <= 12'd0;
        xn   <= 8'sd0;
    end
    else begin
        if(addr < 12'd2999) begin
            addr <= addr + 12'd1;
            xn   <= xn_mem[addr + 12'd1];
        end
        else begin
            addr <= 12'd3000;
            xn   <= 8'sd0;
        end
    end
end

// finish only
initial begin
    wait(n_rst == 1'b1);

    wait(addr == 12'd3000);

    repeat(50) @(posedge clk);

    $finish;
end

`ifdef SDF_PRE
initial begin   
    $sdf_annotate("./results/lpf.sdf", u_lpf);
end
`endif

// dump
initial begin
`ifdef FSDB
`ifdef SDF_PRE
    $fsdbDumpfile("lpf.pre.fsdb");
`else
    $fsdbDumpfile("lpf.fsdb");
`endif
    $fsdbDumpvars(0, tb_lpf);
`else
    $dumpfile("lpf.vcd");
    $dumpvars(0, tb_lpf);
`endif
end

// monitor
initial begin
    $monitor("time=%0t n_rst=%b addr=%d xn=%d yn=%d",
              $time, n_rst, addr, xn, yn);
end

endmodule