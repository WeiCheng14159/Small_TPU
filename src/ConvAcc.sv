`include "ConvAcc.svh"
`include "sp_ram_intf.sv"
`include "define.v"

module ConvAcc (
    input  logic       clk,
    input  logic       rstn,
    input  logic       start,
    input  logic [3:0] mode,
    output logic       finish,

    sp_ram_intf.compute param_intf,
    sp_ram_intf.compute base_kernel_intf,
    sp_ram_intf.compute filter_kernel_intf,
    sp_ram_intf.compute input_intf,
    sp_ram_intf.compute output_intf
);
  logic mydata;
  /* Write your code here */
//   always @(posedge clk) begin
//     mydata <= input_intf.R_data;
//   end
// DO NOT FORGET TO DO THIS.
    wire [`STATE_W-1:0] curr_state;
    wire [`STATE_DONE_W-1:0] done_state;

    ctrl ctrl(
        .clk(clk),
        .rstn(rstn),
        .curr_state(curr_state),// in the () is not the default name
        .done_state(done_state),
        .filter_kernel_intf(filter_kernel_intf)
    );

    dp dp(
        .clk(clk),
        .rstn(rstn),
        .finish(finish),
        .curr_state(curr_state),
        .done_state(done_state),
        .base_kernel_intf(base_kernel_intf),
        .filter_kernel_intf(filter_kernel_intf),
        .input_intf(input_intf),
        .output_intf(output_intf)
    );

endmodule

module ctrl (
    input                               clk,
    input                               rstn, 
    input         [`STATE_DONE_W-1:0]   done_state,
    output logic  [`STATE_W-1:0]        curr_state,
    sp_ram_intf                         filter_kernel_intf
);

reg [`STATE_W-1:0] next_state;

// State Register (S)
always @(posedge clk) begin
    curr_state <= next_state;
end

reg [0:0] initial_flag;

