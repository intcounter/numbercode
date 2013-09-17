{-|
 The following program converts files into numbers. Each file is regarded as
 a binary string, and then that string is regarded as a number between 0 and 1
 by imagining that binary string to be the binary expansion to the right of a
 decimal point. This program converts such numbers into decimal expansions and
 can convert such decimal expansions back into files.

 Compile with optimization (-O flag) and keep file size small (50kb and under?)
-}
import Data.Char
import System.IO

{-| 
 Define two new datatypes: DecFrac, which represents a decimal number between
 0 and 1, and BinFrac, which represents a binary number between 0 and 1.
 DecFrac is represented by a pair: num, a numerator, and logDenom, the log base
 10 of the denominator (hence the number of places by which the decimal has
 been moved to produce num). BinFrac is represented as a string (all the binary
 digits to the right of the decimal place)
-} 
data DecFrac = DecFrac { num :: Integer, logDenom :: Int }
type BinFrac = String

instance Show DecFrac where
	show x = "0." ++ replicate (logDenom x - length showIt) '0' ++ showIt
		where showIt = show . num $ x

{-|
 The main IO action gives the user a choice:
  'e': Encode a file into a decimal number between 0 and 1. As an example, the
       user might encode the file 'image.gif' into a number contained in the
       file 'image.txt'. 'image.txt' would then contain the decimal expansion
       of a number between 0 and 1, split to 80 characters per line.
  'd': Decode a number back into the file from which it originally came. So for
       example the user might take the number in 'image.txt' from above and
       convert it back to 'image.gif'
-}
main = do
	putStrLn "Would you like to encode a file to a number (e) or decode (d): "
	ch <- getLine
	let choice = map toLower ch
	case choice of
		"e" -> fileToNumber
		"d" -> numberToFile
		_ -> do
			putStrLn "Invalid option. Try again."
			main

-- Convert a file to a decimal number between 0 and 1 and write to a txt file
fileToNumber :: IO ()
fileToNumber = do
	putStrLn "Please enter the data file to encode: "
	fileIn <- getLine
	putStrLn "Please enter the number file to output: "
	fileOut <- getLine
	handleIn <- openBinaryFile fileIn ReadMode
	contentsIn <- hGetContents handleIn
	let binstring = concat $ map (byte . ord) contentsIn
	    number = noTrailing . show . binFracToInt $ binstring
	    split = splitString 80 number
	handleOut <- openFile fileOut WriteMode
	hPutStr handleOut (unlines split)
	hClose handleOut
	hClose handleIn
	return ()

-- Convert a decimal number between 0 and 1 back into a digital file
numberToFile :: IO ()
numberToFile = do
	putStrLn "Please enter the number file to decode: "
	fileIn <- getLine
	putStrLn "Please enter the data file to output: "
	fileOut <- getLine
	handleIn <- openFile fileIn ReadMode
	contentsIn <- hGetContents handleIn
	let number = concat . lines $ contentsIn
	    bits = fracbinToChars . fracToBin . fracToInt $ number
	handleOut <- openBinaryFile fileOut WriteMode
	hPutStr handleOut bits
	hClose handleOut
	hClose handleIn
	return ()

-- Given an Integral x, convert to a reversed binary string
reverseBinary :: (Integral a) => a -> String
reverseBinary x
	| x == 0 = ""
	| odd x = '1':reverseBinary ((x-1) `div` 2)
	| otherwise = '0':reverseBinary (x `div` 2)

-- Given an Integral x, convert to a binary string
binary :: (Integral a) => a -> String
binary = reverse . reverseBinary

-- Given an Integral x between 0 and 255, convert to a byte string of 0s and 1s
byte :: (Integral a) => a -> String
byte x = pad ++ bin
	where bin = binary x
	      pad = replicate (8 - length bin) '0'

-- Given a reversed binary string, convert back to the corresponding integer
rBinToInt :: String -> Integer
rBinToInt "" = 0
rBinToInt (x:xs)
	| x == '0' = 2*(rBinToInt xs)
	| otherwise = 1 + 2*(rBinToInt xs)

-- Given a binary string, convert back to the corresponding integer
binToInt :: String -> Integer
binToInt = rBinToInt . reverse

-- Given a string, remove all trailing zeros
noTrailing :: String -> String
noTrailing = reverse . (dropWhile (== '0')) . reverse

-- Given a binary fraction, convert to a DecFrac (decimal fraction)
binFracToInt :: BinFrac -> DecFrac
binFracToInt x = DecFrac (5^(len)*binToInt x) len
	where len = length x

-- Given a string representing a DecFrac, convert to a DecFrac
fracToInt :: String -> DecFrac
fracToInt (_:_:xs) = DecFrac (read xs) (length xs)

-- Given a DecFrac, convert to a binary fraction
fracToBin :: DecFrac -> BinFrac
fracToBin x = replicate padNum '0' ++ digs
	where digs = binary $ (num x) `div` (5^(logDenom x))
	      padNum = (logDenom x) - (length digs)

-- Pad a string with 0s so that the number of bits is divisible by 8
bytePad :: String -> String
bytePad x = x ++ replicate padNum '0'
	where padNum = (8 - ((length x) `rem` 8)) `rem` 8

-- Split up a string into a list of strings of a prescribed length
splitString :: Int -> String -> [String]
splitString _ "" = []
splitString n x = (take n x):splitString n (drop n x)

-- Take a binary fraction and convert each byte into corresponding chars
fracbinToChars :: BinFrac -> String
fracbinToChars x = map (chr . fromIntegral . binToInt) bytes
	where bytes = splitString 8 . bytePad $ x