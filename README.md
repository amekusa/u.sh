# U.SH
A collection of utility libraries for shell scripting in Bash/Zsh

- Current: `v0.1.0`
- Author: [@amekusa](https://github.com/amekusa)


## FEATURES
- Customizable function prefix
- Does not load the same library twice
- Supports caching to minimize the loading overheads


## INSTALLATION


### Via Git Submodule

```sh
git submodule add https://github.com/amekusa/ush.git
```

Initialize/Update submodule:

```sh
git submodule update --init
```


## USAGE
```sh
#!/usr/bin/env bash
. ush/load util     # Load util lib
. ush/load util io  # Load util & io libs
```

By default, all the functions are prefixed with `_(underscore)`.
If you don't like it however, it can be changed to whatever you like with `--prefix` or `-p` option:

```sh
#!/usr/bin/env bash
. ush/load --prefix 'my_' util  # Prefixise util with 'my_'
. ush/load -p 'my_' util io     # Prefixise util & io with 'my_'
```

Then, all the functions in the specified libraries are renamed to have the specified prefix instead of `_`.


### Available Options
```
--prefix <prefix> : Custom prefix for functions (default: '_')
--p <prefix>
--verbose, -v     : Output debug messages
--cache, -c       : Enable cache (default: true)
--no-cache        : Disable cache
--cache-ttl <sec> : Cache lifespan (default: 3600) (Negative number means infinity)
```


## DOCUMENTATIONS
Not ready yet.


## LICENSE

	MIT License

	Copyright (c) 2022 Satoshi Soma

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
