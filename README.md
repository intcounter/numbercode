numbercode
==========

numbercode is an application that converts back and forth between computer files and numbers with
decimal expansion between 0 and 1


BACKGROUND AND INFORMATION:

An alien came to earth with the express purpose of recording the sum of human knowledge to bring
back to his home planet. He came, he saw, he put a small notch into a metal rod, and he was off.
Somehow, with nothing more than a notch on a metal rod, the alien had recorded nearly the sum
total of all human knowledge. How did he do it?

With numbercode of course! Imagine the sum of human knowledge encoded as a data file. (Perhaps
a backup of Wikipedia?) Now imagine that data file as a string of 0s and 1s. If you put a decimal
point in front of that huge string, you could picture this file as the binary expansion of some
number between 0 and 1. Thus if you could record this number (perhaps as a notch on a metal number
line), you would have recorded a tremendous amount of information. This is how the alien stored
human knowledge as a notch on a metal rod.

(Note though that limits on the precision with which one can create a notch sort of destroys this
fun thought experiment)

numbercode was built based on this thought experiment. This program will take a data file and
convert it into a number between 0 and 1 (interpreting the file just as described above). This
number's decimal expansion is then output as a text file. It can also convert back: taking
a text file containing the decimal expansion of a number between 0 and 1 and converting it
back into a data file.


EXAMPLE:

In the directory ./example/ you will find intcounter.jpg, a 2kb image file, which was converted
by numbercode into intcounter.txt. You will see that intcounter.jpg is stored as the number:

  0.9994048997...5634765625
  
where we have omitted about 12756 digits in the preceding expansion.


COMPILATION AND USE:

Compile numbercode with the -O option (e.g. ghc -O numbercode.hs) to optimize the program. The
numbercode application performs large precision arithmetic (precision matching the number of
bits in the data file being converted), and so it can easily choke on large files (where large
in this case means >50kb).

Example log of usage for encoding (decoding is similar):

numbercode.exe

Would you like to encode a file (e) or decode (d):

e

Please enter the data file to encode:

intcounter.jpg

Please enter the number file to output:

intcounter.txt
