# Pro

`pro` is a command to wrangle your git repositories.
It includes features like instantly cd'ing to your git repos and getting a
status overview, and running an arbitrary command in every git repo.

Note that pro only currently works on Unix systems. If you experience speed issues
see the section on setting a pro base.

## CD'ing to a project's repository

Cd'ing to your projects is harder than it should be.
There are [attempts](https://github.com/rupa/z) to solve this
problem using frequency and recency.
`pro` solves the problem by fuzzy searching only git repositories.

The supplementary `pd` command allows you to instantly CD to any git repo by
fuzzy matching its name. It is implemented as a shell function.
You can install `pd` (name configurable) by running `pro install`.
Once you have it you can do some pretty intense cd'ing:

![pd demo](http://thume.ca/assets/postassets/pro/pd_screen.png)

## State of the Repos Address

Oftentimes I find myself wondering which git repositories of mine still have
uncommitted changes or unpushed commits. I could find them all and run git
status but it would be nice to get a quick overview. `pro status` does this.

![pro status](http://thume.ca/assets/postassets/pro/pro_status.png)

You can also run `pro status <repo>` to show the output of `git status` for a
certain repo.

## Run all the commands!

Wouldn't it be cool if you could run a command on all your repos and see a
summary of the output? Now you can!

You can do this with `pro run <command>`. If you don't pass a command it will
prompt you for one.

For example, searching all your repos for ruby files:

![pro run](http://thume.ca/assets/postassets/pro/pro_run.png)

Notice that it double checks before running so you don't accidentally run
`rm -rf *` on all your projects.

## The Pro Base

`pro` can use a base directory to speed up its search for git repos. By default it
uses your home folder.

To set the base directory either create a file at `~/.proBase` containing the
base path or set the environment variable PRO_BASE.

## Installation

`pro` is bundled as a Ruby gem. To install run:

    $ gem install pro

You may also want to set your Pro Base. See the above section.

## Usage

    pro is a command to help you manage your git repositories.

    Base Directory ==========
    pro works from a base directory for efficiency.
    This is the folder that contains all your other git repositories;
    they don't have to be at the base level, just somewhere down the tree.

    To set the base directory set the PRO_BASE environment variable or make
    a ~/.proBase file containing the path.

    Commands ===============
    pro search <query> - prints path of git repo that matches query.
    pro status - prints a list of all repos with uncommitted or unpushed changes.
    pro status <name> - prints the output of 'git status' on the repo.
    pro run - prompts for a command to run in all git repos.
    pro run <command> - runs the given command in all git repos.
    pro install - Install the pro cd command. cd to a directory by fuzzy git repo matching.
    pro help - display help

    CD Command ============
    You can use the 'pro install' command to install a wrapper shell function that allows
    you to cd to git repositories in your Pro Base wherever you are based on fuzzy matching.

    Example:

      ~/randomFolder/ $ pd pro
      pro/ $ pwd
      /Users/tristan/Box/Dev/Projects/pro


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