// initial_flag
always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        initial_flag <= 1;
    end else begin
        if (curr_state[`S_READ_I]) begin
            initial_flag <= 0;
        end
    end
end

// Next State Logic (C)
always @(*) begin
    next_state = 0;
    if (~rstn) begin
        next_state[`S_INIT] = 1'b1;
    end else begin
        case (1'b1)
            curr_state[`S_INIT]: begin
                if (initial_flag) begin
                    next_state[`S_READ_I] = 1'b1;
                end else begin
                    next_state[`S_INIT] = 1'b1;
                end
            end

            curr_state[`S_READ_I]: begin
                if (done_state[`DONE_READ_I]) begin
                    next_state[`S_GEN_BASE] = 1'b1;
                end else begin
                    next_state[`DONE_READ_I] = 1'b1;
                end
            end

            curr_state[`S_GEN_BASE]: begin
                if (done_state[`DONE_GEN_BASE]) begin
                    next_state[`S_READ_K] = 1'b1;
                end else begin
                    next_state[`S_GEN_BASE] = 1'b1;
                end
            end

            curr_state[`S_READ_K]: begin
                if (done_state[`DONE_READ_K]) begin
                    next_state[`S_ADD] = 1'b1;
                end else begin
                    next_state[`S_READ_K] = 1'b1;
                end
            end

            curr_state[`S_ADD]: begin
                if (done_state[`DONE_ADD]) begin
                    next_state[`S_COMPOSE] = 1'b1;
                end else begin
                    next_state[`S_ADD] = 1'b1;
                end
            end

            curr_state[`S_COMPOSE]: begin
                if (done_state[`DONE_COMPOSE]) begin
                    next_state[`S_OUT] = 1'b1;
                end else begin
                    next_state[`S_ADD] = 1'b1;
                end
            end

            curr_state[`S_OUT]: begin
                if (done_state[`DONE_OUT]) begin
                    next_state[`S_WAIT] = 1'b1;
                end else begin
                    next_state[`S_OUT] = 1'b1;
                end
            end

            curr_state[`S_WAIT]: begin
                if (done_state[`DONE_WAIT]) begin
                    if (filter_kernel_intf.addr == 32) begin
                        next_state[`S_READ_I] = 1'b1;
                    end else begin
                        next_state[`S_READ_K] = 1'b1;
                    end
                end else if (done_state[`DONE_FINISH]) begin
                    next_state[`S_END] = 1'b1;
                end else begin
                    next_state[`S_WAIT] = 1'b1;
                end
            end
        endcase
    end
end
endmodule

module dp (
    input                               clk,
    input                               rstn,
    output logic                        finish,
    input         [`STATE_W-1:0]        curr_state,
    output logic  [`STATE_DONE_W-1:0]   done_state,
    sp_ram_intf                         base_kernel_intf,
    sp_ram_intf                         filter_kernel_intf,
    sp_ram_intf                         input_intf,
    sp_ram_intf                         output_intf
);

reg [6:0] i;
reg [6:0] j, k, p;

// finish
always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        finish <= 0;
    end else begin
        if (curr_state[`S_END]) begin
            finish <= 1;
        end else begin
            finish <= 0;
        end
    end
end

reg [`ADDR_W-1:0] addr_base, addr_cnt;
assign input_intf.addr = addr_base + addr_cnt;

// addr_base
always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        addr_base <= 0;
    end else begin
        if (curr_state[`S_WAIT]) begin
            if (filter_kernel_intf.addr == 32) begin
                if (addr_base % 30 == 27) begin
                    addr_base <= addr_base + 3;
                end else begin
                    addr_base <= addr_base + 1;
                end
            end else begin
                addr_base <= addr_base;
            end
        end else begin
            addr_base <= addr_base;
        end
    end
end

// addr_cnt
always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        addr_cnt <= 0;
    end else begin
        if (curr_state[`S_READ_I]) begin
            case (addr_cnt)
                0: addr_cnt <= 1;
                1: addr_cnt <= 2;
                2: addr_cnt <= 30;
                30: addr_cnt <= 31;
                31: addr_cnt <= 32;
                32: addr_cnt <= 60;
                60: addr_cnt <= 61;
                61: addr_cnt <= 62;
                62: addr_cnt <= 0; 
                default:  addr_cnt <= addr_cnt;
            endcase
        end else begin
            addr_cnt <= addr_cnt;
        end
    end
end


reg [`DATA_W-1:0] image[9];
reg [3:0] image_cnt;
// image
always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        for (i = 0; i <= 8; i = i + 1) begin
            image[i] <= -1;
        end
    end else begin
        if (curr_state[`S_READ_I]) begin
            image[image_cnt] <= input_intf.R_data;
        end
    end
end

reg [0:0] R_img_flag;
// image_cnt
always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        image_cnt <= 0;
        R_img_flag <= 0;
    end else begin
        if (curr_state[`S_READ_I]) begin
            if (image_cnt == 8 || R_img_flag == 0) begin
                image_cnt <= 0;
                R_img_flag <= 1;
            end else begin
                image_cnt <= image_cnt + 1; 
            end
        end else begin
            image_cnt <= image_cnt;
        end
    end
end

// input_intf.oe, input_intf.cs
always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        input_intf.oe <= 0;
        input_intf.cs <= 0;
    end else begin
        if (curr_state[`S_INIT]) begin
            input_intf.oe <= 1;
            input_intf.cs <= 1;
        end else begin
            input_intf.oe <= input_intf.oe;
            input_intf.cs <= input_intf.cs;
        end
    end
end

reg [`DATA_W-1:0] BASE_image;
// BASE_image
always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        BASE_image <= 0;
    end else begin
        if (curr_state[`S_GEN_BASE]) begin
            BASE_image <= 0 - image[0] - image[1]- image[2] - image[3] - image[4] - image[5] - image[6] - image[7] - image[8];                  //not sure
        end else begin
            BASE_image <= BASE_image;
        end
    end
end

reg [8:0] FILTER_kernel;
// filter_kernel_intf.oe, filter_kernel_intf.cs
always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        filter_kernel_intf.oe <= 0;
        filter_kernel_intf.cs <= 0;
    end else begin
        if (curr_state[`S_INIT]) begin
            filter_kernel_intf.oe <= 1;
            filter_kernel_intf.cs <= 1;
        end else begin
            filter_kernel_intf.oe <= filter_kernel_intf.oe;
            filter_kernel_intf.cs <= filter_kernel_intf.cs;
        end
    end
end

// filter_kernel_intf.addr
always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        filter_kernel_intf.addr <= 0;
    end else begin
        if (curr_state[`S_READ_K]) begin
            if (filter_kernel_intf.addr == 32) begin
                filter_kernel_intf.addr <= 0; 
            end else begin
                filter_kernel_intf.addr <= filter_kernel_intf.addr + 1;
            end
        end else begin
            filter_kernel_intf.addr <= filter_kernel_intf.addr;
        end
    end
end

// FILTER_kernel
always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        FILTER_kernel <= 0;
    end else begin
        if (curr_state[`S_READ_K]) begin
            FILTER_kernel <= filter_kernel_intf.R_data;
        end else begin
            FILTER_kernel <= FILTER_kernel;
        end
    end
end

reg [3:0] fil_img_cnt;
// fil_img_cnt
always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        fil_img_cnt <= 0;
    end else begin
        if (curr_state[`S_ADD]) begin
            if (fil_img_cnt == 8) begin
                fil_img_cnt <= 0;
            end else begin
                fil_img_cnt <= fil_img_cnt + 1;
            end
        end else begin
            fil_img_cnt <= fil_img_cnt;
        end
    end
end

reg [`DATA_W-1:0] FILTER_image;
// FILTER_image
always @(posedge clk or negedge rstn) begin                                                                 //not sure
    if (~rstn) begin
        FILTER_image <= 0;
    end else begin
        if (curr_state[`S_ADD]) begin
            if (FILTER_kernel[fil_img_cnt] == 1) begin
                FILTER_image <= FILTER_kernel[fil_img_cnt] * image[8 - fil_img_cnt];
            end else begin
                FILTER_image <= image[8 - fil_img_cnt] * -1;
            end

        end else if (curr_state[`S_READ_K]) begin
            FILTER_image <= 0;
        end
    end
end

reg [`DATA_W-1:0] COMPOSE_image;
// COMPOSE_image
always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        COMPOSE_image <= 0;
    end else begin
        // if (curr_state[`S_COMPOSE]) begin
        //     COMPOSE_image <= BASE_image + (FILTER_image << 1);
        // end else if (curr_state[`S_READ_I]) begin
        //     COMPOSE_image <= 0;
        // end
        if (curr_state[`S_COMPOSE]) begin
            COMPOSE_image <= COMPOSE_image + FILTER_image;
        end else if (curr_state[`S_READ_K]) begin
            COMPOSE_image <= 0;
        end        
    end
end



// output_intf.oe, output_intf.cs
always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        output_intf.oe <= 0;
        output_intf.cs <= 0;
    end else begin
        if (curr_state[`S_OUT]) begin
            output_intf.oe <= 1;
            output_intf.cs <= 1;
        end else begin
            output_intf.oe <= output_intf.oe;
            output_intf.cs <= output_intf.cs;
        end
    end
end

// output_intf.W_req
always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        output_intf.W_req <= `WRITE_DIS;
    end else begin
        if (curr_state[`S_OUT]) begin
            output_intf.W_req <= `WRITE_ENB;
        end else begin
            output_intf.W_req <= `WRITE_DIS;
        end
    end
end

reg [9:0] addr_base_o;
// addr_base_o
always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        addr_base_o <= 0;
    end else begin
        if (curr_state[`S_WAIT]) begin
            if (filter_kernel_intf.addr == 32) begin
                addr_base_o <= addr_base_o + 1;
            end else begin
                addr_base_o <= addr_base_o;
            end
        end else begin
            addr_base_o <= addr_base_o;
        end
    end
end

// output_intf.addr
always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        output_intf.addr <= 0;
    end else begin
        if (curr_state[`S_WAIT]) begin
            if (1) begin
                output_intf.addr <= addr_base_o + 784 * filter_kernel_intf.addr;
            end else begin
                output_intf.addr <= 0;
            end
        end else begin
            output_intf.addr <= output_intf.addr;
        end
    end
end

// output_intf.W_data
always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        output_intf.W_data <= 0;
    end else begin
        if (curr_state[`S_OUT]) begin
            output_intf.W_data <= COMPOSE_image;
        end else begin
            output_intf.W_data <= output_intf.W_data;
        end
    end
end

// done_state
always @(*) begin
    done_state = `DONE_ZVEC;
    case (1'b1)
        curr_state[`S_INIT]: begin
            done_state[`DONE_INIT] = 1'b1;
        end
        
        curr_state[`S_READ_I]: begin
            if (image_cnt == 8) begin
                done_state[`DONE_READ_I] = 1'b1;
            end
        end
        
        curr_state[`S_GEN_BASE]: begin
            done_state[`DONE_GEN_BASE] = 1'b1;
        end

        curr_state[`S_READ_K]: begin
            done_state[`DONE_READ_K] = 1'b1;
        end

        curr_state[`S_ADD]: begin
            //if (fil_img_cnt == 8) begin
            done_state[`DONE_ADD] = 1'b1;
            //end
        end

        curr_state[`S_COMPOSE]: begin
            if (fil_img_cnt == 8) begin
                done_state[`DONE_COMPOSE] = 1'b1;
            end            
            
        end

        curr_state[`S_OUT]: begin
            done_state[`DONE_OUT] = 1'b1;
        end

        curr_state[`S_WAIT]: begin
            if (addr_base_o == 783 && filter_kernel_intf.addr == 32) begin
                done_state[`DONE_FINISH] = 1'b1;
            end else begin
                done_state[`DONE_WAIT] = 1'b1; 
            end
        end
    endcase
end

endmodule