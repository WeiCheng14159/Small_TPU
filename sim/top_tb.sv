`timescale 1ns / 1ns
`define CYCLE 6.0 // Cycle time
`define MAX 3000000 // Max cycle number

`ifdef SYN
`include "top_syn.v"
`include "InOut_SRAM/SUMA180_32768X16X1BM8.v"
`include "Weight_SRAM/SUMA180_16384X18X1BM4.v"
`timescale 1ns / 10ps
`include "/usr/cad/CBDK/CBDK018_UMC_Faraday_v1.0/orig_lib/fsa0m_a/2009Q2v2.0/GENERIC_CORE/FrontEnd/verilog/fsa0m_a_generic_core_21.lib"
`elsif PR
`include "top_pr.v"
`include "InOut_SRAM/SUMA180_32768X16X1BM8.v"
`include "Weight_SRAM/SUMA180_16384X18X1BM4.v"
`timescale 1ns / 10ps
`include "/usr/cad/CBDK/CBDK018_UMC_Faraday_v1.0/orig_lib/fsa0m_a/2009Q2v2.0/GENERIC_CORE/FrontEnd/verilog/fsa0m_a_generic_core_21.lib"
`else
`include "top.sv"
`include "InOut_SRAM/SUMA180_32768X16X1BM8_rtl.sv"
`include "Weight_SRAM/SUMA180_16384X18X1BM4_rtl.sv"
`endif

`include "accelerator_mode.svh"
`define INOUT_BLOCK_WORD_SIZE 32768
`define WEIGHT_BLOCK_WORD_SIZE 32768
`define BIAS_BLOCK_WORD_SIZE 1000

