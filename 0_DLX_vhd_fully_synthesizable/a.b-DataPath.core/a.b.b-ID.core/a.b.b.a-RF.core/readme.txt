This is a brief description of the datapath of our FSM (RF).
As we wanted to make a Moore machine, the CPU can make a call every two clock fronts, in order to have time to update the CANSAVE_COUNTER and CANRESTORE_COUNTER outputs 
(these components are described below).
----------------------------------- -------------- DATAPATH -------------
Obviously the datapath includes the physical register file that we previously made.
The datapath includes 5 counter:
CWP_COUNTER: it is a counter that can count up or down. It is used to increase or decrease the CWP.
SWP_COUNTER: it is a counter that can count up or down. It is used to increase or decrease the SWP.
CANSAVE_COUNTER: it is a counter that can count up or down. It is used to count the number of windows available, before which a SPILL must be made. When the output of this counter is 
equal to zero the CANSAVE status signal is set to zero.
CANRESTORE_COUNTER: it is a counter that can count up or down. It is used to count the number of windows available, before which a FILL must be made. When the output of this counter is 
equal to zero, the CANRESTORE status signal is set to zero.
SPILL_FILL_COUNTER: is an up counter. It is used to count the number of registers to read / write when we need to do a SPILL / FILL. When the output of this counter is equal to 2N-1 the 
status signal END_SF is set to 1.

The datapath includes 4 address converters. Each converter has as inputs a relative address to be converted into physical, and a window pointer that corresponds to the "offset" to be 
added to the relative address (excluding the case in which a GLOBAL is being addressed). The address converters are:

CONV_RD1: this converter is used to convert the relative address ADD_RD1 coming from the CPU into a physical adddress, using the CWP as offset.

CONV_RD2: this converter is used to convert the relative address ADD_RD2 coming from the CPU into a physical adddress, using the CWP as offset.

CONV_WR: this converter is used to convert the relative ADD_WR address from the CPU into a physical adddress, using the CWP as offset.

SF_CONVERTER: this converter is used to convert the SPILL_FILL_COUNTER output into a physical address,used to read/write the 2N registers during the SPILL / FILL operations. A signal selected 
by a multiplexer is used as offset of the SF_CONVERTER. This signal corresponds to the CWP during the FILL operations, and to the CWP + 1 during the SPILL operations (since during the 
SPILL the data of the window following the one pointed to by the CWP must be saved).

All the control signals and addresses entering the physical register file are the outputs of a series of multiplexers. When the CPU_WORK selection signal is active, the multiplexer 
outputs are the control signals coming from the CPU, and the addresses coming from the CPU converted into physical ones. In other words, when CPU_WORK is active, the CPU controls the 
physical register file. Instead, when CPU_WORK is not active, the control signals entering the physical register file come from the control unit of the register file itself, and the
 addresses correspond to the output of the SF_CONVERTER.


In the ASM_charts folder it's possible to see the behavior of the RF control unit, and the FSM state evolution.
