# Overview

## Introduction

CISC-Style

## Motivation


# Features

## Instructions

## Performance

## Additional features

# Build

## Requirements

## Compilation

## Dependencies
There are no dependencies.

# Usage

Send instructions and data as bits using the interface defined in the software headerfile, then wait for the data to be sent back.

# Technical details

## ISA

| Instruction | binary (d: dont care, x: see alu op) |
| :-- | --: |
| Nop  | 0000000000000000 |
| Save scal to each element of vec A (len, #) | 000000000010aaaa |
| Save vec to vec A (len, #)                  | 000000000001aaaa |
| Return vec B                                | 0001bbbb1ddddddd |
| Move vec B to vec A                         | 0010bbbb1dddaaaa |
| Vec - Vec immediate ALU (len, #)            | 1110dddd1xxxaaaa |
| Vec - vec ALU (reg)                         | 1010bbbb1xxxaaaa |
| Vec - scal immediate (#)                    | 1111dddd1xxxaaaa |
| Vec - scal with scalar acc                  | 1011dddd1xxxaaaa |
| Vec red and return                          | 1001dddd1dxxaaaa |
| Vec red and acc                             | 1000dddd1dxxaaaa |

*Vec-Vec/Scalar ALU codes*
| bits | Description|
| :--: | :--: |
| 000 | A+B |
| 001 | A-B |
| 010 | A*B |
| 011 | A cmp B |
| 100 | A&B |
| 101 | A\|B |
| 110 | A^B |
| 111 | ~A |

*Scalar RED ALU codes*
| bits | Description|
| :--: | :--: |
| 00 | sum |
| 01 | or |
| 10 | min |
| 11 | max |

## State

This accelerator includes 16 general purpose vector registers

## Input/output
The accelerator is interfaced through sending and receiving instructions and data over a serial UART interface.

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
