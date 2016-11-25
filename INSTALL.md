# Install Elixir on the Raspberry PI 3

We need Erlang first, then we add Elixir.

Check you have more than 300 MB of space on disc. How much depends on the exact version you're compiling. 500 MB should be safe.

## Erlang

There is no Erlang binary for the Raspberry yet. We must compile it from source.
Download the latest version from http://erlang.org/download/
It's named like ```otp_src_<version>.tar.gz```

Example:

```
cd
wget http://erlang.org/download/otp_src_19.1.tar.gz
```

Compute the checksum

```
md5sum otp_src_19.1.tar.gz # or get md5sum with sudo apt-get install coreutils
```

and check that it matches the one at http://erlang.org/download/MD5

```
sudo apt-get curl
curl -s http://erlang.org/download/MD5 | grep otp_src_19.1.tar.gz
```

If the checksums don't match don't proceed any further. You probably did something wrong or the file didn't download completely. The worst case is that somebody is trying to snatch malware into those files.

```
tar xzf otp_src_19.1.tar.gz # this is slow
cd otp_src_19.1
./configure
```

If it complains that some package is missing google the ```apt-get``` to install it.

I got

```
odbc           : ODBC library - link check failed
wx             : wxWidgets not found, wx will NOT be usable
documentation  :
                 xsltproc is missing.
                 fop is missing.
                 xmllint is missing.
                 The documentation can not be built.
```

which are OK for most use cases.

Finally run

```
make
```

which is very slow. You'll appreciate a fast SD card here. With a Cat 10 8 GB SD my Raspberry 3 took almost 28 minutes. Run ```time make``` if you want to measure how slow it is for you.

```
sudo make install
```

Erlang is installed to ```/usr/local/bin/erl```

```
$ erl
Erlang/OTP 19 [erts-8.1] [source] [smp:4:4] [async-threads:10] [hipe] [kernel-poll:false]

Eshell V8.1  (abort with ^G)
1>
```

## Elixir

Installing Elixir is easier because we can just download the precompiled version (for Erlang) from https://github.com/elixir-lang/elixir/releases/

Go to that page to find out what the last version is. Check that it matches the version of Erlang you just compiled. For this example it's Elixir 1.4.3.

```
cd
wget https://github.com/elixir-lang/elixir/releases/download/v1.3.4/Precompiled.zip
mkdir elixir
cd elixir
sudo apt-get install unzip
unzip ../Precompiled.zip
```

This creates an ```elixir``` directory. Add the location of the binaries to ```PATH```

```
cd
echo 'if [ -d "$HOME/elixir/bin" ] ; then' >> .profile
echo '    PATH="$HOME/elixir/bin:$PATH"' >> .profile
echo 'fi' >> .profile
source .profile
```

Check that it works

```
$ iex
Erlang/OTP 19 [erts-8.1] [source] [smp:4:4] [async-threads:10] [hipe] [kernel-poll:false]

Interactive Elixir (1.3.4) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)>
```

## Clean up

```
cd
rm -fr otp_src_19.1/ otp_src_19.1.tar.gz Precompiled.zip
```
