#include<iostream>
#include<fstream>
#include<algorithm>
#include<string>
#include<array>
#include<vector>
#include<map>

class Parser {
public:
	const size_t A_INSTRUCTION = 0;
	const size_t C_INSTRUCTION = 1;
	const size_t L_INSTRUCTION = 2;

	std::string current_instruction, current_line;
	std::vector<std::string>all_instructions;
	std::vector<std::string>::iterator it;

	Parser(std::ifstream &fin) {
		while (std::getline(fin, current_line)) {
			while(current_line.back()=='\n' || current_line.back()==(char)(13)){
				current_line.pop_back();
			}

			while (current_line.find(' ') != std::string::npos) {
				current_line.erase(current_line.find(' '), 1);
			}
			if (current_line.find("//") != std::string::npos) {
				current_line.erase(current_line.find("//"));
			}
			if (current_line.empty()) continue;

			all_instructions.push_back(current_line);
		}
	}

	bool hasMoreLines() {
		return it != all_instructions.end();
	}

	void init() {
		it = all_instructions.begin();
		current_instruction = *it;
	}

	void advance() {
		++it;
		if(it!=all_instructions.end()) {
			current_instruction = *it;
		}
	}

	size_t instructionType() {
		if (current_instruction[0] == '@') return A_INSTRUCTION;
		if (current_instruction[0] == '(') return L_INSTRUCTION;
		return C_INSTRUCTION;
	}

	std::string symbol() {
		std::string ans = current_instruction;
		ans.erase(ans.begin());
		if (ans.back() == ')') ans.pop_back();
		return ans;
	}

	std::string dest() {
		if (current_instruction.find('=') == std::string::npos) {
			return "null";
		}
		size_t eq_pos = current_instruction.find('=');
		return current_instruction.substr(0, eq_pos);
	}

	std::string comp() {
		std::string ans = current_instruction;

		size_t eq_pos = current_instruction.find('=');
		if (eq_pos != std::string::npos) {
			ans.erase(0, eq_pos + 1);
		}

		size_t semicolon_pos = current_instruction.find(';');
		if (semicolon_pos != std::string::npos) {
			ans.erase(semicolon_pos);
		}

		return ans;
	}

	std::string jump() {
		size_t semicolon_pos = current_instruction.find(';');
		if (semicolon_pos == std::string::npos) {
			return "null";
		}

		return current_instruction.substr(semicolon_pos + 1);
	}
};

class Code {
public:
	std::map<std::string, std::string>dest_table, comp_table, jump_table;

	Code() {
		comp_table["0"] = "0101010";
		comp_table["1"] = "0111111";
		comp_table["-1"] = "0111010";
		comp_table["D"] = "0001100";
		comp_table["A"] = "0110000";
		comp_table["M"] = "1110000";
		comp_table["!D"] = "0001101";
		comp_table["!A"] = "0110001";
		comp_table["!M"] = "1110001";
		comp_table["-D"] = "0001111";
		comp_table["-A"] = "0110011";
		comp_table["-M"] = "1110011";
		comp_table["D+1"] = "0011111";
		comp_table["A+1"] = "0110111";
		comp_table["M+1"] = "1110111";
		comp_table["D-1"] = "0001110";
		comp_table["A-1"] = "0110010";
		comp_table["M-1"] = "1110010";
		comp_table["D+A"] = "0000010";
		comp_table["D+M"] = "1000010";
		comp_table["D-A"] = "0010011";
		comp_table["D-M"] = "1010011";
		comp_table["A-D"] = "0000111";
		comp_table["M-D"] = "1000111";
		comp_table["D&A"] = "0000000";
		comp_table["D&M"] = "1000000";
		comp_table["D|A"] = "0010101";
		comp_table["D|M"] = "1010101";

		jump_table["null"] = "000";
		jump_table["JGT"] = "001";
		jump_table["JEQ"] = "010";
		jump_table["JGE"] = "011";
		jump_table["JLT"] = "100";
		jump_table["JNE"] = "101";
		jump_table["JLE"] = "110";
		jump_table["JMP"] = "111";
	}

	std::string dest(std::string s) {
		std::string ans = "";
		ans += (s.find("A")!=std::string::npos)?"1":"0";
		ans += (s.find("D")!=std::string::npos)?"1":"0";
		ans += (s.find("M")!=std::string::npos)?"1":"0";
		return ans;
	}

	std::string comp(std::string s) {
		return comp_table[s];
	}

	std::string jump(std::string s) {
		return jump_table[s];
	}
};

class SymbolTable {
public:
	std::map<std::string, size_t> table;

	SymbolTable() {
		table["R0"] = 0;
		table["R1"] = 1;
		table["R2"] = 2;
		table["R3"] = 3;
		table["R4"] = 4;
		table["R5"] = 5;
		table["R6"] = 6;
		table["R7"] = 7;
		table["R8"] = 8;
		table["R9"] = 9;
		table["R10"] = 10;
		table["R11"] = 11;
		table["R12"] = 12;
		table["R13"] = 13;
		table["R14"] = 14;
		table["R15"] = 15;
		table["SCREEN"] = 16384;
		table["KBD"] = 24576;
		table["SP"] = 0;
		table["LCL"] = 1;
		table["ARG"] = 2;
		table["THIS"] = 3;
		table["THAT"] = 4;
	}
	void addEntry(std::string s, size_t address) {
		table[s] = address;
	}
	bool contains(std::string s) {
		return table.count(s);
	}
	size_t getAddress(std::string s) {
		return table[s];
	}
};

void solve(std::string prog_name) {
	std::ifstream fin;
	fin.open(prog_name + ".asm", std::ios::in);

	std::ofstream fout;
	fout.open(prog_name + ".hack", std::ios::out);

	// run
	Parser parser(fin);
	Code code;
	SymbolTable symbol_table;

	// first pass
	size_t instruction_count = 0;
	parser.init();

	while (true) {
		if (parser.instructionType() == parser.L_INSTRUCTION) {
			symbol_table.addEntry(parser.symbol(), instruction_count);
		}
		else {
			instruction_count++;
		}

		parser.advance();
		if (!parser.hasMoreLines()) break;
	}

	// second pass;
	size_t last_address = 16;
	parser.init();
	while (true) {
		if (parser.instructionType() == parser.A_INSTRUCTION) {
			auto is_number = [](std::string s)->bool {
				return !s.empty() && std::find_if(s.begin(), s.end(), [](char c) { return !std::isdigit(c); }) == s.end();
			};
			auto to_binary = [](size_t val)->std::string{
				std::string ans = "";
				for(int bit = 14 ; ~bit ; bit--){
					ans += (val>>bit&1)?"1":"0";
				}
				return ans;
			};

			auto symbol = parser.symbol();
			if (is_number(symbol)) {
				fout << "0" + to_binary(stoi(symbol)) << std::endl;
			}
			else {
				if (!symbol_table.contains(symbol)) {
					symbol_table.addEntry(symbol, last_address);
					last_address++;
				}
				fout << "0" + to_binary(symbol_table.getAddress(symbol)) << std::endl;
			}
		}
		else if (parser.instructionType() == parser.C_INSTRUCTION) {
			fout << "111" + code.comp(parser.comp()) + code.dest(parser.dest()) + code.jump(parser.jump()) << std::endl;
		}
		else {
			// do nothing
		}

		parser.advance();
		if (!parser.hasMoreLines()) break;
	}

	fout.close();
	fin.close();
}

int main(int argc, char *argv[]) {
	std::string prog_name = std::string(argv[1]);
	// prog_name.erase(prog_name.find(".asm"));

	solve(prog_name);

	return 0;
}