![Header Image](http://www.cixtor.com/files/large/mamutools-logo.gif)

# MamuTools

[MamuTools](http://www.cixtor.com/mamutools) is a collection of custom scripts intended to be used through a command line to offer more utilities on things like fetch remote content, format piped output, compress and package repositories, etc. They were tested on a **Linux Debian** installation but with a few modifications you can use them in your **UNIX** based operating system.

### What's exactly?

This is a collection of individual scripts written independently to solve a specific problem or to improve a specific action in my development environment. This **IS NOT A TOOLBET**, I mean there isn't a main executable file from where you can call the other scripts, basically because they are not correlated at all. However, with some time someone can write a `main wrapper` from where execute all the other tools, the code is open-source so do it if you want.

### Requirements

As the scripts are not correlated among them, you probably will want to check them individually to know what kind of prior software will be needed to be installed to use them. But basically this is a general list of dependencies required to run the majority of tools.

* PHP >= 5.2 (Including modules: GD and CURL)
* Ruby >= 1.8 (Check this if you are newbie: [RVM - Ruby Version Manager](https://rvm.io/))
* RubyGems (Install the latest stable version)
* Bash >= 3.0 (Change the [Shebang](http://en.wikipedia.org/wiki/Shebang_(Unix)) if you need to use an alternative to this)
* XTerm (or whatever you have in your UNIX box)

### Installation

**WARNING!** This procedure refers to a Linux Debian based system, as I don't know very well other environments, I can't ensure that this will work in your machine if you use other Operating System. Most of the commands will work in a UNIX based system, maybe you'll have to change a few commands.

You'll probably need **super administrator** privileges to do these things, if that's the case become `root` using this command: `su root`

```
$ cd /opt/
$ git clone https://github.com/cixtor/mamutools.git
$ cd /usr/local/bin/
$ for FILE in $(ls -1 /opt/mamutools/); do ln -s /opt/mamutools/$FILE $(echo $FILE | cut -d '.' -f 1); done
```

### Motivation

I've spent many hours writing these scripts, also testing and fixing trivial bugs. They are also helping me to improve my workflow in my job as **Security Analyst** saving time when I need to do some specific task. I've decided to create this repository to ensure my work will prevail in time (if my hard drive crashes or something) and maybe someone can help me to improve them, which means that my workflow will be improved too.

### License

[Cixtor MamuTools](http://www.cixtor.com/) uses the [BSD 3-Clause "New" or "Revised" license](http://opensource.org/licenses/BSD-3-Clause).