import string
import os
import sys
import argparse


def process_file(f_read, f_write):

	AT_COMMANDS = {}
	
	if not os.path.isfile(f_read):
		print "No such file exists:", f_read

	if os.path.isfile(f_write):
		os.remove(f_write)

	xsio_extracted = False
		
	with open(f_read, "r") as hex_istp:
		hex_s = hex_istp.readline()
		while len(hex_s) > 0:
			printable = string.printable
			translated_s = "".join(c if c in printable else '?' for c in hex_s)

			# we only check for AT+ or at+
			# aT and At are invalid

			if not xsio_extracted:
				if translated_s.find("+xsio") or translated_s.find("+XSIO"):
					AT_COMMANDS["+xsio"] = "+xsio"
					xsio_present = True

			index = translated_s.find("AT+")	
			if index == -1:
				index = translated_s.find("at+")
			if index >= 0:
				s = ""
				c = translated_s[index]
				while c != '=' and c != '?':
					s += c
					index += 1
					c = translated_s[index]

				# ignore AT+<single char> commands
				# as they dont seem to exist
				# but might be present in file because of the 
				# decode error in the form AT+C????

				if len(s) > 4 and s not in AT_COMMANDS:
					AT_COMMANDS[s] = s

			hex_s = hex_istp.readline()

	with open(f_write, "a") as at_commands:
		for command in AT_COMMANDS:
			print "Writing to the file:", command
			at_commands.write(command.upper() + "\n")

if __name__ == "__main__":
	parser = argparse.ArgumentParser(description="")
	parser.add_argument("in_f", help="Input Hex ISTP File Path")
	parser.add_argument("out_f", help="Output AT Commands File Path")
	args = parser.parse_args()
	
	process_file(args.in_f, args.out_f)
