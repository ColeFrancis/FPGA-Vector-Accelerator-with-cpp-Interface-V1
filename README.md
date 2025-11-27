# Overview

## Introduction

This project implements a CISC-style SIMD/vector instruction accelerator on an FPGA. The design includes vector–vector, vector–scalar, and immediate-operand ALU operations, plus vector reductions, register moves, and data-loading instructions.

The accelerator was implemented in SystemVerilog and a C++ host interface for issuing instructions and retrieving results from a computer over UART.

## Motivation

The goal of this project was to learn more about hardware acceleration and SIMD instruction architectures. It's uses may include

- machine learning

- scientific computing

- data analysis

While the UART interface limits bandwidth, the hardware core is intentionally modular and interface-agnostic. With a faster transport layer (AXI, PCIe, or an FPGA SoC), the accelerator can serve as a building block for larger architectures or FPGA-accelerated compute nodes.

# Features

## ISA

| Instruction | binary (d: dont care, x: see alu op) | Description |
| :-- | :-- | :-- |
| Nop  | 0000000000000000 | No Operation |
| Save scal to each element of vec A (len, #) | 000000000010aaaa |  Broadcast a single scalar immediate into register A | 
| Save vec to vec A                           | 000000000001aaaa (len, #) | Load an immediate vector of a specified length into register A |
| Return vec B                                | 0001bbbb1ddddddd | Send vector B to host |
| Move vec B to vec A                         | 0010bbbb1dddaaaa | Copy B into A |
| Vec - Vec immediate ALU                     | 1110dddd1xxxaaaa (len, #) | A = f(A, vec imm) |
| Vec - vec ALU                               | 1010bbbb1xxxaaaa | A = f(A, B) |
| Vec - scal immediate                        | 1111dddd1xxxaaaa (#) | A = f(A, scal imm) |
| Vec - scal with scalar acc                  | 1011dddd1xxxaaaa | A = f(A, scalar acc) |
| Vec red and return                          | 1001dddd1dxxaaaa | Operation reducing A to a scalar and return |
| Vec red and acc                             | 1000dddd1dxxaaaa | Operation reducing A to a scalar and store in scalar acc |

*Vec-Vec/Scalar ALU codes*
| bits | Operation |
| :--: | :--: |
| 000 | A+B |
| 001 | A-B |
| 010 | A*B |
| 011 | A cmp B (1 bit result saved element-wise in output) |
| 100 | A&B |
| 101 | A\|B |
| 110 | A^B |
| 111 | ~A |

*Scalar RED ALU codes*
| bits | Operation |
| :--: | :--: |
| 00 | cumutive sum |
| 01 | cumlutive or |
| 10 | min element in vector (signed) |
| 11 | max element in vector (signed) |

## Internal State

- 16 vecor registers, each of length N.

- 1 scalar accumulator register (used in reduction and scalar ALU ops)

- Instruction and decode registers.

- UART Rx/TX buffers.

## Input/output

Communication occurs over a UART serial link:

- Host to FPGA: instructions(little endian), immediate operands (after instruction)

- FPGA to Host: return instructions (vector data or scalars)

UART was chosen due to limitations of the specific FPGA board used; the accelerator is not inherently tied to UART. Any higher-bandwidth interface (AXI-Stream, PCIe, SPI, etc.) can replace it without modifying the core datapath.

## Performance

The performance is dependent on vector width N, clock frequency f_clk, UART baud rate B, and instruction type.

This processor is not pipelined, so each instruction runs to completion before the next begins.

### Fetch

There are 4 fetch stages for all instructions.

### Decode

For register sourced instructions, the decode stage takes 2 cycles. For immediate sources instructions, the decode takes (3 + N)*10*(f_clk/B) where f_clk is the clock frequency (Given 8 bit UART with no parity and 1 stop bit). This and the Baud factor are included because the immediate data is sent over the UART line.

### Execute

Not all instructions use the execute stage. For vec-vec or vec-scal instructions the execute stage takes 1 cycle. For vec reduce instructions the execute stage takes 1 + N cycles.

### Write back

For non returning instructions the write back stage takes 1 cycle. For returning instructions the write back stage takes (2 + N)*10*(f_clk/B), where f_clk is the clock frequency (Given 8 bit UART with no parity and 1 stop bit). This and the Baud factor are included because the immediate data is sent over the UART line.

### Summary of performance

Therefore, the number of cycles is 8 + Imm?(1 + N)*10*f_clk/Baud:0 + Red?N:0 + Ret?(1 + N)*10*f_clk/Baud:0 where Imm is true if the given insturction is immediate, Red is true if the given instruction features a vec reduce execute stage and Ret is true if the instruction Returns, f_clk is the clock frequency, and Baud is the baud rate of the UART module.

### Notes on Pipelining

Pipelining this processor would significantly increase the average cycles per instruction. For example, because UART is full-duplex, more instructions could be executed while data is being written out. This is one of the significant disadvantages of using a UART protocol.

## Additional features

# Build

## Requirements

- Windows (for the host interface; Linux version in progress)

- SystemVerilog toolchain (Tested with Vivado 2022.1)

## Compilation

Include the provided C++ header file in your host software

Use the .sv files to create a new Vivado project

Synthesize, implement, and generate the bitstream as normal

## Dependencies

There are no dependencies beyond a standard C++ compiler

# Usage

Send instructions and data as bits using the interface defined in the software headerfile, then wait for the data to be sent back.

# Known Issues

## Bugs
There are no known bugs.

## Limitations
This accelerator is limited by a UART serial interface. This is not a core feature of the design but a hardware limitation. The design can be integrated with a full FPGA SoC or an FPGA with a faster hardware interface like PCIe.

# License
This code is covered under the standard MIT license.

# Contact

## Author information
You can contact me directly over Github, or through my linkedin: Cole Francis.

## Feedback
Please feel free to send me any feedback on the usability, readability, or maintainability of the code!
