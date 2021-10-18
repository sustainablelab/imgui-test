# Create a repo

I create this Git repository to test IMGUI:

```bash
$ cd ~/gitrepos
$ mkdir imgui-test
$ cd imgui-test
$ git init
```

## Add IMGUI

I add IMGUI as a Git Submodule:

```bash
$ cd ~/gitrepos/imgui-test
$ git submodule add https://github.com/ocornut/imgui.git
```

# Test gcc

Test gcc. Create `bob.c`:

```c
int main(void){}
```

Generate disassembly:

```bash
$ gcc -S bob.c 
```

Open `bob.s`:

```asm
	.file	"bob.c"
	.text
	.def	__main;	.scl	2;	.type	32;	.endef
	.globl	main
	.def	main;	.scl	2;	.type	32;	.endef
	.seh_proc	main
main:
	pushq	%rbp
    ...
	popq	%rbp
	ret
	.seh_endproc
	.ident	"GCC: (Rev5, Built by MSYS2 project) 10.3.0"
```

# Start a Makefile

I create a Makefile similar to the IMGUI examples Makefile, but I
can simplify it a lot because I don't need to generalize for all
frameworks and all operating systems.

## What compiler is CXX

Start the Makefile with this simple recipe to find out what
compiler is invoked by variable `CXX`:

```make
.PHONY:
what-compiler: 
	@echo $(CXX)
```

- `echo` prints recipe and its result to stdout
- `@echo` prints only the result (recipe is silenced)

Find out what the compiler is:

```bash
$ make
g++
```
# Find files

## Vim find

View the Vim `path` variable:

```vim
:echo &path
```

In my `.vimrc`, I start `path` with `.,**`

- `,` separates paths
- `.` means the current directory
- `**` is a recursive dive into this directory

`path` determines where `:find` looks for files. Since IMGUI is
cloned as a submodule, if I do `:find` from this top-level, the
first place Vim checks is recursively into every folder in this
directory.

Find `imgui.h`:

```vim
:find imgui.h
```

That command opens `imgui/imgui.h`. This is useful when looking
at C code. Code often starts with a header include like `#include
<imgui.h>`. I put the cursor on the name of the file and use
shortcut `gf`. This works the same way as `:find`.

## GNU find

```bash
$ find -name main.cpp
./imgui/examples/example_allegro5/main.cpp
./imgui/examples/example_android_opengl3/main.cpp
./imgui/examples/example_emscripten_opengl3/main.cpp
./imgui/examples/example_emscripten_wgpu/main.cpp
./imgui/examples/example_glfw_opengl2/main.cpp
./imgui/examples/example_glfw_opengl3/main.cpp
./imgui/examples/example_glfw_vulkan/main.cpp
./imgui/examples/example_glut_opengl2/main.cpp
./imgui/examples/example_marmalade/main.cpp
./imgui/examples/example_null/main.cpp
./imgui/examples/example_sdl_directx11/main.cpp
./imgui/examples/example_sdl_opengl2/main.cpp
./imgui/examples/example_sdl_opengl3/main.cpp
./imgui/examples/example_sdl_sdlrenderer/main.cpp
./imgui/examples/example_sdl_vulkan/main.cpp
./imgui/examples/example_win32_directx10/main.cpp
./imgui/examples/example_win32_directx11/main.cpp
./imgui/examples/example_win32_directx12/main.cpp
./imgui/examples/example_win32_directx9/main.cpp
```

## Combine GNU find and Vim find

When there are lots of matches, such as `main.cpp`:

- paste the result of GNU find into a Vim buffer
- place the cursor on the desired match
- hit `gf` to go to that file

# Identify library dependencies

Use the `gf` trick to open
`./imgui/examples/example_glfw_opengl3/main.cpp`.

Copy the include statements from `main.cpp` into `bob.c`:

```c
#include "imgui.h"
#include "imgui_impl_glfw.h"
#include "imgui_impl_opengl3.h"
#include <stdio.h>
#include <GLFW/glfw3.h> // Will drag system OpenGL headers
```

Add this recipe to the Makefile:

```make
MY_MAIN = bob.c

.PHONY:
print-libs: $(MY_MAIN)
	$(CXX) $< -M > libs.txt
```

*I make variable `MY_MAIN` because I know I'll be changing the
name `bob.c` to something else soon.*

Run this recipe (it will fail):

```fail-to-make-libs.txt
$ make print-libs
g++ bob.c -M > libs.txt
bob.c:1:10: fatal error: imgui.h: No such file or directory
    1 | #include "imgui.h"
      |          ^~~~~~~~~
compilation terminated.
```

We need to tell the compiler where to find header files.

Use the GNU find trick to list all the Makefiles and the `gf`
trick to open `./imgui/examples/example_glfw_opengl3/Makefile`.

Use `:vimgrep` to find `CXXFLAGS`:

```vim
:vimgrep CXXFLAGS %
:copen
```

- `%` means "this file"
- `:copen` opens the *Quickfix List* buffer
    - this has the `:vimgrep` search results

