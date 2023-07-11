---
# try also 'default' to start simple
theme: apple-basic
# https://sli.dev/custom/highlighters.html
highlighter: shiki
lineNumbers: false
info: |
  ## Nix
drawings:
  persist: false
transition: slide-left
canvasWidth: 700
---

<style>
.slidev-code {
  line-height: 1 !important;
}
</style>

### Moderator Slide 

# Preparations

Install nix with flakes and new commands enabled.
Add a default repository for repl demos:

```nix
nix-channel --add https://channels.nixos.org/nixos-23.05 nixpkgs
nix-channel --update
```

```bash
alacritty -o font.size=20 --working-directory demo -e nix repl
```


---
layout: quote
---

## "Yes, Fabian, nix does sounds amazing, but again,  
## &nbsp;&nbsp;I'll wait for your nix talk before I get started." 

&mdash; Anonymous 😁

---
layout: statement
---

So welcome to the

# ultimate<br>comprehensive<br>nix talk 

™️. Sorry!

---
layout: statement
---

Once upon a time in 2006...

# The Purely Functional Software Deployment Model

&nbsp;  
[Eelco Dolstra, PhD Thesis](https://edolstra.github.io/pubs/phd-thesis.pdf)


---

# 🎯 My Goals for Today: You...

- are introduced you to the Nix universe
- understand how NixOS is built up
- know how to setup NixOS and nix in your projects
- know where to look up stuff

---

# 🎯 What we'll take a look at today

* `nix` (the tool)  
* Nix (the expression language)  
* nixpkgs
* NixOS  
* Nix Flakes

&nbsp;  
🤔 What are they?  
🤔 How on earth are they all connected?


---
layout: section
---

# With no further ado: `nix`.


---

# `nix` is a functional build tool

 📥 **Input:**

- Build instruction (defined in Nix)
- Source code
- Build tools / script

📤 **Output:**

- Build results (immutable)

Easy as that!

---

🤓
The [nix manual](https://nixos.org/manual/nix/stable) states that:




> Nix is a *purely functional package manager*.  
> &nbsp;  
>  This means that it treats packages like values [...] —  
> they are **built by functions that don’t have side-effects,  
> and they never change after they have been built**

* No side effects
* Results are immutable

---

## Q: So how are build results stored?

**A: The _Nix Store_**!

> Nix stores packages in [...] the directory `/nix/store`,  
> where each package has its own unique subdirectory such as

```bash
/nix/store/b6gvzjyb2pg0kjfwrjmg1vfhh54ad73z-firefox-33.1/
```

> 
> where `b6gvzjyb2pg0…` is a unique identifier for the package that captures all its dependencies.

---

The next line in the manual states:

&nbsp;

> ## This enables many powerful features.

&nbsp;

# ⚡Wow!

---

### I demand code! 🙎

## file.nix

```nix
{pkgs}: derivation {
  name = "my-very-cool-app";
  system = "x86_64-linux";
  builder = ./build.sh;
  outputs = [ "out" ];
  buildInputs = [ pkgs.bash ];
}
```

▶️ `nix build`

---
layout: statement
---

# Thanks for coming<br/>to my talk! 🙏

&nbsp;  
... ok I lied. It takes more than that to create a working package.

---

# 😇 I omitted some stuff

* `pkgs` (a.k.a. `nixpkgs`) bootstrapping.
* Nobody uses `derivation` without abstraction.
* We should use the Nix Flake structure for packages.

And what is this weird `derivation` thing?... 🙀

---

# 🎯 What we'll take a look at today

* `nix` (the tool) ✅
* Nix (the expression language)  
* nixpkgs
* NixOS  
* Nix Flakes


---

# Nix Expression Language
 
> The Nix language is designed for conveniently **creating and composing *derivations*** – precise descriptions of how contents of existing files are used to derive new files.  
> &nbsp;
> 
> It is:
> 
> - *domain-specific*
> - *declarative*
> - *pure*
> - *functional*
> - *lazy*
> - *dynamically typed*

---
layout: fact
---

### Bad People on the internet claim that

##  😈<br>Nix is JSON with functions

&nbsp;  
and they are not wholly wrong I'm afraid.

<v-click>

&nbsp;  
But in truth: With the exception of curly braces  
&nbsp; and beeing slightly annoying to use,  
it doesn't have a lot in common.

</v-click>

---
layout: statement
---

### Nix deserves a talk of it's own.

## Here are four slides of the<br>most important language constructs.

---
layout: two-cols
---

## Conditionals

```nix {1,3,5}
a = if
    negate true == false
  then
    "cool bananas 🍌"
  else
    null;
```

## Let Expressions

```nix {1-2,4}
mynumber = let
    a = 1;
    b = 2;
  in a + b;

# mynumber= 3
```

::right::

## Strings

```nix
mySurname = "Hauser";

myName = "Fabian ${mySurname}";

myStory = ''
  Once upon a time,
  there was a person called ${myName}
'';
```

---
layout: two-cols
---

## Sets

Other languages call this  
dictionary or object.

You will see this a lot.

```nix {1-2,4,6}
mySet = {
  keyA = "value";
  "key2" = 13;
};

yourSet.first.second = "Subset";

```

::right::

## Inherit Expression

```nix {1,3-4,6}
a = "A";

values = {
  inherit a;
  b = "B";
};

```

## With Expressions

```nix
values = { a = "A"; };

myLetterA = with values; a;
```

---

## Functions: `pattern: body`

```nix
concatStrings = x: y: x + " " + y;

# Usage:
myName = concatStrings "Fabian" "Hauser";
```
<v-click>
<br>

### **Set-pattern function**
```nix
mkPackageName = {pname, version}: "${pname}-${version};

pkgName = mkPackageName {
            pname = "hello";
            version: "1.0";
          };
```

</v-click>

---

## `builtins.`: Built-in functions

| | |
|---|---|
| `derivation` | Add stuff to the Nix Store |
| `import` | Load, parse and return the Nix expression of a file.
| `map f list` | Apply the function f to each element in the list list. |
| ... | [&rarr; List of built-in functions in Nix Manual](https://nixos.org/manual/nix/stable/language/builtins.html) |


&nbsp;  
💡 Often, abstractions from `pkgs.lib` are used.

---
layout: statement
---

## Remember our `file.nix` from the `nix` part?

Now you should be able to understand some more things.

---

## file.nix

```nix
{pkgs}: derivation {
  name = "my-very-cool-app";
  system = "x86_64-linux";
  builder = ./build.sh;
  outputs = [ "out" ];
  buildInputs = [ pkgs.bash ];
}
```

So again: what happens if we build this thing?


---

<div class="flex justify-center" style="text-align: center; margin: auto; height: 100%;">
  <img src="/imgs/derivation.svg"/>
</div>

---

### Moderator Slide
## Demo with `nix repl`

```nix
pkgs = import <nixpkgs> {}
theApp = import ./file.nix
:t theApp
theApp

theAppDrv = theApp { pkgs = pkgs; }
:t theAppDrv
theAppDrv
# Show derivation and output attributes

# Show string cast
"${theAppDrv}"

# Note: The derivation is not actually buildable due to `build.sh` 🙃
```

---

## So what was that weird string cast?!?

<small>From the [nix manual](https://nixos.org/manual/nix/stable/language/builtins.html#builtins-toString) on `builtins`:</small>

> `toString e`: Convert the expression e to a string. e can be:  <small>[...]</small>
> * A set containing `{ __toString = self: ...; }` or `{ outPath = ...; }`.

<v-click>

👨‍🏫 Of course, a simple reduction:

`"${theAppDrv}"`  
&rarr; `toString theAppDrv`  
&rarr;`theAppDrv.outPath`  
&rarr; `"/nix/store/[...]-my-very-cool-app"`

</v-click>

---
layout: statement
---

# 🧙<br>Welcome<br>to nix magic

---

# 🟥 Don't panic

Having a hard time getting started with nix is normal.

* **Expressions** are sometimes hard to read...
* **Lazily evaluated**:  errors might show up later than expected

* **Eval-Errors are complicated**:  
nix is not `rustc`-helpful I'm afraid 🙁


* **IDE-Support still not great**  
Abstractions can drive you crazy  
_(the new `nixd` LSP is very promising)_

---

# 📚 Ressources

* https://nix.dev/
* https://zero-to-nix.com/
* Nix Manual: https://nixos.org/manual/nix/
* NixOS Wiki: https://nixos.wiki/wiki/Overview_of_the_Nix_Language

---

# 🎯 What we'll take a look at today

* `nix` (the tool) ✅
* Nix (the expression language) ✅
* nixpkgs
* NixOS  
* Nix Flakes

---
layout: fact
---


# 🌊<br>How about a break?


---

# nixpkgs

**The** mono-repository for:

🗂️  pkgs, pkgs, and more pkgs

🔧 some nix libs

❄️ NixOS  

<ul style="margin-top: -1.5rem; margin-left: 1.5rem;">
  <li>modules</li>
  <li>integration tests</li>
  <li>utilities/scripts</li>
</ul>



The CI ("Hydra") pushes binary builds to cache.nixos.org.

---

# 📦 Packages in nixpkgs

Let's take a look at a package I am the maintainer of: `hamster`.

http://github.com/NixOS/nixpkgs <small>(&rarr; [all-packages.nix](https://github.com/NixOS/nixpkgs/blob/master/pkgs/top-level/all-packages.nix) and
[default.nix](https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/misc/hamster/default.nix))</small>

## So how do I use this package?

```bash
nix run nixpkgs#hamster
```
This builds and executes: <br>
<small><code>"${nixpkgs.legacyPackages.x86_64-linux.hamster.out}/bin/hamster"</code></small>

---

# 🌌 Welcome to the Nix Universe

<div class="flex justify-center align-center " style="text-align: center; margin: auto; max-height: 100%">
  <img src="/imgs/nix-universe.svg"/>
</div>

---

# 🔧 Nixpkgs: Specific Builders

Nixpkgs contains specific builders for:

* Languages (e.g. haskell, python, node)
* Frameworks or environments (e.g. gtk, QT, CUDA, teXlive, android)
* Build tools (e.g. cmake, Xcode)
* Container / Packaging (e.g. docker/OCI, snap, disk-image)
* Testing (e.g. `nixosTest`)

---

# 🔧 `pkgs.stdenv.mkDerivation`

The convenience `derivation` wrapper.

* Contains some build essentials™
* Default `build.sh` with custom phases, <small>e.g. `buildPhase`, `installPhase`</small>
* Used by most specific builders <small>&rarr; they wrap or hook into `mkDerivation`</small>

&nbsp;

📜 For documentation: [The Source is your Friend](https://github.com/NixOS/nixpkgs/blob/master/pkgs/stdenv/generic/setup.sh#L1557).

---

# 🎯 What we'll take a look at today

* `nix` (the tool) ✅
* Nix (the expression language) ✅
* nixpkgs ✅
* NixOS  
* Nix Flakes

---

<div class="flex justify-center align-center " style="text-align: center; margin: auto;">
  <img src="/imgs/nixos.png" style="max-width: 80%; margin-bottom: 2rem"/>
</div>


> NixOS is a Linux distribution  
> based on the purely functional package management system Nix,  
> that is **composed using modules and packages defined in the Nixpkgs** project. 

-- [Nix Manual: Preface](https://nixos.org/manual/nixos/)

---

# 🚀 NixOS: Features

- Build whole system from a Nix file
- Configuration with NixOS Module abstractions
- Manage system with `nixos-*` scripts

Properties:

- The system is *immutable*
- Setup changes result in a "whole new system"

---

<style>

ol {
  list-style: decimal !important;
}

</style>

# 🏗️ NixOS Setup

In a nutshell:

1. 💾 Boot live Image
1. Partitioning (`/` root-FS, `/boot/efi` boot partition, the usual)
1. `nixos-generate-config`: <small>Generate a basic `configuration.nix`</small>
1. `nixos-install`: <small>Install the system to the Disk</small>
1. Reboot and enjoy

---
layout: section
---

## Let's take a look at a minimal NixOS desktop setup with gnome and networking.

---

```nix {1-2,17|3-5|6-8|8-11|12-16|all}
{ config, pkgs, ... }: {
  system.stateVersion = "23.11";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";

  services.xserver.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  users.users.alice = {
    isNormalUser = true;
    password = "bob"; # TODO: Insecure
    extraGroups = [ "wheel" ];
  };
}
```

---

# 🧨 Demo time!

```bash {6-8}
# Preparations:
cd demo
rm -f nixos.qcow2
export NIXOS_CONFIG=`pwd`/configuration.nix

nixos-rebuild build-vm --no-flake
./result/bin/run-nixos-vm
```

---

# 📝 Applying config changes

Let's add `hamster` to the system's packages:

📃 /etc/nixos/configuration.nix
```nix {1. 3-4}
{ config, pkgs, ... }: {
  ...
  environment.systemPackages = [ pkgs.hamster ];
}
```

▶️ Apply

```bash
nixos-rebuild switch
```

---

# NixOS Modules

* Configuration options come from NixOS Modules
* Option search: https://search.nixos.org/
* Additional docs: https://nixos.org/manual/nixos/

Pretty cool abstractions, e.g.:
```nix
services.nextcloud = {
  enable = true;
  host = "nextcloud.coredump.ch";
};
```

Due to time constraint, no more Modules tonight, sorry 😞

---

# 🎯 What we'll take a look at today

* `nix` (the tool) ✅
* Nix (the expression language) ✅
* nixpkgs ✅
* NixOS  ✅
* Nix Flakes

---

# ❄️ Flakes

What `Cargo.toml` is to `cargo`, just on steroids 🔥


## 📥 inputs

Other nix flakes (or git repos) that we want to use in our flake  
<small>(plus `self`: the folder our `flake.nix` lives in)</small>

## 📤 outputs

Standardized nix-tree with derivations

---

# ❄️ Output tree

```nix {1-5,11}
{
  packages.<system>.<name> = derivation ...;
  devShells.<system>.<name> = derivation ...;
  nixosConfigurations.<host> = ...;
  nixosModules.<name> = ...;
  apps = ...;
  checks = ...;
  formatter = ...;
  templates = ...;
  ...
}
```


<small>`<system>` is the arch (e.g. `x86_64-linux`)</small>  
<small>`<name>` is a custom name or `default`</small>

---

# ❄️ Example: NixOS Installation

▶️ `nixos-rebuild switch`
```nix{1-3,10|1,4,9,10|4-9|all}
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";

  outputs = { self, nixpkgs }: {
    nixosConfigurations.fabian-desktop = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./configuration.nix ];
    };
  };
}
```

&rarr; `/etc/nixos/flake.nix`

---

# ❄️ Example: Dev Shell

▶️ `nix develop`

```nix{8-11|1-7,12-15}
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs";

  outputs = { self, nixpkgs }: let
   system = "x86_64-linux";
   pkgs = import nixpkgs { inherit system; };
  in {
    devShells.${system}.default = pkgs.mkShell {
      name = "my-node-application";
      buildInputs = [ pkgs.nodejs_20 ];
    };
  };
}
```


---

# ❄️ Example: Simple Package

▶️ `nix build`

```nix{6-11|all}
{ 
  outputs = { self, nixpkgs }: let
   system = "x86_64-linux";
   pkgs = import nixpkgs { inherit system; };
  in {
    packages.${system}.default = pkgs.mkDerivation {
      name = "hello";
      src = self;
      buildPhase = "gcc -o hello ./hello.c";
      installPhase = "mkdir -p $out/bin; install -t $out/bin hello";
    };
  };
}
```
---

# `flake.lock`

What `Cargo.lock` is to `cargo`, just on steroids 🔥

- pin inputs to an exact version (=git hash)
- Automatically initialised on first flake run
- Update with `nix flake update`

Tracking this file makes your builds (mostly) reproducible.

---

# 📚 On the Topic of Documentation

Nix Flakes are still considered unstable. However...  
Flakes are also the de-facto-standard way to use nix nowadays.

The documentation is still a work in progress I'm afraid.

A good starting point:

💡 https://nixos.wiki/wiki/Flakes

---
layout: section
---

You made it 💪

# Welcome to the Universe of nix!



