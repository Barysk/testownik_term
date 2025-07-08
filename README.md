# testownik_cli - テステル

テステル is a testownik app for solving tests created by PWr students. This is a terminal version made to be as light as possible – no unneeded interface or, god forbid, .js

Tesuteru comes from test terminal, if someone was wondering.

## Installation

No need, just start a binary and provide path, there will be no questions about making it your default ;)

Or if you want and you on linux system just move the binary to /usr/local/bin/

## Usage

```tesuteru <path/to/directory_with_quesions> <flags>```

### flags
```
-a - addintional repeats if you failed to answer correctly
-i - initial repeats for each question
-m - max repeats for each question
-c - activate cheat mode
-d - disable ansi codes (not recomended, use if your term doesn't support them for any reason. But consider upgrading your term, it not 1975 anymore bruh). Hope your term supprorts UTF-8 at least.
```

## How to write questions?

The same way you writing them for good old testownik

### here is an ideal example:

```
X0001
Która z poniższych metod jest popularnym szyfrem z kluczem publicznym?
RC4
IDEA
DES
ElGamal
```

### here is some examples from the test directory

More answers than defined at X -> last one is omitted

```001.txt
X01
Will this work if we will give more answers than defined at start?
No
Yes
What?
```

Less answers than defined at X -> one will be empty

```002.txt
X0100
Will this work if we will give less answers than defined at start?
No
Yes, but one question will be empty
Yes, but behaviour will be undefined
```

Is tesuteru any good? -> Yes.

```003.txt
X010
Is tesuteru any good?
no
definetly
maybe
```

Multichoice example -> separate numbers with ```,```

```004.txt
X1010
What about multichoice?
It is supported
To answer choose multiple answers you need to provide sequence of correct answers ex: 134
To answer choose multiple answers you need to provide sequence of correct answers separated by , ex: 1,3,4
I does not supported
```

## No windows?

For now, yes -> no windows. Why? Becouse ```Linking for cross compilation for this platform is not yet supported (windows amd64)```. So until either support will be provided, either I'll find free windows machine.

Hey you can totally compile if yourself ;)
