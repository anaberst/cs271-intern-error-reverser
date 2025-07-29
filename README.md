# 🔁 CS271 Intern Error Reverser

Final project for `CS271: Computer Architecture and Assembly Language` at Oregon State University. It has been approved for public sharing.

This Microsoft Macro Assembler (MASM) program reads a comma-delimited file containing ASCII-encoded temperature values that were stored in reverse order due to an intern's mistake. The program parses the values, converts them to signed integers, and prints them in the correct forward order.

It highlights low-level manipulation of strings, macros, and file I/O using x86 assembly.

## 🧠 Program Features

- Prompts the user for the filename of the temperature data
- Reads a single line of comma-separated ASCII values from the file
- Converts ASCII strings to signed integers (handling negatives)
- Prints the converted values in reverse order
- Includes custom macros for input/output abstraction

## 🛠️ Key Components

- `mGetString`: Macro to prompt the user and read a string input
- `mDisplayString` & `mDisplayChar`: Macros to simplify console output
- `ParseTempsFromString`: Procedure to parse and convert the ASCII values into integers
- `WriteTempsReverse`: Procedure to print the integers in reverse order

## 🧪 Example Execution

```plaintext
Uh Oh! Did the intern make a mistake? Not to worry... Welcome to the Intern Error Reverser!
This programs reads a ','-delimited file storing various temperature values, in ASCII format.
It'll then convert the ASCII to signed integers and print them out in the corrected reverse order.

Enter the name of the file (20 characters max) to be read: temps.txt

Here's the corrected temperature order:
10,8,6,-2,0,-5,...
Thank you for using the Intern Error Reverser! Goodbye!
