#!/bin/bash

timestamp=$(date +%Y/%m/%d-%H:%M:%S)
# printf "// This is generated automatically on ${timestamp}\n"
printf "// Check the # of bits for state registers !!!\n"
printf "// Check the # of bits for flag registers !!!\n\n"

STATES=("S_IDLE"         \
        "S_LOAD"         \
        "S_STREAM"       \
        "S_TAIL"         \
        "S_IMG2COL"      \
        "S_END"          \
)

def_pattern="%-30s \t %-3s\n"
# Generate macro
printf "\`ifndef __FLAG_DEF__\n"
printf "\`define __FLAG_DEF__\n"

# Generate FSM states
len=${#STATES[@]}
printf "\n// There're ${len} states in this design\n"
for((idx=0; idx<${len}; idx++))
do
  printf "$def_pattern" "\`define ${STATES[$idx]}" "${idx}"
done

# Generate FSM init vector
printf "$def_pattern" "\`define S_ZVEC"     "${len}'b0"
printf "$def_pattern" "\`define STATE_W"    "${len}"

# Generate other macro
printf "\n// Macro from template\n"
printf "$def_pattern" "\`define BUF_SIZE"             "8'd66"

printf "$def_pattern" "\`define DATA_WIDTH"               "20"
printf "$def_pattern" "\`define ADDR_WIDTH"               "20"

printf "$def_pattern" "\`define EMPTY_ADDR"           "{\`ADDR_WIDTH{1'b0}}"
printf "$def_pattern" "\`define EMPTY_DATA"           "{\`DATA_WIDTH{1'b0}}"

printf "\n// Self-defined macro\n"
printf "$def_pattern" "\`define CNT_WIDTH"                "15"

printf "\n// Memory control signal \n"
printf "$def_pattern" "\`define WRITE_ENB"                "(1'b0)"
printf "$def_pattern" "\`define WRITE_DIS"                "(1'b1)"
printf "$def_pattern" "\`define READ_ENB"                 "(1'b1)"
printf "$def_pattern" "\`define READ_DIS"                 "(1'b0)"

# Generate end macro
printf "\n\`endif\n"