module top_tb;

  logic clk;
  logic rstn;
  logic fin;
  logic start;
  logic [3:0] epu_mode;

  logic signed [7:0] GOLDEN[200000:0];
  logic [31:0] param[3:0];
  // GOLDEN
  logic signed [7:0] out;

  integer gf, i, num, slice;
  integer err, ret;
  string prog_path, layer, layer_num;
  always #(`CYCLE / 2) clk = ~clk;

  top TOP (
      .rstn(rstn),
      .clk(clk),
      .start_i(start),
      .mode_i(epu_mode),
      .finish_o(fin)
  );

  initial begin
    clk = 0;
    rstn = 1;
    start = 0;
    epu_mode = 1 << `IDLE_MODE;
    #1 rstn = 0;
    #(`CYCLE) rstn = 1;
    ret = $value$plusargs("prog_path=%s", prog_path);

    layer = prog_path.substr(prog_path.len() - 3, prog_path.len() - 1);
    layer_num = prog_path[prog_path.len()-1];

    if (layer == "fc") begin
      epu_mode = 1 << `FC_MODE;
    end else if (layer == "conv") begin
      epu_mode = 1 << `CONV_MODE;
    end else begin
      epu_mode = 1 << `IDLE_MODE;
    end

    // TODO: Read in parameter
    // $readmemh({prog_path, "/param.hex"}, param);
    // for (i = 0; i < 4; i = i + 1) begin
    //   TOP.i_param_mem.Memory[i] = param[i];
    // end

    // Read in input
    num = 0;
    slice = 0;
    gf = $fopen({prog_path, "/input.hex"}, "r");
    while (!$feof(
        gf
    )) begin
      if (num < `INOUT_BLOCK_WORD_SIZE) begin
        if (slice == 0)
          ret = $fscanf(
              gf,
              "%h\n",
              TOP.i_Input_SRAM_384k.SRAM_blk[0].i_SRAM_16b_32768w_64k.i_SUMA180_32768X16X1BM8.Memory[num]
          );
        else if (slice == 1)
          ret = $fscanf(
              gf,
              "%h\n",
              TOP.i_Input_SRAM_384k.SRAM_blk[1].i_SRAM_16b_32768w_64k.i_SUMA180_32768X16X1BM8.Memory[num]
          );
        else if (slice == 2)
          ret = $fscanf(
              gf,
              "%h\n",
              TOP.i_Input_SRAM_384k.SRAM_blk[2].i_SRAM_16b_32768w_64k.i_SUMA180_32768X16X1BM8.Memory[num]
          );
        else if (slice == 3)
          ret = $fscanf(
              gf,
              "%h\n",
              TOP.i_Input_SRAM_384k.SRAM_blk[3].i_SRAM_16b_32768w_64k.i_SUMA180_32768X16X1BM8.Memory[num]
          );
        else if (slice == 4)
          ret = $fscanf(
              gf,
              "%h\n",
              TOP.i_Input_SRAM_384k.SRAM_blk[4].i_SRAM_16b_32768w_64k.i_SUMA180_32768X16X1BM8.Memory[num]
          );
        else if (slice == 5)
          ret = $fscanf(
              gf,
              "%h\n",
              TOP.i_Input_SRAM_384k.SRAM_blk[5].i_SRAM_16b_32768w_64k.i_SUMA180_32768X16X1BM8.Memory[num]
          );

        num = num + 1;
      end else begin  // num == 32768
        slice = slice + 1;
        num   = 0;
      end
    end
    $fclose(gf);

    // Read in bias 
    num = 0;
    slice = 0;
    gf = $fopen({prog_path, "/bias.hex"}, "r");
    while (!$feof(
        gf
    )) begin
      if (num < `BIAS_BLOCK_WORD_SIZE) begin
        if (slice == 0)
          ret = $fscanf(
              gf,
              "%h\n",
              TOP.i_Weight_SRAM_384k.SRAM_blk[0].i_SRAM_16b_32768w_64k.i_SUMA180_32768X16X1BM8.Memory[num]
          );
        else if (slice == 1)
          ret = $fscanf(
              gf,
              "%h\n",
              TOP.i_Weight_SRAM_384k.SRAM_blk[1].i_SRAM_16b_32768w_64k.i_SUMA180_32768X16X1BM8.Memory[num]
          );
        else if (slice == 2)
          ret = $fscanf(
              gf,
              "%h\n",
              TOP.i_Weight_SRAM_384k.SRAM_blk[2].i_SRAM_16b_32768w_64k.i_SUMA180_32768X16X1BM8.Memory[num]
          );
        else if (slice == 3)
          ret = $fscanf(
              gf,
              "%h\n",
              TOP.i_Weight_SRAM_384k.SRAM_blk[3].i_SRAM_16b_32768w_64k.i_SUMA180_32768X16X1BM8.Memory[num]
          );
        else if (slice == 4)
          ret = $fscanf(
              gf,
              "%h\n",
              TOP.i_Weight_SRAM_384k.SRAM_blk[4].i_SRAM_16b_32768w_64k.i_SUMA180_32768X16X1BM8.Memory[num]
          );

        num = num + 1;
      end else begin  // num == 32768
        slice = slice + 1;
        num   = 0;
      end
    end
    $fclose(gf);

    // Read in weights
    num = 0;
    slice = 0;
    gf = $fopen({prog_path, "/weight.hex"}, "r");
    while (!$feof(
        gf
    )) begin
      if (num < `WEIGHT_BLOCK_WORD_SIZE) begin
        if (slice == 0)
          ret = $fscanf(
              gf,
              "%h\n",
              TOP.i_Weight_SRAM_384k.SRAM_blk[0].i_SRAM_16b_32768w_64k.i_SUMA180_32768X16X1BM8.Memory[num]
          );
        else if (slice == 1)
          ret = $fscanf(
              gf,
              "%h\n",
              TOP.i_Weight_SRAM_384k.SRAM_blk[1].i_SRAM_16b_32768w_64k.i_SUMA180_32768X16X1BM8.Memory[num]
          );
        else if (slice == 2)
          ret = $fscanf(
              gf,
              "%h\n",
              TOP.i_Weight_SRAM_384k.SRAM_blk[2].i_SRAM_16b_32768w_64k.i_SUMA180_32768X16X1BM8.Memory[num]
          );
        else if (slice == 3)
          ret = $fscanf(
              gf,
              "%h\n",
              TOP.i_Weight_SRAM_384k.SRAM_blk[3].i_SRAM_16b_32768w_64k.i_SUMA180_32768X16X1BM8.Memory[num]
          );
        else if (slice == 4)
          ret = $fscanf(
              gf,
              "%h\n",
              TOP.i_Weight_SRAM_384k.SRAM_blk[4].i_SRAM_16b_32768w_64k.i_SUMA180_32768X16X1BM8.Memory[num]
          );

        num = num + 1;
      end else begin  // num == 32768
        slice = slice + 1;
        num   = 0;
      end
    end
    $fclose(gf);

    // Read in output
    num = 0;
    gf  = $fopen({prog_path, "/output.hex"}, "r");
    while (!$feof(
        gf
    )) begin
      ret = $fscanf(gf, "%h\n", GOLDEN[num]);
      num = num + 1;
    end
    $fclose(gf);
  end 

  initial begin
    #20 start = 1;
    #(`CYCLE) start = 0;
    wait (fin);
    #(`CYCLE * 2) #20 $display("\nDone\n");
    err = 0;
    // if(num > 2000) num = 2000;  // Check first 2000 data by default
    check(0, num, err);
    result(err, num);
    $finish;
  end

  initial begin
    #(`CYCLE * `MAX) check(0, num, err);
    result(err, num);
    $display("SIM_END not finish!!!");
    $finish;
  end

`ifdef SYN
  initial $sdf_annotate("conv_syn.sdf", TOP);
`elsif PR
  initial $sdf_annotate("conv_pr.sdf", TOP);
