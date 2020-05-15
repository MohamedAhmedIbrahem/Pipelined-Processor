import sys

class Assembler():

    def __init__(self, path, code_output_path):
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
                        "rti" : "01110"}
        
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
        
        self.hex_to_bin = {
            '0' : "0000",
            '1' : "0001",
            '2' : "0010",
            '3' : "0011",
            '4' : "0100",
            '5' : "0101",
            '6' : "0110",
            '7' : "0111",
            '8' : "1000",
            '9' : "1001",
            'a' : "1010",
            'b' : "1011",
            'c' : "1100",
            'd' : "1101",
            'e' : "1110",
            'f' : "1111"
        }

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
                    operands = []
                    for i in range(1,len(words)):
                        operands.append(self.registers[words[i]])

                    if len(operands) > 0:
                        length = len(operands)
                        for i in range(length-1):
                            operands.append(operands[i])
                        operands = operands[length-1:]
                        if words[0] == "swap":
                            operands.append(operands[len(operands)-1])
                        
                        for i in range(len(operands)):
                            ir += operands[i]
                            
                    ir += ('0' * (16-len(ir)))
                    #print("GroupA",ir,len(ir))
                    return ir,1
                elif words[0] in self.groupB.keys():    #shift
                    shift_value,valid = self.__parse_hex(words[2],5)
                    if valid == False:                  #large shift value
                        return '0',1
                    ir = "00" + self.groupB[words[0]] + self.registers[words[1]] + shift_value + "0"
                    #print("GroupB",ir,len(ir))
                    return ir,1
                elif words[0] in self.groupC.keys():    #immediate
                    if words[0] in self.TwoOperand:     #ldm
                        immediate_value,valid = self.__parse_hex(words[2],16)
                        if valid == False:
                            return '0',2
                        ir ="01" + self.groupC[words[0]] + self.registers[words[1]] + "00000" + immediate_value[0] + "1" + immediate_value[1:]
                    else:                               #iadd
                        immediate_value,valid = self.__parse_hex(words[3],16)
                        if valid == False:
                            return '0',2
                        ir ="01" + self.groupC[words[0]] + self.registers[words[2]] + self.registers[words[1]] + "00" + immediate_value[0] + "1" + immediate_value[1:]
                    #print("GroupC",ir,len(ir))
                    return ir,2
                elif words[0] in self.groupD.keys():    #memory
                    effective_address,valid = self.__parse_hex(words[2],20)
                    if valid == False:
                        return '0',2
                    ir = "01" + self.groupD[words[0]] + self.registers[words[1]] + "0" + effective_address[:5] + "1" + effective_address[5:]
                    #print("GroupD",ir,len(ir))
                    return ir,2
            except:
                pass 
        return '0'*16,0
    def __read_code_file(self):

        line_count = 0
        with open(self.path) as FILE:
            line = FILE.readline()
            while line:
                line_count += 1
                line = line.strip()
                if len(line) != 0 and line[0] != "#" :  #if the line isn't empty or comment
                    line = line.lower()
                    line = line.split("#", 1)[0]        #remove the comment
                    self.code_lines.append([line.strip(),line_count])
                line = FILE.readline()

    def __parse_hex(self,number,length):
        while len(number)*4 < length:   #complete the number
            number = "0" + number

        number = number[::-1]
        ret = ""
        for i in range(len(number)-1,-1,-1):
            ret += self.hex_to_bin[number[i]]

        if length == 5:
            return ret[3:],ret[:3] == "000"

        sign = ret[0]
        while len(ret) < length:
            ret = sign + ret
        
        return ret,len(ret) == length

    def __unsigned_bin_to_dec(self,number):
        ret = 0
        for i in range(len(number)):
            digit = number[len(number)-i-1]
            if digit == '1':
                ret += pow(2,i)
        return ret

    # Scan the code to get instructions.
    def __scan_code(self):
        for i in range(len(self.code_lines)):
            line = self.code_lines[i][0]
            line_words = line.split(" ", 1)

            if len(line_words) == 1:
                try:
                    number,valid = self.__parse_hex(line_words[0].strip(),32)
                    if valid == False or number[0] == '1':
                        print("invalid address in line "+str(self.code_lines[i][1]) + " !")
                        break
                    self.binary_code[self.current_code_mem_location]   = number[:16]
                    self.binary_code[self.current_code_mem_location+1] = number[16:]
                    continue
                except:
                    pass
            if len(line_words) == 2 and line_words[0][:4] == '.org':
                try:
                    number,valid = self.__parse_hex(line_words[1].strip(),32)
                    if valid == False:
                        print("Large Number in line "+str(self.code_lines[i][1]) + " !")
                        break
                    else:                               #normal address
                        if number[0] == '1':
                            print("Negative address in ORG line " + self.code_lines[i][1] + " !")
                            break
                        self.current_code_mem_location = self.__unsigned_bin_to_dec(number)
                    continue
                except:
                    print("invalid number in line "+str(self.code_lines[i][1]) + " !")
                    break
            
            ir, size = self.__get_instruction_info(line)

            if size == 0:
                print("invalid instruction in line " + str(self.code_lines[i][1]) + " !")
                return
            elif size == 1 and len(ir)==16:
                self.binary_code[self.current_code_mem_location] = ir
            elif size == 2 and len(ir)==32:
                    self.binary_code[self.current_code_mem_location]   = ir[16:]
                    self.binary_code[self.current_code_mem_location+1] = ir[:16]
            else:
                print("invalid immediate value in line " + str(self.code_lines[i][1]) + " !")
                return
            self.current_code_mem_location += size

    def __save_instructions(self):
        if len(self.binary_code.keys()) == 0:
            return
        mx = max(self.binary_code.keys())
        with open(self.code_output_path, "w") as f:
            for address in range(mx+1):
                if address in self.binary_code.keys():
                    f.write(self.binary_code[address]+"\n")
                else:
                    f.write('0'*16 + "\n")


if __name__ == '__main__':
    code_file_path = sys.argv[1]
    code_ram_file_path = sys.argv[2]
    a = Assembler(code_file_path, code_ram_file_path)
    a.parse()
