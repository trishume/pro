# Pro

`pro` is a little utility to wrangle your git repositories.
It includes features like instantly cd'ing to your git repos and getting a
status overview. You can also run commands in every git repository.

## CD'ing to a project's repository

Cd'ing to your projects is harder than it should be.
There are [many tools](https://github.com/rupa/z) that try and solve this
problem using frequency and recency.
Pro solves the problem by fuzzy searching only git repositories.

The `pd` command allows you to instantly CD to any git repo by fuzzy matching
its name.
You can install the `pd` tool (name configurable) by running `pro install`.
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

Notice that it double checks before running so you don't accidentally run `rm -rf *` on all
your projects.

## Installation

Pro is bundled as a Ruby gem. To install run:

    $ gem install pro

## Usage

    pro is a command to help you manage your git repositories.

    Base Directory ==========
    Pro works from a base directory for efficiency.
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
    You can use the 'pro install' command to install a wrapper function that allows
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