`endif

  initial begin
`ifdef FSDB
    $fsdbDumpfile(`FSDB_FILE);
    $fsdbDumpvars();
    $fsdbDumpvars(1, TOP.param_intf);
    $fsdbDumpvars(1, TOP.input_intf);
    $fsdbDumpvars(1, TOP.base_kernel_intf);
    $fsdbDumpvars(1, TOP.filter_kernel_intf);
    $fsdbDumpvars(1, TOP.output_intf);
`elsif FSDB_ALL
    $fsdbDumpfile(`FSDB_FILE);
    $fsdbDumpvars("+struct", "+mda", TOP);
    $fsdbDumpvars(1, TOP.param_intf);
    $fsdbDumpvars(1, TOP.input_intf);
    $fsdbDumpvars(1, TOP.base_kernel_intf);
    $fsdbDumpvars(1, TOP.filter_kernel_intf);
    $fsdbDumpvars(1, TOP.output_intf);
    // $fsdbDumpvars("+struct", "+mda", TOP.i_param_mem);
    // $fsdbDumpvars("+struct", "+mda", TOP.i_Input_SRAM_384k);
    // $fsdbDumpvars("+struct", "+mda", TOP.i_Output_SRAM_384k);
    // $fsdbDumpvars("+struct", "+mda", TOP.i_Weight_SRAM_384k);
    // $fsdbDumpvars("+struct", "+mda", TOP.i_Bias_SRAM_2k);
`endif
  end

  task check(input integer word_begin, input integer word_end, output integer err_cnt);
    begin
      err_cnt = 0;
      for (i = word_begin; i < word_end; i = i + 1) begin
        slice = i / `INOUT_BLOCK_WORD_SIZE;
        if (slice == 0)
          out = TOP.i_Output_SRAM_384k.SRAM_blk[0].i_SRAM_16b_32768w_64k.i_SUMA180_32768X16X1BM8.Memory[i % `INOUT_BLOCK_WORD_SIZE][7:0];
        else if (slice == 1)
          out = TOP.i_Output_SRAM_384k.SRAM_blk[1].i_SRAM_16b_32768w_64k.i_SUMA180_32768X16X1BM8.Memory[i % `INOUT_BLOCK_WORD_SIZE][7:0];
        else if (slice == 2)
          out = TOP.i_Output_SRAM_384k.SRAM_blk[2].i_SRAM_16b_32768w_64k.i_SUMA180_32768X16X1BM8.Memory[i % `INOUT_BLOCK_WORD_SIZE][7:0];
        else if (slice == 3)
          out = TOP.i_Output_SRAM_384k.SRAM_blk[3].i_SRAM_16b_32768w_64k.i_SUMA180_32768X16X1BM8.Memory[i % `INOUT_BLOCK_WORD_SIZE][7:0];
        else if (slice == 4)
          out = TOP.i_Output_SRAM_384k.SRAM_blk[4].i_SRAM_16b_32768w_64k.i_SUMA180_32768X16X1BM8.Memory[i % `INOUT_BLOCK_WORD_SIZE][7:0];
        else if (slice == 5)
          out = TOP.i_Output_SRAM_384k.SRAM_blk[5].i_SRAM_16b_32768w_64k.i_SUMA180_32768X16X1BM8.Memory[i % `INOUT_BLOCK_WORD_SIZE][7:0];

        if (out === GOLDEN[i] | (out + 1) === GOLDEN[i] | (out - 1) === GOLDEN[i]) begin
          $display("DM[%4d] = %h, pass", i, out);
        end else begin
          $display("DM[%4d] = %h, expect = %h", i, out, GOLDEN[i]);
          err_cnt = err_cnt + 1;
        end
      end
    end
  endtask


  task result;
    input integer err;
    input integer num;
    integer rf;
    begin
`ifdef SYN
      rf = $fopen({"./result_syn.txt"}, "w");
`elsif PR
      rf = $fopen({"./result_pr.txt"}, "w");
`else
      rf = $fopen({"./result_rtl.txt"}, "w");
`endif
      $fdisplay(rf, "%d,%d", num - err, num);
      if (err === 0) begin
        $display("\n");
        $display("\n");
        $display("        ****************************               ");
        $display("        **                        **       |\__||  ");
        $display("        **  Congratulations !!    **      / O.O  | ");
        $display("        **                        **    /_____   | ");
        $display("        **  Simulation PASS!!     **   /^ ^ ^ \\  |");
        $display("        **                        **  |^ ^ ^ ^ |w| ");
        $display("        ****************************   \\m___m__|_|");
        $display("\n");
      end else begin
        $display("\n");
        $display("\n");
        $display("        ****************************               ");
        $display("        **                        **       |\__||  ");
        $display("        **  OOPS!!                **      / X,X  | ");
        $display("        **                        **    /_____   | ");
        $display("        **  Simulation Failed!!   **   /^ ^ ^ \\  |");
        $display("        **                        **  |^ ^ ^ ^ |w| ");
        $display("        ****************************   \\m___m__|_|");
        $display("         Totally has %d errors                     ", err);
        $display("\n");
      end
    end
  endtask

endmodule
