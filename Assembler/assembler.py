import sys

class Assembler():

    def __init__(self, path, code_output_path):
        self.number_of_lines = (1<<20)
        self.path = path
        self.code_output_path = code_output_path

        self.registers = {'r0': '000',
                          'r1': '001', 
                          'r2': '010', 
                          'r3': '011', 
                          'r4': '100', 
                          'r5': '101',
                          'r6': '110', 
                          'r7': '111'}

        self.code_lines = []

        self.current_code_mem_location = 0

        self.binary_code = {}
        self.groupA = { "nop" : "00000",
                        "swap": "10001",
                        "not" : "10010",
                        "inc" : "10011",
                        "dec" : "10100",
                        "add" : "10101",
                        "sub" : "10110",
                        "and" : "10111",
                        "or"  : "11000",
                        "jz"  : "11001",
                        "in"  : "11010",
                        "pop" : "11011",
                        "jmp" : "11100",
                        "push": "11101",
                        "call": "11110",
                        "out" : "11111",
                        "ret" : "01101",
                        "rti" : "01100"}
        
        self.groupB = { "shl" : "00001",
                        "shr" : "00010"}

        self.groupC = { "ldm" : "00101",
                        "iadd": "00110"}
        
        self.groupD = { "ldd" : "01001",
                        "std" : "01010"}
        #for code testing
        self.NOP = ["nop","ret","rti"]
        self.OneOperand = ["not","inc","dec","out","in","push","pop","jz","jmp","call"]
        self.TwoOperand = ["swap","shl","shr","ldm","ldd","std"]
        self.ThreeOperand = ["add","iadd","sub","and","or"]
    def parse(self):
        self.__read_code_file()     
        self.__scan_code()
        self.__save_instructions()

    def __get_instruction_info(self, line):
        words = []
        operation = line.split(" ", 1)
        # Remove all spaces.
        operation[0] = operation[0].replace(" ", "")
        words.append(operation[0])
        if len(operation) > 1: 
            operation[1] = operation[1].replace(" ", "")
            if (len(operation[1]) == 0):
                operation = [operation[0]]
            else:
                for word in operation[1].split(","):
                    words.append(word)
        if  (words[0] in self.NOP and len(words)==1) or (words[0] in self.OneOperand and len(words)==2) or (words[0] in self.TwoOperand and len(words)==3) or (words[0] in self.ThreeOperand and len(words)==4):
            try:
                if words[0] in self.groupA.keys():
                    ir = "00" + self.groupA[words[0]]
                    for i in range(1,len(words)):
                        ir += self.registers[words[i]]
                    ir += ('0' * (16-len(ir)))
                    print("GroupA",ir,len(ir))
                    return ir,1,False
                elif words[0] in self.groupB.keys():    #shift
                    ir = "00" + self.groupB[words[0]] + self.registers[words[1]] + bin(int(words[2])).replace("0b","").zfill(5) + "0"
                    print("GroupB",ir,len(ir))
                    return ir,1,False
                elif words[0] in self.groupC.keys():    #immediate
                    if words[0] in self.TwoOperand:     #ldm
                        immediate_value = bin(int(words[2])).replace("0b","").zfill(16)
                        ir ="01" + self.groupC[words[0]] + self.registers[words[1]] + "00000" + immediate_value[0] + "1" + immediate_value[1:]
                    else:                               #iadd
                        immediate_value = bin(int(words[3])).replace("0b","").zfill(16)
                        ir ="01" + self.groupC[words[0]] + self.registers[words[1]] + self.registers[words[2]] + "00" + immediate_value[0] + "1" + immediate_value[1:]
                    print("GroupC",ir,len(ir))
                    return ir,2,False   
                elif words[0] in self.groupD.keys():    #memory
                    effective_address = bin(int(words[2])).replace("0b","").zfill(20)
                    ir = "01" + self.groupD[words[0]] + self.registers[words[1]] + "0" + effective_address[:5] + "1" + effective_address[5:]
                    print("GroupD",ir,len(ir))
                    return ir,2,(words[0]=="ldd")
            except:
                print("Invalid instruction Format!")
        return '0'*16,0,False
    def __read_code_file(self):

        with open(self.path) as FILE:
            line = FILE.readline()
            while line:
                line = line.strip()
                if len(line) != 0 and line[0] != ";" :  #if the line isn't empty or comment
                    line = line.lower()
                    line = line.split(";", 1)[0]        #remove the comment
                    self.code_lines.append(line.strip())
                line = FILE.readline()

    # Scan the code to get instructions.
    def __scan_code(self):

        for i in range(len(self.code_lines)):
            line = self.code_lines[i]
            line_words = line.split(" ", 1)

            if line_words[0][:4] == '.org':
                self.current_code_mem_location = int(line_words[1].strip())
                continue
            if line_words[0].isnumeric():
                number = bin(int(line_words[0])).replace("0b","").zfill(16)
                if(len(number) != 16):
                    print("Large Number!")
                    return
                self.binary_code[self.current_code_mem_location] = number
                self.current_code_mem_location += 1
                continue

            ir, size,isLoad = self.__get_instruction_info(line)

            if size == 0:
                print("invalid instruction !")
                return
            elif size == 1 and len(ir)==16:
                self.binary_code[self.current_code_mem_location] = ir
            elif size == 2 and len(ir)==32:
                if isLoad:
                    self.binary_code[self.current_code_mem_location+1] = ir[:16]
                    self.binary_code[self.current_code_mem_location]   = ir[16:]
                else:
                    self.binary_code[self.current_code_mem_location]   = ir[:16]
                    self.binary_code[self.current_code_mem_location+1] = ir[16:]
            else:
                print("Large immediate value!")
                return
            self.current_code_mem_location += size

    def __save_instructions(self):
        with open(self.code_output_path, "w") as f:
            for address in range(self.number_of_lines):
                if address in self.binary_code.keys():
                    f.write(self.binary_code[address]+"\n")
                else:
                    f.write('0'*16 + "\n")

if __name__ == '__main__':
    code_file_path = 'code.txt'
    code_ram_file_path = 'CODE_RAM.txt'
    a = Assembler(code_file_path, code_ram_file_path)
    a.parse()