```vimgrep-Quickfix-List
imgui/examples/example_glfw_opengl3/Makefile|26 col 1| CXXFLAGS = -I$(IMGUI_DIR) -I$(IMGUI_DIR)/backends
imgui/examples/example_glfw_opengl3/Makefile|27 col 1| CXXFLAGS += -g -Wall -Wformat
imgui/examples/example_glfw_opengl3/Makefile|35 col 3| # CXXFLAGS += -DIMGUI_IMPL_OPENGL_ES2
imgui/examples/example_glfw_opengl3/Makefile|46 col 2| CXXFLAGS += `pkg-config --cflags glfw3`
imgui/examples/example_glfw_opengl3/Makefile|47 col 13| CFLAGS = $(CXXFLAGS)
imgui/examples/example_glfw_opengl3/Makefile|57 col 2| CXXFLAGS += -I/usr/local/include -I/opt/local/include -I/opt/homebrew/include
imgui/examples/example_glfw_opengl3/Makefile|58 col 13| CFLAGS = $(CXXFLAGS)
imgui/examples/example_glfw_opengl3/Makefile|65 col 2| CXXFLAGS += `pkg-config --cflags glfw3`
imgui/examples/example_glfw_opengl3/Makefile|66 col 13| CFLAGS = $(CXXFLAGS)
imgui/examples/example_glfw_opengl3/Makefile|74 col 11| $(CXX) $(CXXFLAGS) -c -o $@ $<
imgui/examples/example_glfw_opengl3/Makefile|77 col 11| $(CXX) $(CXXFLAGS) -c -o $@ $<
imgui/examples/example_glfw_opengl3/Makefile|80 col 11| $(CXX) $(CXXFLAGS) -c -o $@ $<
imgui/examples/example_glfw_opengl3/Makefile|86 col 20| $(CXX) -o $@ $^ $(CXXFLAGS) $(LIBS)
```

The useful bits are lines 26, 27, and 67. Copy these bits into my Makefile:

```make
IMGUI_DIR = ./imgui/
CXXFLAGS = -I$(IMGUI_DIR) -I$(IMGUI_DIR)/backends # <--- Line 26
CXXFLAGS += -g -Wall -Wformat # <----------------------- Line 27
CXXFLAGS += `pkg-config --cflags glfw3` # <------------- Line 67
```

The essential edit to my `print-libs` recipe is this:

```make
.PHONY:
print-libs: bob.c
	$(CXX) -I$(IMGUI_DIR) -I$(IMGUI_DIR)/backends $< -M > libs.txt
```

Same thing, but use the `CXXFLAGS` variable:

```make
.PHONY:
print-libs: bob.c
	$(CXX) $(CXXFLAGS) $< -M > libs.txt
```

This makes `libs.txt`, a list of paths to all 43 headers that are
included.

Now I know how to find paths to dependencies. I use this to tell
Vim where to look for files, and to create a special tags list
for dependencies.

Now that I have the recipe working, I'm going to get rid of the
`.PHONY` and change the target name from `print-libs` to
`libs.txt`:

```make
libs.txt: $(MY_MAIN)
	$(CXX) $(CXXFLAGS) $< -M > $@
```

The reason I made this change is that I'm going to make another
recipe that needs `libs.txt`. I don't want to write my recipe
for `libs.txt` twice (there should only be one place I define
how to generate `libs.txt`). And I don't want `make` to recreate
this file if I already have it. I do want `make` to recreate this
file if `MY_MAIN` file (`bob.c`) has changed (because I might
have changed the `#include` lines). The above recipe does all
that.

## Edit Vim path

Two of the 43 paths start with `imgui/`, so my simple
`.,**` Vim `path` works for those two headers. For the other 41,
I need to add their folders to Vim `path`.

The whole point of this is to make it easy to find files. I'm
probably not going to need to find most of these, but if, for
example, I want to find `C:/msys64/mingw64/include/GLFW/glfw3.h`,
I need to edit my path. Start the path at `/mingw64`, ignore the
parents above that.

For example, my `.vimrc` sets up `path` like this:

```vim
set path=.
set path+=**
let &path = &path . ',' . '/mingw64/x86_64-w64-mingw32/include/'
let &path = &path . ',' . '/mingw64/include/GLFW/'
```

## Tags

First I add a recipe to generate tags lists for my project:

```make
.PHONY: tags
tags: main.cpp
	ctags --c-kinds=+l --exclude=Makefile -R .
```

And I make those tags:

```bash
$ make tags
ctags --c-kinds=+l --exclude=Makefile -R .
```

I also want tag hopping to work when the definitions are in my
dependencies. The `libs.txt` has my dependencies, but I need to
do a little formatting to use that file with `ctags`. Here is a
Python script to format the paths:

```python
#!/usr/bin/python
# -*- coding: utf-8 -*-
import pathlib
with open("libs.txt") as fin:
    with open("headers-posix.txt", mode="w") as fout:
        for line in fin:
            for s in line.split():
                if '.h' in s:
                    fout.write(str(pathlib.PurePosixPath(s)))
                    fout.write("\n")
```

And the `make` recipe to generate tags for my dependencies:

```make
.PHONY: lib-tags
lib-tags: libs.txt
	python.exe parse-lib-tags.py
	rm -f headers-windows.txt
	ctags -f lib-tags --c-kinds=+p -L headers-posix.txt
	rm -f headers-posix.txt
```

Generate the lib-tags:

```bash
$ make lib-tags
python.exe parse-lib-tags.py
rm -f headers-windows.txt
ctags -f lib-tags --c-kinds=+p -L headers-posix.txt
rm -f headers-posix.txt
```

Now I have two tags files: `tags` and `lib-tags`. I tell Vim to
use both by editing my `.vimrc` to use definition of the Vim
`tags` variable:

```vim
set tags=./tags,tags,lib-tags
```
