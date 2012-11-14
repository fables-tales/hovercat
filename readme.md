#Hovercat cipher


Setup:
```
git clone samphippen/hovercat
git submodule init
git submodule update
cd lsquare
make
cd ../
ruby hovercat.rb

```

Hovercat is a simple encryption based on a latin square.

The encryption and decryption process is best explained with pictures. But
the basic idea is to find the character in the plaintext you're looking for
(start from the top left) and then draw an arrow with the three characters
around it pointing to the next one. Examples:



```
 1
3l2

next direction: up

3l1
 2

next direction: down

1
l2
3

next direction right

 1
3l
 2

next direction: left
```

you should always do this in a clockwise fashion. If you're currently searching
a row, search a column, if you're currently searching a column search a row.

DL and run the code for examples.
