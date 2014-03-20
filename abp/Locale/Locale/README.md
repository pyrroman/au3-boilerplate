au3-udfs
========
_A collection of my UDFs or forks of others_

### _FileGetMime()

An UDF for retrieving MIME types based on the extension of the filename/filepath/URL provided.

**Features:**
- contains DB of strict IANA MIMEs
- contains DB of non-strict IANA MIMEs
- can retrieve MIMEs from the Windows Registery
- can create MIME based on the filetype found in the Windows Registery
- can create MIME based on the extension (basically just prepends "application/x-")
- all resources above can be combined independently
- query time is between 0.5 - 1.5 ms (up to 2 ms on the first execution)

### VarDump()

An universal variable dumper.

**Features:**
- tries to print as much info as possible about any type of variable

### AsyncInet()

Asynchronous InetRead

**Features:**
- incredibly fast if you need to download many small files
