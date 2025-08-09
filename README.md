# :arrows_counterclockwise: CS271 Error Reverser

Final project for `CS271: Computer Architecture and Assembly Language` at Oregon State University. It has been approved for public sharing.

This Microsoft Macro Assembler (MASM) program reads a comma-delimited file containing ASCII-encoded temperature values that were stored in reverse order due to an intern's error. The program parses the values, converts them to signed integers, and prints them in the correct forward order.
 
It consists of these key components:

- `mGetString`: Macro to prompt the user and read a string input
- `mDisplayString` & `mDisplayChar`: Macros to simplify console output
- `ParseTempsFromString`: Procedure to parse and convert the ASCII values into integers
- `WriteTempsReverse`: Procedure to print the integers in reverse order

## :computer: Example Execution

```plaintext
Uh Oh! Did the intern make a mistake? Not to worry... Welcome to the Intern Error Reverser!
This programs reads a ','-delimited file storing various temperature values, in ASCII format.
It'll then convert the ASCII to signed integers and print them out in the corrected reverse order.

Enter the name of the file (20 characters max) to be read: temps.txt

Here's the corrected temperature order:
10,8,6,-2,0,-5,...
Thank you for using the Intern Error Reverser! Goodbye!
```

## :open_file_folder: File Structure
```
cs271-error-reverser/
├── README.md            # You are here
├── Proj6_bersta.asm     # MASM source code
└── Temps090124.txt      # Sample input file
```

## :bulb: Concepts Demonstrated

- Use of string primitive instructions (`LODSB`, `STOSD`) for character and array processing
- File input/output operations via the Irvine32 library:
  - `OpenInputFile`, `ReadFromFile`, `CloseFile`
- Stack-based parameter passing and local variable management with `EBP`
- Use of custom macros for modular code structure and reuse:
  - `mGetString`, `mDisplayString`, `mDisplayChar`
- ASCII-to-signed-integer conversion, including handling of negative values
- Reverse traversal of arrays using `STD` and pointer arithmetic

## :paperclip: Requirements

- Windows OS with MASM-compatible development environment (e.g., Visual Studio)
- Irvine32 library properly installed and configured
- Sample temperature data file in comma-delimited ASCII format (e.g., `Temps090124.txt`)

