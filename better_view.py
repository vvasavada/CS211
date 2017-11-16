import string
import os
import sys
import argparse

def process_file(f_read, f_write):
	
	if not os.path.isfile(f_read):
		print "No such file exists:", f_read

	if os.path.isfile(f_write):
		os.remove(f_write)
		
	with open(f_read, "r") as hex_istp:
		hex_s = hex_istp.readline()
		while len(hex_s) > 0:
			printable = string.printable
			translated_s = "".join(c if c in printable else c.encode("hex") for c in hex_s)
			print "Writing to file:", translated_s
			with open(f_write, "a") as translated_istp:
				translated_istp.write(translated_s)
			hex_s = hex_istp.readline()

if __name__ == "__main__":
	parser = argparse.ArgumentParser(description="")
	parser.add_argument("in_f", help="Input Hex ISTP File Path")
	parser.add_argument("out_f", help="Output Translated File Path")
	args = parser.parse_args()
	
	process_file(args.in_f, args.out_f)
