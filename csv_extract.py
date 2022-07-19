fin = open("DLX - Opcode.csv", "r")
fout = open("dlx_codes.vhd", "w")

count = 0
table_begin = False

mandatory = []
rr_mandatory = []
optional = []
rr_optional = []
alu_commands = []
instructions = []

# From now, elaborate each line
for line in fin:
	
    count += 1
    #print('\t' + line[0] + line[1])
    
    #print("line "+i+": ")
    #line = fin.readline()		# Read the whole line
    print(line)
    line_split = line.split(",")	# Split the line using comma
    line_out = ''
    
    #for y in line_split:
    #    if( y == '!' or y == '#' ):
    #        line_split.remove(y)        # Clean the list from garbage
 
    print(line_split)
    #print(len(line_split))
    #if(line[1] == '-'):
    #    continue
    
    # Each list is organized as:
    # [ ? | Instruction | OPCODE | OPCODE[bin] | FUNC | FUNC[bin] | Description ]
    
    if(line_split[0] == '?' or line_split[0] == ""):
        continue;
    
    # I need to:
    # 1. Convert to upper the instruction
    instruction = line_split[1].upper()
    instructions.append(instruction)
    
    # 2. Extend the binary value to 6 bits
    opcode = ""
    func = ""
    command = ""
    
    if(line_split[2] == "0x00"):    # FUNC instruction
        
        alu_commands.append(instruction)
        
        # Register-register instruction -> FUNC to be used            
        for i in range(6 - len(line_split[5])):
            func += '0'
        func += line_split[5];
        
        command = "constant "+instruction+"_FUNC\t: std_logic_vector(FUNC_SIZE-1 downto 0) := \""+func+"\";\n"
        
    else:                           # OPCODE instruction
        for i in range(6 - len(line_split[3])):
            opcode += '0'
        opcode += line_split[3];
        command = "constant "+instruction+"_OP\t: std_logic_vector(OP_SIZE-1 downto 0) := \""+opcode+"\";\n"
        
    print(command)
    
    
    # Save the commands in the corresponding list
    if(line_split[0] == "x"):           # Mandatory instruction
        if(line_split[2] == "0x00"):    # ALU Instruction
            rr_mandatory.append(command)
        else:
            mandatory.append(command)
    else:                               # Optional instruction
        if(line_split[2] == "0x00"):    # ALU Instruction
            rr_optional.append(command)
        else:
            optional.append(command)

fout.write("-- MANDATORY INSTRUCTIONS\n")
fout.write("-- ALU instruction -> OPCODE = 0x00\n")
fout.write("constant ALU_O\t: std_logic_vector(FUNC_SIZE-1 downto 0) := \"000000\";\n")
for line in rr_mandatory:
    fout.write(line)

fout.write("-- General instructions\n")
for line in mandatory:
    fout.write(line)

fout.write("-- OPTIONAL INSTRUCTIONS\n")
fout.write("-- ALU instruction -> OPCODE = 0x00\n")
for line in rr_optional:
    fout.write(line)

fout.write("-- General instructions\n")
for line in optional:
    fout.write(line)
    
# aluOp generation types
fout.write("\n\ntype aluOp is ( \n")
for op in alu_commands:
    fout.write(op+",\n")

# States generation for FSM
fout.write("------------------- FSM STATES ----------------------\n")
fout.write("type TYPE_STATE is (\n")
i = 0;
for instr in instructions:
    fout.write(instr+",")
    i+=1
    if i == 3:
        fout.write("\n")
        i=0
fout.write("\t);")

fin.close()
fout.close()
exit()
